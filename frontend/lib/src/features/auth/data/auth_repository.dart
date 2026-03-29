import '../domain/app_user.dart';
export 'firebase_auth_repository.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  AppUser? get currentUser;
  Future<AppUser> signInWithEmailAndPassword(String email, String password);
  Future<AppUser> signUpWithEmailAndPassword(String email, String password, {String? displayName});
  Future<void> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<String?> getIdToken();
}
