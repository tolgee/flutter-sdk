import 'package:flutter/material.dart';
import 'package:tolgee/src/api/models/tolgee_key_model.dart';
import 'package:tolgee/src/api/tolgee_project_language.dart';
import 'package:tolgee/src/ui/translation_pop_up.dart';

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
    final supportProjectLanguages = allProjectLanguages.values.where(
      (element) => model.translations.keys.contains(element.tag),
    );

    final languageTags = supportProjectLanguages.map((e) => e.tag).toList();
    final languageFlags =
        supportProjectLanguages.map((e) => e.flagEmoji).toList();
    final languageTranslations = supportProjectLanguages
        .map((e) => model.translations[e.tag]?.text)
        .toList();

    return ListTile(
      title: Text(model.keyName),
      subtitle: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: languageTags
                .map(
                  (e) => Text(
                    e,
                  ),
                )
                .toList(),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: languageFlags
                .map(
                  (e) => Text(
                    e ?? '',
                    strutStyle: const StrutStyle(
                      forceStrutHeight: true,
                    ),
                  ),
                )
                .toList(),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: languageTranslations.map((e) => Text(e ?? '')).toList(),
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
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
