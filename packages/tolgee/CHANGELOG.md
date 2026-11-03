## 1.2.1 (2026-10-27)
### Fixed
- Plurals created in Tolgee crashed the widget, and plural forms always followed English rules
- Language flags and saved non-ASCII translations were garbled
- Apps could start in the first language by tag (e.g. German) instead of the base language. On the web this happened every time
- A translation that isn't a valid ICU message crashed the widget. It now shows as raw text
- Projects with more than 20 languages lost all languages after the first 20
### Changed
- Numbers in plurals and parameters use the current language's format, e.g. `1.000` in German instead of `1,000`


## 1.2.0 (2024-10-25)
### New
- Override default boxDecoration using customBoxDecoration (#7)
### Fixed
- Handle properly platforms without localeName


## 1.1.0 (2024-10-06)
### New
- Language fetching improvements
- Added CDN Support
### Fixed
- Fixed setting custom language
- Fixed language code normalization


## 1.0.1 (2024-02-25)
### New
- Added initial files.
- Added `Tolgee` class to provide access to the Tolgee SDK methods.
- Added `TranslationText` and `TranslationWidget` widgets to display the translations in the app. The `TranslationWidget` widget provides a builder function to access the translations. The `TranslationText` widget is a simple wrapper around the `TranslationWidget` widget.
- Added `Tolgee.init` method to initialize the Tolgee SDK using either the dynamic or static mode. In the dynamic mode, the SDK fetches the translations from the Tolgee platform. In the static mode, the translations are loaded from the local assets.
- Added `Tolgee.highlightTolgeeWidgets` method to highlight the widgets that use the Tolgee SDK and add or modify the translation directly from the app.
