import 'package:http/http.dart';
import 'package:tolgee/tolgee/api/tolgee_config.dart';
import 'package:tolgee/tolgee/api/tolgee_translations_response.dart';

class TolgeeApi {
  const TolgeeApi._();

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

  static Future<void> updateTranslation({
    required TolgeeConfig config,
    required String key,
    required String language,
    required String value,
  }) async {
    final response = await post(
      Uri.parse('${config.apiUrl}/projects/translations'),
      headers: {
        'X-Api-Key': config.apiKey,
      },
      body: {
        'key': key,
        'translations': {
          language: value,
        },
      },
    );
    print(response.body);
  }
}
