import 'package:flutter/material.dart';
import 'package:tolgee/src/api/models/tolgee_key_model.dart';
import 'package:tolgee/src/api/tolgee_project_language.dart';

abstract class TolgeeTranslations {
  Map<String, TolgeeProjectLanguage> get allProjectLanguages;

  Locale? get currentLanguage;

  void setCurrentLanguage(Locale locale);

  void toggleTranslationEnabled();

  void updateKeyModel({
    required TolgeeKeyModel updatedKeyModel,
  });

  String translate(String key);

  Set<TolgeeKeyModel> translationForKeys(Set<String> keys);

  bool get isTranslationEnabled;

  Future<void> updateTranslations({
    required String key,
    required Map<String, String> translations,
  });
}
