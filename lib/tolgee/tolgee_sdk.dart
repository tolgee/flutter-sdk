import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:tolgee/tolgee/api/tolgee_api.dart';
import 'package:tolgee/tolgee/api/tolgee_config.dart';
import 'package:tolgee/tolgee/api/tolgee_key_model.dart';

class TolgeeSdk extends ChangeNotifier {
  TolgeeConfig? _config;

  String get currentLanguage => 'en';

  bool _isTranslationEnabled = true;
  bool get isTranslationEnabled => _isTranslationEnabled;
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
    final translations = await TolgeeApi.getTranslations(
      config: instance._config!,
    );

    print('jsonBody: $translations');
    TolgeeSdk.instance._translations = translations.keys;
    TolgeeSdk.instance.notifyListeners();
  }

  List<TolgeeKeyModel> translationForKeys(List<String> keys) {
    final emptyTranslations = keys.map((key) {
      return TolgeeKeyModel(
        keyName: key,
        translations: {},
      );
    }).toList();

    return emptyTranslations
        .map((translationKey) =>
            _translations.firstWhereOrNull(
              (element) => element.keyName == translationKey.keyName,
            ) ??
            translationKey)
        .toList();
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
