import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/failures.dart';
import '../domain/app_user.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;

  FirebaseAuthRepository(this._auth);

  // Helper method to convert Firebase User to our custom AppUser
  AppUser? _mapFirebaseUser(User? firebaseUser) {
    if (firebaseUser == null) return null;
    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
    );
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  AppUser? get currentUser => _mapFirebaseUser(_auth.currentUser);

  @override
  Future<AppUser> signInWithEmailAndPassword(String email, String password) {
    return _guard(() async {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return _mapFirebaseUser(credential.user)!;
    });
  }

  @override
  Future<AppUser> signUpWithEmailAndPassword(String email, String password, {String? displayName}) {
    return _guard(() async {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      final user = credential.user;
      if (user != null && displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
        // The cached user still carries the old (null) name until it is reloaded.
        await user.reload();
      }

      return _mapFirebaseUser(_auth.currentUser ?? user)!;
    });
  }

  @override
  Future<void> signOut() => _auth.signOut();

  /// Firebase refreshes the ID token itself when it is close to expiry, so this
  /// is always safe to call right before a request.
  @override
  Future<String?> getIdToken() async {
    return await _auth.currentUser?.getIdToken();
  }

  /// Maps every failure to a [Failure] whose message is safe to show to users.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e, stackTrace) {
      // Raw exception text can contain internals; log it, show a generic message.
      debugPrint('Auth error: $e\n$stackTrace');
      throw const ServerFailure();
    }
  }

  Failure _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const InvalidCredentialsFailure();
      case 'email-already-in-use':
        return const EmailAlreadyInUseFailure();
      case 'weak-password':
        return const WeakPasswordFailure();
      case 'invalid-email':
        return const InvalidEmailFailure();
      case 'network-request-failed':
        return const NetworkFailure();
      case 'too-many-requests':
        return const AuthFailure('Too many attempts. Please wait a moment and try again');
      case 'user-disabled':
        return const AuthFailure('This account has been disabled');
      default:
        return AuthFailure(e.message ?? 'Authentication failed');
    }
  }
}

// -------------------------------------------------------------------
// THE RIVERPOD PROVIDERS
// -------------------------------------------------------------------

// Provider for the Firebase Auth instance
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(ref.watch(firebaseAuthProvider));
});

// Stream for Auth State
final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});
