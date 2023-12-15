import 'package:flutter/widgets.dart';

class TranslationModel {
  final String key;
  final String value;

  TranslationModel({
    required this.key,
    required this.value,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TranslationModel &&
        other.key == key &&
        other.value == value;
  }

  @override
  String toString() {
    return 'TranslationModel(key: $key, value: $value)';
  }

  @override
  int get hashCode => key.hashCode ^ value.hashCode;
}

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
  List<TranslationModel> translations = [
    TranslationModel(key: 'key', value: 'value'),
  ];

  bool isTranslationEnabled = false;

  @override
  Widget build(BuildContext context) {
    if (isTranslationEnabled) {
      return Container(
        child: widget.builder(
          context,
          (key) {
            return translations
                .firstWhere(
                  (element) => element.key == key,
                  orElse: () => TranslationModel(key: key, value: key),
                )
                .value;
          },
        ),
      );
    }
    return Text('data');
  }
}
