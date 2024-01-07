import 'package:flutter/widgets.dart';

class TolgeeSdk {
  static const String _apiKey =
      'tgpak_gm4tqok7nzzw2ylgoy2ds4lwgjvwq43rgvqxa33wgfzxeolwge';

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

  static final instance = TolgeeSdk._();
  TolgeeSdk._();
}

extension Tolgee on BuildContext {
  TolgeeSdk get tolgee => TolgeeSdk.instance;
  // TolgeeSdk get tolgee => watch<TolgeeSdk>();
}
