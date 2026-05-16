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
      test('pioneer_week', () {
        final m = readingBadgeMeta(ReadingBadgeIds.pioneerWeek);
        expect(m!.title, 'Starter de la semaine');
        expect(m.description, contains('semaine'));
      });
      test('pioneer_month', () {
        final m = readingBadgeMeta(ReadingBadgeIds.pioneerMonth);
        expect(m!.title, 'Lanceur du mois');
        expect(m.description, contains('mois'));
      });
      test('pioneer_year', () {
        final m = readingBadgeMeta(ReadingBadgeIds.pioneerYear);
        expect(m!.title, 'Démarreur de l’année');
        expect(m.description, contains('année'));
      });
    });

    group('volume milestone badges', () {
      test('first_book_ever', () {
        final m = readingBadgeMeta(ReadingBadgeIds.firstBookEver);
        expect(m!.title, 'Première page tournée');
        expect(m.description, contains('premier'));
      });
      test('books_10', () {
        final m = readingBadgeMeta(ReadingBadgeIds.books10);
        expect(m!.title, 'Lecteur assidu');
        expect(m.description, contains('10'));
      });
      test('books_25', () {
        final m = readingBadgeMeta(ReadingBadgeIds.books25);
        expect(m!.title, 'Herbivore de cases');
        expect(m.description, contains('25'));
      });
      test('books_50', () {
        final m = readingBadgeMeta(ReadingBadgeIds.books50);
        expect(m!.title, 'Cinquante bulles');
        expect(m.description, contains('50'));
      });
      test('books_100', () {
        final m = readingBadgeMeta(ReadingBadgeIds.books100);
        expect(m!.title, 'Centurion des bulles');
        expect(m.description, contains('100'));
      });
    });

    group('series milestone badges', () {
      test('first_series_complete', () {
        final m = readingBadgeMeta(ReadingBadgeIds.firstSeriesComplete);
        expect(m!.title, 'Série bouclée !');
        expect(m.description, contains('première'));
      });
      test('series_collector_5', () {
        final m = readingBadgeMeta(ReadingBadgeIds.seriesCollector5);
        expect(m!.title, 'Chasseur de fins');
        expect(m.description, contains('5'));
      });
      test('series_collector_10', () {
        final m = readingBadgeMeta(ReadingBadgeIds.seriesCollector10);
        expect(m!.title, 'Maître des arcs');
        expect(m.description, contains('10'));
      });
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
