import 'package:flutter/foundation.dart';

import 'package:spotlight_connect/storage/key_value_store_prefs.dart'
    if (dart.library.html) 'package:spotlight_connect/storage/key_value_store_web.dart';

/// Minimal key/value storage used for local-only persistence.
///
/// - Web: uses `window.localStorage` (no plugins required).
/// - Mobile/Desktop: uses SharedPreferences.
abstract class KeyValueStore {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
}

KeyValueStore createKeyValueStore() => createKeyValueStoreImpl();

@visibleForTesting
KeyValueStore createKeyValueStoreForTests(KeyValueStore store) => store;
