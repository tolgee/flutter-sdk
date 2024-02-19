import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:tolgee/src/api/models/tolgee_key_model.dart';
import 'package:tolgee/src/api/models/tolgee_translation_model.dart';
import 'package:tolgee/src/api/tolgee_project_language.dart';
import 'package:tolgee/src/translations/tolgee_translations.dart';

class TolgeeStaticTranslations implements TolgeeTranslations {
  Locale? _currentLanguage;
  Map<String, TolgeeProjectLanguage> _projectLanguages = {};
  Set<TolgeeKeyModel> _translations = {};

  static Future<void> init() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

    final tolgeeFiles = manifest
        .listAssets()
        .where((element) => element.startsWith('lib/tolgee'))
        .where((element) => element.endsWith('json'))
        .toList();

    final futures = tolgeeFiles.map((e) async {
      final content = await rootBundle.loadString(e);
      return MapEntry(
        e.split('/').last.split('.').first,
        Map<String, dynamic>.from(json.decode(content)),
      );
    });

    final filesContent = Map<String, Map<String, dynamic>>.fromEntries(
      await Future.wait(futures),
    );

    Map<String, TolgeeProjectLanguage> projectLanguages = {};

    for (final (index, locale) in filesContent.keys.indexed) {
      projectLanguages[locale] = TolgeeProjectLanguage(
        name: locale,
        tag: locale,
        base: index == 0,
      );
    }

    Set<TolgeeKeyModel> translations0 = {};

    Map<String, Map<String, dynamic>> tempTranslations = {};
    for (final fileEntry in filesContent.entries) {
      for (final contentEntry in fileEntry.value.entries) {
        if (tempTranslations[contentEntry.key] == null) {
          tempTranslations[contentEntry.key] = {};
        }

        tempTranslations[contentEntry.key]?[fileEntry.key] = contentEntry.value;
      }
    }

    for (final entry in tempTranslations.entries) {
      Map<String, TolgeeTranslationModel> translations = {};
      for (final translation in entry.value.entries) {
        translations[translation.key] = TolgeeTranslationModel(
          text: translation.value,
        );
      }

      translations0.add(
        TolgeeKeyModel(
          keyName: entry.key,
          translations: translations,
          keyId: entry.key.hashCode,
        ),
      );
    }

    instance._currentLanguage = Locale(
      projectLanguages.values.firstWhere((element) => element.base).tag,
    );
    instance._projectLanguages = projectLanguages;
    instance._translations = translations0;
  }

  TolgeeStaticTranslations._();

  static final instance = TolgeeStaticTranslations._();

  @override
  Map<String, TolgeeProjectLanguage> get allProjectLanguages =>
      _projectLanguages;

  @override
  Locale? get currentLanguage => _currentLanguage;

  @override
  void setCurrentLanguage(Locale locale) {
    _currentLanguage = locale;
  }

  @override
  void toggleTranslationEnabled() {
    // do nothing
  }

  @override
  String translate(String key) {
    final languageCode = _currentLanguage?.languageCode;
    if (languageCode == null) {
      return key;
    }

    return _translations
            .firstWhere((element) => element.keyName == key)
            .translations[languageCode]
            ?.text ??
        key;
  }

  @override
  Set<TolgeeKeyModel> translationForKeys(Set<String> keys) {
    return _translations
        .where((element) => keys.contains(element.keyName))
        .toSet();
  }

  @override
  void updateKeyModel({
    required TolgeeKeyModel updatedKeyModel,
  }) {
    // do nothing
  }

  @override
  Future<void> updateTranslations({
    required String key,
    required Map<String, String> translations,
  }) async {
    // do nothing
  }
}
