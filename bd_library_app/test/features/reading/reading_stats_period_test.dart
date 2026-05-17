import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:bd_library_app/db/app_db.dart';

void main() {
  late AppDb db;
  setUp(() => db = AppDb.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> _session(DateTime ended, int seconds) async {
    await db.insertReadingSession(ReadingSessionsCompanion.insert(
      id: 'sess-${ended.millisecondsSinceEpoch}',
      bookId: 'book-1',
      startedAt: ended.subtract(Duration(seconds: seconds)),
      endedAt: Value(ended),
      durationSeconds: Value(seconds),
    ));
  }

  group('readingSecondsBetween', () {
    test('retourne 0 si aucune session', () async {
      expect(await db.readingSecondsBetween(DateTime(2026,1,1), DateTime(2026,12,31,23,59,59)), 0);
    });

    test('additionne les sessions dans l\'intervalle', () async {
      await _session(DateTime(2026,5,10,10), 3600);
      await _session(DateTime(2026,5,15,12), 1800);
      final total = await db.readingSecondsBetween(DateTime(2026,5,1), DateTime(2026,5,31,23,59,59));
      expect(total, 5400);
    });

    test('exclut les sessions hors intervalle', () async {
      await _session(DateTime(2026,4,30,23,59,59), 900); // avant
      await _session(DateTime(2026,5,10), 3600);          // dans
      await _session(DateTime(2026,6,1), 600);            // après
      final total = await db.readingSecondsBetween(DateTime(2026,5,1), DateTime(2026,5,31,23,59,59));
      expect(total, 3600);
    });

    test('exclut les sessions sans endedAt', () async {
      await db.insertReadingSession(ReadingSessionsCompanion.insert(
        id: 'active',bookId:'book-1',startedAt:DateTime(2026,5,5),durationSeconds:const Value(500),
      ));
      expect(await db.readingSecondsBetween(DateTime(2026,5,1), DateTime(2026,5,31,23,59,59)), 0);
    });

    test('inclut les bornes', () async {
      await _session(DateTime(2026,5,1), 100); // borne début
      await _session(DateTime(2026,5,31,23,59,59), 200); // borne fin
      expect(await db.readingSecondsBetween(DateTime(2026,5,1), DateTime(2026,5,31,23,59,59)), 300);
    });
  });
}
