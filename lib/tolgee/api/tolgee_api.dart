import 'package:http/http.dart';
import 'package:tolgee/tolgee/api/tolgee_config.dart';
import 'package:tolgee/tolgee/api/tolgee_translations_response.dart';

class TolgeeApi {
  const TolgeeApi._();

  static Future<TolgeeTranslationsResponse> getTranslations({
    required TolgeeConfig config,
  }) async {
    final response = await get(
        Uri.parse('https://app.tolgee.io/v2/projects/translations'),
        headers: {
          'X-Api-Key': config.apiKey,
        });

    final body = TolgeeTranslationsResponse.fromJsonString(response.body);
    return body;
  }
}
