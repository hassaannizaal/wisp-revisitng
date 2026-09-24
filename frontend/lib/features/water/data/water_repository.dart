import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';
import '../../../core/storage/local_first_repository.dart';
import '../../../core/storage/local_store.dart';
import '../../auth/data/firebase_auth_repository.dart';
import '../domain/water_day.dart';

/// Local-first hydration log. Spec: docs/screens/07-water.md
class WaterRepository extends LocalFirstRepository<WaterDay> {
  WaterRepository({required super.store, required ApiClient api, required String uid, DateTime Function()? now})
    : _api = api,
      _store = store,
      _uid = uid,
      _now = now ?? DateTime.now,
      super(key: 'water.$uid.days');

  final ApiClient _api;
  final LocalStore _store;
  final String _uid;
  final DateTime Function() _now;

  @override
  WaterDay fromJson(Map<String, dynamic> json) => WaterDay.fromJson(json);

  @override
  WaterDay withSync(WaterDay item, SyncState sync) => item.copyWith(sync: sync);

  @override
  int compare(WaterDay a, WaterDay b) => b.date.compareTo(a.date);

  // PUT is idempotent by (user, date), so create and update are the same call.
  @override
  Future<WaterDay> push(WaterDay item) => _api.putWater(item);

  DateTime get _today {
    final n = _now();
    return DateTime(n.year, n.month, n.day);
  }

  Future<WaterDay> today() async => await byId(WaterDay.formatDate(_today)) ?? WaterDay(date: _today, glasses: 0);

  /// The last seven days ending today, oldest first, zero-filled.
  Future<List<WaterDay>> week() async {
    final byDate = {for (final d in await all()) d.id: d};
    final today = _today;
    return [
      for (var i = 6; i >= 0; i--)
        () {
          // Calendar arithmetic, not Duration: across a DST change the latter
          // lands on 23:00 of the previous date.
          final date = DateTime(today.year, today.month, today.day - i);
          return byDate[WaterDay.formatDate(date)] ?? WaterDay(date: date, glasses: 0);
        }(),
    ];
  }

  /// Sets the running total for a day. Tapping glass *n* sets the total to
  /// *n*; tapping the last filled glass sets it to *n − 1* (see the screen).
  Future<WaterDay> setGlasses(DateTime date, int glasses) {
    final day = DateTime(date.year, date.month, date.day);
    return save(WaterDay(date: day, glasses: glasses.clamp(0, 99), sync: SyncState.pendingUpdate));
  }

  Future<WaterDay> logGlass({required int goal}) async {
    final current = await today();
    return setGlasses(current.date, (current.glasses + 1).clamp(0, goal));
  }

  Future<List<WaterDay>> refresh({Duration window = const Duration(days: 35)}) async {
    await sync();
    final today = _today;
    return merge(await _api.fetchWater(from: today.subtract(window), to: today));
  }

  // ---- Reminder preference -------------------------------------------------

  String get _remindersKey => 'water.$_uid.reminders';

  Future<bool> remindersEnabled() async => await _store.read(_remindersKey) == true;

  Future<void> setRemindersEnabled(bool enabled) => _store.write(_remindersKey, enabled);
}

final waterRepositoryProvider = Provider<WaterRepository>((ref) {
  final uid = ref.watch(authStateChangesProvider).valueOrNull?.uid ?? 'anonymous';
  return WaterRepository(store: ref.watch(localStoreProvider), api: ref.watch(apiClientProvider), uid: uid);
});
