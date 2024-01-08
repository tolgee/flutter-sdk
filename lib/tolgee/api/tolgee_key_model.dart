import 'package:tolgee/tolgee/api/tolgee_translation_model.dart';

class TolgeeKeyModel {
  // final num keyId;
  final String keyName;
  final Map<String, TolgeeTranslationModel> translations;

  const TolgeeKeyModel({
    // required this.keyId,
    required this.keyName,
    required this.translations,
  });
// final String keyNamespaceId;
// final String? keyNamespace;
// final List<> keyTags;
// final String screenshotCount;
// final String screenshots;
// final String contextPresent;
}
