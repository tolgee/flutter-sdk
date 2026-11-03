import 'package:flutter_test/flutter_test.dart';
import 'package:tolgee/src/api/tolgee_config.dart';
import 'package:tolgee/src/sdk/dev_config.dart';

void main() {
  const fromEnvironment = TolgeeConfig(apiUrl: 'https://env.io', apiKey: 'e');

  test('ignores a passed key in release builds', () {
    expect(
      resolveDevConfig(apiKey: 'k', apiUrl: 'https://a.io', release: true),
      isNull,
    );
  });

  test('treats empty strings as not set', () {
    expect(resolveDevConfig(apiKey: '', apiUrl: '', release: false), isNull);
  });

  test('uses the --dart-define values when nothing is passed', () {
    expect(
      resolveDevConfig(fromEnvironment: fromEnvironment, release: false),
      fromEnvironment,
    );
  });

  test('prefers the passed key over --dart-define', () {
    final config = resolveDevConfig(
      apiKey: 'k',
      apiUrl: 'https://a.io',
      fromEnvironment: fromEnvironment,
      release: false,
    );

    expect(config?.apiKey, 'k');
  });

  test('accepts the API URL with /v2', () {
    final config = resolveDevConfig(
      apiKey: 'k',
      apiUrl: 'https://app.tolgee.io/v2/',
      release: false,
    );

    expect(config?.apiUrl, 'https://app.tolgee.io');
  });

  test('never prints the API key', () {
    const config = TolgeeConfig(apiUrl: 'https://a.io', apiKey: 'secret');

    expect(config.toString(), isNot(contains('secret')));
  });
}
