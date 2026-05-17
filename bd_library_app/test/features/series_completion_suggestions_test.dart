import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:bd_library_app/db/app_db.dart';

void main() {
  late AppDb db;
  setUp(() => db = AppDb.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<String> _series(String name, int expected) async {
    final id = 'series-${name.toLowerCase()}';
    await db.upsertSeries(SeriesCompanion.insert(id: id, name: name, expectedVolumes: Value(expected), updatedAt: DateTime.now()));
    return id;
  }

  Future<void> _book(String seriesId, int vol) => db.upsertBook(BooksCompanion.insert(
    id: 'book-$seriesId-$vol', title: 'Tome $vol',
    seriesId: Value(seriesId), volumeNumber: Value(vol),
    updatedAt: DateTime.now()));

  group('getSeriesCompletionSuggestions', () {
    test('retourne vide si aucune série', () async {
      expect(await db.getSeriesCompletionSuggestions(), isEmpty);
    });

    test('exclut les séries sans tome possédé', () async {
      await _series('Vide', 5);
      expect(await db.getSeriesCompletionSuggestions(), isEmpty);
    });

    test('exclut les séries sans expectedVolumes', () async {
      final id = 's-no-exp';
      await db.upsertSeries(SeriesCompanion.insert(id: id, name: 'NoExp', updatedAt: DateTime.now()));
      await _book(id, 1);
      expect(await db.getSeriesCompletionSuggestions(), isEmpty);
    });

    test('exclut les séries complètes', () async {
      final id = await _series('Complet', 3);
      await _book(id, 1); await _book(id, 2); await _book(id, 3);
      expect(await db.getSeriesCompletionSuggestions(), isEmpty);
    });

    test('inclut une série avec au moins 1 tome possédé et 1 manquant', () async {
      final id = await _series('Asterix', 40);
      for (int i = 1; i <= 35; i++) await _book(id, i);
      final res = await db.getSeriesCompletionSuggestions();
      expect(res, hasLength(1));
      expect(res.first.series.name, 'Asterix');
      expect(res.first.owned, 35);
      expect(res.first.missing, [36, 37, 38, 39, 40]);
    });

    test('trie par taux de complétion décroissant', () async {
      final idA = await _series('A-low', 10);
      await _book(idA, 1); await _book(idA, 2); // 20%

      final idB = await _series('B-high', 10);
      for (int i = 1; i <= 8; i++) await _book(idB, i); // 80%

      final idC = await _series('C-mid', 10);
      for (int i = 1; i <= 5; i++) await _book(idC, i); // 50%

      final res = await db.getSeriesCompletionSuggestions();
      expect(res.map((e) => e.series.name).toList(), ['B-high', 'C-mid', 'A-low']);
    });

    test('le premier tome manquant est le plus petit numéro absent', () async {
      final id = await _series('Lacunes', 10);
      await _book(id, 1); await _book(id, 3); await _book(id, 5);
      final res = await db.getSeriesCompletionSuggestions();
      expect(res.first.missing.first, 2);
    });
  });
}
