import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:spotlight_connect/storage/key_value_store.dart';

class _PrefsKeyValueStore implements KeyValueStore {
  SharedPreferences? _prefs;

  Future<SharedPreferences> _ensurePrefs() async {
    if (_prefs != null) return _prefs!;
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      // On some runtimes (e.g. plugin not registered), this can throw.
      debugPrint('KeyValueStore: SharedPreferences init failed: $e');
      rethrow;
    }
    return _prefs!;
  }

  @override
  Future<String?> getString(String key) async {
    final prefs = await _ensurePrefs();
    return prefs.getString(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    final prefs = await _ensurePrefs();
    await prefs.setString(key, value);
  }

  @override
  Future<void> remove(String key) async {
    final prefs = await _ensurePrefs();
    await prefs.remove(key);
  }
}

KeyValueStore createKeyValueStoreImpl() => _PrefsKeyValueStore();
