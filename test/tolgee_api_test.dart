import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:tolgee/src/api/tolgee_api.dart';
import 'package:tolgee/src/api/tolgee_config.dart';

void main() {
  const config = TolgeeConfig(apiKey: 'key', apiUrl: 'https://tolgee.test/v2');

  test('requests all project languages in one page', () async {
    Uri? requested;
    final client = MockClient((request) async {
      requested = request.url;
      return Response('{"_embedded": {"languages": []}}', 200);
    });

    await runWithClient(
      () => TolgeeApi.getAllProjectLanguages(config: config),
      () => client,
    );

    expect(requested?.queryParameters['size'], '1000');
  });

  test('returns no languages when the request fails', () async {
    final client =
        MockClient((_) async => Response('{"code": "unauthenticated"}', 401));

    final languages = await runWithClient(
      () => TolgeeApi.getAllProjectLanguages(config: config),
      () => client,
    );

    expect(languages, isEmpty);
  });
}
