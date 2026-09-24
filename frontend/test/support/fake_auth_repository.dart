import 'dart:async';

import 'package:wisp_mental_health/features/auth/data/auth_repository.dart';
import 'package:wisp_mental_health/features/auth/domain/app_user.dart';

/// In-memory [AuthRepository] for tests: no Firebase, fully deterministic.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AppUser? user, this.idToken = 'test-token'}) : _user = user;

  AppUser? _user;
  String? idToken;
  final _controller = StreamController<AppUser?>.broadcast();
  final List<String> calls = [];

  /// When set, the next sign-in / sign-up throws this instead of succeeding.
  Exception? failure;

  @override
  Stream<AppUser?> authStateChanges() => _controller.stream;

  @override
  AppUser? get currentUser => _user;

  @override
  Future<AppUser> signInWithEmailAndPassword(String email, String password) async {
    calls.add('signIn:$email');
    if (failure != null) throw failure!;
    return _setUser(AppUser(uid: 'uid-$email', email: email));
  }

  @override
  Future<AppUser> signUpWithEmailAndPassword(String email, String password, {String? displayName}) async {
    calls.add('signUp:$email:${displayName ?? ''}');
    if (failure != null) throw failure!;
    return _setUser(AppUser(uid: 'uid-$email', email: email, displayName: displayName));
  }

  @override
  Future<void> signOut() async {
    calls.add('signOut');
    _user = null;
    _controller.add(null);
  }

  @override
  Future<String?> getIdToken() async => _user == null ? null : idToken;

  AppUser _setUser(AppUser user) {
    _user = user;
    _controller.add(user);
    return user;
  }
}
