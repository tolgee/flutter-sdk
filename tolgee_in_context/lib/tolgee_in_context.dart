import 'package:flutter/foundation.dart';
import 'package:tolgee/tolgee.dart';
import 'package:tolgee/tolgee_editor.dart';
import 'package:tolgee_in_context/src/editor.dart';

class TolgeeInContext {
  const TolgeeInContext._();

  /// Turns on in-context editing in dev builds: Alt (Option) + click on the
  /// web and macOS, a Tolgee bubble on iOS and Android. Does nothing in
  /// release builds and on Windows and Linux.
  static void install() {
    // Lets the compiler drop the editor and the WebView code from release builds.
    if (kReleaseMode) return;
    final editor = InContextEditor();
    if (editor.mode == EditorMode.none) {
      TolgeeLogger.info('Tolgee in-context editing is not available here');
      return;
    }
    TolgeeEditor.install(editor);
  }
}
