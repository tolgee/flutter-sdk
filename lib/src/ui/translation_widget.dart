import 'package:flutter/material.dart';
import 'package:intl/message_format.dart';
import 'package:tolgee/src/logger/logger.dart';
import 'package:tolgee/src/translations/tolgee_store.dart';

// intl's MessageFormat rejects whitespace between the last plural/select case and
// the closing brace, which is how Tolgee stores them: `{n, plural,\none {…}\n}`.
final _lineBreakBeforeClosingBrace = RegExp(r'\}\s*\n\s*\}');

@visibleForTesting
String formatMessage(String pattern, Map<String, Object> args, String locale) {
  final normalized = pattern.replaceAll(_lineBreakBeforeClosingBrace, '}}');
  // intl has no number data for some locales (e.g. eo, ckb, yi) and throws for them.
  for (final candidate in {locale, 'en'}) {
    try {
      return MessageFormat(normalized, locale: candidate).format(args);
    } catch (e) {
      TolgeeLogger.warning('Failed to format "$pattern" in $candidate: $e');
    }
  }
  return pattern;
}

typedef TranslationGetter = String Function(
  String key, [
  Map<String, Object>? args,
]);
typedef TranslatedWidgetBuilder = Widget Function(
  BuildContext context,
  TranslationGetter translationGetter,
);

class TranslationWidget extends StatefulWidget {
  final TranslatedWidgetBuilder builder;

  /// Enabled Custom BoxDecoration
  final BoxDecoration? enabledBoxDecoration;

  const TranslationWidget({
    super.key,
    required this.builder,
    this.enabledBoxDecoration,
  });

  @override
  State createState() => _TranslationWidgetState();
}

class _TranslationWidgetState extends State<TranslationWidget> {
  String _translate(String key, [Map<String, Object>? args]) {
    final result = TolgeeStore.instance.translate(key) ?? key;
    if (args == null) {
      return result;
    }
    return formatMessage(
      result,
      args,
      TolgeeStore.instance.currentLanguage ?? 'en',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TolgeeStore.instance,
      builder: (context, _) => widget.builder(context, _translate),
    );
  }
}
