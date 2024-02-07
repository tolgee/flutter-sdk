import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tolgee/tolgee.dart';

class TolgeeLocalization {
  const TolgeeLocalization._();

  static bool isSupported(Locale locale) {
    return Tolgee.supportedLocales.contains(locale);
  }

  static Future<TolgeeLocalization> load(Locale locale) async {
    Tolgee.currentLocale = locale;
    return const TolgeeLocalization._();
  }

  static const LocalizationsDelegate<TolgeeLocalization> delegate =
      TolgeeLocalizationDelegate();

  static Iterable<LocalizationsDelegate<dynamic>> get localizationsDelegates {
    return [
      delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ];
  }

  String translate(String key) {
    return TolgeeSdk.instance.translate(key);
  }
}

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
