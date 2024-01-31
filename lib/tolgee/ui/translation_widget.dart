import 'package:flutter/material.dart';
import 'package:tolgee/tolgee/tolgee_sdk.dart';
import 'package:tolgee/tolgee/ui/translation_list_pop_up.dart';

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
  List<String> _keys = [];
  Color? _backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: TolgeeSdk.instance,
        builder: (BuildContext context, Widget? child) {
          final isTranslationEnabled = TolgeeSdk.instance.isTranslationEnabled;
          final backgroundColor = isTranslationEnabled ? Colors.green : null;

          final onTap = isTranslationEnabled
              ? () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return TranslationListPopUp(
                            translationModels:
                                TolgeeSdk.instance.translationForKeys(_keys));
                      });
                }
              : null;

          return Container(
            color: backgroundColor,
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.deferToChild,
              child: AbsorbPointer(
                absorbing: true,
                child: widget.builder(
                  context,
                  (key) {
                    _keys.add(key);
                    return TolgeeSdk.instance.translate(key);
                  },
                ),
              ),
            ),
          );
        });
  }
}
