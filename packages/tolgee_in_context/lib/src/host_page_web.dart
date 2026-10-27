import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:web/web.dart' as web;

@JS('tolgeeInit')
external JSPromise<JSAny?> _tolgeeInit(JSString config);

@JS('tolgeeOpen')
external void _tolgeeOpen(JSString request);

Future<void>? _initialized;

Future<void> openInHostPage({
  required String initJson,
  required String requestJson,
  required Future<void> Function(String message) onMessage,
}) async {
  try {
    await (_initialized ??= _initialize(initJson, onMessage));
  } catch (_) {
    _initialized = null;
    rethrow;
  }
  _tolgeeOpen(requestJson.toJS);
}

Future<void> _initialize(
  String initJson,
  Future<void> Function(String message) onMessage,
) async {
  final bridge = JSObject();
  bridge['postMessage'] = ((JSString message) {
    onMessage(message.toDart);
  }).toJS;
  globalContext['TolgeeBridge'] = bridge;

  if (globalContext['tolgeeInit'] == null) {
    final loaded = Completer<void>();
    final script = web.HTMLScriptElement()
      ..src = ui_web.assetManager
          .getAssetUrl('packages/tolgee_in_context/assets/tolgee_bridge.js');
    script.onload = ((web.Event _) => loaded.complete()).toJS;
    script.onerror = ((web.Event _) =>
            loaded.completeError(StateError('Failed to load tolgee_bridge.js')))
        .toJS;
    web.document.head!.append(script);
    await loaded.future;
  }

  await _tolgeeInit(initJson.toJS).toDart;
}
