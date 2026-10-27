import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tolgee/src/api/tolgee_project_language.dart';
import 'package:tolgee/src/l10n/tolgee_localization.dart';
import 'package:tolgee/src/logger/logger.dart';
import 'package:tolgee/src/sdk/dev_config.dart';
import 'package:tolgee/src/translations/language_tags.dart';
import 'package:tolgee/src/translations/tolgee_loader.dart';
import 'package:tolgee/src/translations/tolgee_store.dart';

class Tolgee {
  const Tolgee._();

  /// Initializes Tolgee and loads the texts of the start language.
  ///
  /// Dev builds load from the Tolgee API when `TOLGEE_API_KEY` and
  /// `TOLGEE_API_URL` are passed with `--dart-define`. Otherwise texts come
  /// from the CDN when [useCDN] and [cdnUrl] are set, or from the JSON files
  /// bundled in `lib/tolgee/`. With [fallbackOnFail], a failed CDN request
  /// falls back to the bundled files.
  ///
  /// [apiKey] and [apiUrl] are kept for 1.x apps and ignored in release builds.
  /// Without the API, [availableLanguages] (default: the bundled file names)
  /// lists the languages and [baseLanguage] picks the base one.
  static Future<void> init({
    String? apiKey,
    String? apiUrl,
    String? cdnUrl,
    bool useCDN = false,
    bool fallbackOnFail = false,
    List<String>? availableLanguages,
    String? baseLanguage,
    String? currentLanguage,
  }) async {
    if (useCDN && cdnUrl == null) {
      TolgeeLogger.warning('useCDN is set without cdnUrl, the CDN is not used');
    }
    final loader = TolgeeLoader(
      dev: resolveDevConfig(
        apiKey: apiKey,
        apiUrl: apiUrl,
        fromEnvironment: devConfigFromEnvironment(),
        release: kReleaseMode,
      ),
      cdnUrl: useCDN ? cdnUrl : null,
      fallbackOnFail: fallbackOnFail,
      availableLanguages: availableLanguages,
      baseLanguage: baseLanguage,
    );
    await TolgeeStore.instance.init(
      loader,
      requestedLanguage:
          currentLanguage ?? PlatformDispatcher.instance.locale.toLanguageTag(),
    );
  }

  /// Returns the base language
  static Locale get baseLocale =>
      localeFromTag(TolgeeStore.instance.baseLanguage);

  /// Returns the current locale
  static Locale? get currentLocale {
    final current = TolgeeStore.instance.currentLanguage;
    return current == null ? null : localeFromTag(current);
  }

  /// Sets the current locale
  static Future<void> setCurrentLocale(Locale locale) =>
      TolgeeStore.instance.setLanguage(locale.toLanguageTag());

  /// Returns list of supported locales, base language first
  static Iterable<Locale> get supportedLocales =>
      TolgeeStore.instance.languages.map((l) => localeFromTag(l.tag));

  /// The project languages, base language first. Names and flags are only
  /// known when loading from the Tolgee API.
  static List<TolgeeProjectLanguage> get languages =>
      TolgeeStore.instance.languages;

  /// Loads the texts of the current and base language again.
  static Future<void> reload() => TolgeeStore.instance.reload();

  /// Returns TolgeeLocalizationDelegate
  static Iterable<LocalizationsDelegate<dynamic>> get localizationDelegates {
    return TolgeeLocalization.localizationsDelegates;
  }

  /// Toggle highlight of Tolgee widgets.
  static void highlightTolgeeWidgets() {}

  static String translate({required String key, String? defaultValue}) {
    return TolgeeStore.instance.translate(key) ?? defaultValue ?? key;
  }
}
