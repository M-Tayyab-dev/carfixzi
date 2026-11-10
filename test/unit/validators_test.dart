import 'package:flutter_test/flutter_test.dart';
import 'package:carfixzi/core/utils/validators.dart';

void main() {
  group('Firebase Strong Password Policy Tests (Min 12 chars, upper, lower, digit, symbol)', () {
    test('Rejects passwords shorter than 12 characters', () {
      expect(Validators.validatePassword('Short1!'), 'Password must be at least 12 characters');
      expect(Validators.validatePassword('Passw0rd123!'), null); // 12 characters valid
    });

    test('Rejects passwords without uppercase letter', () {
      expect(Validators.validatePassword('weakpassword123!'), 'Must include at least one uppercase letter');
    });

    test('Rejects passwords without lowercase letter', () {
      expect(Validators.validatePassword('WEAKPASSWORD123!'), 'Must include at least one lowercase letter');
    });

    test('Rejects passwords without digits', () {
      expect(Validators.validatePassword('WeakPasswordSpecial!'), 'Must include at least one number');
    });

    test('Rejects passwords without special symbols', () {
      expect(Validators.validatePassword('WeakPassword12345'), 'Must include at least one special character');
    });

    test('Accepts compliant strong password', () {
      expect(Validators.validatePassword('CarFixzi2026!#Secure'), null);
    });

    test('Calculates accurate strength score', () {
      expect(Validators.getPasswordStrength('weak'), 0);
      expect(Validators.getPasswordStrength('CarFixzi2026!#'), 4);
    });
  });

  group('Pakistani Phone Number Tests', () {
    test('Validates Pakistani phone numbers', () {
      expect(Validators.validatePakistaniPhone('+923001234567'), null);
      expect(Validators.validatePakistaniPhone('03001234567'), null);
      expect(Validators.validatePakistaniPhone('0321-9876543'), null);
      expect(Validators.validatePakistaniPhone('+1234567890'), 'Enter a valid Pakistani mobile number (+923xxxxxxxxx)');
    });
  });
}
