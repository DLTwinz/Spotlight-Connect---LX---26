// Web-only implementation.

import 'package:web/web.dart';

import 'package:spotlight_connect/storage/key_value_store.dart';

class _WebKeyValueStore implements KeyValueStore {
  @override
  Future<String?> getString(String key) async =>
      window.localStorage.getItem(key);

  @override
  Future<void> setString(String key, String value) async {
    window.localStorage.setItem(key, value);
  }

  @override
  Future<void> remove(String key) async {
    window.localStorage.removeItem(key);
  }
}

KeyValueStore createKeyValueStoreImpl() => _WebKeyValueStore();
