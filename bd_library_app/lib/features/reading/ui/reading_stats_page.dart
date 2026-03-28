import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/reading_repository.dart';
import 'reading_formatters.dart';

class ReadingStatsPage extends StatelessWidget {
  const ReadingStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ReadingRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques de lecture')),
      body: FutureBuilder(
        future: Future.wait([
          repo.totalReadingSeconds(),
          repo.genresByReadingTime(),
        ]),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final totalSec = snap.data![0] as int;
          final genres = snap.data![1] as List<(String, int)>;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Temps de lecture total',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                formatReadingDuration(totalSec),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Somme des durées des séances terminées (entre le début et la fin déclarés dans l’app).',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Divider(height: 32),
              Text(
                'Genres / tags favoris (par temps passé)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (genres.isEmpty)
                const Text(
                  'Aucune donnée : renseignez des tags sur vos livres et terminez des séances.',
                )
              else
                ...genres.take(15).map(
                      (e) => ListTile(
                        dense: true,
                        title: Text(e.$1),
                        trailing: Text(formatReadingDuration(e.$2)),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}
