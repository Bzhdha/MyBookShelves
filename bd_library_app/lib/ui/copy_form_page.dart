import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

import '../db/app_db.dart';

class CopyFormPage extends StatefulWidget {
  final String bookId;
  final String? copyId;

  const CopyFormPage({super.key, required this.bookId, this.copyId});

  @override
  State<CopyFormPage> createState() => _CopyFormPageState();
}

class _CopyFormPageState extends State<CopyFormPage> {
  int rating = 0;
  int condition = 3;
  String? location;
  String review = '';
  String notes = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    if (widget.copyId == null) return;
    final db = context.read<AppDb>();
    final copies = await db.getCopiesByBook(widget.bookId);
    final c = copies.firstWhere((e) => e.id == widget.copyId);

    setState(() {
      rating = c.rating;
      condition = c.condition;
      location = c.location;
      review = c.review;
      notes = c.notes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDb>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.copyId == null ? 'Nouvel exemplaire' : 'Modifier exemplaire'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Note'),
            Row(
              children: [
                for (int i = 1; i <= 5; i++)
                  IconButton(
                    icon: Icon(i <= rating ? Icons.star : Icons.star_border),
                    onPressed: () => setState(() => rating = i),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Etat (1..5)'),
            Slider(
              min: 1,
              max: 5,
              divisions: 4,
              value: condition.toDouble(),
              label: condition.toString(),
              onChanged: (v) => setState(() => condition = v.toInt()),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Localisation'),
              onChanged: (v) => location = v,
              controller: TextEditingController(text: location),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Avis'),
              minLines: 2,
              maxLines: 5,
              onChanged: (v) => review = v,
              controller: TextEditingController(text: review),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Notes exemplaire'),
              minLines: 2,
              maxLines: 5,
              onChanged: (v) => notes = v,
              controller: TextEditingController(text: notes),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                final id = widget.copyId ?? const Uuid().v4();
                await db.upsertCopy(CopiesCompanion.insert(
                  id: id,
                  bookId: widget.bookId,
                  rating: Value(rating),
                  review: Value(review),
                  condition: Value(condition),
                  location: Value(location),
                  notes: Value(notes),
                  updatedAt: DateTime.now(),
                ));
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
