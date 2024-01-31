import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:tolgee/tolgee/api/tolgee_api.dart';
import 'package:tolgee/tolgee/api/tolgee_config.dart';
import 'package:tolgee/tolgee/api/tolgee_key_model.dart';
import 'package:tolgee/tolgee/api/tolgee_project_language.dart';

class TolgeeSdk extends ChangeNotifier {
  TolgeeConfig? _config;

  String get currentLanguage => 'en';

  bool _isTranslationEnabled = true;
  bool get isTranslationEnabled => _isTranslationEnabled;

  Map<String, TolgeeProjectLanguage> get allProjectLanguages =>
      _projectLanguages;

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

    final translation = value.translations[currentLanguage];
    if (translation == null) {
      return key;
    }

    return translation.text;
  }

  static final instance = TolgeeSdk._();
  TolgeeSdk._();

  static Future<void> init({
    required String apiKey,
    required String apiUrl,
  }) async {
    instance._config = TolgeeConfig(
      apiKey: apiKey,
      apiUrl: apiUrl,
    );

    final allProjectLanguages = await TolgeeApi.getAllProjectLanguages(
      config: instance._config!,
    );

    print('allProjectLanguages: $allProjectLanguages');

    final translations = await TolgeeApi.getTranslations(
      config: instance._config!,
    );

    print('jsonBody: $translations');
    TolgeeSdk.instance._projectLanguages =
        Map.fromEntries(allProjectLanguages.map((e) => MapEntry(e.tag, e)));
    TolgeeSdk.instance._translations = translations.keys;
    TolgeeSdk.instance.notifyListeners();
  }

  Set<TolgeeKeyModel> translationForKeys(Set<String> keys) {
    final emptyTranslations = keys.map((key) {
      return TolgeeKeyModel(
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

  static Future<void> updateTranslation({
    required String key,
    required String value,
    required String language,
  }) async {
    await TolgeeApi.updateTranslation(
      config: instance._config!,
      key: key,
      language: language,
      value: value,
    );

    await TolgeeSdk.init(
      apiKey: instance._config!.apiKey,
      apiUrl: instance._config!.apiUrl,
    );
  }
}

extension Tolgee on BuildContext {
  TolgeeSdk get tolgee => TolgeeSdk.instance;
}
