import 'package:flutter_test/flutter_test.dart';
import 'package:tolgee/src/api/tolgee_project_language.dart';
import 'package:tolgee/src/translations/tolgee_remote_translations.dart';

void main() {
  // Sorted by tag, the way the Tolgee API returns them.
  const languages = [
    TolgeeProjectLanguage(name: 'German', tag: 'de', base: false),
    TolgeeProjectLanguage(name: 'English', tag: 'en', base: true),
    TolgeeProjectLanguage(name: 'Polish', tag: 'pl', base: false),
  ];

  test('picks the requested language when the project has it', () {
    expect(selectStartLanguage(languages, 'pl_PL'), 'pl');
  });

  test('falls back to the base language, not the first one', () {
    expect(selectStartLanguage(languages, 'ja_JP'), 'en');
  });

  test('falls back to the first language when there is no base', () {
    final noBase = languages.where((l) => !l.base).toList();
    expect(selectStartLanguage(noBase, 'ja_JP'), 'de');
  });

  test('lists the base language first', () {
    expect(baseLanguageFirst(languages).map((l) => l.tag), ['en', 'de', 'pl']);
  });
}
