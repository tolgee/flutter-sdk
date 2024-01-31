import 'package:flutter/material.dart';
import 'package:tolgee/tolgee/tolgee_sdk.dart';
import 'package:tolgee/tolgee/ui/translation_widget.dart';

Future<void> main() async {
  await TolgeeSdk.init(
    apiKey: 'tgpak_gm4tqok7nzzw2ylgoy2ds4lwgjvwq43rgvqxa33wgfzxeolwge',
    apiUrl: 'https://app.tolgee.io/v2',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: context.tolgee.currentLanguage,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
            title: TranslationWidget(
          builder: (context, tr) => Text(
            tr('title'),
          ),
        )),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('static text'),
              Divider(),
              TranslationWidget(
                builder: (context, tr) => Text(
                  tr('title'),
                ),
              ),
              Divider(),
              TranslationWidget(
                builder: (context, tr) => Column(
                  children: [
                    Text(
                      tr('title'),
                    ),
                    Text(
                      tr('subtitle'),
                    ),
                  ],
                ),
              ),
              Divider(),
              TranslationWidget(builder: (context, tr) {
                return OutlinedButton(
                  onPressed: () {
                    print("Pressed");
                  },
                  child: Text(
                    tr('button'),
                  ),
                );
              }),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => TolgeeSdk.instance.toggleTranslationEnabled(),
          tooltip: 'Toggle',
          child: const Icon(Icons.swap_horizontal_circle_outlined),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
