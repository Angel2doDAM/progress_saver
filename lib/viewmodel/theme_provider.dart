import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isLightMode = true;

  bool get isLightMode => _isLightMode;

  ThemeProvider(this._prefs) {
    _isLightMode = _prefs.getBool("lightMode") ?? true;
  }

  Future<void> updateMode(bool isLight) async {
    _isLightMode = isLight;
    await _prefs.setBool("lightMode", isLight);
    notifyListeners();
  }
}
