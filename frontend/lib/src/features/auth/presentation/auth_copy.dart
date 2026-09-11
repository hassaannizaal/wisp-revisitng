import '../../../../core/error/failures.dart';

/// Where an auth error is shown: under a field, or as a toast when it is not
/// about any one field. Copy follows docs/screens/02-sign-in.md — it names
/// what to do, and never reveals whether an email exists.
class ErrorPlacement {
  const ErrorPlacement({this.email, this.password, this.toast});

  final String? email;
  final String? password;
  final String? toast;
}

class AuthCopy {
  const AuthCopy._();

  static const passwordMismatch = "That password doesn't match this email.";
  static const emailMalformed = "That doesn't look like an email address.";
  static const emailTaken = "There's already an account with this email. Try signing in instead.";
  static const passwordWeak = 'Choose a password with at least 6 characters.';
  static const offline = "You're offline. Check your connection and try again.";
  static const generic = "Something went wrong on our side. Please try again in a moment.";
  static const resetComingSoon = 'Password reset is coming soon. For now, contact support to regain access.';

  static String providerComingSoon(String provider) => '$provider sign-in is coming soon.';

  static ErrorPlacement placeSignInError(Object error) {
    return switch (error) {
      InvalidCredentialsFailure() => const ErrorPlacement(password: passwordMismatch),
      InvalidEmailFailure() => const ErrorPlacement(email: emailMalformed),
      NetworkFailure() => const ErrorPlacement(toast: offline),
      AuthFailure(:final message) => ErrorPlacement(toast: message),
      _ => const ErrorPlacement(toast: generic),
    };
  }

  static ErrorPlacement placeSignUpError(Object error) {
    return switch (error) {
      EmailAlreadyInUseFailure() => const ErrorPlacement(email: emailTaken),
      InvalidEmailFailure() => const ErrorPlacement(email: emailMalformed),
      WeakPasswordFailure() => const ErrorPlacement(password: passwordWeak),
      NetworkFailure() => const ErrorPlacement(toast: offline),
      AuthFailure(:final message) => ErrorPlacement(toast: message),
      _ => const ErrorPlacement(toast: generic),
    };
  }
}
