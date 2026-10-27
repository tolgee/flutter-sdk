import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:tolgee/src/api/tolgee_config.dart';
import 'package:tolgee/src/translations/tolgee_loader.dart';

const dev = TolgeeConfig(apiUrl: 'https://tolgee.test', apiKey: 'key');
const cdn = 'https://cdn.test/abc';

Response json(Object body, [int status = 200]) => Response.bytes(
      utf8.encode(jsonEncode(body)),
      status,
      headers: {'content-type': 'application/json'},
    );

/// Answers the Tolgee API and the CDN; [api] and [cdnOk] switch them off.
MockClient server({bool api = true, bool cdnOk = true}) {
  return MockClient((request) async {
    final url = request.url.toString();
    if (url.startsWith(cdn)) {
      if (!cdnOk) return json({}, 500);
      final tag = request.url.pathSegments.last.replaceAll('.json', '');
      return json({'k': 'cdn $tag'});
    }
    if (!api) return json({}, 500);
    if (request.url.path == '/v2/projects/languages') {
      return json({
        '_embedded': {
          'languages': [
            {'name': 'German', 'tag': 'de', 'base': false},
            {'name': 'English', 'tag': 'en', 'base': true},
          ],
        },
      });
    }
    final tags = request.url.pathSegments.last.split(',');
    return json({
      for (final tag in tags) tag: {'k': 'api $tag'},
    });
  });
}

void main() {
  var fileReads = 0;
  Future<Map<String, Map<String, String>>> files(List<String> tags) async {
    fileReads++;
    return {
      for (final tag in tags) tag: {'k': 'file $tag'},
    };
  }

  setUp(() => fileReads = 0);

  test('loads languages and texts from the API in dev', () async {
    final loader = TolgeeLoader(
      dev: dev,
      client: server(),
      files: () => files(['en']),
    );

    final languages = await loader.loadLanguages();
    final texts = await loader.load({'en', 'de'});

    expect(languages.map((l) => l.tag), ['en', 'de']);
    expect(languages.first.name, 'English');
    expect(texts, {
      'en': {'k': 'api en'},
      'de': {'k': 'api de'},
    });
    expect(loader.usesApi, isTrue);
    expect(fileReads, 0);
  });

  test('falls back to the CDN when the API fails', () async {
    final loader = TolgeeLoader(
      dev: dev,
      cdnUrl: cdn,
      availableLanguages: ['en'],
      client: server(api: false),
    );

    await loader.loadLanguages();

    expect(await loader.load({'en'}), {
      'en': {'k': 'cdn en'},
    });
    expect(loader.usesApi, isFalse);
  });

  test('falls back to bundled files when the API fails', () async {
    final loader = TolgeeLoader(
      dev: dev,
      client: server(api: false),
      files: () => files(['en']),
    );

    await loader.loadLanguages();

    expect(await loader.load({'en'}), {
      'en': {'k': 'file en'},
    });
  });

  test('treats a missing network like a failed request', () async {
    final loader = TolgeeLoader(
      dev: dev,
      client: MockClient((_) => throw ClientException('offline')),
      files: () => files(['en']),
    );

    expect((await loader.loadLanguages()).map((l) => l.tag), ['en']);
    expect(await loader.load({'en'}), {
      'en': {'k': 'file en'},
    });
  });

  test('loads from the CDN without bundled files', () async {
    final loader = TolgeeLoader(
      cdnUrl: cdn,
      availableLanguages: ['en', 'de'],
      client: server(),
      files: () => files([]),
    );

    final languages = await loader.loadLanguages();

    expect(languages.map((l) => l.tag), ['en', 'de']);
    expect(await loader.load({'en', 'de'}), {
      'en': {'k': 'cdn en'},
      'de': {'k': 'cdn de'},
    });
    expect(fileReads, 0);
  });

  test('shows keys when the CDN fails and fallbackOnFail is off', () async {
    final loader = TolgeeLoader(
      cdnUrl: cdn,
      availableLanguages: ['en'],
      client: server(cdnOk: false),
      files: () => files(['en']),
    );

    expect(await loader.load({'en'}), {'en': <String, String>{}});
  });

  test('uses bundled files when the CDN fails and fallbackOnFail is on',
      () async {
    final loader = TolgeeLoader(
      cdnUrl: cdn,
      fallbackOnFail: true,
      availableLanguages: ['en'],
      client: server(cdnOk: false),
      files: () => files(['en']),
    );

    expect(await loader.load({'en'}), {
      'en': {'k': 'file en'},
    });
  });

  test('loads bundled files without the API and the CDN', () async {
    final loader = TolgeeLoader(files: () => files(['de', 'en']));

    await loader.loadLanguages();

    expect(await loader.load({'de'}), {
      'de': {'k': 'file de'},
    });
    expect(fileReads, 1);
  });

  group('base language without the API', () {
    Future<List<String>> tags(List<String> files_, {String? base}) async {
      final loader =
          TolgeeLoader(baseLanguage: base, files: () => files(files_));
      return (await loader.loadLanguages()).map((l) => l.tag).toList();
    }

    test('uses baseLanguage', () async {
      expect(await tags(['de', 'en', 'fr'], base: 'de'), ['de', 'en', 'fr']);
    });

    test('defaults to English', () async {
      expect(await tags(['de', 'en', 'fr']), ['en', 'de', 'fr']);
    });

    test('defaults to the first language without English', () async {
      expect(await tags(['de', 'fr']), ['de', 'fr']);
    });
  });

  test('fails clearly when there are no languages at all', () async {
    final loader = TolgeeLoader(cdnUrl: cdn, files: () => files([]));

    expect(loader.loadLanguages(), throwsStateError);
  });
}
