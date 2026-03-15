import 'package:flutter/material.dart';

import '../../../models/export_model.dart';

/// Détail d'un livre dans une bibliothèque importée (lecture seule).
class ImportedBookDetailPage extends StatelessWidget {
  final String libraryName;
  final ExportBook book;
  final List<ExportCopy> copies;

  const ImportedBookDetailPage({
    super.key,
    required this.libraryName,
    required this.book,
    required this.copies,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'ISBN: ${book.isbn ?? "-"}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 4),
          Text('Auteurs: ${book.authors}'),
          if (book.volumeNumber != null) Text('Tome: ${book.volumeNumber}'),
          if (book.publisher != null) Text('Éditeur: ${book.publisher}'),
          if (book.publishedDate != null) Text('Date: ${book.publishedDate}'),
          const Divider(height: 32),
          Text(
            'Exemplaires (${copies.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (copies.isEmpty)
            const Text('Aucun exemplaire')
          else
            ...copies.map((c) => Card(
                  child: ListTile(
                    title: Text('Note: ${c.rating}/5  |  État: ${c.condition}/5'),
                    subtitle: Text([
                      if (c.location != null) 'Lieu: ${c.location}',
                      if (c.review.isNotEmpty) 'Avis: ${c.review}',
                      if (c.notes.isNotEmpty) 'Notes: ${c.notes}',
                    ].join(' • ')),
                  ),
                )),
        ],
      ),
    );
  }
}
