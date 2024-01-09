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
    return SafeArea(
      child: Column(
        children: [
          Row(
            children: [
              Text('Key name: '),
              Text(
                model.keyName,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Divider(),
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
          FilledButton(
              onPressed: () async {
                await TolgeeSdk.updateTranslation(
                  key: model.keyName,
                  value: model.translations.values.first.text,
                  language: model.translations.keys.first,
                );
                Navigator.of(context).pop(model);
              },
              child: Text('Save')),
        ],
      ),
    );
  }
}

class TranslationTextField extends StatefulWidget {
  final String text;
  final String languageCode;
  final void Function(String text) onTextChange;

  const TranslationTextField({
    Key? key,
    required this.text,
    required this.languageCode,
    required this.onTextChange,
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
