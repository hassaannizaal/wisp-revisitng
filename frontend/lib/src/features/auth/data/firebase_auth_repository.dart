import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      return _mapFirebaseUser(credential.user)!;
    } on FirebaseAuthException catch (e) {
      // Throw clean error messages to show in the UI
      throw Exception(e.message ?? 'Login failed');
    }
  }

  @override
  Future<AppUser> signUpWithEmailAndPassword(String email, String password, {String? displayName}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update the display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
      }
      
      return _mapFirebaseUser(credential.user)!;
      // Note: If you want to use the createUserWithEmailAndPassword name from the old interface, 
      // replace this method with one that matches that name. 
      // However, the user-supplied code used 'signUpWithEmailAndPassword'.
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Sign up failed');
    }
  }

  // Bridging method for the existing interface
  @override
  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    await signUpWithEmailAndPassword(email, password);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
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
  return FirebaseAuthRepository(firebaseAuth);
});

// Stream for Auth State
final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});
