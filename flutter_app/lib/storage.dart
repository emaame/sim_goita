library storage;
import 'package:shared_preferences/shared_preferences.dart';

const KEY_TRIALS = "trials";

const DEFAULT_CONFIG = {
  KEY_TRIALS: 1000000
};

class Storage {
  static SharedPreferences prefs;
  static init() async {
    prefs = await SharedPreferences.getInstance();
  }
  static int getInt(String key) {
    try {
      final val = prefs.getInt(key);
      if (val != null) {
        return val;
      }
    } catch(Exception) {
    }
    return DEFAULT_CONFIG[key];
  }
  static setInt(String key, int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(key, value);
  }
}