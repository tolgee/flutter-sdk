import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:tolgee/src/api/tolgee_config.dart';
import 'package:tolgee/src/logger/logger.dart';

import 'api/models/tolgee_key_model.dart';
import 'api/requests/update_translations_request.dart';
import 'api/tolgee_api.dart';
import 'api/tolgee_project_language.dart';

class TolgeeChangeNotifier extends ChangeNotifier {
  TolgeeConfig? _config;

  Locale? _currentLanguage;

  bool _isTranslationEnabled = true;
  bool get isTranslationEnabled => _isTranslationEnabled;

  Map<String, TolgeeProjectLanguage> get allProjectLanguages =>
      _projectLanguages;

  Locale get currentLanguage => _currentLanguage ?? Locale('en');

  set currentLanguage(Locale locale) {
    _currentLanguage = locale;
    notifyListeners();
  }

  bool mutateTranslationEnabled(bool value) {
    _isTranslationEnabled = value;
    notifyListeners();
    return _isTranslationEnabled;
  }

  void setTranslationEnabled(bool value) {
    _isTranslationEnabled = value;
    notifyListeners();
  }

  void toggleTranslationEnabled() {
    _isTranslationEnabled = !_isTranslationEnabled;
    notifyListeners();
  }

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

  String translate(String key) {
    if (!_isTranslationEnabled) {
      return key;
    }
    final value = _translations.firstWhereOrNull(
      (element) => element.keyName == key,
    );
    if (value == null) {
      return key;
    }

    final translation = value.translations[currentLanguage.toLanguageTag()];
    if (translation == null) {
      return key;
    }

    return translation.text;
  }

  static final instance = TolgeeChangeNotifier._();
  TolgeeChangeNotifier._();

  static Future<void> init({
    required String apiKey,
    required String apiUrl,
  }) async {
    final config = TolgeeConfig(
      apiKey: apiKey,
      apiUrl: apiUrl,
    );

    instance._config = config;

    final allProjectLanguages = await TolgeeApi.getAllProjectLanguages(
      config: config,
    );

    TolgeeLogger.debug('allProjectLanguages: $allProjectLanguages');

    final translations = await TolgeeApi.getTranslations(
      config: config,
    );

    TolgeeLogger.debug('jsonBody: $translations');

    TolgeeChangeNotifier.instance._projectLanguages =
        Map.fromEntries(allProjectLanguages.map((e) => MapEntry(e.tag, e)));
    TolgeeChangeNotifier.instance._translations = translations.keys;
    TolgeeChangeNotifier.instance.notifyListeners();
  }

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

  static Future<void> updateTranslations({
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

    TolgeeChangeNotifier.instance
        .updateKeyModel(updatedKeyModel: updatedKeyModel);
  }
}
