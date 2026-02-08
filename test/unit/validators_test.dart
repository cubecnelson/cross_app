import 'package:flutter_test/flutter_test.dart';
import 'package:cross/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('returns null for valid email', () {
        expect(Validators.validateEmail('test@example.com'), isNull);
        expect(Validators.validateEmail('user.name+tag@domain.co.uk'), isNull);
      });

      test('returns error for null or empty', () {
        expect(Validators.validateEmail(null), 'Email is required');
        expect(Validators.validateEmail(''), 'Email is required');
      });

      test('returns error for invalid email formats', () {
        expect(Validators.validateEmail('invalid'), 'Please enter a valid email');
        expect(Validators.validateEmail('test@'), 'Please enter a valid email');
        expect(Validators.validateEmail('@example.com'), 'Please enter a valid email');
        expect(Validators.validateEmail('test@example.'), 'Please enter a valid email');
      });
    });

    group('validatePassword', () {
      test('returns null for valid password', () {
        expect(Validators.validatePassword('Password123'), isNull);
        expect(Validators.validatePassword('SecurePass1'), isNull);
      });

      test('returns error for null or empty', () {
        expect(Validators.validatePassword(null), 'Password is required');
        expect(Validators.validatePassword(''), 'Password is required');
      });

      test('returns error for too short password', () {
        expect(Validators.validatePassword('Short1'), 'Password must be at least 8 characters');
      });

      test('returns error for missing uppercase', () {
        expect(Validators.validatePassword('lowercase123'), 'Password must contain at least one uppercase letter');
      });

      test('returns error for missing lowercase', () {
        expect(Validators.validatePassword('UPPERCASE123'), 'Password must contain at least one lowercase letter');
      });

      test('returns error for missing number', () {
        expect(Validators.validatePassword('NoNumbers'), 'Password must contain at least one number');
      });
    });

    group('validateRequired', () {
      test('returns null for non-empty value', () {
        expect(Validators.validateRequired('value', 'Field'), isNull);
        expect(Validators.validateRequired('   trimmed   ', 'Field'), isNull);
      });

      test('returns error for null or empty', () {
        expect(Validators.validateRequired(null, 'Name'), 'Name is required');
        expect(Validators.validateRequired('', 'Email'), 'Email is required');
        expect(Validators.validateRequired('   ', 'Title'), 'Title is required');
      });
    });

    group('validateNumber', () {
      test('returns null for valid numbers', () {
        expect(Validators.validateNumber('123', 'Age'), isNull);
        expect(Validators.validateNumber('123.45', 'Weight'), isNull);
        expect(Validators.validateNumber('0', 'Count'), isNull);
        expect(Validators.validateNumber('-123', 'Temperature'), isNull);
      });

      test('returns error for null or empty', () {
        expect(Validators.validateNumber(null, 'Age'), 'Age is required');
        expect(Validators.validateNumber('', 'Weight'), 'Weight is required');
      });

      test('returns error for non-numeric values', () {
        expect(Validators.validateNumber('abc', 'Age'), 'Please enter a valid number');
        expect(Validators.validateNumber('123abc', 'Weight'), 'Please enter a valid number');
      });
    });

    group('validatePositiveNumber', () {
      test('returns null for positive numbers', () {
        expect(Validators.validatePositiveNumber('123', 'Weight'), isNull);
        expect(Validators.validatePositiveNumber('123.45', 'Price'), isNull);
        expect(Validators.validatePositiveNumber('0.1', 'Amount'), isNull);
      });

      test('returns error for zero or negative', () {
        expect(Validators.validatePositiveNumber('0', 'Weight'), 'Weight must be greater than 0');
        expect(Validators.validatePositiveNumber('-5', 'Price'), 'Price must be greater than 0');
        expect(Validators.validatePositiveNumber('-0.1', 'Amount'), 'Amount must be greater than 0');
      });

      test('inherits validation from validateNumber', () {
        expect(Validators.validatePositiveNumber(null, 'Weight'), 'Weight is required');
        expect(Validators.validatePositiveNumber('', 'Price'), 'Price is required');
        expect(Validators.validatePositiveNumber('abc', 'Amount'), 'Please enter a valid number');
      });
    });

    group('validateInteger', () {
      test('returns null for valid integers', () {
        expect(Validators.validateInteger('123', 'Age'), isNull);
        expect(Validators.validateInteger('0', 'Count'), isNull);
        expect(Validators.validateInteger('-456', 'Level'), isNull);
      });

      test('returns error for null or empty', () {
        expect(Validators.validateInteger(null, 'Age'), 'Age is required');
        expect(Validators.validateInteger('', 'Count'), 'Count is required');
      });

      test('returns error for non-integer values', () {
        expect(Validators.validateInteger('123.45', 'Age'), 'Please enter a valid whole number');
        expect(Validators.validateInteger('abc', 'Count'), 'Please enter a valid whole number');
        expect(Validators.validateInteger('123abc', 'Level'), 'Please enter a valid whole number');
      });
    });
  });
}