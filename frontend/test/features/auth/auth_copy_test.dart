import 'package:flutter_test/flutter_test.dart';
import 'package:wisp_mental_health/core/error/failures.dart';
import 'package:wisp_mental_health/src/features/auth/presentation/auth_copy.dart';

void main() {
  group('AuthCopy.placeSignInError', () {
    test('puts a wrong password under the password field without revealing the email exists', () {
      final placement = AuthCopy.placeSignInError(const InvalidCredentialsFailure());
      expect(placement.password, AuthCopy.passwordMismatch);
      expect(placement.email, isNull);
      expect(placement.toast, isNull);
      expect(placement.password, isNot(contains('exist')));
    });

    test('puts a malformed email under the email field', () {
      expect(AuthCopy.placeSignInError(const InvalidEmailFailure()).email, AuthCopy.emailMalformed);
    });

    test('shows network and unknown failures as a toast', () {
      expect(AuthCopy.placeSignInError(const NetworkFailure()).toast, AuthCopy.offline);
      expect(AuthCopy.placeSignInError(Exception('boom')).toast, AuthCopy.generic);
    });
  });

  group('AuthCopy.placeSignUpError', () {
    test('routes email-in-use and weak-password to their fields', () {
      expect(AuthCopy.placeSignUpError(const EmailAlreadyInUseFailure()).email, AuthCopy.emailTaken);
      expect(AuthCopy.placeSignUpError(const WeakPasswordFailure()).password, AuthCopy.passwordWeak);
    });
  });
}
