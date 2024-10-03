import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:tolgee/src/api/responses/tolgee_translations_response.dart';
import 'package:tolgee/src/api/tolgee_config.dart';
import 'package:tolgee/src/logger/logger.dart';
import 'package:tolgee/src/translations/tolgee_translations.dart';

import '../api/models/tolgee_key_model.dart';
import '../api/requests/update_translations_request.dart';
import '../api/tolgee_api.dart';
import '../api/tolgee_project_language.dart';

String normalizeLanguageCode(String languageCode) {
  // Split the language code by underscore
  List<String> parts = languageCode.split(RegExp(r'[_-]'));

  if (parts.length != 2) {
    // If the format is incorrect, return the original code or handle the error
    return languageCode.toLowerCase();
  }

  // Convert the first part (language) to lowercase
  String language = parts[0].toLowerCase();

  // Join the parts with a hyphen
  return language;
}

class TolgeeRemoteTranslations extends ChangeNotifier
    implements TolgeeTranslations {
  TolgeeConfig? _config;

  Locale? _currentLanguage;

  bool _isTranslationEnabled = true;

  @override
  bool get isTranslationEnabled => _isTranslationEnabled;

  @override
  Map<String, TolgeeProjectLanguage> get allProjectLanguages =>
      _projectLanguages;

  @override
  Locale? get currentLanguage => _currentLanguage;

  @override
  Future<void> setCurrentLanguage(Locale locale) async {
    final config = _config;

    if (config == null) {
      throw Exception('Tolgee is not initialized');
    }

    _currentLanguage = locale;
    TolgeeTranslationsResponse? translations = await TolgeeApi.getTranslations(
      config: config,
      currentLanguage: locale.toString(),
    );
    TolgeeLogger.debug('jsonBody: $translations');
    _translations = translations.keys;
    notifyListeners();
  }

  @override
  void toggleTranslationEnabled() {
    _isTranslationEnabled = !_isTranslationEnabled;
    notifyListeners();
  }

  @override
  void updateKeyModel({
    required TolgeeKeyModel updatedKeyModel,
  }) async {
    _translations = _translations.map((keyModel) {
      if (keyModel.keyName == updatedKeyModel.keyName) {
        return updatedKeyModel;
      }
      return keyModel;
    }).toList();

    notifyListeners();
  }

  List<TolgeeKeyModel> _translations = [];
  Map<String, TolgeeProjectLanguage> _projectLanguages = {};

  @override
  String? translate(String key) {
    final currentLanguage = _currentLanguage;
    if (currentLanguage == null) {
      return key;
    }

    final value = _translations.firstWhereOrNull(
      (element) => element.keyName == key,
    );

    if (value == null) {
      return null;
    }

    final translation = value
        .translations[normalizeLanguageCode(currentLanguage.toLanguageTag())];
    if (translation == null) {
      return null;
    }

    return translation.text;
  }

  static final instance = TolgeeRemoteTranslations._();
  TolgeeRemoteTranslations._();

  static Future<void> init({
    required String apiKey,
    required String apiUrl,
    String? currentLanguage,
    String? cdnUrl,
    bool useCDN = false,
  }) async {
    final config = TolgeeConfig(
      apiKey: apiKey,
      apiUrl: apiUrl,
      cdnUrl: cdnUrl,
      useCDN: useCDN,
    );

    instance._config = config;

    final allProjectLanguages = await TolgeeApi.getAllProjectLanguages(
      config: config,
    );
    TolgeeLogger.debug('allProjectLanguages: $allProjectLanguages');
    TolgeeRemoteTranslations.instance._projectLanguages =
        Map.fromEntries(allProjectLanguages.map((e) => MapEntry(e.tag, e)));

    var selectedLanguage = normalizeLanguageCode(currentLanguage ?? Platform.localeName);
    var found = allProjectLanguages.firstWhereOrNull(
      (element) => element.tag == selectedLanguage,
    );
    if (found == null && allProjectLanguages.isNotEmpty) {
      selectedLanguage = allProjectLanguages.first.tag;
    }
    TolgeeLogger.debug('selectedLanguage: $selectedLanguage');

    TolgeeRemoteTranslations.instance.setCurrentLanguage(Locale(selectedLanguage));
    TolgeeRemoteTranslations.instance.notifyListeners();
  }

  @override
  Set<TolgeeKeyModel> translationForKeys(Set<String> keys) {
    final emptyTranslations = keys.map((key) {
      return TolgeeKeyModel(
        keyId: 0,
        keyName: key,
        translations: {},
      );
    }).toSet();

    return emptyTranslations
        .map((translationKey) =>
            _translations.firstWhereOrNull(
              (element) => element.keyName == translationKey.keyName,
            ) ??
            translationKey)
        .toSet();
  }

  @override
  Future<void> updateTranslations({
    required String key,
    required Map<String, String> translations,
  }) async {
    final updateTranslationRequest = UpdateTranslationsRequest(
      key: key,
      translations: translations,
    );

    final config = instance._config;

    if (config == null) {
      TolgeeLogger.critical('Tolgee is not initialized');
      return;
    }

    final updatedKeyModel = await TolgeeApi.updateTranslations(
      config: config,
      request: updateTranslationRequest,
    );

    TolgeeRemoteTranslations.instance
        .updateKeyModel(updatedKeyModel: updatedKeyModel);
  }
}
