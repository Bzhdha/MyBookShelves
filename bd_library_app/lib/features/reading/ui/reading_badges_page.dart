import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../db/app_db.dart';
import '../domain/reading_badge_catalog.dart';

class ReadingBadgesPage extends StatelessWidget {
  const ReadingBadgesPage({super.key});

  static final _dateFmt = DateFormat.yMMMd('fr_FR');

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDb>();
    return Scaffold(
      appBar: AppBar(title: const Text('Badges de lecture')),
      body: FutureBuilder<List<EarnedBadgeRow>>(
        future: db.allEarnedBadgesOrdered(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final rows = snap.data!;
          if (rows.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Aucun badge pour l’instant. Termine un livre depuis une séance de lecture pour en débloquer.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: rows.length,
            separatorBuilder: (_, _) => const SizedBox(height: 4),
            itemBuilder: (context, i) {
              final r = rows[i];
              final meta = readingBadgeMeta(r.badgeId);
              final title = meta?.title ?? r.badgeId;
              final subtitle = meta?.description;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      title.isNotEmpty
                          ? title.substring(0, 1).toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(title),
                  subtitle: subtitle != null
                      ? Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      : null,
                  isThreeLine: subtitle != null,
                  trailing: Text(
                    _dateFmt.format(r.unlockedAt.toLocal()),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
