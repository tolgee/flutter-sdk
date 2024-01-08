import 'dart:convert';

import 'package:tolgee/tolgee/api/tolgee_key_model.dart';
import 'package:tolgee/tolgee/api/tolgee_translation_model.dart';

class TolgeeTranslationsResponse {
  final List<TolgeeKeyModel> keys;

  const TolgeeTranslationsResponse(this.keys);

  static fromJsonString(String jsonString) {
    final jsonBody = jsonDecode(jsonString);
    final keys = jsonBody['_embedded']['keys'] as List;
    final keysModels = keys.map((key) {
      final keyName = key['keyName'] as String;
      final translations = key['translations'] as Map<String, dynamic>;
      final translationsModels = translations.map((key, value) {
        return MapEntry(key, TolgeeTranslationModel(value['text']));
      });
      return TolgeeKeyModel(
        keyName: keyName,
        translations: translationsModels,
      );
    });
    return TolgeeTranslationsResponse(keysModels.toList());
  }
}
