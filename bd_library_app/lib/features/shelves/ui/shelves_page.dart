import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../db/app_db.dart';
import '../../books/ui/book_detail_page.dart';
import '../domain/shelf_service.dart';
import 'shelf_edit_page.dart';

class ShelvesPage extends StatelessWidget {
  const ShelvesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shelfService = context.watch<ShelfService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Étagères thématiques'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle étagère'),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ShelfEditPage(),
            ),
          );
        },
      ),
      body: StreamBuilder<List<Shelf>>(
        stream: shelfService.watchAllShelves(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final shelves = snapshot.data!;
          if (shelves.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aucune étagère.\nCréez des étagères pour classer vos livres par thème (nom + couleur).',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: shelves.length,
            itemBuilder: (context, index) {
              final shelf = shelves[index];
              final color = _parseColor(shelf.color);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color,
                  child: const Icon(Icons.menu_book, color: Colors.white, size: 20),
                ),
                title: Text(shelf.name),
                subtitle: StreamBuilder<List<Book>>(
                  stream: shelfService.watchBooksByShelf(shelf.id),
                  builder: (context, bookSnap) {
                    final count = bookSnap.hasData ? bookSnap.data!.length : 0;
                    return Text('$count livre${count > 1 ? 's' : ''}');
                  },
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'Modifier ou supprimer l\'étagère',
                  onPressed: () => _editOrDeleteShelf(context, shelf),
                ),
                onTap: () => _openShelfBooks(context, shelf),
                onLongPress: () => _editOrDeleteShelf(context, shelf),
              );
            },
          );
        },
      ),
    );
  }

  void _openShelfBooks(BuildContext context, Shelf shelf) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ShelfBooksPage(shelf: shelf),
      ),
    );
  }

  Future<void> _editOrDeleteShelf(BuildContext context, Shelf shelf) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier'),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            if (shelf.id != DefaultUnclassifiedShelf.id)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
          ],
        ),
      ),
    );
    if (!context.mounted || action == null) return;
    if (action == 'edit') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ShelfEditPage(shelf: shelf),
        ),
      );
    } else if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Supprimer l\'étagère ?'),
          content: Text(
            '« ${shelf.name} » sera supprimée. Les livres ne seront pas supprimés, seulement le classement.',
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
      if (confirm == true && context.mounted) {
        final ok = await context.read<ShelfService>().deleteShelf(shelf.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ok
                    ? 'Étagère supprimée'
                    : 'L\'étagère « ${DefaultUnclassifiedShelf.name} » ne peut pas être supprimée.',
              ),
            ),
          );
        }
      }
    }
  }

  static Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    if (h.length == 6) {
      return Color(int.parse('FF$h', radix: 16));
    }
    return const Color(0xFF6200EE);
  }
}

class _ShelfBooksPage extends StatelessWidget {
  final Shelf shelf;

  const _ShelfBooksPage({required this.shelf});

  @override
  Widget build(BuildContext context) {
    final shelfService = context.read<ShelfService>();
    final color = ShelvesPage._parseColor(shelf.color);

    return Scaffold(
      appBar: AppBar(
        title: Text(shelf.name),
        backgroundColor: color,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Modifier ou supprimer l\'étagère',
            onSelected: (value) async {
              if (value == 'edit') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ShelfEditPage(shelf: shelf),
                  ),
                );
              } else if (value == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Supprimer l\'étagère ?'),
                    content: Text(
                      '« ${shelf.name} » sera supprimée. Les livres ne seront pas supprimés, seulement le classement.',
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
                if (confirm == true && context.mounted) {
                  final ok =
                      await context.read<ShelfService>().deleteShelf(shelf.id);
                  if (context.mounted) {
                    if (ok) Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? 'Étagère supprimée'
                              : 'L\'étagère « ${DefaultUnclassifiedShelf.name} » ne peut pas être supprimée.',
                        ),
                      ),
                    );
                  }
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Modifier l\'étagère')),
              if (shelf.id != DefaultUnclassifiedShelf.id)
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Supprimer l\'étagère', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<Book>>(
        stream: shelfService.watchBooksByShelf(shelf.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final books = snapshot.data!;
          if (books.isEmpty) {
            return const Center(
              child: Text('Aucun livre dans cette étagère.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final b = books[index];
              final coverPath = b.coverLocalPath;
              final hasCover =
                  coverPath != null && coverPath.trim().isNotEmpty;
              return ListTile(
                leading: SizedBox(
                  width: 40,
                  height: 56,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: hasCover
                        ? Image.file(
                            File(coverPath),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _coverPlaceholder(),
                          )
                        : _coverPlaceholder(),
                  ),
                ),
                title: Text(b.title),
                subtitle: Text([
                  if (b.volumeNumber != null) 'T. ${b.volumeNumber}',
                  if (b.authors.trim().isNotEmpty) b.authors,
                ].join(' · ')),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookDetailPage(bookId: b.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static Widget _coverPlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: const Icon(Icons.menu_book, size: 28),
    );
  }
}
