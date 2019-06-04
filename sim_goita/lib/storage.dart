library storage;
import 'dart:html';
import 'package:flutter_web/material.dart';

const KEY_TRIALS = "trials";

const DEFAULT_CONFIG = {
  KEY_TRIALS: 1000000
};

class Storage {
  static init() async {
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
  static setInt(String key, int value) {
    final db = window.localStorage;
    db[key] = value.toString();
  }
}
