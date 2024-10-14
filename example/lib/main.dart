import 'package:flutter/material.dart';
import 'package:tolgee/tolgee.dart';

Future<void> main() async {
  // Initialize Tolgee. If apiKey and apiUrl are not provided,
  // the app will be initialized in static mode.
  // The translations will be read from `lib/tolgee/` directory.
  await Tolgee.init(
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

extension WidgetExtension on List<Widget> {
  List<Widget> divided({
    double? width,
    double? height,
  }) {
    return List<Widget>.generate(
      length * 2 - 1,
      (index) => index.isEven
          ? this[index ~/ 2]
          : SizedBox(
              width: width,
              height: height,
            ),
    );
  }
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
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
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
                    ].divided(width: 8),
                  ),
                ),
                const Spacer(),
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
                        tr('subtitle', {'name': 'John'}),
                      ),
                    ],
                  ),
                  // enabledBoxDecoration: BoxDecoration(
                  //     color: Colors.blueAccent.withOpacity(0.2),
                  //     borderRadius: BorderRadius.circular(8)
                  // ),
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
                const Spacer(),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Tolgee.highlightTolgeeWidgets(),
          tooltip: 'Toggle',
          child: const Icon(Icons.swap_horizontal_circle_outlined),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
