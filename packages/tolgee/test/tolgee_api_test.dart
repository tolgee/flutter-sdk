import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:tolgee/src/api/tolgee_api.dart';
import 'package:tolgee/src/api/tolgee_config.dart';
import 'package:tolgee/src/api/tolgee_project_language.dart';

void main() {
  group('API client', () {
    const dev = TolgeeConfig(apiKey: 'key', apiUrl: 'https://tolgee.test');

    Response json(String body, [int status = 200]) => Response.bytes(
          utf8.encode(body),
          status,
          headers: {'content-type': 'application/json'},
        );

    test('fetches all languages with the API key', () async {
      late Request request;
      final client = MockClient((r) async {
        request = r;
        return json('{"_embedded": {"languages": [{"name": "Czech", '
            '"originalName": "Čeština", "tag": "cs", "flagEmoji": "🇨🇿", '
            '"base": true}]}}');
      });

      final languages = await fetchLanguages(client, dev);

      expect(request.url.path, '/v2/projects/languages');
      expect(request.url.queryParameters['size'], '1000');
      expect(request.headers['X-Api-Key'], 'key');
      expect(languages, [
        const TolgeeProjectLanguage(
          name: 'Czech',
          originalName: 'Čeština',
          tag: 'cs',
          flagEmoji: '🇨🇿',
          base: true,
        ),
      ]);
    });

    test('fetches all translations of several languages in one request',
        () async {
      late Request request;
      final client = MockClient((r) async {
        request = r;
        return json('{"en": {"a": null, "b": "x"}, "de": {"b": "y"}}');
      });

      final texts = await fetchTranslations(client, dev, {'en', 'de'});

      expect(
          request.url.path,
          anyOf('/v2/projects/translations/en,de',
              '/v2/projects/translations/de,en'));
      expect(request.url.query, 'structureDelimiter=');
      expect(request.headers['X-Api-Key'], 'key');
      expect(texts, {
        'en': {'b': 'x'},
        'de': {'b': 'y'},
      });
    });

    test('fetches a CDN file without the API key and flattens it', () async {
      late Request request;
      final client = MockClient((r) async {
        request = r;
        return json('{"home": {"title": "Hi"}}');
      });

      final texts =
          await fetchCdnTranslations(client, 'https://cdn.test/abc', 'pt-BR');

      expect(request.url.toString(), 'https://cdn.test/abc/pt-BR.json');
      expect(request.headers.containsKey('X-Api-Key'), isFalse);
      expect(texts, {'home.title': 'Hi'});
    });

    test('throws when the server answers with an error', () async {
      final client = MockClient((_) async => json('{}', 500));

      expect(fetchLanguages(client, dev), throwsA(isA<TolgeeLoadException>()));
      expect(fetchTranslations(client, dev, {'en'}),
          throwsA(isA<TolgeeLoadException>()));
      expect(fetchCdnTranslations(client, 'https://cdn.test', 'en'),
          throwsA(isA<TolgeeLoadException>()));
    });
  });
}
