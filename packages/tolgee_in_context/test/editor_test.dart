import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:tolgee/tolgee.dart';
import 'package:tolgee/tolgee_editor.dart';
import 'package:tolgee_in_context/src/dialog.dart';
import 'package:tolgee_in_context/src/editor.dart';

final highlighted = find.byWidgetPredicate(
  (w) => w is Container && w.foregroundDecoration != null,
);

void main() {
  late InContextEditor editor;
  late List<({Set<String> keys, Rect? anchor})> opened;
  var childTaps = 0;

  setUpAll(() async {
    await runWithClient(
      () => Tolgee.init(apiKey: 'k', apiUrl: 'https://tolgee.test'),
      () => MockClient((request) async {
        final body = request.url.path == '/v2/projects/languages'
            ? {
                '_embedded': {
                  'languages': [
                    {'name': 'English', 'tag': 'en', 'base': true},
                  ],
                },
              }
            : {
                'en': {'a': 'Text A'},
              };
        return Response(jsonEncode(body), 200);
      }),
    );
  });

  InContextEditor install(EditorMode mode) {
    editor = InContextEditor(
      mode: mode,
      open: (context, {required config, required keys, anchor}) async {
        opened.add((keys: keys, anchor: anchor));
      },
    );
    TolgeeEditor.install(editor);
    return editor;
  }

  Widget app() => MaterialApp(
        home: Scaffold(
          body: Center(
            child: TranslationWidget(
              builder: (context, tr) => GestureDetector(
                onTap: () => childTaps++,
                child: Text(tr('a')),
              ),
            ),
          ),
        ),
      );

  setUp(() {
    opened = [];
    childTaps = 0;
    tolgeeDialogOpen.value = false;
  });

  test('picks the editing mode for each platform', () {
    for (final platform in TargetPlatform.values) {
      expect(
          editorModeFor(isWeb: true, platform: platform), EditorMode.altClick);
    }
    expect(editorModeFor(isWeb: false, platform: TargetPlatform.macOS),
        EditorMode.altClick);
    expect(editorModeFor(isWeb: false, platform: TargetPlatform.iOS),
        EditorMode.bubble);
    expect(editorModeFor(isWeb: false, platform: TargetPlatform.android),
        EditorMode.bubble);
    expect(editorModeFor(isWeb: false, platform: TargetPlatform.windows),
        EditorMode.none);
    expect(editorModeFor(isWeb: false, platform: TargetPlatform.linux),
        EditorMode.none);
    expect(editorModeFor(isWeb: false, platform: TargetPlatform.fuchsia),
        EditorMode.none);
  });

  testWidgets('without Alt, taps reach the app', (tester) async {
    install(EditorMode.altClick);
    await tester.pumpWidget(app());

    await tester.tap(find.text('Text A'));

    expect(childTaps, 1);
    expect(opened, isEmpty);
    expect(highlighted, findsNothing);
  });

  testWidgets('Alt + hover highlights, Alt + click opens the dialog',
      (tester) async {
    install(EditorMode.altClick);
    await tester.pumpWidget(app());
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await mouse.moveTo(tester.getCenter(find.text('Text A')));
    await tester.pump();

    expect(highlighted, findsOneWidget);

    await tester.tap(find.text('Text A'));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);

    expect(childTaps, 0);
    expect(opened.single.keys, {'a'});
    expect(opened.single.anchor, isNotNull);
  });

  testWidgets('the bubble switches editing on and off', (tester) async {
    install(EditorMode.bubble);
    await tester.pumpWidget(app());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.translate));
    await tester.pump();
    expect(highlighted, findsOneWidget);

    await tester.tap(find.text('Text A'));
    expect(opened.single.keys, {'a'});
    expect(childTaps, 0);

    await tester.tap(find.byIcon(Icons.translate));
    await tester.pump();
    expect(highlighted, findsNothing);
  });

  testWidgets('shows one bubble for many translation widgets', (tester) async {
    install(EditorMode.bubble);
    await tester.pumpWidget(MaterialApp(
      home: Column(children: [
        for (var i = 0; i < 3; i++)
          TranslationWidget(builder: (context, tr) => Text(tr('a'))),
      ]),
    ));
    await tester.pump();

    expect(find.byIcon(Icons.translate), findsOneWidget);
  });

  testWidgets('the bubble hides while the dialog is open', (tester) async {
    install(EditorMode.bubble);
    await tester.pumpWidget(app());
    await tester.pump();

    tolgeeDialogOpen.value = true;
    await tester.pump();

    expect(find.byIcon(Icons.translate), findsNothing);
  });

  testWidgets('toggle switches editing on without Alt', (tester) async {
    install(EditorMode.altClick);
    await tester.pumpWidget(app());

    Tolgee.highlightTolgeeWidgets();
    await tester.pump();

    expect(highlighted, findsOneWidget);
  });
}
