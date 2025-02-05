import 'package:shared_preferences/shared_preferences.dart';

class Initializer {
  static late SharedPreferences prefs;

  static Future<void> startPreferences() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getKeys().length == 0) {
      await prefs.setBool("lightMode", true);
      await prefs.setString("lang", "es");
      await prefs.setDouble("textSize", 12);
    }
  }
}
