import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/app_logger.dart';
import '../../../core/app_theme.dart';
import '../../../db/app_db.dart';
import '../data/badges_prefs.dart';
import '../domain/reading_badge_catalog.dart';
import '../domain/reading_badge_evaluator.dart';

const _cats = [
  ('📖 Jalons de lecture', [
    (ReadingBadgeIds.firstBookEver, '📖'),
    (ReadingBadgeIds.books10, '📚'),
    (ReadingBadgeIds.books25, '🏅'),
    (ReadingBadgeIds.books50, '🥈'),
    (ReadingBadgeIds.books100, '🏆'),
  ]),
  ('⚡ Pionniers', [
    (ReadingBadgeIds.pioneerWeek, '⚡'),
    (ReadingBadgeIds.pioneerMonth, '🌙'),
    (ReadingBadgeIds.pioneerYear, '⭐'),
  ]),
  ('🎯 Collectionneurs de séries', [
    (ReadingBadgeIds.firstSeriesComplete, '🎯'),
    (ReadingBadgeIds.seriesCollector5, '🎖️'),
    (ReadingBadgeIds.seriesCollector10, '👑'),
  ]),
];

const _total = 11;

// ── États visuels centralisés ────────────────────────────────────────────────
enum _BS { earned, next, locked }

typedef _BStyle = ({Color border, double bw, double emojiOp, Color titleC, Color descC, Color bgLeft});

_BStyle _bstyle(_BS s) => switch (s) {
  _BS.earned => (
    border: kPaper, bw: 2.0, emojiOp: 1.0,
    titleC: kPaper, descC: kPaper,
    bgLeft: kPaper.withValues(alpha: .12),
  ),
  _BS.next => (
    border: kYellow.withValues(alpha: .5), bw: 1.5, emojiOp: .7,
    titleC: kPaper.withValues(alpha: .8), descC: kPaper.withValues(alpha: .65),
    bgLeft: kYellow.withValues(alpha: .06),
  ),
  _BS.locked => (
    border: kBorder, bw: 1.0, emojiOp: .35,
    titleC: kMuted, descC: kMuted.withValues(alpha: .75),
    bgLeft: Colors.transparent,
  ),
};

class ReadingBadgesPage extends StatefulWidget {
  const ReadingBadgesPage({super.key});
  @override
  State<ReadingBadgesPage> createState() => _ReadingBadgesPageState();
}

class _ReadingBadgesPageState extends State<ReadingBadgesPage> {
  static final _fmt = DateFormat.yMMMd('fr_FR');
  late final Stream<List<EarnedBadgeRow>> _stream;
  bool _syncing = true;
  int? _loggedEarnedCount;

  @override
  void initState() {
    super.initState();
    final db = context.read<AppDb>();
    context.read<AppLogger>().log('ReadingBadgesPage.open');
    _stream = db.watchEarnedBadges();
    ReadingBadgeEvaluator(db).syncMilestoneBadgesFromProgress().whenComplete(() {
      if (!mounted) return;
      setState(() => _syncing = false);
      context.read<AppLogger>().log('ReadingBadgesPage.syncComplete');
    });
  }

  @override
  Widget build(BuildContext ctx) {
    final prefs=ctx.watch<BadgesPrefs>();
    return Scaffold(
    backgroundColor: prefs.bg,
    appBar: AppBar(
      title: const Text('Badges de lecture'),
      actions: [
        if (_syncing)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: kInk)),
          ),
        PopupMenuButton<Color>(
          icon: const Icon(Icons.palette_outlined),
          tooltip: 'Couleur de fond',
          itemBuilder: (_) => BadgesPrefs.options.map((o) {
            final (c, label) = o;
            return PopupMenuItem(
              value: c,
              child: Row(children: [
                Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    color: c,
                    border: Border.all(color: c==prefs.bg ? kYellow : kBorder, width: c==prefs.bg ? 2 : 1),
                  ),
                ),
                const SizedBox(width: 10),
                Text(label, style: tMono(11, c: kPaper)),
              ]),
            );
          }).toList(),
          onSelected: (c) {
            ctx.read<AppLogger>().log('ReadingBadgesPage.bgColorChanged', {'color': '#${c.value.toRadixString(16)}'});
            ctx.read<BadgesPrefs>().setBg(c);
          },
        ),
      ],
    ),
    body: StreamBuilder<List<EarnedBadgeRow>>(
      stream: _stream,
      initialData: const [],
      builder: (ctx, snap) {
        if (snap.hasError) return Center(child: Text('Erreur: ${snap.error}', style: const TextStyle(color: kRed)));
        final earned = {for (final r in snap.data ?? <EarnedBadgeRow>[]) r.badgeId: r};
        if (_loggedEarnedCount != earned.length) {
          _loggedEarnedCount = earned.length;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) ctx.read<AppLogger>().log('ReadingBadgesPage.badgesLoaded', {
              'earnedCount': earned.length,
              'earnedIds': earned.keys.join(', '),
            });
          });
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            _ProgressBanner(count: earned.length),
            ..._cats.expand<Widget>((cat) {
              var nextFound = false;
              final widgets = <Widget>[_CatHeader(cat.$1)];
              for (final b in cat.$2) {
                final row = earned[b.$1];
                final isNext = !nextFound && row == null;
                if (isNext) nextFound = true;
                widgets.add(_BadgeRow(badgeId: b.$1, emoji: b.$2, row: row, fmt: _fmt, isNext: isNext));
              }
              return widgets;
            }),
          ],
        );
      },
    ),
  );
}
}

class _ProgressBanner extends StatelessWidget {
  const _ProgressBanner({required this.count});
  final int count;

  @override
  Widget build(BuildContext ctx) {
    final done = count == _total;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPanelBg,
        border: Border.all(color: done ? kYellow : kBorder, width: done ? 2 : 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('$count', style: tBebas(52, c: kYellow)),
          Padding(
            padding: const EdgeInsets.only(left: 6, top: 8),
            child: Text('/ $_total\nbadges', style: tSerif(13, c: kMuted)),
          ),
          const Spacer(),
          if (done)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              color: kYellow,
              child: Text('COMPLET', style: tBebas(14, c: kInk, ls: 2)),
            ),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.zero,
          child: LinearProgressIndicator(
            value: count / _total,
            backgroundColor: kBorder,
            valueColor: const AlwaysStoppedAnimation(kYellow),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          count == 0
              ? 'Lance ta première lecture pour décrocher ton premier badge !'
              : done
                  ? 'Bravo ! Tu as débloqué tous les badges. Tu es un(e) maître des BD !'
                  : '$count badge${count > 1 ? 's' : ''} décroché${count > 1 ? 's' : ''} — ${count < 4 ? 'beau départ' : 'belle progression'}, continue !',
          style: tSerif(12, italic: true, c: count == 0 ? kMuted : kPaper),
        ),
      ]),
    );
  }
}

class _CatHeader extends StatelessWidget {
  const _CatHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext ctx) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text(label, style: tBebas(15, c: kYellow, ls: 2)),
  );
}

class _BadgeRow extends StatelessWidget {
  const _BadgeRow({required this.badgeId, required this.emoji, required this.row, required this.fmt, this.isNext = false});
  final String badgeId, emoji;
  final EarnedBadgeRow? row;
  final DateFormat fmt;
  final bool isNext;

  @override
  Widget build(BuildContext ctx) {
    final meta = readingBadgeMeta(badgeId);
    final ok = row != null;
    final bs = ok ? _BS.earned : isNext ? _BS.next : _BS.locked;
    final st = _bstyle(bs);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: kPanelBg,
        border: Border.all(color: st.border, width: st.bw),
      ),
      child: Row(children: [
        Container(
          width: 70, height: 70,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: st.bgLeft,
            border: Border(right: BorderSide(color: st.border, width: st.bw)),
          ),
          child: Opacity(opacity: st.emojiOp, child: Text(emoji, style: const TextStyle(fontSize: 34))),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (bs == _BS.next) ...[
                Text('PROCHAIN OBJECTIF', style: tMono(8, c: kYellow.withValues(alpha: .7), ls: 1.5)),
                const SizedBox(height: 3),
              ],
              Text(meta?.title ?? badgeId, style: tBebas(15, c: st.titleC, ls: 1)),
              const SizedBox(height: 3),
              Text(meta?.description ?? '', style: tSerif(12, c: st.descC), maxLines: 2, overflow: TextOverflow.ellipsis),
              if (ok) ...[
                const SizedBox(height: 5),
                Row(children: [
                  const Icon(Icons.check_circle, color: kYellow, size: 12),
                  const SizedBox(width: 4),
                  Text(fmt.format(row!.unlockedAt.toLocal()), style: tMono(9, c: kYellow)),
                ]),
              ],
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: switch (bs) {
            _BS.earned => const Icon(Icons.emoji_events, color: kYellow, size: 22),
            _BS.next   => Icon(Icons.radio_button_unchecked, color: kYellow.withValues(alpha: .5), size: 20),
            _BS.locked => const Icon(Icons.lock_outline, color: kMuted, size: 18),
          },
        ),
      ]),
    );
  }
}
