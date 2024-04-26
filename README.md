# Tolgee Flutter SDK 🐁

A multiplatform Flutter SDK for the Tolgee localization platform.

The SDK is currently in beta. We're working on adding more features and improving the existing ones. If you have any
suggestions, feel free to open an issue or a pull request!

![Tolgee FLutter SDK - example usage](doc/assets/app-showcase.gif)

## Usage

- Sign up on [tolgee.io](https://tolgee.io) and create a new project.
- Initialize the Tolgee SDK in your app. You can do this by adding the following code to your `main.dart` file: 
  ```dart
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
  ```

- Use either the `TranslationText` or the `TranslationWidget` widget to display translated text in your app. You can do this by adding the following code to your `main.dart` file:
  ```dart
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

  class _MyAppState extends State<MyApp> {
    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        localizationsDelegates: Tolgee.localizationDelegates,
        supportedLocales: Tolgee.supportedLocales,
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
          ),
        ),
      );
    }
  }

  ```

- Run the app. The translations will be fetched from the Tolgee platform and displayed in the app. You can also use the `Tolgee.highlightTolgeeWidgets()` method to highlight the widgets that use the Tolgee SDK and add or modify the translation directly from the app.

- You can also [export the translations from the Tolgee platform](https://tolgee.io/platform/projects_and_organizations/export) and add them to the `lib/tolgee/` directory. The Tolgee asset directory can be added to your project by adding the following to your `pubspec.yaml` file:
  ```yaml
  flutter:
    assets:
      - lib/tolgee/
  ```
- If you want to use the Tolgee SDK in static mode, you can initialize it without providing the `apiKey` and `apiUrl`:
  ```dart
  import 'package:tolgee/tolgee.dart';

  Future<void> main() async {
    // Initialize Tolgee in static mode.
    await Tolgee.init();

    runApp(const MyApp());
  }
  ```

## Contributing
Contributions are welcome!

----
🧀