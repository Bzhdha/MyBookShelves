import 'package:flutter_test/flutter_test.dart';
import 'package:bd_library_app/features/reading/ui/reading_formatters.dart';

void main() {
  group('formatReadingDuration', () {
    test('zero returns em dash', () {
      expect(formatReadingDuration(0), '—');
    });
    test('negative returns em dash', () {
      expect(formatReadingDuration(-1), '—');
    });
    test('seconds only (< 60)', () {
      expect(formatReadingDuration(45), '45 s');
    });
    test('exactly 59 seconds', () {
      expect(formatReadingDuration(59), '59 s');
    });
    test('exactly 1 minute', () {
      expect(formatReadingDuration(60), '1 min');
    });
    test('minutes only (< 3600)', () {
      expect(formatReadingDuration(90), '1 min');
    });
    test('59 minutes 59 seconds', () {
      expect(formatReadingDuration(3599), '59 min');
    });
    test('exactly 1 hour', () {
      expect(formatReadingDuration(3600), '1 h 0 min');
    });
    test('1 hour 30 minutes', () {
      expect(formatReadingDuration(5400), '1 h 30 min');
    });
    test('2 hours 1 minute', () {
      expect(formatReadingDuration(7261), '2 h 1 min');
    });
  });

  group('readingStatusLabel', () {
    test('0 → À lire', () {
      expect(readingStatusLabel(0), 'À lire');
    });
    test('1 → En cours', () {
      expect(readingStatusLabel(1), 'En cours');
    });
    test('2 → Terminé', () {
      expect(readingStatusLabel(2), 'Terminé');
    });
    test('unknown → ?', () {
      expect(readingStatusLabel(99), '?');
    });
    test('negative → ?', () {
      expect(readingStatusLabel(-1), '?');
    });
  });
}
