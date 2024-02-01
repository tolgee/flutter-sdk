import 'package:flutter/material.dart';
import 'package:tolgee/src/api/models/tolgee_key_model.dart';
import 'package:tolgee/src/api/models/tolgee_translation_model.dart';
import 'package:tolgee/src/tolgee_sdk.dart';
import 'package:tolgee/src/utils/tolgee_translation_model_extension.dart';

class TranslationPopUp extends StatefulWidget {
  final TolgeeKeyModel translationModel;

  const TranslationPopUp({
    Key? key,
    required this.translationModel,
  }) : super(key: key);

  @override
  _TranslationPopUpState createState() =>
      _TranslationPopUpState(translationModel);
}

class _TranslationPopUpState extends State<TranslationPopUp> {
  TolgeeKeyModel model;
  bool isLoading = false;

  _TranslationPopUpState(this.model);

  void updateTranslationForKey({
    required String languageCode,
    required String text,
  }) {
    model.translations[languageCode] = TolgeeTranslationModel(
      text: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final allProjectLanguages = TolgeeSdk.instance.allProjectLanguages;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              model.keyName,
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
                  final translation = model.translations[language.tag];

                  return TranslationTextField(
                    text: translation?.text,
                    languageCode:
                        model.languageCodeWithFlag(language: language),
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
              Center(
                child: CircularProgressIndicator(),
              ),
            if (!isLoading)
              FilledButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    await TolgeeSdk.updateTranslations(
                      key: model.keyName,
                      translations: model.translations.map(
                        (key, value) => MapEntry(key, value.text),
                      ),
                    );
                    Navigator.of(context).pop(model);
                  },
                  child: Text('Update translations')),
          ],
        ),
      ),
    );
  }
}

class TranslationTextField extends StatefulWidget {
  final String? text;
  final String languageCode;
  final String? flagEmoji;
  final void Function(String text) onTextChange;

  const TranslationTextField({
    Key? key,
    required this.text,
    required this.languageCode,
    required this.onTextChange,
    this.flagEmoji,
  }) : super(key: key);

  @override
  _TranslationTextFieldState createState() => _TranslationTextFieldState(text);
}

class _TranslationTextFieldState extends State<TranslationTextField> {
  final TextEditingController _controller;

  _TranslationTextFieldState(String? initialText)
      : _controller = TextEditingController(text: initialText);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.languageCode),
        VerticalDivider(),
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'No translation yet',
            ),
            onChanged: widget.onTextChange,
          ),
        ),
      ],
    );
  }
}
