/// Represents language in Tolgee project
class TolgeeProjectLanguage {
  /// Language name in English
  final String name;

  /// Language tag according to BCP 47 definition
  final String tag;

  /// Language name in original language
  final String? originalName;

  /// Language flag as UTF-8 emoji
  final String? flagEmoji;

  /// Whether this language is base language of the project
  final bool base;

  /// Creates new instance of [TolgeeProjectLanguage]
  const TolgeeProjectLanguage({
    required this.name,
    required this.tag,
    this.originalName,
    this.flagEmoji,
    required this.base,
  });

  @override
  int get hashCode =>
      name.hashCode ^
      tag.hashCode ^
      originalName.hashCode ^
      flagEmoji.hashCode ^
      base.hashCode;

  @override
  String toString() {
    return 'TolgeeProjectLanguage{name: $name, tag: $tag, originalName: $originalName, flagEmoji: $flagEmoji, base: $base}';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TolgeeProjectLanguage &&
            name == other.name &&
            tag == other.tag &&
            originalName == other.originalName &&
            flagEmoji == other.flagEmoji &&
            base == other.base);
  }
}
