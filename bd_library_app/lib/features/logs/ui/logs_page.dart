import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_logger.dart';

/// Page d'affichage des logs applicatifs (fonctions appelées et paramètres).
class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  static void _showLogDetailDialog(BuildContext context, AppLogEntry e) {
    final params = e.params!;
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final maxHeight = MediaQuery.sizeOf(ctx).height * 0.7;
        return AlertDialog(
          title: Text(e.function),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500, maxHeight: maxHeight),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  _formatTime(e.at),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                ...params.entries.map((entry) {
                  final valueStr = entry.value?.toString() ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SelectableText(
                            valueStr,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

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
              final hasParams = e.params != null && e.params!.isNotEmpty;
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
                          e.paramsSummary.length > 120
                              ? '${e.paramsSummary.substring(0, 120)}…'
                              : e.paramsSummary,
                          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ),
                  ],
                ),
                isThreeLine: e.paramsSummary.isNotEmpty,
                onTap: hasParams
                    ? () => _showLogDetailDialog(context, e)
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
