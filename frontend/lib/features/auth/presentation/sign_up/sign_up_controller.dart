import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';

class SignUpController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // nothing to do
  }

  Future<void> signUp({required String name, required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signUpWithEmailAndPassword(email, password, displayName: name),
    );
  }
}

final signUpControllerProvider = AsyncNotifierProvider.autoDispose<SignUpController, void>(() {
  return SignUpController();
});
