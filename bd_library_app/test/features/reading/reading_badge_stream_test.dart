import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:bd_library_app/db/app_db.dart';
import 'package:bd_library_app/features/reading/domain/reading_badge_catalog.dart';

void main() {
  late AppDb db;
  setUp(() => db = AppDb.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('watchEarnedBadges — réactivité stream (fix page grise)', () {
    test('émet une liste vide au démarrage', () async {
      expect(await db.watchEarnedBadges().first, isEmpty);
    });

    test('émet la liste mise à jour après insertion d\'un badge', () async {
      expect(await db.watchEarnedBadges().first, isEmpty);

      await db.insertEarnedBadgeIfAbsent(EarnedBadgesCompanion.insert(
        id: 'test-uuid',
        badgeId: ReadingBadgeIds.firstBookEver,
        unlockedAt: DateTime(2026, 1, 15),
      ));

      final rows = await db.watchEarnedBadges().first;
      expect(rows, hasLength(1));
      expect(rows.first.badgeId, ReadingBadgeIds.firstBookEver);
    });

    test('n\'insère pas de doublon pour un badge sans période', () async {
      final companion = EarnedBadgesCompanion.insert(
        id: 'uuid-1',
        badgeId: ReadingBadgeIds.books10,
        unlockedAt: DateTime(2026, 2, 1),
      );
      expect(await db.insertEarnedBadgeIfAbsent(companion), isTrue);
      final companion2 = EarnedBadgesCompanion.insert(
        id: 'uuid-2',
        badgeId: ReadingBadgeIds.books10,
        unlockedAt: DateTime(2026, 2, 2),
      );
      expect(await db.insertEarnedBadgeIfAbsent(companion2), isFalse);
      expect(await db.watchEarnedBadges().first, hasLength(1));
    });

    test('émet plusieurs badges dans l\'ordre décroissant d\'obtention', () async {
      await db.insertEarnedBadgeIfAbsent(EarnedBadgesCompanion.insert(
        id: 'uuid-a',
        badgeId: ReadingBadgeIds.firstBookEver,
        unlockedAt: DateTime(2026, 1, 1),
      ));
      await db.insertEarnedBadgeIfAbsent(EarnedBadgesCompanion.insert(
        id: 'uuid-b',
        badgeId: ReadingBadgeIds.books10,
        unlockedAt: DateTime(2026, 3, 1),
      ));

      final rows = await db.watchEarnedBadges().first;
      expect(rows, hasLength(2));
      expect(rows.first.badgeId, ReadingBadgeIds.books10);  // plus récent en premier
      expect(rows.last.badgeId, ReadingBadgeIds.firstBookEver);
    });
  });
}
