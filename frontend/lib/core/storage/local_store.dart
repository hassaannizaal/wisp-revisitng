import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Small on-device key/value store for JSON documents.
///
/// This is the "local first" layer: every feature writes here before it talks
/// to the network, so the app works with no signal and the user never waits
/// on a round trip to see their own data. `shared_preferences` is deliberate —
/// it is the lightest store that works on every platform including web; a
/// real database can replace [PrefsLocalStore] behind this interface when the
/// data outgrows it.
abstract class LocalStore {
  Future<Object?> read(String key);
  Future<void> write(String key, Object? value);
  Future<void> remove(String key);
}

class PrefsLocalStore implements LocalStore {
  PrefsLocalStore(this._prefs);

  final SharedPreferencesAsync _prefs;

  @override
  Future<Object?> read(String key) async {
    final raw = await _prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } on FormatException {
      // A corrupt entry is dropped rather than crashing every read after it.
      await _prefs.remove(key);
      return null;
    }
  }

  @override
  Future<void> write(String key, Object? value) => _prefs.setString(key, jsonEncode(value));

  @override
  Future<void> remove(String key) => _prefs.remove(key);
}

/// In-memory store for tests and previews.
class MemoryLocalStore implements LocalStore {
  final Map<String, String> _data = {};

  @override
  Future<Object?> read(String key) async {
    final raw = _data[key];
    return raw == null ? null : jsonDecode(raw);
  }

  @override
  Future<void> write(String key, Object? value) async => _data[key] = jsonEncode(value);

  @override
  Future<void> remove(String key) async => _data.remove(key);
}

final localStoreProvider = Provider<LocalStore>((ref) => PrefsLocalStore(SharedPreferencesAsync()));
