import 'package:flutter/material.dart';
import 'package:tolgee/tolgee.dart';

Future<void> main() async {
  await TolgeeSdk.init(
    apiKey: 'tgpak_gm4tqok7nzzw2ylgoy2ds4lwgjvwq43rgvqxa33wgfzxeolwge',
    apiUrl: 'https://app.tolgee.io/v2',
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Locale> supportedLocales = Tolgee.supportedLocales.toList();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Tolgee.baseLocale.languageCode,
      localizationsDelegates: Tolgee.localizationDelegates,
      supportedLocales: Tolgee.supportedLocales,
      locale: supportedLocales.first,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var locale in supportedLocales)
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          Tolgee.currentLocale = locale;
                        });
                      },
                      child: Text(locale.languageCode),
                    ),
                ],
              ),
              const Text('static text'),
              const Divider(),
              const TranslationText('title'),
              const Divider(),
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
              const Divider(),
              TranslationWidget(builder: (context, tr) {
                return OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Clicked!'),
                        duration: Duration(milliseconds: 1000),
                      ),
                    );
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
