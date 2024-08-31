import 'dart:convert';

import 'package:http/http.dart';
import 'package:tolgee/src/api/models/tolgee_translation_model.dart';
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
    required String currentLanguage,
  }) async {
    // Check if should use CDN
    if (config.useCDN) {
      return getTranslationsFromCDN(
        config: config,
        currentLanguage: currentLanguage,
      );
    }

    List<TolgeeKeyModel> allTranslations = [];
    int currentPage = 0;
    int totalPages = 1; // Initialize to 1 to enter the loop

    while (currentPage < totalPages) {
      final response = await get(
        Uri.parse(
          '${config.apiUrl}/projects/translations?page=$currentPage&size=20&sort=keyId,asc&languages=$currentLanguage',
        ),
        headers: {
          'X-Api-Key': config.apiKey,
        },
      );

      if (response.statusCode == 200) {
        final utf8DecodedBody = utf8.decode(response.bodyBytes);

        final body = TolgeeTranslationsResponse.fromJsonString(utf8DecodedBody);
        allTranslations.addAll(body.keys);
        totalPages = body.totalPages;
        currentPage++;
      }
    }

    return TolgeeTranslationsResponse(allTranslations, totalPages, currentPage);
  }

  static Future<TolgeeTranslationsResponse> getTranslationsFromCDN({
    required TolgeeConfig config,
    required String currentLanguage,
  }) async {
    final response = await get(
      Uri.parse(
        '${config.cdnUrl}/$currentLanguage.json',
      ),
    );

    List<TolgeeKeyModel> tolgeeKeyModels = [];

    if (response.statusCode == 200) {
      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      final jsonResponse = jsonDecode(utf8DecodedBody) as Map<String, dynamic>;

      // Transform JSON response into a list of TolgeeKeyModel instances
      tolgeeKeyModels = jsonResponse.entries.map((entry) {
        return TolgeeKeyModel(
          keyId: entry.key.hashCode, // Using hashCode as a unique identifier
          keyName: entry.key,
          translations: {
            currentLanguage: TolgeeTranslationModel(text: entry.value),
          },
        );
      }).toList();
    }

    return TolgeeTranslationsResponse(tolgeeKeyModels, 1, 0);
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
