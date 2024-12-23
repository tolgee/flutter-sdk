/// The configuration for the Tolgee client.
class TolgeeConfig {
  /// The API key for your Tolgee project.
  final String apiKey;

  /// The URL of your Tolgee server.
  final String apiUrl;

  // CDN URL
  final String? cdnUrl;

  // Should use CDN
  final bool useCDN;

  /// Creates a new TolgeeConfig instance.
  ///
  /// The [apiKey] and [apiUrl] parameters must not be null.
  const TolgeeConfig({
    required this.apiKey,
    required this.apiUrl,
    this.cdnUrl,
    this.useCDN = false,
  });

  @override
  int get hashCode => apiKey.hashCode ^ apiUrl.hashCode;

  @override
  String toString() {
    return 'TolgeeConfig(apiKey: $apiKey, apiUrl: $apiUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TolgeeConfig &&
            apiKey == other.apiKey &&
            apiUrl == other.apiUrl);
  }
}
