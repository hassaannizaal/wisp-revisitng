import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  AppUser? get currentUser;
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();
}

class MockAuthRepository implements AuthRepository {
  AppUser? _currentUser;
  
  @override
  Stream<AppUser?> authStateChanges() => Stream.value(_currentUser);

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'test@test.com' && password == 'password') {
      _currentUser = AppUser(uid: '123', email: email, displayName: 'Test User');
    } else {
      throw Exception('Invalid email or password');
    }
  }

  @override
  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = AppUser(uid: '123', email: email, displayName: 'New User');
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});
