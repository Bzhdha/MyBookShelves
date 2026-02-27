import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../db/app_db.dart';
import 'copy_form_page.dart';

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
    final db = context.read<AppDb>();
    final b = await db.getBookById(widget.bookId);
    final c = await db.getCopiesByBook(widget.bookId);

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
      appBar: AppBar(title: Text(book!.title)),
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
