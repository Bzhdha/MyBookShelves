import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:bd_library_app/db/app_db.dart';
import 'package:bd_library_app/features/reading/domain/reading_badge_catalog.dart';
import 'package:bd_library_app/features/reading/ui/reading_badges_page.dart';

void main() {
  late AppDb db;

  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await initializeDateFormatting('fr_FR', null);
  });

  setUp(() => db = AppDb.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Widget wrap() => MaterialApp(
    home: Provider<AppDb>.value(value: db, child: const ReadingBadgesPage()),
  );

  group('ReadingBadgesPage — états visuels', () {
    testWidgets('affiche les 11 titres de badges sans badge gagné', (t) async {
      await t.pumpWidget(wrap());
      await t.pumpAndSettle();
      for (final id in [
        ReadingBadgeIds.firstBookEver, ReadingBadgeIds.books10, ReadingBadgeIds.books25,
        ReadingBadgeIds.books50, ReadingBadgeIds.books100,
        ReadingBadgeIds.pioneerWeek, ReadingBadgeIds.pioneerMonth, ReadingBadgeIds.pioneerYear,
        ReadingBadgeIds.firstSeriesComplete, ReadingBadgeIds.seriesCollector5,
        ReadingBadgeIds.seriesCollector10,
      ]) {
        expect(find.text(readingBadgeMeta(id)!.title), findsOneWidget, reason: id);
      }
    });

    testWidgets('affiche exactement 3 labels PROCHAIN OBJECTIF (un par catégorie)', (t) async {
      await t.pumpWidget(wrap());
      await t.pumpAndSettle();
      expect(find.text('PROCHAIN OBJECTIF'), findsNWidgets(3));
    });

    testWidgets('badge verrouillé affiche lock_outline', (t) async {
      await t.pumpWidget(wrap());
      await t.pumpAndSettle();
      // 8 badges verrouillés (11 total − 3 premiers de chaque catégorie = next)
      expect(find.byIcon(Icons.lock_outline), findsNWidgets(8));
    });

    testWidgets('badge gagné affiche emoji_events + check_circle', (t) async {
      await db.insertEarnedBadgeIfAbsent(EarnedBadgesCompanion.insert(
        id: 'uuid-1', badgeId: ReadingBadgeIds.firstBookEver, unlockedAt: DateTime(2026, 1, 15),
      ));
      await t.pumpWidget(wrap());
      await t.pumpAndSettle();
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('badge gagné supprime le label PROCHAIN OBJECTIF de sa catégorie', (t) async {
      await db.insertEarnedBadgeIfAbsent(EarnedBadgesCompanion.insert(
        id: 'uuid-1', badgeId: ReadingBadgeIds.firstBookEver, unlockedAt: DateTime(2026, 1, 15),
      ));
      await t.pumpWidget(wrap());
      await t.pumpAndSettle();
      // firstBookEver gagné → books10 devient PROCHAIN OBJECTIF dans sa catégorie
      // les 2 autres catégories conservent leur propre PROCHAIN OBJECTIF
      expect(find.text('PROCHAIN OBJECTIF'), findsNWidgets(3));
    });
  });
}
