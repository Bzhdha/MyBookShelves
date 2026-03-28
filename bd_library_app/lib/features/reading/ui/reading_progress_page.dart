import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../db/app_db.dart';
import '../data/reading_repository.dart';
class ReadingProgressPage extends StatefulWidget {
  const ReadingProgressPage({super.key});

  @override
  State<ReadingProgressPage> createState() => _ReadingProgressPageState();
}

class _ReadingProgressPageState extends State<ReadingProgressPage> {
  Future<void> _reload() async {
    setState(() {});
  }

  double _ratio(ReadingProgressRow p) {
    if (p.usePercentage && p.progressPercent != null) {
      return (p.progressPercent!.clamp(0, 100)) / 100.0;
    }
    final total = p.totalPages;
    if (total != null && total > 0) {
      return (p.currentPage.clamp(0, total)) / total;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ReadingRepository>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progression'),
      ),
      body: FutureBuilder<List<(Book, ReadingProgressRow)>>(
        future: repo.allBooksWithProgress(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final rows = snap.data!;
          if (rows.isEmpty) {
            return const Center(child: Text('Aucun livre dans la bibliothèque'));
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: rows.length,
              itemBuilder: (context, i) {
                final b = rows[i].$1;
                final p = rows[i].$2;
                final r = _ratio(p);
                final label = p.usePercentage
                    ? '${p.progressPercent ?? 0} %'
                    : (p.totalPages != null && p.totalPages! > 0)
                        ? 'p. ${p.currentPage} / ${p.totalPages}'
                        : 'p. ${p.currentPage}';
                return Card(
                  child: ListTile(
                    title: Text(b.title.isEmpty ? 'Sans titre' : b.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 6),
                        LinearProgressIndicator(value: r > 0 ? r : null),
                        const SizedBox(height: 4),
                        Text(label),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () => _editProgress(context, repo, b, p),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _editProgress(
    BuildContext context,
    ReadingRepository repo,
    Book b,
    ReadingProgressRow p,
  ) async {
    final usePct = ValueNotifier<bool>(p.usePercentage);
    final totalCtrl = TextEditingController(
      text: p.totalPages?.toString() ?? '',
    );
    final pageCtrl = TextEditingController(text: p.currentPage.toString());
    final pctCtrl = TextEditingController(
      text: p.progressPercent?.toString() ?? '',
    );

    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Progression — ${b.title}'),
            content: SingleChildScrollView(
              child: ValueListenableBuilder<bool>(
                valueListenable: usePct,
                builder: (context, use, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SwitchListTile(
                        title: const Text('Afficher en pourcentage'),
                        value: use,
                        onChanged: (v) => usePct.value = v,
                      ),
                      if (use) ...[
                        TextField(
                          controller: pctCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Pourcentage (0–100)',
                          ),
                        ),
                      ] else ...[
                        TextField(
                          controller: pageCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Page courante',
                          ),
                        ),
                        TextField(
                          controller: totalCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Nombre de pages (total)',
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Enregistrer'),
              ),
            ],
          );
        },
      );

      if (ok == true && mounted) {
        final use = usePct.value;
        int? pct;
        var cur = p.currentPage;
        int? total = p.totalPages;
        if (use) {
          pct = int.tryParse(pctCtrl.text.trim());
          pct = pct?.clamp(0, 100);
        } else {
          cur = int.tryParse(pageCtrl.text.trim()) ?? cur;
          total = int.tryParse(totalCtrl.text.trim());
        }
        await repo.upsertProgress(
          ReadingProgressCompanion(
            bookId: Value(b.id),
            usePercentage: Value(use),
            progressPercent: use ? Value(pct) : const Value.absent(),
            currentPage: Value(cur),
            totalPages: use ? const Value.absent() : Value(total),
          ),
        );
        if (mounted) setState(() {});
      }
    } finally {
      totalCtrl.dispose();
      pageCtrl.dispose();
      pctCtrl.dispose();
      usePct.dispose();
    }
  }
}
