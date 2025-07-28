import 'dart:convert';

import 'package:flutter/services.dart';

class LocalizationApi {
  static final LocalizationApi _singleton = LocalizationApi._internal();
  String languageCode = 'fr';

  factory LocalizationApi({String newLanguageCode = ''}) {
    if (newLanguageCode.isNotEmpty &&
        _localizedValues.containsKey(newLanguageCode)) {
      _singleton.languageCode = newLanguageCode;
    }
    return _singleton;
  }

  static final _localizedValues = <String, Map<String, String>>{
    'en': {},
    'fr': {},
  };

  LocalizationApi._internal();

  setLanguageCode(String newLanguageCode) {
    languageCode = newLanguageCode;
  }

  static List<String> languages() => ['fr']; // _localizedValues.keys.toList();

  Future<void> load(String locale) async {
    for (String languageLoop in languages()) {
      String recipiesString = await rootBundle
          .loadString("assets/localizations/$languageLoop.json");
      _localizedValues[languageLoop] =
          Map<String, String>.from(json.decode(recipiesString));
    }
  }

  Future<String> markdown(String key) async {
    return rootBundle
        .loadString('assets/localizations/markdowns/$languageCode/$key.md');
  }

  String tr(String key, [Map<String, String>? params]) {
    String text = _localizedValues[languageCode]![key] ?? key;

    if (params != null) {
      params.forEach((key, value) {
        text = text.replaceAll('{$key}', value);
      });
    }

    return text;
  }
}
