library storage;
import 'dart:html';

const KEY_TRIALS = "trials";
const KEY_WORKERS = "workers";
final int HWConcurrency = window.navigator.hardwareConcurrency;

final Map<String, int> DEFAULT_CONFIG = {
  KEY_TRIALS: 1000000,
  KEY_WORKERS: (HWConcurrency > 0) ? HWConcurrency : 4
};

class Storage {
  static void init() async {
  }
  static int getInt(String key) {
    final db = window.localStorage;
    if (db != null && db.containsKey(key)) {
        final v = int.tryParse(db[key]);
        if (v != null) {
          return v;
        }
    }
    return DEFAULT_CONFIG[key];
  }
  static void setInt(String key, int value) {
    final db = window.localStorage;
    db[key] = value.toString();
  }
}
