import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:tolgee/src/api/tolgee_config.dart';
import 'package:tolgee/src/logger/logger.dart';
import 'package:tolgee/src/translations/tolgee_static_translations.dart';
import 'package:tolgee/src/translations/tolgee_translations.dart';

import '../api/models/tolgee_key_model.dart';
import '../api/requests/update_translations_request.dart';
import '../api/tolgee_api.dart';
import '../api/tolgee_project_language.dart';

class TolgeeRemoteTranslations extends ChangeNotifier
    implements TolgeeTranslations {
  TolgeeConfig? _config;

  Locale? _currentLanguage;

  bool _isTranslationEnabled = true;
  bool get isTranslationEnabled => _isTranslationEnabled;

  @override
  Map<String, TolgeeProjectLanguage> get allProjectLanguages =>
      _projectLanguages;

  @override
  Locale? get currentLanguage => _currentLanguage;

  @override
  void setCurrentLanguage(Locale locale) {
    _currentLanguage = locale;
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
  String translate(String key) {
    final currentLanguage = _currentLanguage;
    if (currentLanguage == null) {
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

  static final instance = TolgeeRemoteTranslations._();
  TolgeeRemoteTranslations._();

  static Future<void> init({
    required String apiKey,
    required String apiUrl,
  }) async {
    final config = TolgeeConfig(
      apiKey: apiKey,
      apiUrl: apiUrl,
    );
    WidgetsFlutterBinding.ensureInitialized();
    await TolgeeStaticTranslations.init();

    instance._config = config;

    final allProjectLanguages = await TolgeeApi.getAllProjectLanguages(
      config: config,
    );

    TolgeeLogger.debug('allProjectLanguages: $allProjectLanguages');

    final translations = await TolgeeApi.getTranslations(
      config: config,
    );

    TolgeeLogger.debug('jsonBody: $translations');

    TolgeeRemoteTranslations.instance._projectLanguages =
        Map.fromEntries(allProjectLanguages.map((e) => MapEntry(e.tag, e)));
    TolgeeRemoteTranslations.instance._translations = translations.keys;
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
