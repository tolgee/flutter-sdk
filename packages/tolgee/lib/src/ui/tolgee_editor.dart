import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:tolgee/src/api/tolgee_config.dart';
import 'package:tolgee/src/translations/tolgee_store.dart';

/// An in-context editor that wraps every [TranslationWidget] in dev builds.
abstract class TolgeeEditor {
  static TolgeeEditor? _installed;

  static TolgeeEditor? get installed => _installed;

  /// Does nothing in release builds.
  static void install(TolgeeEditor editor) {
    if (kReleaseMode) return;
    _installed = editor;
  }

  @visibleForTesting
  static void uninstall() => _installed = null;

  /// Wraps the [child] of a translation widget that uses [keys].
  Widget wrap(
    BuildContext context, {
    required Widget child,
    required Set<String> keys,
    BoxDecoration? decoration,
  });

  /// Switches editing on or off.
  void toggle();
}

/// The Tolgee API connection while texts come from the API, else null.
TolgeeConfig? get tolgeeDevConfig => TolgeeStore.instance.devConfig;
