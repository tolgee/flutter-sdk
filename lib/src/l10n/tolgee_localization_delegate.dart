import 'package:flutter/material.dart';
import 'package:tolgee/src/l10n/tolgee_localization.dart';

class TolgeeLocalizationDelegate
    extends LocalizationsDelegate<TolgeeLocalization> {
  const TolgeeLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return TolgeeLocalization.isSupported(locale);
  }

  @override
  Future<TolgeeLocalization> load(Locale locale) async {
    return TolgeeLocalization.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<TolgeeLocalization> old) {
    return false;
  }
}
