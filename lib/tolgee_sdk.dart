import 'package:flutter/widgets.dart';

class TolgeeSdk {
  static const String _apiKey =
      'tgpak_gm4tqok7nzzw2ylgoy2ds4lwgjvwq43rgvqxa33wgfzxeolwge';

  String get currentLanguage => 'en';
}

extension Tolgee on BuildContext {
  TolgeeSdk get tolgee => TolgeeSdk();
  // TolgeeSdk get tolgee => watch<TolgeeSdk>();
}
