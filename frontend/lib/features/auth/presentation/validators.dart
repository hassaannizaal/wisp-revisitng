/// Shared form validators for the auth screens. Kept free of Flutter imports
/// so they are trivially unit-testable.
library;

// Pragmatic email check: something@something.tld. Firebase performs the
// authoritative validation server-side ('invalid-email').
final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// Firebase Auth rejects passwords shorter than this ('weak-password').
const int minPasswordLength = 6;

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Email is required';
  if (!_emailPattern.hasMatch(email)) return 'Enter a valid email address';
  return null;
}

String? validatePassword(String? value) {
  final password = value ?? '';
  if (password.isEmpty) return 'Password is required';
  if (password.length < minPasswordLength) return 'Password must be at least $minPasswordLength characters';
  return null;
}
