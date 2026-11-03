import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:tolgee/src/api/tolgee_api.dart';
import 'package:tolgee/src/api/tolgee_config.dart';
import 'package:tolgee/src/api/tolgee_project_language.dart';
import 'package:tolgee/src/logger/logger.dart';
import 'package:tolgee/src/translations/language_tags.dart';

/// Translations as language tag → key → text.
typedef Translations = Map<String, Map<String, String>>;
typedef BundledFiles = Future<Translations> Function();

/// The JSON files in the app's `lib/tolgee/` assets, by file name.
Future<Translations> readBundledFiles() async {
  WidgetsFlutterBinding.ensureInitialized();
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  final paths = manifest.listAssets().where(
      (path) => path.startsWith('lib/tolgee/') && path.endsWith('.json'));
  return {
    for (final path in paths)
      path.split('/').last.replaceFirst(RegExp(r'\.json$'), ''):
          flattenTranslations(jsonDecode(await rootBundle.loadString(path))),
  };
}

/// Loads languages and texts from the Tolgee API in dev builds, otherwise from
/// the CDN or the bundled files.
class TolgeeLoader {
  final TolgeeConfig? dev;
  final String? cdnUrl;
  final bool fallbackOnFail;
  final List<String>? availableLanguages;
  final String? baseLanguage;
  final BundledFiles files;
  final Client _client;

  TolgeeLoader({
    this.dev,
    this.cdnUrl,
    this.fallbackOnFail = false,
    this.availableLanguages,
    this.baseLanguage,
    Client? client,
    this.files = readBundledFiles,
  }) : _client = client ?? Client();

  bool _usesApi = false;
  Future<Translations>? _bundled;

  /// Whether languages and texts come from the Tolgee API.
  bool get usesApi => _usesApi;

  Future<Translations> _bundledFiles() => _bundled ??= files();

  void _stopUsingApi(Object error) {
    TolgeeLogger.warning(
      'Failed to load from the Tolgee API, using the CDN or bundled files: $error',
    );
    _usesApi = false;
  }

  /// The project languages, base language first.
  Future<List<TolgeeProjectLanguage>> loadLanguages() async {
    final dev = this.dev;
    if (dev != null) {
      try {
        final languages = await fetchLanguages(_client, dev);
        if (languages.isNotEmpty) {
          _usesApi = true;
          return [
            ...languages.where((l) => l.base),
            ...languages.where((l) => !l.base),
          ];
        }
        _stopUsingApi('the project has no languages');
      } catch (e) {
        _stopUsingApi(e);
      }
    }

    final tags =
        availableLanguages ?? ((await _bundledFiles()).keys.toList()..sort());
    if (tags.isEmpty) {
      throw StateError(
        'Tolgee has no languages. Pass availableLanguages to Tolgee.init '
        'or bundle translation files in lib/tolgee/.',
      );
    }
    final base = _baseOf(tags);
    return [
      for (final tag in [base, ...tags.where((t) => t != base)])
        TolgeeProjectLanguage(name: tag, tag: tag, base: tag == base),
    ];
  }

  String _baseOf(List<String> tags) {
    final requested = baseLanguage;
    if (requested != null) {
      final match = matchLanguage(tags, requested);
      if (match != null) return match;
      TolgeeLogger.warning('Base language $requested is not in $tags');
    }
    return tags.contains('en') ? 'en' : tags.first;
  }

  /// The texts of [tags]. A language that failed to load is left out, so the
  /// caller keeps what it had and can try again later.
  Future<Translations> load(Set<String> tags) async {
    final dev = this.dev;
    if (dev != null && _usesApi) {
      try {
        final texts = await fetchTranslations(_client, dev, tags);
        return {for (final tag in tags) tag: texts[tag] ?? {}};
      } catch (e) {
        TolgeeLogger.warning(
            'Failed to load translations from the Tolgee API: $e');
        return {};
      }
    }

    final cdnUrl = this.cdnUrl;
    if (cdnUrl != null) {
      final texts = await Future.wait(tags.map((tag) => _fromCdn(cdnUrl, tag)));
      return {
        for (final (index, tag) in tags.indexed)
          if (texts[index] case final loaded?) tag: loaded,
      };
    }

    final bundled = await _bundledFiles();
    return {for (final tag in tags) tag: bundled[tag] ?? {}};
  }

  Future<Map<String, String>?> _fromCdn(String cdnUrl, String tag) async {
    try {
      return await fetchCdnTranslations(_client, cdnUrl, tag);
    } catch (e) {
      if (!fallbackOnFail) {
        TolgeeLogger.error('Failed to load $tag from the CDN: $e');
        return null;
      }
      TolgeeLogger.warning(
        'Failed to load $tag from the CDN, using bundled files: $e',
      );
      return (await _bundledFiles())[tag];
    }
  }
}
