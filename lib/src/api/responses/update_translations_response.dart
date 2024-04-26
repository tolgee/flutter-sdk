import 'dart:convert';

import 'package:tolgee/src/api/models/tolgee_key_model.dart';

/// Represents response from Tolgee API
class UpdateTranslationsResponse {
  /// Updated key
  final TolgeeKeyModel model;

  /// Creates new instance of [UpdateTranslationsResponse]
  const UpdateTranslationsResponse._(this.model);

  /// Creates new instance of [UpdateTranslationsResponse] from JSON
  static fromJsonString(String jsonString) {
    final jsonBody = jsonDecode(jsonString);
    final model = TolgeeKeyModel.fromJson(jsonBody);
    return UpdateTranslationsResponse._(model);
  }
}
