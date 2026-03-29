import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../domain/app_user.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final SecureStorageService _secureStorage;

  FirebaseAuthRepository(this._auth, this._secureStorage);

  // Helper method to convert Firebase User to our custom AppUser
  AppUser? _mapFirebaseUser(User? firebaseUser) {
    if (firebaseUser == null) return null;
    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
    );
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  AppUser? get currentUser => _mapFirebaseUser(_auth.currentUser);

  @override
  Future<AppUser> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Store token securely if needed (optional for Firebase, but good practice here)
      final token = await credential.user?.getIdToken();
      if (token != null) {
        await _secureStorage.saveToken(token);
      }
      
      return _mapFirebaseUser(credential.user)!;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<AppUser> signUpWithEmailAndPassword(String email, String password, {String? displayName}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
      }
      
      return _mapFirebaseUser(credential.user)!;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    await signUpWithEmailAndPassword(email, password);
  }

  @override
  Future<void> signOut() async {
    await _secureStorage.deleteToken();
    await _auth.signOut();
  }

  Failure _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const InvalidCredentialsFailure();
      case 'email-already-in-use':
        return const AuthFailure('Email already in use');
      case 'weak-password':
        return const AuthFailure('Password is too weak');
      case 'invalid-email':
        return const AuthFailure('Invalid email address');
      case 'network-request-failed':
        return const NetworkFailure();
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

// We override the old mock provider with the REAL Firebase one here!
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return FirebaseAuthRepository(firebaseAuth, secureStorage);
});

// Stream for Auth State
final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});
