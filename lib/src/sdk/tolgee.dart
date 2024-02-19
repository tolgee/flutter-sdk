import 'package:flutter/material.dart';
import 'package:tolgee/src/l10n/tolgee_localization.dart';
import 'package:tolgee/src/translations/tolgee_remote_translations.dart';

class Tolgee {
  const Tolgee._();

  /// Initializes Tolgee SDK
  static Future<void> init({
    required String apiKey,
    required String apiUrl,
  }) async {
    await TolgeeRemoteTranslations.init(
      apiKey: apiKey,
      apiUrl: apiUrl,
    );
  }

  /// Returns the base language
  static Locale get baseLocale {
    return Locale(
      TolgeeRemoteTranslations.instance.allProjectLanguages.values
          .firstWhere((element) => element.base)
          .tag,
    );
  }

  /// Returns the current locale
  static Locale? get currentLocale =>
      TolgeeRemoteTranslations.instance.currentLanguage;

  /// Sets the current locale
  static void setCurrentLocale(Locale locale) {
    TolgeeRemoteTranslations.instance.setCurrentLanguage(locale);
  }

  /// Returns list of supported locales
  static Iterable<Locale> get supportedLocales {
    return TolgeeRemoteTranslations.instance.allProjectLanguages.keys
        .map((e) => Locale(e));
  }

  /// Returns TolgeeLocalizationDelegate
  static Iterable<LocalizationsDelegate<dynamic>> get localizationDelegates {
    return TolgeeLocalization.localizationsDelegates;
  }

  static void toggleTranslationEnabled() {
    TolgeeRemoteTranslations.instance.toggleTranslationEnabled();
  }
}
