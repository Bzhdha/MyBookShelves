import 'package:flutter/material.dart';
import '../data/library_transfer_service.dart';

class ImportReviewPage extends StatefulWidget {
  final ImportPlan plan;
  final Future<void> Function(ImportPlan) onApply;

  const ImportReviewPage({super.key, required this.plan, required this.onApply});

  @override
  State<ImportReviewPage> createState() => _ImportReviewPageState();
}

class _ImportReviewPageState extends State<ImportReviewPage> {
  @override
  Widget build(BuildContext context) {
    final conflicts = widget.plan.conflicts;

    return Scaffold(
      appBar: AppBar(title: const Text('Résolution des conflits')),
      body: conflicts.isEmpty
          ? const Center(child: Text('Aucun conflit détecté.'))
          : ListView.builder(
              itemCount: conflicts.length,
              itemBuilder: (context, index) {
                final c = conflicts[index];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Titre importé: ${c.imported.title}'),
                        const SizedBox(height: 8),
                        DropdownButton<ConflictChoice>(
                          value: c.choice,
                          items: const [
                            DropdownMenuItem(
                              value: ConflictChoice.keepLocal,
                              child: Text('Garder local'),
                            ),
                            DropdownMenuItem(
                              value: ConflictChoice.keepImported,
                              child: Text('Prendre import'),
                            ),
                            DropdownMenuItem(
                              value: ConflictChoice.merge,
                              child: Text('Fusionner'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => c.choice = v);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Appliquer'),
        icon: const Icon(Icons.check),
        onPressed: () async {
          await widget.onApply(widget.plan);
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
  }
}
