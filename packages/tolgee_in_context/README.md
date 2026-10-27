# Tolgee in-context editing for Flutter

Edit [Tolgee](https://tolgee.io) translations right in your running Flutter app, in dev builds.
Click a text, and the Tolgee editor opens with all its languages, plural forms and tags. A save
shows up in the app at once.

It works with the [`tolgee`](https://pub.dev/packages/tolgee) package and uses the same editor
as Tolgee's JavaScript SDKs.

## Install

```yaml
dependencies:
  tolgee: ^2.0.0
  tolgee_in_context: ^2.0.0
```

```dart
import 'package:tolgee/tolgee.dart';
import 'package:tolgee_in_context/tolgee_in_context.dart';

Future<void> main() async {
  TolgeeInContext.install();
  await Tolgee.init();
  runApp(const MyApp());
}
```

Run the app with your API key, as described in the
[`tolgee` README](https://pub.dev/packages/tolgee#dev-builds-the-tolgee-api):

```bash
flutter run --dart-define-from-file=tolgee.env
```

Editing works only while texts come from the Tolgee API. In release builds,
`TolgeeInContext.install()` does nothing.

## How to edit

| Platform | How |
|---|---|
| Web, macOS | Hold Alt (Option) and move the mouse over a text to see a red border. Alt + click opens the editor. |
| iOS, Android | Tap the Tolgee bubble (bottom left, you can drag it) to switch editing on. Every text gets a red border, and a tap opens the editor. Tap the bubble again to stop. |
| Windows, Linux | Not available, the app works as usual. |

The builder of a `TranslationWidget` must not return `Expanded`, `Flexible`, `Positioned` or a
sliver, because the editor wraps what it returns. Put those around the `TranslationWidget`.

If a widget shows several keys, a menu next to it lets you pick one. `Tolgee.highlightTolgeeWidgets()`
switches editing on and off from code.

## Limits

- The editor is loaded from [jsdelivr](https://www.jsdelivr.com) at a fixed version, so dev builds
  need to reach `cdn.jsdelivr.net` as well as your Tolgee server. If it can't be loaded, the
  editor doesn't open and the reason is logged. If it takes longer than 20 seconds, the editor
  closes again.
- On iOS, typing in the editor works with the on-screen keyboard. A hardware keyboard (for
  example a Mac keyboard in the simulator) doesn't type into it.
- On macOS, the editor covers the whole app window while it's open.
- On Android, the app needs the `android.permission.INTERNET` permission. On macOS, it needs the
  `com.apple.security.network.client` entitlement.
