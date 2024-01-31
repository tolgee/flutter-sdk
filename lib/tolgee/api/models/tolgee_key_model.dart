import 'package:tolgee/tolgee/api/models/tolgee_translation_model.dart';

class TolgeeKeyModel {
  final num keyId;
  final String keyName;
  final Map<String, TolgeeTranslationModel> translations;

  const TolgeeKeyModel({
    required this.keyId,
    required this.keyName,
    required this.translations,
  });

  static TolgeeKeyModel fromJson(Map<String, dynamic> json) {
    final keyId = json['keyId'] as num;
    final keyName = json['keyName'] as String;
    final translations = json['translations'] as Map<String, dynamic>;
    final translationsModels = translations.map((key, value) {
      return MapEntry(key, TolgeeTranslationModel(text: value['text']));
    });
    return TolgeeKeyModel(
      keyId: keyId,
      keyName: keyName,
      translations: translationsModels,
    );
  }
// final String keyNamespaceId;
// final String? keyNamespace;
// final List<> keyTags;
// final String screenshotCount;
// final String screenshots;
// final String contextPresent;
}
