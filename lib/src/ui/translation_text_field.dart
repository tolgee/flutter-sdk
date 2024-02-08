import 'package:flutter/material.dart';

class TranslationTextField extends StatefulWidget {
  final String? text;
  final String languageCode;
  final String? flagEmoji;
  final void Function(String text) onTextChange;

  const TranslationTextField({
    Key? key,
    required this.text,
    required this.languageCode,
    required this.onTextChange,
    this.flagEmoji,
  }) : super(key: key);

  @override
  State createState() => _TranslationTextFieldState();
}

class _TranslationTextFieldState extends State<TranslationTextField> {
  final TextEditingController _controller;

  _TranslationTextFieldState() : _controller = TextEditingController();

  @override
  void initState() {
    _controller.text = widget.text ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'No translation yet',
                prefix: Text(widget.flagEmoji ?? ''),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
              ),
              onChanged: widget.onTextChange,
            ),
          ),
        ),
      ],
    );
  }
}
