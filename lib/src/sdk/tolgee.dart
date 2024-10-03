import 'package:flutter/material.dart';
import 'package:tolgee/src/l10n/tolgee_localization.dart';
import 'package:tolgee/src/translations/tolgee_translation_strategy.dart';

class Tolgee {
  const Tolgee._();

  /// Initializes Tolgee
  /// [apiKey] is the Tolgee API key
  /// [apiUrl] is the Tolgee API URL
  /// If [apiKey] and [apiUrl] are not provided,
  /// Tolgee will be initialized in static mode.
  /// If [apiKey] and [apiUrl] are provided,
  /// Tolgee will be initialized in remote mode.
  /// In remote mode, translations will be fetched from Tolgee Cloud.
  /// In static mode, translations will be fetched from local files.
  static Future<void> init({
    String? apiKey,
    String? apiUrl,
    String? cdnUrl,
    String? currentLanguage,
    bool useCDN = false,
  }) async {
    apiKey != null && apiUrl != null
        ? await TolgeeTranslationsStrategy.initRemote(
            currentLanguage: currentLanguage,
            apiKey: apiKey,
            apiUrl: apiUrl,
            cdnUrl: cdnUrl,
            useCDN: useCDN,
          )
        : await TolgeeTranslationsStrategy.initStatic(currentLanguage);
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
  static Future<void> setCurrentLocale(Locale locale) async {
    await TolgeeTranslationsStrategy.instance.setCurrentLanguage(locale);
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

  /// Toggle highlight of Tolgee widgets.
  static void highlightTolgeeWidgets() {
    TolgeeTranslationsStrategy.instance.toggleTranslationEnabled();
  }

  static String translate({required String key, String? defaultValue}) {
    String? translatedValue =
        TolgeeTranslationsStrategy.instance.translate(key);
    return translatedValue ?? defaultValue ?? key;
  }
}
