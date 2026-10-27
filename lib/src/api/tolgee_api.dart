import 'dart:convert';

import 'package:http/http.dart';
import 'package:tolgee/src/api/tolgee_config.dart';
import 'package:tolgee/src/api/tolgee_project_language.dart';

class TolgeeLoadException implements Exception {
  final String message;

  const TolgeeLoadException(this.message);

  @override
  String toString() => 'TolgeeLoadException: $message';
}

Future<dynamic> _getJson(
  Client client,
  Uri uri, [
  Map<String, String>? headers,
]) async {
  final response = await client.get(uri, headers: headers);
  if (response.statusCode != 200) {
    throw TolgeeLoadException('HTTP ${response.statusCode} from ${uri.path}');
  }
  return jsonDecode(utf8.decode(response.bodyBytes));
}

Future<List<TolgeeProjectLanguage>> fetchLanguages(
  Client client,
  TolgeeConfig config,
) async {
  final json = await _getJson(
    client,
    Uri.parse('${config.apiUrl}/v2/projects/languages?size=1000'),
    {'X-Api-Key': config.apiKey},
  );
  final languages = json['_embedded']?['languages'] as List? ?? [];
  return [
    for (final language in languages)
      TolgeeProjectLanguage(
        name: language['name'] as String,
        tag: language['tag'] as String,
        originalName: language['originalName'] as String?,
        flagEmoji: language['flagEmoji'] as String?,
        base: language['base'] as bool,
      ),
  ];
}

/// Translations of [tags] in one request, as tag → key → text.
Future<Map<String, Map<String, String>>> fetchTranslations(
  Client client,
  TolgeeConfig config,
  Set<String> tags,
) async {
  final json = await _getJson(
    client,
    Uri.parse(
      '${config.apiUrl}/v2/projects/translations/${tags.join(',')}'
      '?structureDelimiter=',
    ),
    {'X-Api-Key': config.apiKey},
  ) as Map<String, dynamic>;
  return json.map(
    (tag, texts) =>
        MapEntry(tag, flattenTranslations(texts as Map<String, dynamic>)),
  );
}

Future<Map<String, String>> fetchCdnTranslations(
  Client client,
  String cdnUrl,
  String tag,
) async {
  final json = await _getJson(client, Uri.parse('$cdnUrl/$tag.json'));
  return flattenTranslations(json as Map<String, dynamic>);
}

/// Joins nested keys with `.` and drops untranslated (null) values.
Map<String, String> flattenTranslations(
  Map<String, dynamic> json, [
  String prefix = '',
]) {
  final result = <String, String>{};
  json.forEach((key, value) {
    if (value is Map<String, dynamic>) {
      result.addAll(flattenTranslations(value, '$prefix$key.'));
    } else if (value is String) {
      result['$prefix$key'] = value;
    }
  });
  return result;
}
