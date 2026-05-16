import 'package:flutter_test/flutter_test.dart';

import 'package:bd_library_app/core/isbn_validator.dart';

void main() {
  group('IsbnValidator', () {
    group('normalize', () {
      test('strips hyphens', () {
        expect(IsbnValidator.normalize('978-2-7560-1809-6'), '9782756018096');
      });

      test('strips spaces', () {
        expect(IsbnValidator.normalize('978 2 7560 1809 6'), '9782756018096');
      });
    });

    group('validate ISBN-13', () {
      test('valid ISBN-13', () {
        expect(IsbnValidator.validate('9782756018096'), isNull);
      });

      test('valid ISBN-13 starting with 979', () {
        expect(IsbnValidator.validate('9791032309285'), isNull);
      });

      test('invalid checksum', () {
        expect(IsbnValidator.validate('9782756018097'), isNotNull);
      });

      test('does not start with 978 or 979', () {
        expect(IsbnValidator.validate('9772756018096'), isNotNull);
      });

      test('contains non-digits', () {
        expect(IsbnValidator.validate('978275601809X'), isNotNull);
      });
    });

    group('validate ISBN-10', () {
      test('valid ISBN-10', () {
        expect(IsbnValidator.validate('2070360024'), isNull);
      });

      test('valid ISBN-10 with X checksum', () {
        expect(IsbnValidator.validate('080442957X'), isNull);
      });

      test('invalid checksum', () {
        expect(IsbnValidator.validate('2070360025'), isNotNull);
      });
    });

    group('validate edge cases', () {
      test('empty string', () {
        expect(IsbnValidator.validate(''), isNotNull);
      });

      test('wrong length', () {
        expect(IsbnValidator.validate('123456789'), isNotNull);
      });

      test('hyphens are stripped before validation', () {
        expect(IsbnValidator.validate('978-2-7560-1809-6'), isNull);
      });
    });
  });
}
