import 'dart:convert';

import 'package:tolgee/tolgee/api/models/tolgee_key_model.dart';

class UpdateTranslationsResponse {
  final TolgeeKeyModel model;

  const UpdateTranslationsResponse._(this.model);

  static fromJsonString(String jsonString) {
    final jsonBody = jsonDecode(jsonString);
    final model = TolgeeKeyModel.fromJson(jsonBody);
    return UpdateTranslationsResponse._(model);
  }
}
