import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tolgee/src/l10n/tolgee_localization_delegate.dart';
import 'package:tolgee/src/translations/tolgee_translation_strategy.dart';
import 'package:tolgee/tolgee.dart';

class TolgeeLocalization {
  const TolgeeLocalization._();

  static bool isSupported(Locale locale) {
    return Tolgee.supportedLocales.contains(locale);
  }

  static Future<TolgeeLocalization> load(Locale locale) async {
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

  String? translate(String key) {
    return TolgeeTranslationsStrategy.instance.translate(key);
  }
}
