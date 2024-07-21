import 'package:flutter/cupertino.dart';
import 'package:tolgee/src/api/models/tolgee_key_model.dart';
import 'package:tolgee/src/api/tolgee_project_language.dart';
import 'package:tolgee/src/translations/tolgee_remote_translations.dart';
import 'package:tolgee/src/translations/tolgee_static_translations.dart';
import 'package:tolgee/src/translations/tolgee_translations.dart';

class TolgeeTranslationsStrategy extends ChangeNotifier
    implements TolgeeTranslations {
  static Future<void> initRemote({
    required String apiKey,
    required String apiUrl,
  }) async {
    await TolgeeRemoteTranslations.init(apiKey: apiKey, apiUrl: apiUrl);
    TolgeeTranslationsStrategy.instance._tolgeeTranslations =
        TolgeeRemoteTranslations.instance;

    TolgeeRemoteTranslations.instance.addListener(() {
      TolgeeTranslationsStrategy.instance.notifyListeners();
    });
  }

  static Future<void> initStatic() async {
    await TolgeeStaticTranslations.init();
    TolgeeTranslationsStrategy.instance._tolgeeTranslations =
        TolgeeStaticTranslations.instance;
  }

  TolgeeTranslations? _tolgeeTranslations;
  static final TolgeeTranslationsStrategy instance =
      TolgeeTranslationsStrategy._();

  TolgeeTranslationsStrategy._();

  @override
  Map<String, TolgeeProjectLanguage> get allProjectLanguages =>
      _tolgeeTranslations?.allProjectLanguages ?? {};

  @override
  Locale? get currentLanguage => _tolgeeTranslations?.currentLanguage;

  @override
  void setCurrentLanguage(Locale locale) {
    _tolgeeTranslations?.setCurrentLanguage(locale);
  }

  @override
  void toggleTranslationEnabled() {
    _tolgeeTranslations?.toggleTranslationEnabled();
  }

  @override
  String? translate(String key) {
    return _tolgeeTranslations?.translate(key);
  }

  @override
  Set<TolgeeKeyModel> translationForKeys(Set<String> keys) {
    return _tolgeeTranslations?.translationForKeys(keys) ?? {};
  }

  @override
  void updateKeyModel({
    required TolgeeKeyModel updatedKeyModel,
  }) {
    _tolgeeTranslations?.updateKeyModel(updatedKeyModel: updatedKeyModel);
  }

  @override
  Future<void> updateTranslations({
    required String key,
    required Map<String, String> translations,
  }) {
    return _tolgeeTranslations?.updateTranslations(
            key: key, translations: translations) ??
        Future.value();
  }

  @override
  bool get isTranslationEnabled =>
      _tolgeeTranslations?.isTranslationEnabled ?? false;
}
