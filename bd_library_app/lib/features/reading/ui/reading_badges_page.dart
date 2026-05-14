import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/app_theme.dart';
import '../../../db/app_db.dart';
import '../domain/reading_badge_catalog.dart';

class ReadingBadgesPage extends StatelessWidget {
  const ReadingBadgesPage({super.key});

  static final _dateFmt = DateFormat.yMMMd('fr_FR');

  static const _catalog = [
    (ReadingBadgeIds.firstBookEver, '📖'),
    (ReadingBadgeIds.books10, '📚'),
    (ReadingBadgeIds.books25, '🏅'),
    (ReadingBadgeIds.books50, '🥈'),
    (ReadingBadgeIds.books100, '🏆'),
    (ReadingBadgeIds.pioneerWeek, '⚡'),
    (ReadingBadgeIds.pioneerMonth, '🌙'),
    (ReadingBadgeIds.pioneerYear, '⭐'),
    (ReadingBadgeIds.firstSeriesComplete, '🎯'),
    (ReadingBadgeIds.seriesCollector5, '🎖️'),
    (ReadingBadgeIds.seriesCollector10, '👑'),
  ];

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDb>();
    return Scaffold(
      appBar: AppBar(title: const Text('Badges de lecture')),
      body: FutureBuilder<List<EarnedBadgeRow>>(
        future: db.allEarnedBadgesOrdered(),
        builder: (ctx, snap) {
          if (snap.hasError) return Center(child: Text('Erreur: ${snap.error}', style: const TextStyle(color: kRed)));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final earned = {for (final r in snap.data!) r.badgeId: r};
          final unlocked = _catalog.where((e) => earned.containsKey(e.$1)).toList();
          final locked = _catalog.where((e) => !earned.containsKey(e.$1)).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            children: [
              if (unlocked.isNotEmpty) ...[
                _sectionHeader(ctx, 'Obtenus (${unlocked.length})'),
                _grid(ctx, unlocked, earned),
                const SizedBox(height: 16),
              ],
              if (locked.isNotEmpty) ...[
                _sectionHeader(ctx, 'À débloquer (${locked.length})'),
                _grid(ctx, locked, earned),
              ],
              if (unlocked.isEmpty && locked.isEmpty)
                Center(child: Text('Aucun badge disponible.', style: Theme.of(ctx).textTheme.bodyLarge)),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(BuildContext ctx, String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Text(label, style: tBebas(18, c: kYellow, ls: 2)),
  );

  Widget _grid(BuildContext ctx, List<(String, String)> items, Map<String, EarnedBadgeRow> earned) =>
    GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.05,
      children: items.map((e) => _BadgeCard(badgeId: e.$1, emoji: e.$2, row: earned[e.$1], dateFmt: _dateFmt)).toList(),
    );
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.badgeId, required this.emoji, required this.row, required this.dateFmt});
  final String badgeId;
  final String emoji;
  final EarnedBadgeRow? row;
  final DateFormat dateFmt;

  @override
  Widget build(BuildContext ctx) {
    final meta = readingBadgeMeta(badgeId);
    final earned = row != null;
    return Container(
      decoration: BoxDecoration(
        color: kPanelBg,
        border: Border.all(color: earned ? kYellow : kBorder, width: earned ? 2 : 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const Spacer(),
            if (!earned) const Icon(Icons.lock_outline, size: 14, color: kMuted),
          ]),
          const SizedBox(height: 6),
          Text(
            meta?.title ?? badgeId,
            style: GoogleFonts.bebasNeue(fontSize: 14, color: earned ? kYellow : kMuted, letterSpacing: 1),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              meta?.description ?? '',
              style: tSerif(11, c: earned ? kPaper : kMuted),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (earned)
            Text(dateFmt.format(row!.unlockedAt.toLocal()), style: tMono(9, c: kYellow)),
        ],
      ),
    );
  }
}
