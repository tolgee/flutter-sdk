/// Update translations request model.
class UpdateTranslationsRequest {
  /// A map of translations to update.
  final Map<String, String> translations;

  /// The key to update translations for.
  final String key;

  /// Creates a new update translations request instance.
  const UpdateTranslationsRequest({
    required this.translations,
    required this.key,
  });

  /// Creates a new update translations request instance from JSON data.
  Map<String, dynamic> toJson() => {
        'key': key,
        'translations': translations,
        'languagesToReturn': translations.keys.toList(),
      };
}
