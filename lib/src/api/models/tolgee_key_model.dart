import 'package:tolgee/src/api/models/tolgee_translation_model.dart';

/// Represents translated key from Tolgee API
class TolgeeKeyModel {
  /// Key id
  final num keyId;

  /// Key name
  final String keyName;

  /// Translations for key
  final Map<String, TolgeeTranslationModel> translations;

  /// Creates new instance of [TolgeeKeyModel]
  const TolgeeKeyModel({
    required this.keyId,
    required this.keyName,
    required this.translations,
  });

  /// Creates new instance of [TolgeeKeyModel] from JSON
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
