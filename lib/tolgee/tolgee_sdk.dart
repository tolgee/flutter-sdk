import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:tolgee/tolgee/api/tolgee_api.dart';
import 'package:tolgee/tolgee/api/tolgee_config.dart';
import 'package:tolgee/tolgee/api/tolgee_key_model.dart';

class TolgeeSdk {
  TolgeeConfig? _config;

  String get currentLanguage => 'en';

  bool _isTranslationEnabled = true;
  bool get isTranslationEnabled => _isTranslationEnabled;
  bool mutateTranslationEnabled(bool value) {
    _isTranslationEnabled = value;
    return _isTranslationEnabled;
  }

  void setTranslationEnabled(bool value) {
    _isTranslationEnabled = value;
  }

  void toggleTranslationEnabled() {
    _isTranslationEnabled = !_isTranslationEnabled;
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
  }
}

extension Tolgee on BuildContext {
  TolgeeSdk get tolgee => TolgeeSdk.instance;
  // TolgeeSdk get tolgee => watch<TolgeeSdk>();
}
