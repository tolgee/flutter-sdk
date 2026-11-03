Future<void> openInHostPage({
  required String initJson,
  required String requestJson,
  required Future<void> Function(String message) onMessage,
}) {
  throw UnsupportedError('The host page dialog is only available on the web.');
}
