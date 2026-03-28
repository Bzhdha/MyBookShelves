import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../db/app_db.dart';
import '../data/reading_repository.dart';
import '../../books/ui/book_detail_page.dart';
import 'reading_formatters.dart';

class ReadingHistoryPage extends StatelessWidget {
  const ReadingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ReadingRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Historique de lecture')),
      body: FutureBuilder<List<(ReadingSession, Book?)>>(
        future: repo.completedSessionsWithBooks(limit: 200),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final rows = snap.data!;
          if (rows.isEmpty) {
            return const Center(
              child: Text('Aucune séance terminée pour l’instant'),
            );
          }
          return ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, i) {
              final s = rows[i].$1;
              final b = rows[i].$2;
              final title = b?.title ?? 'Livre inconnu';
              final start = s.startedAt;
              final end = s.endedAt;
              final endStr = end != null
                  ? '${end.day}/${end.month}/${end.year} ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}'
                  : '—';
              return ListTile(
                title: Text(title),
                subtitle: Text(
                  'Début : ${start.day}/${start.month}/${start.year} ${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}\n'
                  'Fin : $endStr\n'
                  'Pages ${s.startPage} → ${s.endPage ?? s.startPage} · '
                  '${formatReadingDuration(s.durationSeconds ?? 0)}'
                  '${s.finishedBook ? ' · Livre terminé' : ''}',
                ),
                isThreeLine: true,
                onTap: b != null
                    ? () => Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookDetailPage(bookId: s.bookId),
                          ),
                        )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
