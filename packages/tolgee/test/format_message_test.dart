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

  test('falls back to English rules for locales intl has no data for', () {
    const pattern = '{count, plural, one {# item} other {# items}}';

    expect(formatMessage(pattern, {'count': 1}, 'eo'), '1 item');
  });

  test('returns the raw translation when it is not a valid message', () {
    const pattern = '{count, plural, one {# item}';

    expect(formatMessage(pattern, {'count': 1}, 'en'), pattern);
  });

  test('keeps spaces that are part of the text', () {
    const pattern =
        '{count, plural, one {Price: {price} } other {Prices: {price} }}';

    expect(
      formatMessage(pattern, {'count': 1, 'price': 'X'}, 'en'),
      'Price: X ',
    );
    expect(formatMessage("Use '} }' to close", {}, 'en'), 'Use } } to close');
  });
}
