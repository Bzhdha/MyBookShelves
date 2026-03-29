import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../db/app_db.dart';
import '../data/cover_cache_service.dart';
import '../domain/book_service.dart';
import '../../shelves/domain/shelf_service.dart';
import '../../users/domain/active_user_store.dart';
import 'copy_form_page.dart';
import 'cover_ocr_zones_page.dart';
import 'cover_photo_page.dart';
import 'edit_book_page.dart';
import 'metadata_search_sheet.dart';
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
  String? _backCoverPath;
  Map<String, UserCopyMeta> _copyMetas = {};
  Map<String, String> _userNameById = {};
  /// Incrémenté à chaque remplacement de photo pour forcer le rechargement (éviter le cache Image.file).
  int _coverImageVersion = 0;
  int _backImageVersion = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    final bookService = context.read<BookService>();
    final shelfService = context.read<ShelfService>();
    final coverCache = context.read<CoverCacheService>();
    final db = context.read<AppDb>();
    final userId = context.read<ActiveUserStore>().activeUserId;

    final b = await bookService.getBook(widget.bookId);
    final c = await bookService.getCopies(widget.bookId);
    final shelfIds = await shelfService.getShelfIdsForBook(widget.bookId);
    final allShelves = await shelfService.getAllShelves();
    final shelves = allShelves.where((s) => shelfIds.contains(s.id)).toList();
    final backPath = await coverCache.backCoverPathForBook(widget.bookId);

    Map<String, UserCopyMeta> copyMetas = {};
    Map<String, String> userNameById = {};
    if (userId != null && c.isNotEmpty) {
      final metas = await db.getMetasForUserForCopies(userId, c.map((x) => x.id).toList());
      copyMetas = {for (final m in metas) m.copyId: m};
      final users = await db.getAllUsers();
      userNameById = {for (final u in users) u.id: u.displayName};
    }

    if (!mounted) return;
    setState(() {
      book = b;
      copies = c;
      bookShelves = shelves;
      _backCoverPath = backPath;
      _copyMetas = copyMetas;
      _userNameById = userNameById;
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
            icon: const Icon(Icons.edit),
            tooltip: 'Modifier le livre',
            onPressed: () async {
              await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => EditBookPage(book: book!),
                ),
              );
              if (mounted) await _load();
            },
          ),
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
          _buildCoversSection(context),
          const SizedBox(height: 16),
          _buildMetadataSearchSection(context),
          const SizedBox(height: 16),
          Text('ISBN: ${book!.isbn ?? "-"}'),
          Text('Auteurs: ${book!.authors}'),
          Text('Éditeur: ${book!.publisher?.trim().isNotEmpty == true ? book!.publisher! : "-"}'),
          Text('Tome: ${book!.volumeNumber ?? "-"}'),
          if (book!.summary.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Résumé',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            SelectableText(
              book!.summary,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
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
                      if (_copyMetas[c.id]?.loanedToUserId != null)
                        'Prêté à: ${_userNameById[_copyMetas[c.id]!.loanedToUserId] ?? _copyMetas[c.id]!.loanedToUserId}',
                    ].where((e) => e.isNotEmpty).join(' • ')),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
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
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Supprimer cet exemplaire',
                          onPressed: () => _confirmDeleteCopy(context, c),
                        ),
                      ],
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

  Widget _buildMetadataSearchSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Métadonnées',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextButton.icon(
          icon: const Icon(Icons.search, size: 20),
          label: const Text('Rechercher sur le Web ou par IA'),
          onPressed: () async {
            final applied = await MetadataSearchSheet.show(context, book!);
            if (mounted && applied == true) await _load();
          },
        ),
      ],
    );
  }

  Widget _buildCoversSection(BuildContext context) {
    final coverPath = book!.coverLocalPath;
    final hasCover = coverPath != null && coverPath.trim().isNotEmpty && File(coverPath).existsSync();
    final hasBack = _backCoverPath != null && File(_backCoverPath!).existsSync();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photos',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.photo_camera, size: 18),
              label: const Text('Modifier couverture'),
              onPressed: () => _replaceCoverOrBack(context, isCover: true),
            ),
            TextButton.icon(
              icon: const Icon(Icons.photo_camera, size: 18),
              label: const Text('Modifier dos'),
              onPressed: () => _replaceCoverOrBack(context, isCover: false),
            ),
            if (hasCover && hasBack)
              TextButton.icon(
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: const Text('Inverser couverture et dos'),
                onPressed: () => _swapCoverAndBack(context),
              ),
            if (coverOcrSupportedPlatform()) ...[
              if (hasCover)
                TextButton.icon(
                  icon: const Icon(Icons.document_scanner_outlined, size: 18),
                  label: const Text('Reconnaître texte (couverture)'),
                  onPressed: () => _openCoverOcr(context, coverPath),
                ),
              TextButton.icon(
                icon: const Icon(Icons.image_search, size: 18),
                label: const Text('Reconnaître texte (autre image)'),
                onPressed: () => _pickImageForCoverOcr(context),
              ),
            ],
          ],
        ),
        if (!hasCover && !hasBack)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Aucune photo. Utilisez « Modifier couverture » ou « Modifier dos » pour ajouter des images.',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasCover)
                Expanded(
                  key: ValueKey('cover_$_coverImageVersion'),
                  child: _coverImage(coverPath),
                ),
              if (hasCover && hasBack) const SizedBox(width: 12),
              if (hasBack && _backCoverPath != null)
                Expanded(
                  key: ValueKey('back_$_backImageVersion'),
                  child: _coverImage(_backCoverPath!, label: 'Dos'),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _openCoverOcr(BuildContext context, String imagePath) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CoverOcrZonesPage(
          imagePath: imagePath,
          bookId: widget.bookId,
        ),
      ),
    );
    if (mounted) await _load();
  }

  Future<void> _pickImageForCoverOcr(BuildContext context) async {
    final r = await FilePicker.platform.pickFiles(type: FileType.image);
    if (!mounted) return;
    final path = r?.files.single.path;
    if (path == null) return;
    await _openCoverOcr(context, path);
  }

  Future<void> _replaceCoverOrBack(BuildContext context, {required bool isCover}) async {
    final result = await Navigator.push<CoverPhotoResult>(
      context,
      MaterialPageRoute(
        builder: (_) => CoverPhotoPage(
          bookId: widget.bookId,
          onlySuffix: isCover ? 'cover' : 'back',
        ),
      ),
    );
    if (!mounted || result == null) return;
    if (isCover && result.coverPath != null) {
      await context.read<BookService>().updateBookCoverFromScan(widget.bookId, result.coverPath!);
    }
    setState(() {
      if (isCover) _coverImageVersion++;
      else _backImageVersion++;
    });
    await _load();
  }

  Future<void> _swapCoverAndBack(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Inverser couverture et dos'),
        content: const Text(
          'Les deux images seront échangées. Cette action est immédiate.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Inverser'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await context.read<BookService>().swapCoverAndBack(widget.bookId);
    if (!mounted) return;
    await _load();
  }

  Widget _coverImage(String path, {String? label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(path),
            fit: BoxFit.cover,
            height: 200,
            width: double.infinity,
            errorBuilder: (_, __, ___) => _coverPlaceholder(),
          ),
        ),
      ],
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.photo_library_outlined, size: 48),
    );
  }

  Future<void> _confirmDeleteCopy(BuildContext context, Copy c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer cet exemplaire ?'),
        content: const Text(
          'Cette action est irréversible.',
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
    await context.read<BookService>().deleteCopy(c.id);
    if (!context.mounted) return;
    await _load();
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
