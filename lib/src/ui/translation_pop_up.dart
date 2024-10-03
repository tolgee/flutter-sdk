import 'package:flutter/material.dart';
import 'package:tolgee/src/api/models/tolgee_key_model.dart';
import 'package:tolgee/src/api/models/tolgee_translation_model.dart';
import 'package:tolgee/src/translations/tolgee_remote_translations.dart';
import 'package:tolgee/src/utils/tolgee_translation_model_extension.dart';

import 'translation_text_field.dart';

enum TranslationPopUpBackIcon { close, back }

extension TranslationPopUpBackIconExtension on TranslationPopUpBackIcon {
  IconData get icon {
    switch (this) {
      case TranslationPopUpBackIcon.close:
        return Icons.close;
      case TranslationPopUpBackIcon.back:
        return Icons.arrow_back;
    }
  }
}

class TranslationPopUp extends StatefulWidget {
  final TolgeeKeyModel translationModel;
  final TranslationPopUpBackIcon backIcon;

  const TranslationPopUp({
    Key? key,
    required this.translationModel,
    this.backIcon = TranslationPopUpBackIcon.back,
  }) : super(key: key);

  @override
  State createState() => _TranslationPopUpState();
}

class _TranslationPopUpState extends State<TranslationPopUp> {
  bool isLoading = false;

  _TranslationPopUpState();

  void updateTranslationForKey({
    required String languageCode,
    required String text,
  }) {
    widget.translationModel.translations[languageCode] = TolgeeTranslationModel(
      text: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final allProjectLanguages =
        TolgeeRemoteTranslations.instance.allProjectLanguages;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(widget.backIcon.icon),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Text(
              widget.translationModel.keyName,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: allProjectLanguages.length,
                itemBuilder: (context, index) {
                  final language = allProjectLanguages.values.elementAt(index);
                  final translation =
                      widget.translationModel.translations[language.tag];

                  return TranslationTextField(
                    text: translation?.text,
                    flagEmoji: language.flagEmoji,
                    languageCode: widget.translationModel
                        .languageCodeWithFlag(language: language),
                    onTextChange: (text) {
                      updateTranslationForKey(
                        languageCode: language.tag,
                        text: text,
                      );
                    },
                  );
                },
              ),
            ),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (!isLoading)
              FilledButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    await TolgeeRemoteTranslations.instance.updateTranslations(
                      key: widget.translationModel.keyName,
                      translations: widget.translationModel.translations.map(
                        (key, value) => MapEntry(key, value.text ?? ''),
                      ),
                    );
                    if (mounted) {
                      Navigator.of(context).pop(widget.translationModel);
                    }
                  },
                  child: const Text('Update translations')),
          ],
        ),
      ),
    );
  }
}
