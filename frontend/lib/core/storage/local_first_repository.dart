import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/api_client.dart';
import 'local_store.dart';

/// Whether the server has this exact version of a record yet.
enum SyncState {
  /// Server has it, and it matches.
  synced,

  /// Written on the device, never sent — needs a create.
  pendingCreate,

  /// Exists on the server, but was changed since — needs an update.
  pendingUpdate,
}

/// A record that can live locally before the server knows about it.
abstract class Syncable {
  String get id;
  SyncState get sync;
  Map<String, dynamic> toJson();
}

/// Local-first storage shared by every module.
///
/// Every write lands in [LocalStore] first and is pushed to the API behind
/// it; reads come from the local copy. The user never waits on the network
/// to see their own data, and a write made with no signal syncs later.
///
/// Subclasses provide the (de)serialisation and the single network push for
/// one record; this class owns ordering, the queue, in-flight edits, and the
/// merge rule (an unacknowledged local edit always beats the server copy).
abstract class LocalFirstRepository<T extends Syncable> {
  LocalFirstRepository({required LocalStore store, required String key}) : _store = store, _key = key;

  final LocalStore _store;
  final String _key;
  Future<void>? _syncInFlight;

  T fromJson(Map<String, dynamic> json);
  T withSync(T item, SyncState sync);

  /// Sends one record and returns the server's acknowledged copy.
  Future<T> push(T item);

  /// Sort order for [all]; newest first by default is up to the subclass.
  int compare(T a, T b);

  Future<List<T>> all() async {
    final raw = await _store.read(_key);
    if (raw is! List) return const [];
    return raw.map((e) => fromJson(Map<String, dynamic>.from(e as Map))).toList()..sort(compare);
  }

  Future<T?> byId(String id) async {
    for (final item in await all()) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// Writes locally and kicks off a background push.
  @protected
  Future<T> save(T item) async {
    await upsert(item);
    unawaited(sync());
    return item;
  }

  @protected
  Future<void> upsert(T item) async {
    final items = {for (final i in await all()) i.id: i}..[item.id] = item;
    await _writeAll(items.values);
  }

  /// Pushes every unsynced record. Stops at the first transport failure and
  /// leaves the rest for next time; other failures are logged and skipped so
  /// one bad record cannot block the queue.
  Future<void> sync() => _syncInFlight ??= _sync().whenComplete(() => _syncInFlight = null);

  Future<void> _sync() async {
    // A record can be edited while its request is in flight, which leaves it
    // pending again; a few passes settle that without spinning forever.
    for (var pass = 0; pass < 3; pass++) {
      final pending = (await all()).where((i) => i.sync != SyncState.synced).toList();
      if (pending.isEmpty) return;
      var progressed = false;

      for (final item in pending) {
        try {
          final acknowledged = await push(item);
          final latest = await byId(item.id) ?? item;
          if (_sameContent(latest, item)) {
            await upsert(withSync(acknowledged, SyncState.synced));
          } else {
            await upsert(withSync(latest, SyncState.pendingUpdate));
          }
          progressed = true;
        } on ApiException catch (e) {
          if (e.statusCode == null) return; // offline — try again later
          debugPrint('Sync skipped $_key/${item.id}: ${e.message}');
        }
      }
      if (!progressed) return;
    }
  }

  /// Merges server records in. Unacknowledged local edits always win.
  @protected
  Future<List<T>> merge(List<T> remote) async {
    final local = {for (final i in await all()) i.id: i};
    for (final item in remote) {
      final mine = local[item.id];
      if (mine == null || mine.sync == SyncState.synced) local[item.id] = withSync(item, SyncState.synced);
    }
    await _writeAll(local.values);
    return all();
  }

  Future<void> _writeAll(Iterable<T> items) => _store.write(_key, items.map((i) => i.toJson()).toList());

  static bool _sameContent(Syncable a, Syncable b) {
    final x = Map.of(a.toJson())..remove('sync');
    final y = Map.of(b.toJson())..remove('sync');
    return mapEquals(x, y);
  }
}
