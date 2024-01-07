import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart';

// jsonBody: {_embedded: {keys: [{keyId: 1041738072, keyName: title, keyNamespaceId: null, keyNamespace: null, keyTags: [], screenshotCount: 0, screenshots: [], contextPresent: false, translations: {en: {id: 1041723320, text: App Title, state: TRANSLATED, outdated: false, auto: false, mtProvider: null, commentCount: 0, unresolvedCommentCount: 0, fromTranslationMemory: false}}}]}, _links: {self: {href: https://app.tolgee.io/v2/projects/translations?page=0&size=20&sort=keyId,asc}}, page: {size: 20, totalElements: 1, totalPages: 1, number: 0}, selectedLanguages: [{id: 1029565004, name: English, tag: en, originalName: English, flagEmoji: 🇬🇧, base: true}], nextCursor: eyJrZXlJZCI6eyJkaXJlY3Rpb24iOiJBU0MiLCJ2YWx1ZSI6IjEwNDE3MzgwNzIifX0=}

class TolgeeKeyModel {
  // final num keyId;
  final String keyName;
  final Map<String, TolgeeTranslationModel> translations;

  const TolgeeKeyModel({
    // required this.keyId,
    required this.keyName,
    required this.translations,
  });
  // final String keyNamespaceId;
  // final String? keyNamespace;
  // final List<> keyTags;
  // final String screenshotCount;
  // final String screenshots;
  // final String contextPresent;
}

class TolgeeTranslationModel {
  // final String id;
  final String text;

  const TolgeeTranslationModel(this.text);
  // final String state;
  // final String outdated;
  // final String auto;
  // final String mtProvider;
  // final String commentCount;
  // final String unresolvedCommentCount;
  // final String fromTranslationMemory;
}

class TolgeeTranslationsResponse {
  final List<TolgeeKeyModel> keys;

  const TolgeeTranslationsResponse(this.keys);

  static fromJsonString(String jsonString) {
    final jsonBody = jsonDecode(jsonString);
    final keys = jsonBody['_embedded']['keys'] as List;
    final keysModels = keys.map((key) {
      final keyName = key['keyName'] as String;
      final translations = key['translations'] as Map<String, dynamic>;
      final translationsModels = translations.map((key, value) {
        return MapEntry(key, TolgeeTranslationModel(value['text']));
      });
      return TolgeeKeyModel(
        keyName: keyName,
        translations: translationsModels,
      );
    });
    return TolgeeTranslationsResponse(keysModels.toList());
  }
}

class TolgeeSdk {
  static const String _apiKey =
      'tgpak_gm4tqok7nzzw2ylgoy2ds4lwgjvwq43rgvqxa33wgfzxeolwge';

  String get currentLanguage => 'en';

  bool _isTranslationEnabled = true;
  bool get isTranslationEnabled => _isTranslationEnabled;
  bool mutateTranslationEnabled(bool value) {
    _isTranslationEnabled = value;
    return _isTranslationEnabled;
  }

  void setTranslationEnabled(bool value) {
    _isTranslationEnabled = value;
  }

  void toggleTranslationEnabled() {
    _isTranslationEnabled = !_isTranslationEnabled;
  }

  static final instance = TolgeeSdk._();
  TolgeeSdk._();

  static Future<void> init() async {
    final response = await get(
        Uri.parse('https://app.tolgee.io/v2/projects/translations'),
        headers: {
          'X-Api-Key': _apiKey,
        });

    final jsonBody = jsonDecode(response.body);

    print('TolgeeSdk initialized');
    final body = TolgeeTranslationsResponse.fromJsonString(response.body);
    print('jsonBody: $jsonBody');
  }
}

extension Tolgee on BuildContext {
  TolgeeSdk get tolgee => TolgeeSdk.instance;
  // TolgeeSdk get tolgee => watch<TolgeeSdk>();
}
