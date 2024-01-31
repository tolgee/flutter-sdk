import 'dart:convert';

import 'package:tolgee/tolgee/api/tolgee_project_language.dart';

/// Represents response from Tolgee API
class TolgeeAllProjectLanguagesResponse {
  /// List of languages in Tolgee project
  const TolgeeAllProjectLanguagesResponse({
    required this.languages,
  });

  /// List of languages in Tolgee project
  final List<TolgeeProjectLanguage> languages;

  /// Creates new instance of [TolgeeAllProjectLanguagesResponse] from JSON string
  static fromJsonString(String jsonString) {
    final jsonBody = jsonDecode(jsonString);
    final languages = jsonBody['_embedded']['languages'] as List;
    final languageModels = languages.map((key) {
      final name = key['name'] as String;
      final tag = key['tag'] as String;
      final originalName = key['originalName'] as String?;
      final flagEmoji = key['flagEmoji'] as String?;
      final base = key['base'] as bool;
      return TolgeeProjectLanguage(
        name: name,
        tag: tag,
        originalName: originalName,
        flagEmoji: flagEmoji,
        base: base,
      );
    });
    return TolgeeAllProjectLanguagesResponse(
      languages: languageModels.toList(),
    );
  }
}
