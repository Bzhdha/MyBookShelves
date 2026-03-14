import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../db/app_db.dart';
import '../features/books/domain/book_service.dart';
import 'copy_form_page.dart';
import 'copy_my_review_page.dart';

class BookDetailPage extends StatefulWidget {
  final String bookId;
  const BookDetailPage({super.key, required this.bookId});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  Book? book;
  List<Copy> copies = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    final service = context.read<BookService>();
    final b = await service.getBook(widget.bookId);
    final c = await service.getCopies(widget.bookId);

    setState(() {
      book = b;
      copies = c;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (book == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(book!.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Supprimer le livre',
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Supprimer ce livre ?'),
                  content: const Text(
                    'Cela supprimera aussi tous les exemplaires associés.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Supprimer'),
                    ),
                  ],
                ),
              );

              if (ok != true || !context.mounted) return;

              final service = context.read<BookService>();
              await service.deleteBook(book!.id);

              if (!context.mounted) return;
              Navigator.pop(context); // retour à la liste
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Ajouter un exemplaire'),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CopyFormPage(bookId: book!.id),
            ),
          );
          await _load();
        },
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('ISBN: ${book!.isbn ?? "-"}'),
          Text('Auteurs: ${book!.authors}'),
          Text('Tome: ${book!.volumeNumber ?? "-"}'),
          const Divider(height: 32),
          const Text('Exemplaires', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (copies.isEmpty)
            const Text('Aucun exemplaire enregistré.')
          else
            ...copies.map((c) => Card(
                  child: ListTile(
                    title: Text('Note: ${c.rating}/5  | Etat: ${c.condition}/5'),
                    subtitle: Text([
                      if (c.location != null) 'Lieu: ${c.location}',
                      if (c.review.isNotEmpty) 'Avis: ${c.review}',
                    ].join(' • ')),
                    trailing: IconButton(
                      icon: const Icon(Icons.rate_review_outlined),
                      tooltip: 'Mon avis (famille)',
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CopyMyReviewPage(copyId: c.id),
                          ),
                        );
                        await _load();
                      },
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CopyFormPage(bookId: book!.id, copyId: c.id),
                        ),
                      );
                      await _load();
                    },
                  ),
                )),
        ],
      ),
    );
  }
}
