import 'dart:convert';

import 'package:tolgee/src/api/models/tolgee_key_model.dart';

class TolgeeTranslationsResponse {
  /// List of keys in Tolgee project
  final List<TolgeeKeyModel> keys;
  final int totalPages;
  final int currentPage;

  const TolgeeTranslationsResponse(
    this.keys,
    this.totalPages,
    this.currentPage,
  );

  static TolgeeTranslationsResponse fromJsonString(String jsonString) {
    final jsonBody = jsonDecode(jsonString);
    final keys = jsonBody['_embedded']['keys'] as List;
    final keysModels = keys.map((key) {
      try {
        return TolgeeKeyModel.fromJson(key);
      } catch (e) {
        return TolgeeKeyModel(keyId: key, keyName: key, translations: {});
      }
    }).toList();
    final page = jsonBody['page'];
    return TolgeeTranslationsResponse(
      keysModels,
      page['totalPages'],
      page['number'],
    );
  }
}
