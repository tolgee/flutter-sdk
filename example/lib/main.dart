import 'package:flutter/material.dart';
import 'package:tolgee/tolgee.dart';

Future<void> main() async {
  // Initialize Tolgee with remote translations from Tolgee Cloud.
  // You can also use static translations by calling `Tolgee.initStatic()`.
  await Tolgee.initRemote(
    apiKey: const String.fromEnvironment('TOLGEE_API_KEY'),
    apiUrl: const String.fromEnvironment('TOLGEE_API_URL'),
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
                          Tolgee.setCurrentLocale(locale);
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
                      tr('subtitle', {'name': 'Marcin'}),
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
          onPressed: () => Tolgee.toggleTranslationEnabled(),
          tooltip: 'Toggle',
          child: const Icon(Icons.swap_horizontal_circle_outlined),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
