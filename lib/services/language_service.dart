import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// Service for managing the application's language settings.
abstract class ILanguageService {
  Future<Locale> getLocale();
  Future<void> setLocale(String languageCode);
}

/// Service for managing the application's language settings, using Hive for local storage.
class LanguageServiceHive implements ILanguageService {
  static const String _settingsBoxName = 'settings';
  static const String _localeKey = 'app_locale';

  /// Fetches the current application language from Hive.
  @override
  Future<Locale> getLocale() async {
    final box = await Hive.openBox(_settingsBoxName);
    final savedLocale = box.get(
      _localeKey,
      defaultValue: 'fr',
    ); // Default language: French
    return Locale(savedLocale);
  }

  /// Changes the application language and saves it to Hive.
  @override
  Future<void> setLocale(String languageCode) async {
    final box = await Hive.openBox(_settingsBoxName);
    await box.put(_localeKey, languageCode);
  }
}
