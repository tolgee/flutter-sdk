import 'dart:convert';

import 'package:http/http.dart';
import 'package:tolgee/src/api/requests/update_translations_request.dart';
import 'package:tolgee/src/api/responses/tolgee_all_project_languages_response.dart';
import 'package:tolgee/src/api/responses/tolgee_translations_response.dart';
import 'package:tolgee/src/api/responses/update_translations_response.dart';
import 'package:tolgee/src/api/tolgee_config.dart';
import 'package:tolgee/src/api/tolgee_project_language.dart';

import 'models/tolgee_key_model.dart';

class TolgeeApi {
  const TolgeeApi._();

  static Future<List<TolgeeProjectLanguage>> getAllProjectLanguages({
    required TolgeeConfig config,
  }) async {
    final response = await get(
      Uri.parse('${config.apiUrl}/projects/languages'),
      headers: {
        'X-Api-Key': config.apiKey,
      },
    );

    final body =
        TolgeeAllProjectLanguagesResponse.fromJsonString(response.body);
    return body.languages;
  }

  static Future<TolgeeTranslationsResponse> getTranslations({
    required TolgeeConfig config,
  }) async {
    final response = await get(
        Uri.parse('${config.apiUrl}/projects/translations'),
        headers: {
          'X-Api-Key': config.apiKey,
        });

    final body = TolgeeTranslationsResponse.fromJsonString(response.body);
    return body;
  }

  static Future<TolgeeKeyModel> updateTranslations({
    required TolgeeConfig config,
    required UpdateTranslationsRequest request,
  }) async {
    final body = jsonEncode(request.toJson());

    final response = await post(
      Uri.parse('${config.apiUrl}/projects/translations'),
      headers: {
        'X-Api-Key': config.apiKey,
        'Content-Type': 'application/json',
      },
      body: body,
    );
    final updateTranslationsResponse =
        UpdateTranslationsResponse.fromJsonString(
      response.body,
    );
    return updateTranslationsResponse.model;
  }
}
