import 'package:flutter/material.dart';
import 'package:tolgee/tolgee.dart';

class TranslationText extends Text {
  final String text;

  const TranslationText(this.text, {super.key}) : super(text);

  @override
  Widget build(BuildContext context) {
    return TranslationWidget(
      builder: (context, tr) => Text(
        tr(text),
      ),
    );
  }
}
