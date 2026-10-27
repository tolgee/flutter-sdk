import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:tolgee/src/api/tolgee_project_language.dart';
import 'package:tolgee/src/translations/language_tags.dart';

void main() {
  const tags = ['en', 'pt', 'pt-BR', 'zh-Hant'];

  test('matches the exact tag', () {
    expect(matchLanguage(tags, 'pt-BR'), 'pt-BR');
  });

  test('ignores case and accepts an underscore', () {
    expect(matchLanguage(tags, 'PT_br'), 'pt-BR');
  });

  test('falls back to the language part', () {
    expect(matchLanguage(tags, 'pt-PT'), 'pt');
  });

  test('falls back to the language and script', () {
    expect(matchLanguage(tags, 'zh-Hant-TW'), 'zh-Hant');
  });

  test('returns null when nothing matches', () {
    expect(matchLanguage(tags, 'ja-JP'), isNull);
  });

  test('starts in the base language when nothing matches', () {
    expect(selectStartLanguage(tags, 'ja-JP', 'en'), 'en');
  });

  test('starts in the base language for an undetermined locale', () {
    expect(selectStartLanguage(tags, 'und', 'en'), 'en');
  });

  test('converts tags to locales and back', () {
    for (final tag in ['en', 'pt-BR', 'zh-Hant', 'zh-Hant-TW', 'es-419']) {
      expect(localeFromTag(tag).toLanguageTag(), tag);
    }
  });

  test('gives a project language its locale', () {
    const language =
        TolgeeProjectLanguage(name: 'Portuguese', tag: 'pt-BR', base: false);

    expect(language.locale, const Locale('pt', 'BR'));
  });
}
