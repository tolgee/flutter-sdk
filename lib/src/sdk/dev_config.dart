import 'package:flutter/foundation.dart';
import 'package:tolgee/src/api/tolgee_config.dart';
import 'package:tolgee/src/logger/logger.dart';

/// The API key and URL passed with `--dart-define`, outside release builds.
TolgeeConfig? devConfigFromEnvironment() {
  // The defines must be read only after this check: the compiler then drops
  // the key from release builds even when the build command passes it.
  if (kReleaseMode) return null;
  const apiKey = String.fromEnvironment('TOLGEE_API_KEY');
  const apiUrl = String.fromEnvironment('TOLGEE_API_URL');
  if (apiKey.isEmpty || apiUrl.isEmpty) return null;
  return const TolgeeConfig(apiUrl: apiUrl, apiKey: apiKey);
}

/// The Tolgee API connection for dev builds, or null when there is none.
TolgeeConfig? resolveDevConfig({
  String? apiKey,
  String? apiUrl,
  TolgeeConfig? fromEnvironment,
  required bool release,
}) {
  if (release) {
    if (apiKey != null && apiKey.isNotEmpty) {
      TolgeeLogger.warning(
        'Tolgee ignores apiKey in release builds. Remove it from the code '
        'and pass it with --dart-define=TOLGEE_API_KEY in dev builds.',
      );
    }
    return null;
  }
  final config =
      apiKey != null && apiKey.isNotEmpty && apiUrl != null && apiUrl.isNotEmpty
          ? TolgeeConfig(apiUrl: apiUrl, apiKey: apiKey)
          : fromEnvironment;
  if (config == null) return null;
  return TolgeeConfig(
    apiUrl: config.apiUrl
        .replaceFirst(RegExp(r'/+$'), '')
        .replaceFirst(RegExp(r'/v2$'), ''),
    apiKey: config.apiKey,
  );
}
