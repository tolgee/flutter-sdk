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
