import 'package:flutter/material.dart';
import 'package:tolgee_in_context/src/dialog.dart';

const _tolgeePink = Color(0xFFEC407A);
const _size = 48.0;
const _margin = 16.0;

/// Adds a draggable bubble to [overlay] that switches [editing] on and off.
void showTolgeeBubble(OverlayState overlay, ValueNotifier<bool> editing) {
  overlay.insert(OverlayEntry(builder: (_) => _TolgeeBubble(editing)));
}

class _TolgeeBubble extends StatefulWidget {
  final ValueNotifier<bool> editing;

  const _TolgeeBubble(this.editing);

  @override
  State<_TolgeeBubble> createState() => _TolgeeBubbleState();
}

class _TolgeeBubbleState extends State<_TolgeeBubble> {
  Offset? _position;

  Offset _clamp(Offset position, Size screen, EdgeInsets padding) {
    return Offset(
      position.dx.clamp(padding.left, screen.width - padding.right - _size),
      position.dy.clamp(padding.top, screen.height - padding.bottom - _size),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final position = _clamp(
      _position ??
          Offset(_margin, screen.height - padding.bottom - _margin - _size),
      screen,
      padding,
    );

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: ListenableBuilder(
        listenable: Listenable.merge([widget.editing, tolgeeDialogOpen]),
        builder: (context, _) {
          final active = widget.editing.value;
          return Visibility(
            visible: !tolgeeDialogOpen.value,
            child: Tooltip(
              message: active
                  ? 'Stop editing translations'
                  : 'Edit translations with Tolgee',
              child: GestureDetector(
                onTap: () => widget.editing.value = !active,
                onPanUpdate: (details) => setState(() {
                  _position = _clamp(position + details.delta, screen, padding);
                }),
                child: Material(
                  shape: const CircleBorder(
                    side: BorderSide(color: _tolgeePink, width: 2),
                  ),
                  elevation: 6,
                  color: active ? _tolgeePink : Colors.white,
                  child: SizedBox.square(
                    dimension: _size,
                    child: Icon(
                      Icons.translate,
                      color: active ? Colors.white : _tolgeePink,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
