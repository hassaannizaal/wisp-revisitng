import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wisp_mental_health/core/error/failures.dart';
import 'package:wisp_mental_health/src/features/auth/data/auth_repository.dart';
import 'package:wisp_mental_health/src/features/auth/presentation/sign_in/sign_in_controller.dart';
import 'package:wisp_mental_health/src/features/auth/presentation/sign_up/sign_up_controller.dart';

import '../../support/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository auth;
  late ProviderContainer container;

  setUp(() {
    auth = FakeAuthRepository();
    container = ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(auth)]);
    addTearDown(container.dispose);
  });

  group('SignInController', () {
    test('signs in through the repository and ends in a data state', () async {
      final sub = container.listen(signInControllerProvider, (_, _) {});
      addTearDown(sub.close);

      await container.read(signInControllerProvider.notifier).signIn('me@example.com', 'secret1');

      expect(auth.calls, ['signIn:me@example.com']);
      expect(container.read(signInControllerProvider), isA<AsyncData<void>>());
      expect(auth.currentUser?.email, 'me@example.com');
    });

    test('surfaces repository failures as an error state without throwing', () async {
      auth.failure = const InvalidCredentialsFailure();
      final sub = container.listen(signInControllerProvider, (_, _) {});
      addTearDown(sub.close);

      await container.read(signInControllerProvider.notifier).signIn('me@example.com', 'wrong');

      final state = container.read(signInControllerProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<InvalidCredentialsFailure>());
      expect(auth.currentUser, isNull);
    });
  });

  group('SignUpController', () {
    test('passes the display name through to the repository', () async {
      final sub = container.listen(signUpControllerProvider, (_, _) {});
      addTearDown(sub.close);

      await container
          .read(signUpControllerProvider.notifier)
          .signUp(name: 'Hassaan', email: 'new@example.com', password: 'secret1');

      expect(auth.calls, ['signUp:new@example.com:Hassaan']);
      expect(auth.currentUser?.displayName, 'Hassaan');
      expect(container.read(signUpControllerProvider), isA<AsyncData<void>>());
    });
  });
}
