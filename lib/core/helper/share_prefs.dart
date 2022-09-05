import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPref {
  SharedPreferences? preferences;
  static SharedPref? _instance;

  SharedPref(this.preferences);

  static Future init({isTest = false}) async {
    if (_instance == null) {
      _instance =
          SharedPref(isTest ? null : await SharedPreferences.getInstance());
    }
  }

  static SharedPref getInstance() {
    if (_instance == null) {
      throw ("SharedPreferenceUtils must call init first");
    }
    return _instance!;
  }

  read(String key) async {
    print(preferences?.getString(key));
    return json.decode(preferences?.getString(key) ?? "[]");
  }

  save(String key, value) async {
    preferences?.setString(key, json.encode(value));
  }

  remove(String key) async {
    preferences?.remove(key);
  }
}
