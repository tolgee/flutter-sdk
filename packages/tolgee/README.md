# Tolgee Flutter SDK 🐁

A Flutter SDK for the [Tolgee](https://tolgee.io) localization platform.

- In dev builds, texts come live from your Tolgee project, and with
  [`tolgee_in_context`](https://pub.dev/packages/tolgee_in_context) you can edit them right in the app.
- In release builds, texts come from the Tolgee CDN, from files bundled with the app, or both.
  Release builds never contain your API key.

Moving from 1.x? See the [migration guide](doc/migrating-to-2.md).

## Install

```yaml
dependencies:
  tolgee: ^2.0.0
```

## Usage

Initialize Tolgee before `runApp`:

```dart
import 'package:flutter/material.dart';
import 'package:tolgee/tolgee.dart';

Future<void> main() async {
  await Tolgee.init();
  runApp(const MyApp());
}
```

Pass the Tolgee delegates and locales to your app:

```dart
MaterialApp(
  localizationsDelegates: Tolgee.localizationDelegates,
  supportedLocales: Tolgee.supportedLocales,
  locale: Tolgee.currentLocale,
  home: const HomePage(),
);
```

Show texts with `TranslationText` or `TranslationWidget`:

```dart
const TranslationText('app-title');

TranslationWidget(
  builder: (context, tr) => Text(tr('items-count', {'count': items.length})),
);
```

Texts use the ICU message format, including plurals. Change the language with
`Tolgee.setCurrentLocale(locale)`, then rebuild the widget that creates `MaterialApp` (for example
with `setState`), so it picks up the new `locale`. `Tolgee.languages` lists the project
languages, with names and flags when the texts come from the Tolgee API.

The builder of `TranslationWidget` must return a normal widget, not `Expanded`, `Flexible`,
`Positioned` or a sliver. In dev builds with `tolgee_in_context`, the editor wraps what the
builder returns. Put `Expanded` around the `TranslationWidget` instead.

## Where texts come from

### Dev builds: the Tolgee API

Create an API key in your Tolgee project (Project settings → API keys) and put it in a file that
is not committed, for example `tolgee.env`:

```
TOLGEE_API_KEY=tgpak_...
TOLGEE_API_URL=https://app.tolgee.io
```

Run the app with it:

```bash
flutter run --dart-define-from-file=tolgee.env
```

Tolgee reads these values only in debug and profile builds. If the build command passes them to a
release build, the compiler leaves the key out.

If the API can't be reached, Tolgee logs a warning and uses the CDN or the bundled files.

### Release builds: CDN and bundled files

- **CDN.** Create a content delivery in your Tolgee project with the JSON format, then:
  ```dart
  await Tolgee.init(useCDN: true, cdnUrl: 'https://cdn.tolg.ee/<your-cdn-id>');
  ```
  Tolgee loads `<cdnUrl>/<language>.json` for the current and the base language.
- **Bundled files.** [Export](https://tolgee.io/platform/projects_and_organizations/export) your
  translations as JSON, one file per language (`en.json`, `pt-BR.json`), into `lib/tolgee/` and
  add the folder to your assets:
  ```yaml
  flutter:
    assets:
      - lib/tolgee/
  ```
- **Both.** With `fallbackOnFail: true`, a failed CDN request falls back to the bundled files.
  Without it, the app shows default values or keys for that language.

Without the API, Tolgee takes the language list from the bundled file names. If you use the CDN
without bundled files, list the languages yourself:

```dart
await Tolgee.init(
  useCDN: true,
  cdnUrl: 'https://cdn.tolg.ee/<your-cdn-id>',
  availableLanguages: ['en', 'de', 'pt-BR'],
  baseLanguage: 'en',
);
```

With no languages at all (no API, no bundled files, no `availableLanguages`), `Tolgee.init`
throws a `StateError`.

The base language defaults to `en` if it's available, otherwise to the first language.

## Languages and fallbacks

- The app starts in the device language if the project has it. Otherwise it tries a shorter tag
  (`pt-PT` → `pt`), then the base language.
- A text missing in the current language comes from the base language, then from the default
  value (`Tolgee.translate(key: 'a', defaultValue: 'A')`), then the key name is shown.

## Logging

Tolgee prints warnings and errors in debug builds, for example when the API or the CDN can't be
reached. Change the level with `TolgeeLogger.setLogLevel(LogLevel.debug)`, or send the messages
elsewhere with `TolgeeLogger.setLog(...)`.

## In-context editing

Add [`tolgee_in_context`](https://pub.dev/packages/tolgee_in_context) to edit texts in the running app in dev builds.

## Example

The [example app](example) is a small packing list in English, German, French and Polish.

## Contributing

Contributions are welcome!

----
🧀
