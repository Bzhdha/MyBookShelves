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
      test('strips mixed hyphens and spaces', () {
        expect(IsbnValidator.normalize('978-2 7560-1809 6'), '9782756018096');
      });
      test('returns already clean string unchanged', () {
        expect(IsbnValidator.normalize('9782756018096'), '9782756018096');
      });
    });

    group('validate ISBN-13', () {
      test('valid 978 prefix', () {
        expect(IsbnValidator.validate('9782756018096'), isNull);
      });
      test('valid 979 prefix', () {
        expect(IsbnValidator.validate('9791032309285'), isNull);
      });
      test('invalid checksum', () {
        expect(IsbnValidator.validate('9782756018097'), isNotNull);
      });
      test('invalid prefix', () {
        expect(IsbnValidator.validate('9772756018096'), isNotNull);
      });
      test('contains non-digits', () {
        expect(IsbnValidator.validate('978275601809X'), isNotNull);
      });
    });

    group('validate ISBN-10', () {
      test('valid digits only', () {
        expect(IsbnValidator.validate('2070360024'), isNull);
      });
      test('valid with X checksum', () {
        expect(IsbnValidator.validate('080442957X'), isNull);
      });
      test('invalid checksum', () {
        expect(IsbnValidator.validate('2070360025'), isNotNull);
      });
      test('lowercase x is invalid', () {
        expect(IsbnValidator.validate('080442957x'), isNotNull);
      });
    });

    group('validate edge cases', () {
      test('empty string', () {
        expect(IsbnValidator.validate(''), isNotNull);
      });
      test('wrong length (9 digits)', () {
        expect(IsbnValidator.validate('123456789'), isNotNull);
      });
      test('wrong length (11 digits)', () {
        expect(IsbnValidator.validate('12345678901'), isNotNull);
      });
      test('hyphens stripped before validation', () {
        expect(IsbnValidator.validate('978-2-7560-1809-6'), isNull);
      });
      test('spaces stripped before validation', () {
        expect(IsbnValidator.validate('978 2 7560 1809 6'), isNull);
      });
    });
  });
}
