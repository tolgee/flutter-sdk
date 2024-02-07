import 'package:flutter/material.dart';
import 'package:tolgee/src/l10n/tolgee_localization_delegate.dart';
import 'package:tolgee/tolgee.dart';

class Tolgee {
  const Tolgee._();

  /// Initializes Tolgee SDK
  static Future<void> init({
    required String apiKey,
    required String apiUrl,
  }) async {
    await TolgeeSdk.init(
      apiKey: apiKey,
      apiUrl: apiUrl,
    );
  }

  /// Returns the base language
  static Locale get baseLocale {
    return Locale(
      TolgeeSdk.instance.allProjectLanguages.values
          .firstWhere((element) => element.base)
          .tag,
    );
  }

  /// Returns the current locale
  static Locale get currentLocale => TolgeeSdk.instance.currentLanguage;

  /// Sets the current locale
  static set currentLocale(Locale locale) {
    TolgeeSdk.instance.currentLanguage = locale;
  }

  /// Returns list of supported locales
  static Iterable<Locale> get supportedLocales {
    return TolgeeSdk.instance.allProjectLanguages.keys.map((e) => Locale(e));
  }

  /// Returns TolgeeLocalizationDelegate
  static Iterable<LocalizationsDelegate<dynamic>> get localizationDelegates {
    return TolgeeLocalization.localizationsDelegates;
  }
}
