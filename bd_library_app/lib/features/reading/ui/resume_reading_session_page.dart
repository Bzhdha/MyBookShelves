import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../db/app_db.dart';
import '../data/reading_repository.dart';
import '../domain/reading_session_store.dart';
import '../../books/ui/book_detail_page.dart';
import 'reading_session_flow.dart';

/// Écran dédié depuis l’accueil « Reprendre la lecture » : rappel de la page, puis lancement de séance.
class ResumeReadingSessionPage extends StatelessWidget {
  const ResumeReadingSessionPage({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context) {
    context.watch<ReadingSessionStore>();
    final repo = context.read<ReadingRepository>();
    final sessionStore = context.read<ReadingSessionStore>();

    return Scaffold(
      appBar: AppBar(title: const Text('Reprendre la lecture')),
      body: FutureBuilder<(Book?, ReadingProgressRow?, DateTime?)>(
        future: repo.resumeSnapshotForBook(bookId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Impossible de charger ce livre.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final book = snap.data!.$1;
          final progress = snap.data!.$2;
          final lastEnd = snap.data!.$3;
          if (book == null || progress == null) {
            return const Center(child: Text('Livre introuvable.'));
          }

          final coverPath = book.coverLocalPath;
          final hasCover = coverPath != null && coverPath.isNotEmpty;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 140,
                    height: 200,
                    child: hasCover
                        ? Image.file(
                            File(coverPath),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _placeholder(),
                          )
                        : _placeholder(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                book.title.isEmpty ? 'Sans titre' : book.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              if (book.authors.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  book.authors,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Où vous en étiez',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        readingResumeProgressLabel(progress),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        readingLastSessionCaption(
                          sessionStore,
                          book.id,
                          lastEnd,
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => startOrResumeReadingSession(
                  context,
                  book,
                  popCount: 1,
                ),
                icon: const Icon(Icons.auto_stories),
                label: const Text('Lancer la séance de lecture'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookDetailPage(bookId: book.id),
                    ),
                  );
                },
                child: const Text('Voir la fiche livre'),
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _placeholder() {
    return ColoredBox(
      color: Colors.grey.shade300,
      child: const Center(child: Icon(Icons.menu_book, size: 48)),
    );
  }
}
