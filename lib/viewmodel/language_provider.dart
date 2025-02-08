import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para gestionar el idioma general de la aplicacion
/// 
/// Hay 5 para elegir (comentame tu favorito)
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
