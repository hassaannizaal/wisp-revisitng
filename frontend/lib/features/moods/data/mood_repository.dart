import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/api_client.dart';
import '../../../core/storage/local_first_repository.dart';
import '../../../core/storage/local_store.dart';
import '../../auth/data/firebase_auth_repository.dart';
import '../domain/mood.dart';

/// Local-first access to the user's check-ins. Spec: docs/screens/05-mood-check-in.md
class MoodRepository extends LocalFirstRepository<MoodLog> {
  MoodRepository({
    required super.store,
    required ApiClient api,
    required String uid,
    Uuid? uuid,
    DateTime Function()? now,
  }) : _api = api,
       _uuid = uuid ?? const Uuid(),
       _now = now ?? DateTime.now,
       // Keyed per user so two accounts on one device never see each other's logs.
       super(key: 'moods.$uid.logs');

  final ApiClient _api;
  final Uuid _uuid;
  final DateTime Function() _now;

  @override
  MoodLog fromJson(Map<String, dynamic> json) => MoodLog.fromJson(json);

  @override
  MoodLog withSync(MoodLog item, SyncState sync) => item.copyWith(sync: sync);

  @override
  int compare(MoodLog a, MoodLog b) => b.loggedAt.compareTo(a.loggedAt);

  @override
  Future<MoodLog> push(MoodLog item) async {
    var acknowledged = switch (item.sync) {
      SyncState.pendingCreate => await _api.postMood(item),
      SyncState.pendingUpdate => await _api.patchMood(item.id, item.mood),
      SyncState.synced => item,
    };
    // A replayed create answers with whatever the server already had; the
    // newer local edit wins.
    if (acknowledged.mood != item.mood) acknowledged = await _api.patchMood(item.id, item.mood);
    return acknowledged;
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
  Future<MoodLog> log(Mood mood, {DateTime? at}) =>
      save(MoodLog(id: _uuid.v4(), mood: mood, loggedAt: at ?? _now(), sync: SyncState.pendingCreate));

  /// Changes the mood on an existing log, e.g. a corrected tap on the same
  /// check-in. One check-in stays one log.
  Future<MoodLog> changeMood(String id, Mood mood) async {
    final current = (await byId(id))!;
    return save(
      current.copyWith(
        mood: mood,
        // A log the server has never seen is still just a create.
        sync: current.sync == SyncState.pendingCreate ? SyncState.pendingCreate : SyncState.pendingUpdate,
      ),
    );
  }

  /// Pulls the last [window] from the server and merges it in.
  Future<List<MoodLog>> refresh({Duration window = const Duration(days: 30)}) async {
    await sync();
    final now = _now();
    return merge(await _api.fetchMoods(from: now.subtract(window), to: now.add(const Duration(days: 1))));
  }

  /// Consecutive days with a check-in, counting back from today (or from
  /// yesterday if today has none yet). `unbroken` is true when today counts.
  Future<({int days, bool unbroken})> streak() async {
    final logged = <DateTime>{for (final l in await all()) DateTime(l.loggedAt.year, l.loggedAt.month, l.loggedAt.day)};
    final today = _now();
    var day = DateTime(today.year, today.month, today.day);
    final unbroken = logged.contains(day);
    if (!unbroken) day = _dayBefore(day);
    var days = 0;
    while (logged.contains(day)) {
      days++;
      day = _dayBefore(day);
    }
    return (days: days, unbroken: unbroken);
  }

  // Calendar arithmetic, not `subtract(Duration(days: 1))`: across a DST
  // change that lands on 23:00 or 01:00 and misses the midnight keys.
  static DateTime _dayBefore(DateTime day) => DateTime(day.year, day.month, day.day - 1);
}

final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  final uid = ref.watch(authStateChangesProvider).valueOrNull?.uid ?? 'anonymous';
  return MoodRepository(store: ref.watch(localStoreProvider), api: ref.watch(apiClientProvider), uid: uid);
});
