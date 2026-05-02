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
      appBar: AppBar(title: const Text('Étagères thématiques')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle étagère'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ShelfEditPage()),
        ),
      ),
      body: StreamBuilder<List<Shelf>>(
        stream: shelfService.watchAllShelves(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snapshot.data!;
          if (all.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aucune étagère.\nCréez des étagères pour classer vos livres par thème.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Groupement client-side
          final roots = all.where((s) => s.parentId == null).toList();
          final byParent = <String, List<Shelf>>{};
          for (final s in all.where((s) => s.parentId != null)) {
            byParent.putIfAbsent(s.parentId!, () => []).add(s);
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80, top: 8),
            itemCount: roots.length,
            itemBuilder: (context, i) {
              final root = roots[i];
              final children = byParent[root.id] ?? [];
              return _ShelfRootTile(
                shelf: root,
                children: children,
              );
            },
          );
        },
      ),
    );
  }
}

// ── Tuile racine (avec expansion si elle a des enfants) ────────────────────

class _ShelfRootTile extends StatelessWidget {
  final Shelf shelf;
  final List<Shelf> children;

  const _ShelfRootTile({required this.shelf, required this.children});

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(shelf.color);
    final shelfService = context.read<ShelfService>();

    if (children.isEmpty) {
      // Étagère racine sans enfants : ListTile classique
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: const Icon(Icons.menu_book, color: Colors.white, size: 20),
        ),
        title: Text(shelf.name),
        subtitle: _BookCount(shelfId: shelf.id, shelfService: shelfService),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.create_new_folder_outlined, size: 20),
              tooltip: 'Ajouter une sous-étagère',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShelfEditPage(initialParentId: shelf.id),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              tooltip: 'Modifier ou supprimer',
              onPressed: () => _editOrDelete(context, shelf),
            ),
          ],
        ),
        onTap: () => _openBooks(context, shelf, hasChildren: false),
      );
    }

    // Étagère racine avec enfants : ExpansionTile
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      clipBehavior: Clip.hardEdge,
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: CircleAvatar(
          backgroundColor: color,
          child: const Icon(Icons.folder_open, color: Colors.white, size: 20),
        ),
        title: Text(shelf.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${children.length} sous-étagère${children.length > 1 ? 's' : ''}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.create_new_folder_outlined, size: 20),
              tooltip: 'Ajouter une sous-étagère',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShelfEditPage(initialParentId: shelf.id),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              tooltip: 'Modifier ou supprimer',
              onPressed: () => _editOrDelete(context, shelf),
            ),
          ],
        ),
        onExpansionChanged: (_) {},
        // Tuile "Tous les livres" de la catégorie parente
        children: [
          ListTile(
            contentPadding: const EdgeInsets.only(left: 32, right: 16),
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.4),
              radius: 14,
              child: const Icon(Icons.layers, size: 16, color: Colors.white),
            ),
            title: const Text('Tous les livres'),
            subtitle: _BookCountWithChildren(
              shelfId: shelf.id,
              shelfService: shelfService,
            ),
            onTap: () => _openBooks(context, shelf, hasChildren: true),
          ),
          ...children.map((child) => _ShelfChildTile(child: child, parentColor: color)),
        ],
      ),
    );
  }

  void _openBooks(BuildContext context, Shelf s, {required bool hasChildren}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ShelfBooksPage(shelf: s, includeChildren: hasChildren),
      ),
    );
  }

  Future<void> _editOrDelete(BuildContext context, Shelf s) async {
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
            if (s.id != DefaultUnclassifiedShelf.id)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Supprimer',
                    style: TextStyle(color: Colors.red)),
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
        MaterialPageRoute(builder: (_) => ShelfEditPage(shelf: s)),
      );
    } else if (action == 'delete') {
      final hasChildren =
          (await context.read<ShelfService>().getChildShelves(s.id)).isNotEmpty;
      if (!context.mounted) return;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Supprimer l\'étagère ?'),
          content: Text(hasChildren
              ? '« ${s.name} » sera supprimée. Ses sous-étagères seront conservées au niveau principal. Les livres ne sont pas supprimés.'
              : '« ${s.name} » sera supprimée. Les livres ne seront pas supprimés, seulement le classement.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Supprimer')),
          ],
        ),
      );
      if (confirm == true && context.mounted) {
        final ok = await context.read<ShelfService>().deleteShelf(s.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(ok
                ? 'Étagère supprimée'
                : 'L\'étagère « ${DefaultUnclassifiedShelf.name} » ne peut pas être supprimée.'),
          ));
        }
      }
    }
  }

  static Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
    return const Color(0xFF6200EE);
  }
}

// ── Tuile enfant (sous-étagère) ───────────────────────────────────────────

class _ShelfChildTile extends StatelessWidget {
  final Shelf child;
  final Color parentColor;

  const _ShelfChildTile({required this.child, required this.parentColor});

  @override
  Widget build(BuildContext context) {
    final shelfService = context.read<ShelfService>();
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 32, right: 16),
      leading: CircleAvatar(
        backgroundColor: _parseColor(child.color),
        radius: 14,
        child: const Icon(Icons.menu_book, color: Colors.white, size: 14),
      ),
      title: Text(child.name),
      subtitle: _BookCount(shelfId: child.id, shelfService: shelfService),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, size: 20),
        tooltip: 'Modifier ou supprimer',
        onPressed: () => _editOrDelete(context, child),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              _ShelfBooksPage(shelf: child, includeChildren: false),
        ),
      ),
    );
  }

  Future<void> _editOrDelete(BuildContext context, Shelf s) async {
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
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer',
                  style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted || action == null) return;
    if (action == 'edit') {
      await Navigator.push(
          context, MaterialPageRoute(builder: (_) => ShelfEditPage(shelf: s)));
    } else if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Supprimer la sous-étagère ?'),
          content: Text(
              '« ${s.name} » sera supprimée. Les livres ne seront pas supprimés.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Supprimer')),
          ],
        ),
      );
      if (confirm == true && context.mounted) {
        await context.read<ShelfService>().deleteShelf(s.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sous-étagère supprimée')));
        }
      }
    }
  }

  static Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
    return const Color(0xFF6200EE);
  }
}

// ── Compteurs réactifs ────────────────────────────────────────────────────

class _BookCount extends StatelessWidget {
  final String shelfId;
  final ShelfService shelfService;
  const _BookCount({required this.shelfId, required this.shelfService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Book>>(
      stream: shelfService.watchBooksByShelf(shelfId),
      builder: (_, snap) {
        final n = snap.data?.length ?? 0;
        return Text('$n livre${n > 1 ? 's' : ''}');
      },
    );
  }
}

class _BookCountWithChildren extends StatelessWidget {
  final String shelfId;
  final ShelfService shelfService;
  const _BookCountWithChildren(
      {required this.shelfId, required this.shelfService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Book>>(
      stream: shelfService.watchBooksInShelfWithChildren(shelfId),
      builder: (_, snap) {
        final n = snap.data?.length ?? 0;
        return Text('$n livre${n > 1 ? 's' : ''} au total');
      },
    );
  }
}

// ── Page liste des livres d'une étagère ───────────────────────────────────

class _ShelfBooksPage extends StatelessWidget {
  final Shelf shelf;
  final bool includeChildren;

  const _ShelfBooksPage({required this.shelf, required this.includeChildren});

  @override
  Widget build(BuildContext context) {
    final shelfService = context.read<ShelfService>();
    final color = _parseColor(shelf.color);

    final stream = includeChildren
        ? shelfService.watchBooksInShelfWithChildren(shelf.id)
        : shelfService.watchBooksByShelf(shelf.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(shelf.name),
        backgroundColor: color,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'edit') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ShelfEditPage(shelf: shelf)),
                );
              } else if (value == 'delete') {
                final hasChildren =
                    (await shelfService.getChildShelves(shelf.id)).isNotEmpty;
                if (!context.mounted) return;
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Supprimer l\'étagère ?'),
                    content: Text(hasChildren
                        ? '« ${shelf.name} » sera supprimée. Ses sous-étagères seront conservées. Les livres ne sont pas supprimés.'
                        : '« ${shelf.name} » sera supprimée. Les livres ne seront pas supprimés.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annuler')),
                      FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Supprimer')),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  final ok = await shelfService.deleteShelf(shelf.id);
                  if (context.mounted) {
                    if (ok) Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(ok
                          ? 'Étagère supprimée'
                          : 'L\'étagère système ne peut pas être supprimée.'),
                    ));
                  }
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Modifier')),
              if (shelf.id != DefaultUnclassifiedShelf.id)
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Supprimer',
                      style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<Book>>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final books = snapshot.data!;
          if (books.isEmpty) {
            return const Center(
                child: Text('Aucun livre dans cette étagère.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final b = books[index];
              final cp = b.coverLocalPath;
              final hasCover = cp != null && cp.trim().isNotEmpty;
              return ListTile(
                leading: SizedBox(
                  width: 40,
                  height: 56,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: hasCover
                        ? Image.file(File(cp),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder())
                        : _placeholder(),
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
                      builder: (_) => BookDetailPage(bookId: b.id)),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static Widget _placeholder() => Container(
        color: Colors.grey.shade300,
        child: const Icon(Icons.menu_book, size: 28),
      );

  static Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
    return const Color(0xFF6200EE);
  }
}
