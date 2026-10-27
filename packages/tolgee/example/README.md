# What To Pack

A small packing list app in English, German, French and Polish, built with the Tolgee Flutter SDK
and `tolgee_in_context`.

## Run with the bundled files

```bash
flutter run
```

Texts come from `lib/tolgee/*.json`.

## Run with live data and in-context editing

Create `tolgee.env` in this folder (it's ignored by git) with an API key of your Tolgee project:

```
TOLGEE_API_KEY=tgpak_...
TOLGEE_API_URL=https://app.tolgee.io
```

The project needs the keys from `lib/tolgee/en.json` and the languages `en`, `de`, `fr`, `pl`.
You can import the four JSON files in Tolgee.

```bash
flutter run --dart-define-from-file=tolgee.env
```

On the web and macOS, hold Alt (Option) and click a text. On iOS and Android, tap the Tolgee
bubble, then a text.

## Release build

```bash
flutter build web --release
```

Release builds use only the bundled files, even when `--dart-define-from-file=tolgee.env` is
passed.
