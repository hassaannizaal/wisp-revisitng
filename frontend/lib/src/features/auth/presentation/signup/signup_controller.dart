import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';

class SignupController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // nothing to do
  }

  Future<bool> signup(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(authRepositoryProvider).createUserWithEmailAndPassword(email, password));
    return !state.hasError;
  }
}

final signupControllerProvider = AsyncNotifierProvider.autoDispose<SignupController, void>(() {
  return SignupController();
});
