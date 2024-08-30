import 'dart:convert';

import 'package:http/http.dart';
import 'package:tolgee/src/api/requests/update_translations_request.dart';
import 'package:tolgee/src/api/responses/tolgee_all_project_languages_response.dart';
import 'package:tolgee/src/api/responses/tolgee_translations_response.dart';
import 'package:tolgee/src/api/responses/update_translations_response.dart';
import 'package:tolgee/src/api/tolgee_config.dart';
import 'package:tolgee/src/api/tolgee_project_language.dart';

import 'models/tolgee_key_model.dart';

/// Represents Tolgee API
class TolgeeApi {
  const TolgeeApi._();

  /// Gets all languages in Tolgee project
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

  /// Gets all translations in Tolgee project
  static Future<TolgeeTranslationsResponse> getTranslations({
    required TolgeeConfig config,
  }) async {
    int currentPage = 0;
    List<TolgeeKeyModel> translations = [];

    while (true) {
      final response = await get(
          Uri.parse(
              '${config.apiUrl}/projects/translations?size=50&page=$currentPage'),
          headers: {
            'X-Api-Key':
                config.apiKey, // add the API key to the headers of the request
          });

      final body = TolgeeTranslationsResponse.fromJsonString(response.body);

      translations.addAll(body.keys);
      currentPage++;

      final jsonBody = jsonDecode(response.body);
      if (currentPage > jsonBody['page']['totalPages'] - 1) {
        break;
      }
    }

    return TolgeeTranslationsResponse(translations);
  }

  /// Updates translations in Tolgee project
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
