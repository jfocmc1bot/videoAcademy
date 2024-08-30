// lib/i18n/custom_localizations_delegate.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class CustomLocalizations {
  final Locale locale;

  static Map<String, dynamic>? _localizedValues;

  CustomLocalizations(this.locale);

  static CustomLocalizations? of(BuildContext context) {
    return Localizations.of<CustomLocalizations>(context, CustomLocalizations);
  }

  Future<bool> load() async {
    String jsonString;
    try {
      final assetPath = getAssetPathForLocale(locale);
      jsonString = await rootBundle.loadString(assetPath);
    } catch (e) {
      jsonString = await rootBundle.loadString('lib/i18n/local_en.json');
    }
    _localizedValues = json.decode(jsonString);
    _localizedValues!['language_code'] = locale.languageCode;
    return true;
  }

  static String getAssetPathForLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'pt':
        return 'lib/i18n/local_pt.json';
      case 'es':
        return 'lib/i18n/local_es.json';
      default:
        return 'lib/i18n/local_en.json';
    }
  }

  String translate(String key) {
    return _localizedValues?[key] ?? key;
  }

  static String getLocalizedValue(Map<String, dynamic> valueMap) {
    final String currentLanguageCode = _localizedValues!["language_code"];
    return valueMap[currentLanguageCode] ?? valueMap['en'] ?? '';
  }
}

class CustomLocalizationsDelegate
    extends LocalizationsDelegate<CustomLocalizations> {
  const CustomLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'pt', 'es'].contains(locale.languageCode);
  }

  @override
  Future<CustomLocalizations> load(Locale locale) async {
    CustomLocalizations localizations = CustomLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(CustomLocalizationsDelegate old) => false;
}
