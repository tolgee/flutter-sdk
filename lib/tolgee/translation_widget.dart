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
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: TolgeeSdk.instance,
        builder: (BuildContext context, Widget? child) {
          final isTranslationEnabled = TolgeeSdk.instance.isTranslationEnabled;
          final backgroundColor = isTranslationEnabled ? Colors.green : null;

          final onTap = isTranslationEnabled
              ? () {
                  setState(() {
                    TolgeeSdk.instance.toggleTranslationEnabled();
                  });
                }
              : () {
                  setState(() {
                    TolgeeSdk.instance.toggleTranslationEnabled();
                  });
                };

          return GestureDetector(
            onTap: onTap,
            child: Container(
              color: backgroundColor,
              child: widget.builder(
                context,
                TolgeeSdk.instance.translate,
              ),
            ),
          );
        });
  }
}
