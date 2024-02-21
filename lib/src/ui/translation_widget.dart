import 'package:flutter/material.dart';
import 'package:intl/message_format.dart';
import 'package:tolgee/src/translations/tolgee_translation_strategy.dart';
import 'package:tolgee/src/ui/translation_list_pop_up.dart';
import 'package:tolgee/src/ui/translation_pop_up.dart';

typedef TranslationGetter = String Function(
  String key, [
  Map<String, Object>? args,
]);
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
    const opacity = 0.2;
    final kGradientBoxDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.center,
        end: const Alignment(-0.2, -0.5),
        stops: const [0.0, 0.5, 0.5, 1],
        colors: [
          Colors.orangeAccent.withOpacity(opacity),
          Colors.orangeAccent.withOpacity(opacity),
          Colors.black.withOpacity(opacity),
          Colors.black.withOpacity(opacity),
        ],
        tileMode: TileMode.repeated,
      ),
    );

    return GestureDetector(
      onTap: () {
        if (_keys.isEmpty) {
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              if (_keys.length == 1) {
                return TranslationPopUp(
                  backIcon: TranslationPopUpBackIcon.close,
                  translationModel: TolgeeTranslationsStrategy.instance
                      .translationForKeys(_keys)
                      .toList()
                      .first,
                );
              } else {
                return TranslationListPopUp(
                    translationModels: TolgeeTranslationsStrategy.instance
                        .translationForKeys(_keys)
                        .toList());
              }
            },
          ),
        );
      },
      behavior: HitTestBehavior.deferToChild,
      child: Container(
        decoration: kGradientBoxDecoration,
        child: AbsorbPointer(
          absorbing: true,
          child: widget.builder(
            context,
            (key, [args]) {
              _keys.add(key);
              return _translate(key, args);
            },
          ),
        ),
      ),
    );
  }

  String _translate(String key, [Map<String, Object>? args]) {
    if (args == null) {
      return TolgeeTranslationsStrategy.instance.translate(key);
    }
    return MessageFormat(
      TolgeeTranslationsStrategy.instance.translate(key),
    ).format(args);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: TolgeeTranslationsStrategy.instance,
        builder: (BuildContext context, Widget? child) {
          final isTranslationEnabled =
              TolgeeTranslationsStrategy.instance.isTranslationEnabled;

          if (isTranslationEnabled) {
            return _buildEnabledWidget(context);
          } else {
            return widget.builder(
              context,
              (key, [args]) => _translate(key, args),
            );
          }
        });
  }
}
