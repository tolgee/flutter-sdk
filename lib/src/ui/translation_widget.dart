import 'package:flutter/material.dart';
import 'package:tolgee/src/tolgee_change_notifier.dart';
import 'package:tolgee/src/ui/translation_list_pop_up.dart';

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
  State createState() => _TranslationWidgetState();
}

class _TranslationWidgetState extends State<TranslationWidget> {
  final Set<String> _keys = {};

  Widget _buildEnabledWidget(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return TranslationListPopUp(
                  translationModels: TolgeeChangeNotifier.instance
                      .translationForKeys(_keys)
                      .toList());
            },
          ),
        );
      },
      behavior: HitTestBehavior.deferToChild,
      child: AbsorbPointer(
        absorbing: true,
        child: widget.builder(
          context,
          (key) {
            _keys.add(key);
            return TolgeeChangeNotifier.instance.translate(key);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: TolgeeChangeNotifier.instance,
        builder: (BuildContext context, Widget? child) {
          final isTranslationEnabled =
              TolgeeChangeNotifier.instance.isTranslationEnabled;

          if (isTranslationEnabled) {
            return _buildEnabledWidget(context);
          } else {
            return widget.builder(
              context,
              (key) => key,
            );
          }
        });
  }
}
