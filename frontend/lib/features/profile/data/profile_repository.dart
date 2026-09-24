import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_client.dart';
import '../../../core/storage/local_store.dart';
import '../../auth/data/firebase_auth_repository.dart';
import '../../auth/domain/app_user.dart';
import '../domain/profile.dart';

/// The user's own profile: cached on the device, pushed to `/api/me`.
class ProfileRepository {
  ProfileRepository({required LocalStore store, required ApiClient api, required AppUser user})
    : _store = store,
      _api = api,
      _user = user;

  final LocalStore _store;
  final ApiClient _api;
  final AppUser _user;

  String get _key => 'profile.${_user.uid}';

  /// The cached profile, or sensible defaults on a fresh device.
  Future<Profile> local() async {
    final raw = await _store.read(_key);
    final cached = raw is Map ? Profile.fromJson(Map<String, dynamic>.from(raw)) : null;
    return (cached ?? Profile(uid: _user.uid, email: _user.email)).copyWith(
      // Auth is the source of truth for the name; the cache can lag behind it.
      displayName: _user.displayName ?? cached?.displayName,
    );
  }

  /// Pushes a pending local change, then takes the server's copy.
  Future<Profile> refresh() async {
    final mine = await local();
    if (mine.pending) {
      await _api.updateProfile(accountMode: mine.accountMode, waterGoalGlasses: mine.waterGoalGlasses);
    }
    final remote = await _api.fetchProfile();
    final merged = mine.copyWith(
      accountMode: remote.accountMode,
      waterGoalGlasses: remote.waterGoalGlasses,
      organizationName: remote.organizationName,
      pending: false,
    );
    await _store.write(_key, merged.toJson());
    return merged;
  }

  /// Writes locally first; the server is told behind it and retried by the
  /// next [refresh] if that fails.
  Future<Profile> update({AccountMode? accountMode, int? waterGoalGlasses}) async {
    final next = (await local()).copyWith(accountMode: accountMode, waterGoalGlasses: waterGoalGlasses, pending: true);
    await _store.write(_key, next.toJson());
    unawaited(_push(next));
    return next;
  }

  Future<void> _push(Profile profile) async {
    try {
      await _api.updateProfile(accountMode: profile.accountMode, waterGoalGlasses: profile.waterGoalGlasses);
      final current = await local();
      if (current == profile) await _store.write(_key, current.copyWith(pending: false).toJson());
    } on ApiException catch (e) {
      debugPrint('Profile push deferred: ${e.message}');
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final user = ref.watch(authStateChangesProvider).valueOrNull ?? const AppUser(uid: 'anonymous', email: '');
  return ProfileRepository(store: ref.watch(localStoreProvider), api: ref.watch(apiClientProvider), user: user);
});

/// Cached profile first, then the server's copy when it answers.
class ProfileController extends AsyncNotifier<Profile> {
  @override
  Future<Profile> build() async {
    final repo = ref.watch(profileRepositoryProvider);
    final cached = await repo.local();
    unawaited(_refreshQuietly(repo));
    return cached;
  }

  Future<void> _refreshQuietly(ProfileRepository repo) async {
    try {
      final fresh = await repo.refresh();
      if (state.valueOrNull != fresh) state = AsyncData(fresh);
    } on ApiException catch (e) {
      debugPrint('Profile refresh skipped: ${e.message}');
    }
  }

  Future<void> setAccountMode(AccountMode mode) async {
    state = AsyncData(await ref.read(profileRepositoryProvider).update(accountMode: mode));
  }

  Future<void> setWaterGoal(int glasses) async {
    state = AsyncData(await ref.read(profileRepositoryProvider).update(waterGoalGlasses: glasses));
  }
}

final profileProvider = AsyncNotifierProvider<ProfileController, Profile>(ProfileController.new);
