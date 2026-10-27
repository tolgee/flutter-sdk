import 'dart:convert';

import 'package:http/http.dart';
import 'package:tolgee/src/api/models/tolgee_translation_model.dart';
import 'package:tolgee/src/api/requests/update_translations_request.dart';
import 'package:tolgee/src/api/responses/tolgee_all_project_languages_response.dart';
import 'package:tolgee/src/api/responses/tolgee_translations_response.dart';
import 'package:tolgee/src/api/responses/update_translations_response.dart';
import 'package:tolgee/src/api/tolgee_config.dart';
import 'package:tolgee/src/api/tolgee_project_language.dart';
import 'package:tolgee/src/logger/logger.dart';

import 'models/tolgee_key_model.dart';

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

/// Represents Tolgee API
class TolgeeApi {
  const TolgeeApi._();

  /// Gets all languages in Tolgee project
  static Future<List<TolgeeProjectLanguage>> getAllProjectLanguages({
    required TolgeeConfig config,
  }) async {
    final response = await get(
      Uri.parse('${config.apiUrl}/projects/languages?size=1000'),
      headers: {
        'X-Api-Key': config.apiKey,
      },
    );

    if (response.statusCode != 200) {
      TolgeeLogger.error(
        'Failed to fetch project languages: HTTP ${response.statusCode}',
      );
      return [];
    }

    final body = TolgeeAllProjectLanguagesResponse.fromJsonString(
      utf8.decode(response.bodyBytes),
    );
    return body.languages;
  }

  /// Gets all translations in Tolgee project
  static Future<TolgeeTranslationsResponse> getTranslations({
    required TolgeeConfig config,
    required String currentLanguage,
  }) async {
    // Check if should use CDN
    if (config.useCDN) {
      return getTranslationsFromCDN(
        config: config,
        currentLanguage: currentLanguage,
      );
    }

    List<TolgeeKeyModel> allTranslations = [];
    int currentPage = 0;
    int totalPages = 1; // Initialize to 1 to enter the loop
    int retries = 3;

    while (currentPage < totalPages) {
      final response = await get(
        Uri.parse(
          '${config.apiUrl}/projects/translations?page=$currentPage&size=20&sort=keyId,asc&languages=$currentLanguage',
        ),
        headers: {
          'X-Api-Key': config.apiKey,
        },
      );

      if (response.statusCode == 200) {
        final utf8DecodedBody = utf8.decode(response.bodyBytes);

        final body = TolgeeTranslationsResponse.fromJsonString(utf8DecodedBody);
        allTranslations.addAll(body.keys);
        totalPages = body.totalPages;
        currentPage++;
      } else {
        retries--;
        if (retries <= 0) {
          TolgeeLogger.warning('Failed to fetch translations');
          return const TolgeeTranslationsResponse([], 0, 0);
        }
      }
    }

    return TolgeeTranslationsResponse(allTranslations, totalPages, currentPage);
  }

  static Future<TolgeeTranslationsResponse> getTranslationsFromCDN({
    required TolgeeConfig config,
    required String currentLanguage,
  }) async {
    final response = await get(
      Uri.parse(
        '${config.cdnUrl}/$currentLanguage.json',
      ),
    );

    List<TolgeeKeyModel> tolgeeKeyModels = [];

    if (response.statusCode == 200) {
      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      final jsonResponse = jsonDecode(utf8DecodedBody) as Map<String, dynamic>;

      // Transform JSON response into a list of TolgeeKeyModel instances
      tolgeeKeyModels = jsonResponse.entries.map((entry) {
        return TolgeeKeyModel(
          keyId: entry.key.hashCode, // Using hashCode as a unique identifier
          keyName: entry.key,
          translations: {
            currentLanguage: TolgeeTranslationModel(text: entry.value),
          },
        );
      }).toList();
    }

    return TolgeeTranslationsResponse(tolgeeKeyModels, 1, 0);
  }

  /// Updates translations in Tolgee project
  static Future<TolgeeKeyModel> updateTranslations({
    required TolgeeConfig config,
    required UpdateTranslationsRequest request,
  }) async {
    final body = jsonEncode(request.toJson());

    final response = await post(
      Uri.parse('${config.apiUrl}/projects/translations'),
      headers: {
        'X-Api-Key': config.apiKey,
        'Content-Type': 'application/json',
      },
      body: body,
    );
    final updateTranslationsResponse =
        UpdateTranslationsResponse.fromJsonString(
      utf8.decode(response.bodyBytes),
    );
    return updateTranslationsResponse.model;
  }
}
