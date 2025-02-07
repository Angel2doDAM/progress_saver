import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  Locale _chosenLocale = Locale('es');

  Locale get chosenLocale => _chosenLocale;

  LanguageProvider(this._prefs) {
    _chosenLocale = Locale(_prefs.getString('language') ?? 'es');
  }

  Future<void> changeLanguage(String language) async {
    _chosenLocale = Locale(language);
    await _prefs.setString('language', language);
    notifyListeners();
  }
}
