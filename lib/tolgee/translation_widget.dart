import 'package:flutter/material.dart';
import 'package:tolgee/tolgee/tolgee_sdk.dart';

typedef TranslationGetter = String Function(String key);
typedef TranslatedWidgetBuilder = Widget Function(
  BuildContext context,
  TranslationGetter translationGetter,
);

class TranslationWidget extends StatefulWidget {
  final TranslatedWidgetBuilder builder;
  const TranslationWidget({
    super.key,
    required this.builder,
  });

  @override
  _TranslationWidgetState createState() => _TranslationWidgetState();
}

class _TranslationWidgetState extends State<TranslationWidget> {
  bool isTranslationEnabled = TolgeeSdk.instance.isTranslationEnabled;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isTranslationEnabled ? Colors.red : null;

    final onTap = isTranslationEnabled
        ? () {
            setState(() {
              isTranslationEnabled = TolgeeSdk.instance
                  .mutateTranslationEnabled(!isTranslationEnabled);
            });
          }
        : () {
            setState(() {
              isTranslationEnabled = TolgeeSdk.instance
                  .mutateTranslationEnabled(!isTranslationEnabled);
            });
          };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: backgroundColor,
        child: widget.builder(
          context,
          (key) {
            return context.tolgee.translate(key);
          },
        ),
      ),
    );
  }
}
