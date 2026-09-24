import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/api_client.dart';
import '../../../core/storage/local_first_repository.dart';
import '../../../core/storage/local_store.dart';
import '../../auth/data/firebase_auth_repository.dart';
import '../domain/crisis.dart';

/// Crisis resources and the record that the sheet was used.
///
/// Rendering the sheet reads local storage only. Logging the event is
/// async and retried — the help itself never waits on it.
class CrisisRepository extends LocalFirstRepository<CrisisEvent> {
  CrisisRepository({required super.store, required ApiClient api, required String uid, Uuid? uuid})
    : _api = api,
      _store = store,
      _uuid = uuid ?? const Uuid(),
      super(key: 'crisis.$uid.events');

  final ApiClient _api;
  final LocalStore _store;
  final Uuid _uuid;

  static const _lineKey = 'crisis.line';

  @override
  CrisisEvent fromJson(Map<String, dynamic> json) => CrisisEvent.fromJson(json);

  @override
  CrisisEvent withSync(CrisisEvent item, SyncState sync) => item.copyWith(sync: sync);

  @override
  int compare(CrisisEvent a, CrisisEvent b) => b.at.compareTo(a.at);

  @override
  Future<CrisisEvent> push(CrisisEvent item) async {
    await _api.postCrisisEvent(item);
    return item;
  }

  /// Never touches the network.
  Future<CrisisLine> line() async {
    final raw = await _store.read(_lineKey);
    return raw is Map ? CrisisLine.fromJson(Map<String, dynamic>.from(raw)) : CrisisLine.bundled;
  }

  /// Called at login so the cached copy is fresh long before it is needed.
  Future<void> cacheLine() async {
    try {
      await _store.write(_lineKey, (await _api.fetchCrisisLine()).toJson());
    } on ApiException catch (e) {
      debugPrint('Crisis line refresh skipped: ${e.message}');
    }
  }

  Future<void> record(CrisisAction action) =>
      save(CrisisEvent(id: _uuid.v4(), action: action, at: DateTime.now(), sync: SyncState.pendingCreate));
}

final crisisRepositoryProvider = Provider<CrisisRepository>((ref) {
  final uid = ref.watch(authStateChangesProvider).valueOrNull?.uid ?? 'anonymous';
  return CrisisRepository(store: ref.watch(localStoreProvider), api: ref.watch(apiClientProvider), uid: uid);
});

final crisisLineProvider = FutureProvider<CrisisLine>((ref) => ref.watch(crisisRepositoryProvider).line());
