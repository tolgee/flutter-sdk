import 'package:flutter_test/flutter_test.dart';
import 'package:tolgee/src/ui/translation_widget.dart';

void main() {
  test('formats plurals in the multi-line shape Tolgee stores them in', () {
    const pattern =
        '{count, plural,\none {# item to pack}\nother {# items to pack}\n}';

    expect(formatMessage(pattern, {'count': 1}, 'en'), '1 item to pack');
    expect(formatMessage(pattern, {'count': 3}, 'en'), '3 items to pack');
  });

  test('uses the plural rules of the given locale', () {
    const pattern = '{count, plural,\none {# przedmiot}\nfew {# przedmioty}\n'
        'many {# przedmiotów}\nother {# przedmiotu}\n}';

    expect(formatMessage(pattern, {'count': 3}, 'pl'), '3 przedmioty');
    expect(formatMessage(pattern, {'count': 5}, 'pl'), '5 przedmiotów');
  });
}
