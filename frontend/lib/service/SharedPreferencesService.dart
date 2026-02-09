import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const FIRST_APP_START_KEY = "first-app-start";

  Future<void> setFirstAppStart() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(FIRST_APP_START_KEY, false);
  }

  Future<bool> isFirstAppStart() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(FIRST_APP_START_KEY) ?? true;
  }
}