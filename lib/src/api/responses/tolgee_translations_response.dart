import 'dart:convert';

import 'package:tolgee/src/api/models/tolgee_key_model.dart';

class TolgeeTranslationsResponse {
  /// List of languages in Tolgee project
  final List<TolgeeKeyModel> keys;

  const TolgeeTranslationsResponse(this.keys);

  static fromJsonString(String jsonString) {
    final jsonBody = jsonDecode(jsonString);
    final keys = jsonBody['_embedded']['keys'] as List;
    final keysModels = keys.map((key) {
      return TolgeeKeyModel.fromJson(key);
    });
    return TolgeeTranslationsResponse(keysModels.toList());
  }
}
