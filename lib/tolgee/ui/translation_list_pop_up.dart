import 'package:flutter/material.dart';
import 'package:tolgee/tolgee/api/tolgee_key_model.dart';

class TranslationListPopUp extends StatefulWidget {
  final List<TolgeeKeyModel> translationModels;

  const TranslationListPopUp({
    super.key,
    required this.translationModels,
  });

  @override
  _TranslationListPopUpState createState() => _TranslationListPopUpState();
}

class _TranslationListPopUpState extends State<TranslationListPopUp> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: widget.translationModels.length,
        itemBuilder: (context, index) {
          final model = widget.translationModels[index];
          return ListTile(
            title: Text(model.keyName),
            subtitle: Text(model.userFriendlyTranslations()),
          );
        },
      ),
    );
  }
}

extension TolgeeKeyModelExtension on TolgeeKeyModel {
  String userFriendlyTranslations() {
    if (this.translations.isEmpty) {
      return 'Not translated yet';
    }
    return this
        .translations
        .entries
        .map((e) => '${e.key}: ${e.value.text}')
        .join('\n');
  }
}
