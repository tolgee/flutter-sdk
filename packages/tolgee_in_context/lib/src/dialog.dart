import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tolgee/tolgee.dart';
import 'package:tolgee/tolgee_editor.dart';
import 'package:tolgee_in_context/src/host_page_stub.dart'
    if (dart.library.js_interop) 'package:tolgee_in_context/src/host_page_web.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Whether the WebView dialog is shown over the app.
final ValueNotifier<bool> tolgeeDialogOpen = ValueNotifier(false);

/// Opens the tolgee-js in-context dialog for [keys]: on the web in the host
/// page, elsewhere in a transparent WebView over the app. With several keys,
/// tolgee-js lets the user pick one in a menu next to [anchor].
Future<void> showTolgeeDialog(
  BuildContext context, {
  required TolgeeConfig config,
  required Set<String> keys,
  Rect? anchor,
}) async {
  final requestJson = jsonEncode({
    'keys': keys.toList(),
    if (anchor != null)
      'rect': {
        'left': anchor.left,
        'top': anchor.top,
        'width': anchor.width,
        'height': anchor.height,
      },
  });
  final initJson = jsonEncode({
    'apiUrl': config.apiUrl,
    'apiKey': config.apiKey,
    'language': Tolgee.currentLocale?.toLanguageTag(),
  });
  if (kIsWeb) {
    try {
      await openInHostPage(
        initJson: initJson,
        requestJson: requestJson,
        onMessage: (raw) =>
            handleBridgeMessage(raw, onReady: () {}, onClosed: () {}),
      );
    } catch (e) {
      TolgeeLogger.error('Failed to open the Tolgee editor: $e');
    }
    return;
  }
  tolgeeDialogOpen.value = true;
  try {
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) =>
            _TolgeeDialog(initJson: initJson, requestJson: requestJson),
      ),
    );
  } finally {
    tolgeeDialogOpen.value = false;
  }
}

@visibleForTesting
Future<void> handleBridgeMessage(
  String raw, {
  required VoidCallback onReady,
  required VoidCallback onClosed,
}) async {
  final Object? message;
  try {
    message = jsonDecode(raw);
  } on FormatException {
    TolgeeLogger.warning('Unexpected message from the Tolgee editor: $raw');
    return;
  }
  switch (message) {
    case {'type': 'ready'}:
      onReady();
    case {'type': 'saved'}:
      await Tolgee.reload();
    case {'type': 'closed'}:
      onClosed();
    case {'type': 'error'}:
      TolgeeLogger.error(
        'The Tolgee editor failed: ${(message as Map)['message']}',
      );
      onClosed();
    default:
      TolgeeLogger.warning('Unexpected message from the Tolgee editor: $raw');
  }
}

class _TolgeeDialog extends StatefulWidget {
  final String initJson;
  final String requestJson;

  const _TolgeeDialog({required this.initJson, required this.requestJson});

  @override
  State<_TolgeeDialog> createState() => _TolgeeDialogState();
}

class _TolgeeDialogState extends State<_TolgeeDialog> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    // webview_flutter can't make the WebView transparent on macOS (it throws),
    // so there the dialog covers the app.
    if (defaultTargetPlatform != TargetPlatform.macOS) {
      _controller.setBackgroundColor(Colors.transparent);
    }
    _controller
      ..addJavaScriptChannel(
        'TolgeeBridge',
        onMessageReceived: (message) => handleBridgeMessage(
          message.message,
          onReady: () =>
              _controller.runJavaScript('tolgeeOpen(${widget.requestJson})'),
          onClosed: () {
            if (mounted) Navigator.of(context).pop();
          },
        ),
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) =>
            _controller.runJavaScript('tolgeeInit(${widget.initJson})'),
      ))
      ..loadFlutterAsset(
          'packages/tolgee_in_context/assets/tolgee_dialog.html');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: WebViewWidget(controller: _controller));
  }
}
