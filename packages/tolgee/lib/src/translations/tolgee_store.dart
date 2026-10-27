import 'package:flutter/foundation.dart';
import 'package:tolgee/src/api/tolgee_config.dart';
import 'package:tolgee/src/api/tolgee_project_language.dart';
import 'package:tolgee/src/logger/logger.dart';
import 'package:tolgee/src/translations/language_tags.dart';
import 'package:tolgee/src/translations/tolgee_loader.dart';

/// The languages and texts the app currently uses.
class TolgeeStore extends ChangeNotifier {
  static TolgeeStore instance = TolgeeStore();

  TolgeeLoader? _loader;
  List<TolgeeProjectLanguage> _languages = [];
  String? _baseLanguage;
  String? _currentLanguage;
  final Translations _texts = {};
  int _languageRequest = 0;

  List<TolgeeProjectLanguage> get languages => _languages;

  String get baseLanguage =>
      _baseLanguage ?? (throw StateError('Call Tolgee.init first'));

  String? get currentLanguage => _currentLanguage;

  /// The Tolgee API connection while texts come from the API.
  TolgeeConfig? get devConfig {
    final loader = _loader;
    return loader != null && loader.usesApi ? loader.dev : null;
  }

  Future<void> init(
    TolgeeLoader loader, {
    required String requestedLanguage,
  }) async {
    _loader = loader;
    _languages = await loader.loadLanguages();
    final base = _languages.first.tag;
    final current = selectStartLanguage(
      _languages.map((l) => l.tag).toList(),
      requestedLanguage,
      base,
    );
    _texts
      ..clear()
      ..addAll(await loader.load({current, base}));
    _baseLanguage = base;
    _currentLanguage = current;
    notifyListeners();
  }

  Future<void> setLanguage(String requested) async {
    final tag = matchLanguage(_languages.map((l) => l.tag).toList(), requested);
    if (tag == null) {
      TolgeeLogger.warning('Language $requested is not in the project');
      return;
    }
    final request = ++_languageRequest;
    final missing = {tag, baseLanguage}.difference(_texts.keys.toSet());
    if (missing.isNotEmpty) _texts.addAll(await _loader!.load(missing));
    if (request != _languageRequest) return;
    _currentLanguage = tag;
    notifyListeners();
  }

  Future<void> reload() async {
    final loader = _loader;
    final current = _currentLanguage;
    if (loader == null || current == null) return;
    _texts.addAll(await loader.load({current, baseLanguage}));
    notifyListeners();
  }

  /// The text in the current language, else in the base language.
  String? translate(String key) {
    final current = _currentLanguage;
    if (current == null) return null;
    return _texts[current]?[key] ?? _texts[_baseLanguage]?[key];
  }
}
