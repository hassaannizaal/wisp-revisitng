import 'package:flutter_test/flutter_test.dart';
import 'package:wisp_mental_health/src/features/auth/presentation/validators.dart';

void main() {
  group('validateEmail', () {
    test('rejects empty and whitespace-only input', () {
      expect(validateEmail(null), 'Email is required');
      expect(validateEmail('   '), 'Email is required');
    });

    test('rejects malformed addresses', () {
      expect(validateEmail('nope'), isNotNull);
      expect(validateEmail('a@b'), isNotNull);
      expect(validateEmail('a b@c.com'), isNotNull);
    });

    test('accepts a normal address, ignoring surrounding whitespace', () {
      expect(validateEmail('someone@example.com'), isNull);
      expect(validateEmail('  someone@example.com '), isNull);
    });
  });

  group('validatePassword', () {
    test('requires at least $minPasswordLength characters', () {
      expect(validatePassword(null), 'Password is required');
      expect(validatePassword('12345'), contains('$minPasswordLength'));
      expect(validatePassword('123456'), isNull);
    });
  });
}
