# Migrating from 1.x to 2.0

## In-context editing moved to `tolgee_in_context`

The 1.x popups (opened with `Tolgee.highlightTolgeeWidgets()` and the striped highlight) are
removed. Editing now uses the Tolgee web editor:

```yaml
dependencies:
  tolgee_in_context: ^2.0.0
```

```dart
TolgeeInContext.install();
await Tolgee.init();
```

See the [`tolgee_in_context` README](../tolgee_in_context/README.md) for how to edit on each
platform.

## Pass the API key with `--dart-define`, not in code

1.x apps passed the key to `Tolgee.init`:

```dart
await Tolgee.init(
  apiKey: const String.fromEnvironment('TOLGEE_API_KEY'),
  apiUrl: const String.fromEnvironment('TOLGEE_API_URL'),
);
```

In 2.0, remove both parameters and call `Tolgee.init()`. Tolgee reads `TOLGEE_API_KEY` and
`TOLGEE_API_URL` from `--dart-define` itself, and only outside release builds, so a release build
can't contain the key.

`apiKey` and `apiUrl` still work in debug and profile builds, but are ignored in release builds.
A key passed in code is still compiled into the app, so don't keep it there.

`TOLGEE_API_URL` works with or without `/v2` at the end.

## Release builds don't call the Tolgee API

Use the CDN, bundled files or both. See
[Where texts come from](../README.md#where-texts-come-from).

The CDN no longer needs an API key. 1.x read the language list from the API even with
`useCDN: true`. 2.0 takes it from the bundled file names or from `availableLanguages`.

## Language tags are kept whole

1.x cut tags to the language part (`pt-BR` → `pt`). 2.0 keeps the project's tags, so bundled
files are named after them (`pt-BR.json`), and `supportedLocales` has `Locale('pt', 'BR')`.

## Smaller changes

- `Tolgee.init` completes with the texts loaded, so the first frame already shows them.
- A text missing in the current language comes from the base language.
- New: `Tolgee.languages` (names and flags from the API), `Tolgee.reload()`, and
  `TolgeeProjectLanguage.locale`.
- Dart 3.3 or newer is required.
