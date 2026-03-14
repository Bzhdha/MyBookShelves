import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../db/app_db.dart';
import '../domain/book_service.dart';
import '../../shelves/domain/shelf_service.dart';
import 'copy_form_page.dart';
import '../../users/ui/copy_my_review_page.dart';

class BookDetailPage extends StatefulWidget {
  final String bookId;
  const BookDetailPage({super.key, required this.bookId});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  Book? book;
  List<Copy> copies = [];
  List<Shelf> bookShelves = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    final bookService = context.read<BookService>();
    final shelfService = context.read<ShelfService>();
    final b = await bookService.getBook(widget.bookId);
    final c = await bookService.getCopies(widget.bookId);
    final shelfIds = await shelfService.getShelfIdsForBook(widget.bookId);
    final allShelves = await shelfService.getAllShelves();
    final shelves = allShelves.where((s) => shelfIds.contains(s.id)).toList();

    setState(() {
      book = b;
      copies = c;
      bookShelves = shelves;
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
          _buildShelvesSection(context),
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

  Widget _buildShelvesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Étagères',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Classer'),
              onPressed: () => _pickShelves(context),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (bookShelves.isEmpty)
          const Text(
            'Aucune étagère. Utilisez « Classer » pour ajouter ce livre à une étagère thématique.',
            style: TextStyle(color: Colors.grey),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: bookShelves.map((shelf) {
              final color = _colorFromHex(shelf.color);
              return Chip(
                avatar: CircleAvatar(backgroundColor: color),
                label: Text(shelf.name),
                onDeleted: () => _removeFromShelf(context, shelf.id),
              );
            }).toList(),
          ),
      ],
    );
  }

  Future<void> _pickShelves(BuildContext context) async {
    final shelfService = context.read<ShelfService>();
    final allShelves = await shelfService.getAllShelves();
    final currentIds = await shelfService.getShelfIdsForBook(widget.bookId);
    final selectedIds = currentIds.toSet();

    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Étagères pour ce livre',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (allShelves.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Créez d\'abord des étagères depuis l\'accueil.',
                      ),
                    )
                  else
                    ...allShelves.map((shelf) {
                      final on = selectedIds.contains(shelf.id);
                      final color = _colorFromHex(shelf.color);
                      return CheckboxListTile(
                        value: on,
                        secondary: CircleAvatar(
                          backgroundColor: color,
                          radius: 14,
                        ),
                        title: Text(shelf.name),
                        onChanged: (v) {
                          setModalState(() {
                            if (v == true) {
                              selectedIds.add(shelf.id);
                            } else {
                              selectedIds.remove(shelf.id);
                            }
                          });
                        },
                      );
                    }),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: FilledButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await shelfService.setBookShelves(
                          widget.bookId,
                          selectedIds.toList(),
                        );
                        if (mounted) await _load();
                      },
                      child: const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _removeFromShelf(BuildContext context, String shelfId) async {
    final shelfService = context.read<ShelfService>();
    final currentIds = await shelfService.getShelfIdsForBook(widget.bookId);
    final newIds = currentIds.where((id) => id != shelfId).toList();
    await shelfService.setBookShelves(widget.bookId, newIds);
    if (mounted) await _load();
  }

  static Color _colorFromHex(String hex) {
    final h = hex.replaceFirst('#', '');
    if (h.length == 6) {
      return Color(int.parse('FF$h', radix: 16));
    }
    return const Color(0xFF6200EE);
  }
}
