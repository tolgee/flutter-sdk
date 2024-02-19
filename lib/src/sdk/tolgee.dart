import 'package:flutter/material.dart';
import 'package:tolgee/src/l10n/tolgee_localization.dart';
import 'package:tolgee/src/translations/tolgee_translation_strategy.dart';

class Tolgee {
  const Tolgee._();

  static Future<void> initRemote({
    required String apiKey,
    required String apiUrl,
  }) async {
    await TolgeeTranslationsStrategy.initRemote(apiKey: apiKey, apiUrl: apiUrl);
  }

  static Future<void> initStatic() async {
    await TolgeeTranslationsStrategy.initStatic();
  }

  /// Returns the base language
  static Locale get baseLocale {
    return Locale(
      TolgeeTranslationsStrategy.instance.allProjectLanguages.values
          .firstWhere((element) => element.base)
          .tag,
    );
  }

  /// Returns the current locale
  static Locale? get currentLocale =>
      TolgeeTranslationsStrategy.instance.currentLanguage;

  /// Sets the current locale
  static void setCurrentLocale(Locale locale) {
    TolgeeTranslationsStrategy.instance.setCurrentLanguage(locale);
  }

  /// Returns list of supported locales
  static Iterable<Locale> get supportedLocales {
    return TolgeeTranslationsStrategy.instance.allProjectLanguages.keys
        .map((e) => Locale(e));
  }

  /// Returns TolgeeLocalizationDelegate
  static Iterable<LocalizationsDelegate<dynamic>> get localizationDelegates {
    return TolgeeLocalization.localizationsDelegates;
  }

  static void toggleTranslationEnabled() {
    TolgeeTranslationsStrategy.instance.toggleTranslationEnabled();
  }
}
