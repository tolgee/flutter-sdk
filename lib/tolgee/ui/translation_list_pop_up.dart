import 'package:flutter/material.dart';
import 'package:tolgee/tolgee/api/tolgee_key_model.dart';
import 'package:tolgee/tolgee/ui/translation_pop_up.dart';

/// Pop-up widget that displays a list of [TolgeeKeyModel]s.
class TranslationListPopUp extends StatefulWidget {
  /// List of [TolgeeKeyModel]s to be displayed in the pop-up.
  final List<TolgeeKeyModel> translationModels;

  /// Creates a new [TranslationListPopUp] widget.
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Translations'),
      ),
      body: Material(
        child: ListView.builder(
          itemCount: widget.translationModels.length,
          itemBuilder: (context, index) {
            final model = widget.translationModels[index];
            return ListTile(
              title: Text(model.keyName),
              subtitle: Text(model.userFriendlyTranslations()),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return TranslationPopUp(
                        translationModel: model,
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
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
