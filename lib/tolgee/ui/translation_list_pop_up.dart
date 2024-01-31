import 'package:flutter/material.dart';
import 'package:tolgee/tolgee/api/tolgee_key_model.dart';
import 'package:tolgee/tolgee/api/tolgee_project_language.dart';
import 'package:tolgee/tolgee/tolgee_sdk.dart';
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
    final allProjectLanguages = TolgeeSdk.instance.allProjectLanguages;
    return Scaffold(
      appBar: AppBar(
        title: Text('Translations'),
      ),
      body: Material(
        child: ListView.builder(
          itemCount: widget.translationModels.length,
          itemBuilder: (context, index) {
            final model = widget.translationModels[index];
            return TranslationListTile(
              model: model,
              allProjectLanguages: allProjectLanguages,
            );
          },
        ),
      ),
    );
  }
}

class TranslationListTile extends StatelessWidget {
  final TolgeeKeyModel model;
  final Map<String, TolgeeProjectLanguage> allProjectLanguages;

  const TranslationListTile({
    Key? key,
    required this.model,
    required this.allProjectLanguages,
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
  }
}

extension TolgeeKeyModelExtension on TolgeeKeyModel {
  String userFriendlyTranslations({
    required Map<String, TolgeeProjectLanguage> languages,
  }) {
    return languages.entries.map((language) {
      final flagEmoji = languages[language.key]?.flagEmoji;
      String flag = '';
      if (flagEmoji != null) {
        flag = ' $flagEmoji';
      }

      final translation = this.translations[language.key];
      String translationText = 'Not translated yet';

      if (translation != null) {
        translationText = translation.text;
      }

      return '${language.value.tag}$flag $translationText';
    }).join('\n');
  }
}
