import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:bd_library_app/db/app_db.dart';

void main() {
  late AppDb db;
  setUp(() => db = AppDb.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<String> _series(String name) async {
    final id = 'series-${name.toLowerCase().replaceAll(' ', '-')}';
    await db.upsertSeries(SeriesCompanion.insert(id: id, name: name, updatedAt: DateTime.now()));
    return id;
  }

  Future<void> _book(String seriesId, int vol) => db.upsertBook(BooksCompanion.insert(
    id: 'book-$seriesId-$vol', title: 'Tome $vol',
    seriesId: Value(seriesId), volumeNumber: Value(vol),
    updatedAt: DateTime.now()));

  group('getAutoDetectedSeriesGaps', () {
    test('retourne vide si aucune série', () async {
      expect(await db.getAutoDetectedSeriesGaps(), isEmpty);
    });

    test('retourne vide si série avec 1 seul tome', () async {
      final id = await _series('Solo');
      await _book(id, 1);
      expect(await db.getAutoDetectedSeriesGaps(), isEmpty);
    });

    test('retourne vide si tomes consécutifs sans lacune', () async {
      final id = await _series('Consec');
      await _book(id, 1); await _book(id, 2); await _book(id, 3);
      expect(await db.getAutoDetectedSeriesGaps(), isEmpty);
    });

    test('détecte une lacune entre deux tomes possédés', () async {
      final id = await _series('Lacune');
      await _book(id, 1); await _book(id, 3);
      final res = await db.getAutoDetectedSeriesGaps();
      expect(res, hasLength(1));
      expect(res.first.series.name, 'Lacune');
      expect(res.first.gaps, [2]);
    });

    test('détecte plusieurs lacunes dans une série', () async {
      final id = await _series('Multi');
      await _book(id, 1); await _book(id, 4); await _book(id, 7);
      final res = await db.getAutoDetectedSeriesGaps();
      expect(res, hasLength(1));
      expect(res.first.gaps, [2, 3, 5, 6]);
    });

    test('ne signale pas les tomes après le max possédé', () async {
      final id = await _series('OpenEnd');
      await _book(id, 1); await _book(id, 2); await _book(id, 5);
      final res = await db.getAutoDetectedSeriesGaps();
      expect(res.first.gaps, [3, 4]); // pas 6, 7, etc.
    });

    test('trie par nombre de lacunes croissant', () async {
      final idA = await _series('Many');
      await _book(idA, 1); await _book(idA, 5); // 3 lacunes: 2,3,4
      final idB = await _series('Few');
      await _book(idB, 1); await _book(idB, 3); // 1 lacune: 2
      final res = await db.getAutoDetectedSeriesGaps();
      expect(res.map((e) => e.series.name).toList(), ['Few', 'Many']);
    });

    test('fonctionne sans expectedVolumes', () async {
      final id = 'no-exp';
      await db.upsertSeries(SeriesCompanion.insert(id: id, name: 'NoExp', updatedAt: DateTime.now()));
      await _book(id, 1); await _book(id, 3);
      final res = await db.getAutoDetectedSeriesGaps();
      expect(res, hasLength(1));
      expect(res.first.gaps, [2]);
    });
  });
}
