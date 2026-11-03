import 'dart:ui';

import 'package:collection/collection.dart';

String _canonical(String tag) => tag.replaceAll('_', '-').toLowerCase();

String _languagePart(String tag) => _canonical(tag).split('-').first;

/// The project tag for [requested]: the exact tag, otherwise the longest
/// matching prefix (`zh-Hant-TW` → `zh-Hant` → `zh`), otherwise the first tag
/// of the same language (`en-GB` → `en-US`).
String? matchLanguage(List<String> tags, String requested) {
  var candidate = _canonical(requested);
  while (candidate.isNotEmpty) {
    final match = tags.firstWhereOrNull((tag) => _canonical(tag) == candidate);
    if (match != null) return match;
    final cut = candidate.lastIndexOf('-');
    candidate = cut == -1 ? '' : candidate.substring(0, cut);
  }
  return tags.firstWhereOrNull(
    (tag) => _languagePart(tag) == _languagePart(requested),
  );
}

String selectStartLanguage(List<String> tags, String requested, String base) {
  return matchLanguage(tags, requested) ?? base;
}

Locale localeFromTag(String tag) {
  final parts = tag.split(RegExp('[-_]'));
  String? script;
  String? country;
  for (final part in parts.skip(1)) {
    if (RegExp(r'^[A-Za-z]{4}$').hasMatch(part)) {
      script = part;
    } else if (RegExp(r'^([A-Za-z]{2}|\d{3})$').hasMatch(part)) {
      country = part;
    }
  }
  return Locale.fromSubtags(
    languageCode: parts.first,
    scriptCode: script,
    countryCode: country,
  );
}
