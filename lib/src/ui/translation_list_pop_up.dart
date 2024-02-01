import 'package:flutter/material.dart';
import 'package:tolgee/src/api/models/tolgee_key_model.dart';
import 'package:tolgee/src/api/tolgee_project_language.dart';
import 'package:tolgee/src/tolgee_sdk.dart';
import 'package:tolgee/src/ui/translation_pop_up.dart';
import 'package:tolgee/src/utils/tolgee_translation_model_extension.dart';

/// Pop-up widget that displays a list of [TolgeeKeyModel]s.
class TranslationListPopUp extends StatefulWidget {
  /// List of [TolgeeKeyModel]s to be displayed in the pop-up.
  final List<TolgeeKeyModel> _translationModels;

  /// Creates a new [TranslationListPopUp] widget.
  const TranslationListPopUp({
    super.key,
    required List<TolgeeKeyModel> translationModels,
  }) : _translationModels = translationModels;

  @override
  State createState() => _TranslationListPopUpState();
}

class _TranslationListPopUpState extends State<TranslationListPopUp> {
  @override
  Widget build(BuildContext context) {
    final allProjectLanguages = TolgeeSdk.instance.allProjectLanguages;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translations'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Material(
        child: ListView.builder(
          itemCount: widget._translationModels.length,
          itemBuilder: (context, index) {
            final model = widget._translationModels[index];
            return TranslationListTile(
              model: model,
              allProjectLanguages: allProjectLanguages,
              onTranslationChanged: (model) {
                setState(() {
                  widget._translationModels[index] = model;
                });
              },
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
