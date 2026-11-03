import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:tolgee/tolgee.dart';
import 'package:tolgee_in_context/src/dialog.dart';

void main() {
  var ready = 0;
  var closed = 0;
  var cdnRequests = 0;

  Future<void> handle(String raw) => handleBridgeMessage(
        raw,
        onReady: () => ready++,
        onClosed: () => closed++,
      );

  setUpAll(() async {
    // Tolgee.init has no client parameter, so a CDN mock stands in via runWithClient.
    await runWithClient(
      () => Tolgee.init(
        useCDN: true,
        cdnUrl: 'https://cdn.test',
        availableLanguages: ['en'],
        currentLanguage: 'en',
      ),
      () => MockClient((_) async {
        cdnRequests++;
        return Response('{}', 200);
      }),
    );
  });

  setUp(() {
    ready = 0;
    closed = 0;
    cdnRequests = 0;
  });

  test('opens the dialog once tolgee-js is ready', () async {
    await handle('{"type": "ready"}');

    expect(ready, 1);
    expect(closed, 0);
  });

  test('reloads the translations after a save', () async {
    await handle('{"type": "saved", "key": "a"}');

    expect(cdnRequests, 1);
  });

  test('closes when the dialog is closed', () async {
    await handle('{"type": "closed"}');

    expect(closed, 1);
  });

  test('closes when tolgee-js fails to load', () async {
    await handle('{"type": "error", "message": "Failed to load"}');

    expect(closed, 1);
  });

  test('ignores messages it does not understand', () async {
    await handle('not json');
    await handle('{"type": "other"}');
    await handle('[]');

    expect(ready + closed, 0);
  });

  test('moves the anchor into the WebView, which sits inside the safe area',
      () {
    const anchor = Rect.fromLTWH(20, 100, 200, 40);

    expect(
      anchorInWebView(anchor, const EdgeInsets.only(left: 10, top: 59)),
      const Rect.fromLTWH(10, 41, 200, 40),
    );
    expect(anchorInWebView(null, EdgeInsets.zero), isNull);
  });
}
