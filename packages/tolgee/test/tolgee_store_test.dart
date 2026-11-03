import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:tolgee/src/translations/tolgee_loader.dart';
import 'package:tolgee/src/translations/tolgee_store.dart';
import 'package:tolgee/tolgee.dart';

const cdn = 'https://cdn.test/abc';

const _texts = {
  'en': {'k': 'Hello', 'only-base': 'Base text'},
  'de': {'k': 'Hallo'},
  'fr': {'k': 'Bonjour'},
};

void main() {
  late TolgeeStore store;
  var requests = <String>[];
  final delayed = <String, Completer<void>>{};
  var offline = false;
  var texts = Map.of(_texts);

  /// Serves [texts] from the CDN, holding a language back while it is in [delayed].
  TolgeeLoader loader() => TolgeeLoader(
        cdnUrl: cdn,
        availableLanguages: ['en', 'de', 'fr'],
        client: MockClient((request) async {
          final tag = request.url.pathSegments.last.replaceAll('.json', '');
          requests.add(tag);
          await delayed[tag]?.future;
          if (offline) throw ClientException('offline');
          return Response.bytes(utf8.encode(jsonEncode(texts[tag])), 200);
        }),
      );

  setUp(() {
    store = TolgeeStore();
    TolgeeStore.instance = store;
    requests = [];
    delayed.clear();
    offline = false;
    texts = Map.of(_texts);
  });

  test('has the texts as soon as init completes', () async {
    await store.init(loader(), requestedLanguage: 'de-AT');

    expect(store.currentLanguage, 'de');
    expect(store.translate('k'), 'Hallo');
  });

  test('falls back to the base language, then to null', () async {
    await store.init(loader(), requestedLanguage: 'de');

    expect(store.translate('only-base'), 'Base text');
    expect(store.translate('missing'), isNull);
  });

  test('switches the language and notifies', () async {
    await store.init(loader(), requestedLanguage: 'en');
    var notified = 0;
    store.addListener(() => notified++);

    await store.setLanguage('de');

    expect(store.currentLanguage, 'de');
    expect(store.translate('k'), 'Hallo');
    expect(notified, 1);
  });

  test('keeps the last chosen language when loads finish out of order',
      () async {
    await store.init(loader(), requestedLanguage: 'en');
    delayed['de'] = Completer();

    final toGerman = store.setLanguage('de');
    await store.setLanguage('fr');
    delayed['de']!.complete();
    await toGerman;

    expect(store.currentLanguage, 'fr');
  });

  test('loads the texts again on reload', () async {
    await store.init(loader(), requestedLanguage: 'en');
    requests.clear();

    await store.reload();

    expect(requests, ['en']);
  });

  test('keeps the texts when a reload fails', () async {
    await store.init(loader(), requestedLanguage: 'en');
    offline = true;

    await store.reload();

    expect(store.translate('k'), 'Hello');
  });

  test('loads a language again after a failed switch', () async {
    await store.init(loader(), requestedLanguage: 'en');
    offline = true;
    await store.setLanguage('de');
    offline = false;

    await store.setLanguage('en');
    await store.setLanguage('de');

    expect(store.translate('k'), 'Hallo');
  });

  test('drops other languages on reload, so they load fresh', () async {
    await store.init(loader(), requestedLanguage: 'en');
    await store.setLanguage('de');
    await store.setLanguage('en');
    texts['de'] = {'k': 'Hallo neu'};

    await store.reload();
    await store.setLanguage('de');

    expect(store.translate('k'), 'Hallo neu');
  });

  test('translates to the default value before init', () {
    expect(Tolgee.translate(key: 'x', defaultValue: 'd'), 'd');
    expect(Tolgee.translate(key: 'x'), 'x');
  });
}
