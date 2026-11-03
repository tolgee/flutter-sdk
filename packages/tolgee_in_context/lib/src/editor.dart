import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tolgee/tolgee_editor.dart';
import 'package:tolgee_in_context/src/bubble.dart';
import 'package:tolgee_in_context/src/dialog.dart';

/// How editing is switched on: Alt (Option) + click on platforms with a mouse
/// and keyboard, a bubble on touch platforms. `none` where the WebView plugin
/// doesn't run.
enum EditorMode { altClick, bubble, none }

@visibleForTesting
EditorMode editorModeFor({
  required bool isWeb,
  required TargetPlatform platform,
}) {
  if (isWeb) return EditorMode.altClick;
  return switch (platform) {
    TargetPlatform.macOS => EditorMode.altClick,
    TargetPlatform.iOS || TargetPlatform.android => EditorMode.bubble,
    _ => EditorMode.none,
  };
}

typedef DialogOpener = Future<void> Function(
  BuildContext context, {
  required TolgeeConfig config,
  required Set<String> keys,
  Rect? anchor,
});

// Same look as the tolgee-js highlighter: a 5 px red border around the element.
const _highlight = BoxDecoration(
  border: Border.fromBorderSide(BorderSide(
    color: Color(0xFFFF0000),
    width: 5,
    strokeAlign: BorderSide.strokeAlignOutside,
  )),
);

@visibleForTesting
class InContextEditor implements TolgeeEditor {
  final EditorMode mode;
  final DialogOpener open;

  /// Editing on for every widget, from the bubble or [toggle].
  final ValueNotifier<bool> editingEnabled = ValueNotifier(false);
  final ValueNotifier<bool> _altPressed = ValueNotifier(false);
  bool _keyHandlerAdded = false;
  OverlayState? _bubbleOverlay;

  InContextEditor({EditorMode? mode, this.open = showTolgeeDialog})
      : mode = mode ??
            editorModeFor(isWeb: kIsWeb, platform: defaultTargetPlatform);

  bool _onKeyEvent(KeyEvent _) {
    _altPressed.value = HardwareKeyboard.instance.isAltPressed;
    return false;
  }

  void _showBubbleOnce(BuildContext context) {
    if (_bubbleOverlay?.mounted ?? false) return;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    _bubbleOverlay = overlay;
    showTolgeeBubble(overlay, editingEnabled);
  }

  @override
  void toggle() => editingEnabled.value = !editingEnabled.value;

  @override
  Widget wrap(
    BuildContext context, {
    required Widget child,
    required Set<String> keys,
    BoxDecoration? decoration,
  }) {
    if (mode == EditorMode.altClick && !_keyHandlerAdded) {
      HardwareKeyboard.instance.addHandler(_onKeyEvent);
      _keyHandlerAdded = true;
    }
    return _Editable(
      editor: this,
      keys: keys,
      decoration: decoration ?? _highlight,
      child: child,
    );
  }
}

class _Editable extends StatefulWidget {
  final InContextEditor editor;
  final Set<String> keys;
  final BoxDecoration decoration;
  final Widget child;

  const _Editable({
    required this.editor,
    required this.keys,
    required this.decoration,
    required this.child,
  });

  @override
  State<_Editable> createState() => _EditableState();
}

class _EditableState extends State<_Editable> {
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    if (widget.editor.mode == EditorMode.bubble) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.editor._showBubbleOnce(context);
      });
    }
  }

  void _openDialog() {
    final config = tolgeeDevConfig;
    if (config == null) return;
    final box = context.findRenderObject() as RenderBox?;
    widget.editor.open(
      context,
      config: config,
      keys: widget.keys,
      anchor: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    final editor = widget.editor;
    return ListenableBuilder(
      listenable: Listenable.merge([editor.editingEnabled, editor._altPressed]),
      builder: (context, _) {
        final active = editor.editingEnabled.value ||
            (editor.mode == EditorMode.altClick &&
                editor._altPressed.value &&
                _hovered);
        final editable = GestureDetector(
          onTap: active ? _openDialog : null,
          child: Container(
            foregroundDecoration: active ? widget.decoration : null,
            child: AbsorbPointer(absorbing: active, child: widget.child),
          ),
        );
        if (editor.mode != EditorMode.altClick) return editable;
        return MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: editable,
        );
      },
    );
  }
}
