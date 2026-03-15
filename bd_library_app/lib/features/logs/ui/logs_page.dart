import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_logger.dart';

/// Page d'affichage des logs applicatifs (fonctions appelées et paramètres).
class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  static String _formatTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}.${dt.millisecond.toString().padLeft(3, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs applicatifs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Effacer les logs',
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Effacer les logs ?'),
                  content: const Text(
                    'Tous les logs en mémoire seront supprimés.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Effacer'),
                    ),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                context.read<AppLogger>().clear();
              }
            },
          ),
        ],
      ),
      body: Consumer<AppLogger>(
        builder: (context, logger, _) {
          final entries = logger.entries;
          if (entries.isEmpty) {
            return const Center(
              child: Text(
                'Aucun log pour le moment.\nLes appels de fonctions seront enregistrés ici.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final e = entries[index];
              final timeStr = _formatTime(e.at);
              return ListTile(
                title: Text(
                  e.function,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(timeStr, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    if (e.paramsSummary.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          e.paramsSummary,
                          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ),
                  ],
                ),
                isThreeLine: e.paramsSummary.isNotEmpty,
              );
            },
          );
        },
      ),
    );
  }
}
