import 'package:flutter_test/flutter_test.dart';
import 'package:bd_library_app/features/reading/domain/reading_badge_catalog.dart';

void main() {
  group('readingBadgeMeta', () {
    test('returns null for unknown badge id', () {
      expect(readingBadgeMeta('unknown_badge'), isNull);
    });
    test('returns null for empty string', () {
      expect(readingBadgeMeta(''), isNull);
    });

    group('pioneer badges', () {
      test('pioneer_week has title and description', () {
        final m = readingBadgeMeta(ReadingBadgeIds.pioneerWeek);
        expect(m, isNotNull);
        expect(m!.title, isNotEmpty);
        expect(m.description, isNotEmpty);
      });
      test('pioneer_month has title and description', () {
        final m = readingBadgeMeta(ReadingBadgeIds.pioneerMonth);
        expect(m, isNotNull);
        expect(m!.title, isNotEmpty);
        expect(m.description, isNotEmpty);
      });
      test('pioneer_year has title and description', () {
        final m = readingBadgeMeta(ReadingBadgeIds.pioneerYear);
        expect(m, isNotNull);
        expect(m!.title, isNotEmpty);
        expect(m.description, isNotEmpty);
      });
    });

    group('volume milestone badges', () {
      for (final id in [
        ReadingBadgeIds.firstBookEver,
        ReadingBadgeIds.books10,
        ReadingBadgeIds.books25,
        ReadingBadgeIds.books50,
        ReadingBadgeIds.books100,
      ]) {
        test('$id has non-empty title and description', () {
          final m = readingBadgeMeta(id);
          expect(m, isNotNull);
          expect(m!.title, isNotEmpty);
          expect(m.description, isNotEmpty);
        });
      }
    });

    group('series milestone badges', () {
      for (final id in [
        ReadingBadgeIds.firstSeriesComplete,
        ReadingBadgeIds.seriesCollector5,
        ReadingBadgeIds.seriesCollector10,
      ]) {
        test('$id has non-empty title and description', () {
          final m = readingBadgeMeta(id);
          expect(m, isNotNull);
          expect(m!.title, isNotEmpty);
          expect(m.description, isNotEmpty);
        });
      }
    });

    test('all badge ids map to distinct titles', () {
      final ids = [
        ReadingBadgeIds.pioneerWeek,
        ReadingBadgeIds.pioneerMonth,
        ReadingBadgeIds.pioneerYear,
        ReadingBadgeIds.firstBookEver,
        ReadingBadgeIds.books10,
        ReadingBadgeIds.books25,
        ReadingBadgeIds.books50,
        ReadingBadgeIds.books100,
        ReadingBadgeIds.firstSeriesComplete,
        ReadingBadgeIds.seriesCollector5,
        ReadingBadgeIds.seriesCollector10,
      ];
      final titles = ids.map((id) => readingBadgeMeta(id)!.title).toList();
      expect(titles.toSet().length, titles.length);
    });
  });
}
