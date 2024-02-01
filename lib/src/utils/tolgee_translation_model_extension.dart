import 'package:tolgee/src/api/models/tolgee_key_model.dart';
import 'package:tolgee/src/api/tolgee_project_language.dart';

extension TolgeeKeyModelExtension on TolgeeKeyModel {
  String userFriendlyTranslations({
    required Map<String, TolgeeProjectLanguage> languages,
  }) {
    return languages.entries.map((language) {
      final languageCode = languageCodeWithFlag(language: language.value);

      final translation = translations[language.key];
      String translationText = 'Not translated yet';

      if (translation != null) {
        translationText = translation.text;
      }

      return '${languageCode} $translationText';
    }).join('\n');
  }

  String languageCodeWithFlag({
    required TolgeeProjectLanguage language,
  }) {
    final flagEmoji = language.flagEmoji;
    String flag = '';
    if (flagEmoji != null) {
      flag = ' $flagEmoji';
    }

    return '${language.tag}$flag';
  }
}
