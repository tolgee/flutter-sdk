import 'package:flutter/material.dart';
import 'package:tolgee/tolgee/api/tolgee_key_model.dart';
import 'package:tolgee/tolgee/api/tolgee_translation_model.dart';
import 'package:tolgee/tolgee/tolgee_sdk.dart';

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
                itemCount: model.translations.length,
                itemBuilder: (context, index) {
                  final entry = model.translations.entries.elementAt(index);
                  return TranslationTextField(
                    text: entry.value.text,
                    languageCode: entry.key,
                    onTextChange: (text) {
                      updateTranslationForKey(
                        languageCode: entry.key,
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
                    await TolgeeSdk.updateTranslation(
                      key: model.keyName,
                      value: model.translations.values.first.text,
                      language: model.translations.keys.first,
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
  final String text;
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

  _TranslationTextFieldState(String initialText)
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
            onChanged: widget.onTextChange,
          ),
        ),
      ],
    );
  }
}
