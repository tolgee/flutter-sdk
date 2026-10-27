import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:tolgee/src/translations/tolgee_loader.dart';
import 'package:tolgee/src/translations/tolgee_store.dart';
import 'package:tolgee/tolgee.dart';
import 'package:tolgee/tolgee_editor.dart';

class _FakeEditor implements TolgeeEditor {
  Set<String>? keys;
  int toggles = 0;

  @override
  Widget wrap(
    BuildContext context, {
    required Widget child,
    required Set<String> keys,
    BoxDecoration? decoration,
  }) {
    this.keys = keys;
    return KeyedSubtree(key: const Key('wrapped'), child: child);
  }

  @override
  void toggle() => toggles++;
}

Future<void> initStore({required bool api}) {
  final client = MockClient((request) async {
    final body = request.url.path == '/v2/projects/languages'
        ? {
            '_embedded': {
              'languages': [
                {'name': 'English', 'tag': 'en', 'base': true},
              ],
            },
          }
        : {
            'en': {'a': 'A', 'b': '{count, plural, other {# Bs}}'},
          };
    return Response(jsonEncode(body), 200);
  });
  return TolgeeStore.instance.init(
    TolgeeLoader(
      dev: api
          ? const TolgeeConfig(apiUrl: 'https://tolgee.test', apiKey: 'k')
          : null,
      availableLanguages: ['en'],
      files: () async => {
        'en': {'a': 'A', 'b': '{count, plural, other {# Bs}}'},
      },
      client: client,
    ),
    requestedLanguage: 'en',
  );
}

Widget app() => MaterialApp(
      home: TranslationWidget(
        builder: (context, tr) => Text('${tr('a')} ${tr('b', {'count': 2})}'),
      ),
    );

void main() {
  late _FakeEditor editor;

  setUp(() {
    TolgeeStore.instance = TolgeeStore();
    TolgeeEditor.uninstall();
    editor = _FakeEditor();
  });

  testWidgets('renders the child as it is without an editor', (tester) async {
    await initStore(api: true);

    await tester.pumpWidget(app());

    expect(find.text('A 2 Bs'), findsOneWidget);
    expect(find.byKey(const Key('wrapped')), findsNothing);
  });

  testWidgets('does not wrap without the Tolgee API', (tester) async {
    await initStore(api: false);
    TolgeeEditor.install(editor);

    await tester.pumpWidget(app());

    expect(find.byKey(const Key('wrapped')), findsNothing);
  });

  testWidgets('lets the editor wrap the widget with its keys', (tester) async {
    await initStore(api: true);
    TolgeeEditor.install(editor);

    await tester.pumpWidget(app());

    expect(find.byKey(const Key('wrapped')), findsOneWidget);
    expect(find.text('A 2 Bs'), findsOneWidget);
    expect(editor.keys, {'a', 'b'});
  });

  test('highlightTolgeeWidgets toggles the editor', () {
    TolgeeEditor.install(editor);

    Tolgee.highlightTolgeeWidgets();

    expect(editor.toggles, 1);
  });
}
