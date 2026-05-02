import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../db/app_db.dart';
import '../data/reading_repository.dart';
import '../domain/reading_session_store.dart';

final _dateTimeFmt = DateFormat("dd/MM/yyyy 'à' HH:mm");

String readingResumeProgressLabel(ReadingProgressRow p) {
  if (p.usePercentage) {
    return 'Progression : ${p.progressPercent ?? 0} %';
  }
  if (p.totalPages != null && p.totalPages! > 0) {
    return 'Page ${p.currentPage} / ${p.totalPages}';
  }
  return 'Page ${p.currentPage}';
}

String readingLastSessionCaption(
  ReadingSessionStore store,
  String bookId,
  DateTime? lastSessionEnd,
) {
  final active = store.activeSession;
  if (active != null && active.bookId == bookId) {
    return 'Séance ouverte — depuis le ${_dateTimeFmt.format(active.startedAt.toLocal())}';
  }
  if (lastSessionEnd != null) {
    return 'Dernière lecture : ${_dateTimeFmt.format(lastSessionEnd.toLocal())}';
  }
  return 'Aucune séance terminée enregistrée sur ce livre';
}

/// Démarre ou reprend une séance pour [b], gère le conflit « autre livre », snackbar, puis [popCount] `pop`.
Future<void> startOrResumeReadingSession(
  BuildContext context,
  Book b, {
  int popCount = 0,
}) async {
  final store = context.read<ReadingSessionStore>();
  final repo = context.read<ReadingRepository>();
  final progressBefore = await repo.getOrCreateProgress(b.id);

  var result = await store.startOrResumeSession(b.id);
  if (!context.mounted) return;

  if (result == StartSessionResult.conflictOtherBook) {
    final other = store.activeBook?.title ?? 'un autre livre';
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Séance en cours'),
        content: Text(
          'Une séance est déjà ouverte sur « $other ». '
          'Terminer cette séance pour en démarrer une nouvelle sur ce livre ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Terminer l’ancienne'),
          ),
        ],
      ),
    );
    if (go != true || !context.mounted) return;
    await store.abandonActiveSessionForSwitch();
    result = await store.startOrResumeSession(b.id);
    if (!context.mounted) return;
  }

  final p = await repo.getOrCreateProgress(b.id);
  final msg = result == StartSessionResult.resumedSameBook
      ? 'Reprise — page ${p.currentPage}'
      : 'Séance démarrée — reprise page ${progressBefore.currentPage}';

  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  final nav = Navigator.of(context);
  for (var i = 0; i < popCount; i++) {
    if (!context.mounted) return;
    nav.pop();
  }
}
