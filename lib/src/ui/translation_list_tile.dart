import 'package:flutter/material.dart';
import 'package:tolgee/src/api/models/tolgee_key_model.dart';
import 'package:tolgee/src/api/tolgee_project_language.dart';
import 'package:tolgee/src/ui/translation_pop_up.dart';
import 'package:tolgee/src/utils/tolgee_translation_model_extension.dart';

class TranslationListTile extends StatelessWidget {
  final TolgeeKeyModel model;
  final Map<String, TolgeeProjectLanguage> allProjectLanguages;
  final ValueChanged<TolgeeKeyModel> onTranslationChanged;

  const TranslationListTile({
    Key? key,
    required this.model,
    required this.allProjectLanguages,
    required this.onTranslationChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(model.keyName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(model.userFriendlyTranslations(languages: allProjectLanguages)),
        ],
      ),
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return TranslationPopUp(
                translationModel: model,
              );
            },
          ),
        ) as TolgeeKeyModel?;
        if (result != null) {
          onTranslationChanged(result);
        }
      },
    );
  }
}
