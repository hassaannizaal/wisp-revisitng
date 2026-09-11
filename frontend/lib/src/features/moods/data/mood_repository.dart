import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/api_client.dart';
import '../../../../core/storage/local_store.dart';
import '../../auth/data/firebase_auth_repository.dart';
import '../domain/mood.dart';

/// Local-first access to the user's check-ins.
///
/// Every write lands in [LocalStore] first and is pushed to the API behind
/// it. Reads come from the local copy, which [refresh] reconciles with the
/// server. The user never waits on the network to see their own data.
class MoodRepository {
  MoodRepository({
    required LocalStore store,
    required ApiClient api,
    required String uid,
    Uuid? uuid,
    DateTime Function()? now,
  }) : _store = store,
       _api = api,
       _uid = uid,
       _uuid = uuid ?? const Uuid(),
       _now = now ?? DateTime.now;

  final LocalStore _store;
  final ApiClient _api;
  final String _uid;
  final Uuid _uuid;
  final DateTime Function() _now;

  Future<void>? _syncInFlight;

  // Keyed per user so two accounts on one device never see each other's logs.
  String get _key => 'moods.$_uid.logs';

  /// Everything known locally, newest first.
  Future<List<MoodLog>> all() async {
    final raw = await _store.read(_key);
    if (raw is! List) return const [];
    final logs = raw.map((e) => MoodLog.fromJson(Map<String, dynamic>.from(e as Map))).toList()
      ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    return logs;
  }

  Future<MoodLog?> today() async {
    final now = _now();
    for (final log in await all()) {
      if (log.isOn(now)) return log;
    }
    return null;
  }

  /// Records a check-in immediately (spec: writes on selection, not on
  /// Continue). Returns as soon as the local write is done; the network push
  /// runs behind it and retries on the next [sync].
  Future<MoodLog> log(Mood mood, {DateTime? at}) async {
    final entry = MoodLog(id: _uuid.v4(), mood: mood, loggedAt: at ?? _now(), sync: SyncState.pendingCreate);
    await _upsert(entry);
    unawaited(sync());
    return entry;
  }

  /// Changes the mood on an existing log, e.g. a corrected tap on the same
  /// check-in. One check-in stays one log.
  Future<MoodLog> changeMood(String id, Mood mood) async {
    final current = (await all()).firstWhere((l) => l.id == id);
    final next = current.copyWith(
      mood: mood,
      // A log the server has never seen is still just a create.
      sync: current.sync == SyncState.pendingCreate ? SyncState.pendingCreate : SyncState.pendingUpdate,
    );
    await _upsert(next);
    unawaited(sync());
    return next;
  }

  /// Pushes every unsynced log. Stops at the first transport failure and
  /// leaves the rest pending for next time; other failures are logged and
  /// skipped so one bad record cannot block the queue.
  Future<void> sync() => _syncInFlight ??= _sync().whenComplete(() => _syncInFlight = null);

  Future<void> _sync() async {
    // A log can be edited while its request is in flight, which leaves it
    // pending again; a few passes settle that without spinning forever.
    for (var pass = 0; pass < 3; pass++) {
      final pending = (await all()).where((l) => !l.isSynced).toList();
      if (pending.isEmpty) return;
      var progressed = false;

      for (final log in pending) {
        try {
          var acknowledged = switch (log.sync) {
            SyncState.pendingCreate => await _api.postMood(log),
            SyncState.pendingUpdate => await _api.patchMood(log.id, log.mood),
            SyncState.synced => log,
          };
          // A replayed create answers with whatever the server already had;
          // the newer local edit wins.
          if (acknowledged.mood != log.mood) acknowledged = await _api.patchMood(log.id, log.mood);

          final latest = (await all()).firstWhere((l) => l.id == log.id, orElse: () => log);
          if (latest.mood == log.mood) {
            await _upsert(acknowledged.copyWith(sync: SyncState.synced));
          } else {
            await _upsert(latest.copyWith(sync: SyncState.pendingUpdate));
          }
          progressed = true;
        } on ApiException catch (e) {
          if (e.statusCode == null) return; // offline — try again later
          debugPrint('Mood sync skipped ${log.id}: ${e.message}');
        }
      }
      if (!progressed) return;
    }
  }

  /// Pulls the last [window] from the server and merges it in. Local edits
  /// that have not been acknowledged yet always win over the server copy.
  Future<List<MoodLog>> refresh({Duration window = const Duration(days: 30)}) async {
    await sync();
    final now = _now();
    final remote = await _api.fetchMoods(from: now.subtract(window), to: now.add(const Duration(days: 1)));
    final local = {for (final l in await all()) l.id: l};
    for (final log in remote) {
      final mine = local[log.id];
      if (mine == null || mine.isSynced) local[log.id] = log;
    }
    await _store.write(_key, local.values.map((l) => l.toJson()).toList());
    return all();
  }

  Future<void> _upsert(MoodLog entry) async {
    final logs = {for (final l in await all()) l.id: l}..[entry.id] = entry;
    await _store.write(_key, logs.values.map((l) => l.toJson()).toList());
  }
}

final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  final uid = ref.watch(authStateChangesProvider).valueOrNull?.uid ?? 'anonymous';
  return MoodRepository(store: ref.watch(localStoreProvider), api: ref.watch(apiClientProvider), uid: uid);
});
