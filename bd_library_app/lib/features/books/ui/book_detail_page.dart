import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../db/app_db.dart';
import '../data/cover_cache_service.dart';
import '../domain/book_service.dart';
import '../../shelves/domain/shelf_service.dart';
import '../../users/domain/active_user_store.dart';
import '../../reading/data/reading_repository.dart';
import '../../reading/domain/reading_session_store.dart';
import '../../reading/ui/end_reading_session_sheet.dart';
import '../../reading/ui/reading_session_flow.dart';
import 'copy_form_page.dart';
import 'cover_ocr_zones_page.dart';
import 'cover_photo_page.dart';
import 'cover_search_sheet.dart';
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
  /// Même proportion que sur l’accueil ([BookCarousel] : 100×140).
  static const double _coverDisplayAspectRatio = 100 / 140;

  Book? book;
  List<Copy> copies = [];
  List<Shelf> bookShelves = [];
  String? _seriesName;
  List<Book> _seriesSiblings = [];
  String? _backCoverPath;
  Map<String, UserCopyMeta> _copyMetas = {};
  Map<String, String> _userNameById = {};
  ReadingProgressRow? _readingProgress;
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
    final seriesName = await bookService.getSeriesNameForBookId(b?.seriesId);
    final siblings =
        b != null ? await bookService.getSiblingBooksInSeries(b.id) : <Book>[];
    final c = await bookService.getCopies(widget.bookId);
    final shelfIds = await shelfService.getShelfIdsForBook(widget.bookId);
    final allShelves = await shelfService.getAllShelves();
    final shelves = allShelves.where((s) => shelfIds.contains(s.id)).toList();
    final backPath = await coverCache.backCoverPathForBook(widget.bookId);
    final progress = await context.read<ReadingRepository>().getOrCreateProgress(widget.bookId);

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
      _seriesName = seriesName;
      _seriesSiblings = siblings;
      copies = c;
      bookShelves = shelves;
      _backCoverPath = backPath;
      _readingProgress = progress;
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
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 +
              MediaQuery.paddingOf(context).bottom +
              kFloatingActionButtonMargin +
              72,
        ),
        children: [
          _buildCoversSection(context),
          const SizedBox(height: 16),
          _buildReadingSection(context),
          const SizedBox(height: 16),
          _buildMetadataSearchSection(context),
          const SizedBox(height: 16),
          Text('ISBN: ${book!.isbn ?? "-"}'),
          Text('Auteurs: ${book!.authors}'),
          Text('Éditeur: ${book!.publisher?.trim().isNotEmpty == true ? book!.publisher! : "-"}'),
          Text(
            'Série: ${_seriesName?.trim().isNotEmpty == true ? _seriesName! : "-"}',
          ),
          Text('Tome: ${book!.volumeNumber ?? "-"}'),
          if (_seriesSiblings.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Autres tomes',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            ..._seriesSiblings.map((other) {
              final vol = other.volumeNumber;
              final subtitle = vol != null ? 'Tome $vol' : null;
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(other.title),
                subtitle: subtitle != null ? Text(subtitle) : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookDetailPage(bookId: other.id),
                    ),
                  );
                  if (mounted) await _load();
                },
              );
            }),
          ],
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

  Widget _buildReadingSection(BuildContext context) {
    final p = _readingProgress;
    if (p == null) return const SizedBox.shrink();
    return Consumer<ReadingSessionStore>(builder: (ctx, store, _) {
      final isActiveHere = store.activeSession?.bookId == widget.bookId;
      final s = p.status;
      final (label, color, icon) = s == ReadingStatusValues.finished
          ? ('Terminé', Colors.green, Icons.check_circle)
          : s == ReadingStatusValues.inProgress
              ? ('En cours', Colors.blue, Icons.auto_stories)
              : ('À lire', Colors.grey, Icons.bookmark_border);
      String? prog;
      if (s != ReadingStatusValues.toRead) {
        if (p.usePercentage) {
          prog = '${p.progressPercent ?? 0} %';
        } else if ((p.totalPages ?? 0) > 0) {
          prog = 'Page ${p.currentPage} / ${p.totalPages}';
        } else if (p.currentPage > 0) {
          prog = 'Page ${p.currentPage}';
        }
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Lecture', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          if (prog != null) ...[
            const SizedBox(width: 12),
            Text(prog, style: Theme.of(context).textTheme.bodySmall),
          ],
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 4, children: [
          if (s == ReadingStatusValues.toRead && !isActiveHere)
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('Commencer la lecture'),
              onPressed: () => _startReading(context),
            ),
          if (s == ReadingStatusValues.inProgress && !isActiveHere)
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('Reprendre la lecture'),
              onPressed: () => _startReading(context),
            ),
          if (isActiveHere)
            FilledButton.icon(
              icon: const Icon(Icons.stop, size: 18),
              label: const Text('Interrompre la lecture'),
              style: FilledButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () async {
                await showEndReadingSessionSheet(context);
                if (mounted) await _load();
              },
            ),
          if (s != ReadingStatusValues.finished)
            OutlinedButton.icon(
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Marquer comme lu'),
              onPressed: () => _markAsRead(context),
            ),
          if (s == ReadingStatusValues.finished)
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Remettre à lire'),
              onPressed: () => _markAsToRead(context),
            ),
        ]),
      ]);
    });
  }

  Future<void> _startReading(BuildContext context) async {
    await startOrResumeReadingSession(context, book!);
    if (mounted) await _load();
  }

  Future<void> _markAsRead(BuildContext context) async {
    final repo = context.read<ReadingRepository>();
    final now = DateTime.now();
    await repo.upsertProgress(ReadingProgressCompanion(
      bookId: Value(widget.bookId),
      status: const Value(ReadingStatusValues.finished),
      readingFinishedAt: Value(now),
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Livre marqué comme lu')));
      await _load();
    }
  }

  Future<void> _markAsToRead(BuildContext context) async {
    final repo = context.read<ReadingRepository>();
    await repo.upsertProgress(ReadingProgressCompanion(
      bookId: Value(widget.bookId),
      status: const Value(ReadingStatusValues.toRead),
    ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Livre remis dans la liste « À lire »')));
      await _load();
    }
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
              icon: const Icon(Icons.image_search, size: 18),
              label: const Text('Rechercher couverture en ligne'),
              onPressed: () async {
                final applied = await CoverSearchSheet.show(context, book!);
                if (mounted && applied == true) await _load();
              },
            ),
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
    final r = await FilePicker.pickFiles(type: FileType.image);
    if (!mounted) return;
    final path = r?.files.single.path;
    if (path == null) return;
    await _openCoverOcr(context, path);
  }

  Future<void> _replaceCoverOrBack(BuildContext context, {required bool isCover}) async {
    final existingPath = isCover ? book!.coverLocalPath : _backCoverPath;
    final hasExisting = existingPath != null &&
        existingPath.trim().isNotEmpty &&
        File(existingPath).existsSync();
    final result = await Navigator.push<CoverPhotoResult>(
      context,
      MaterialPageRoute(
        builder: (_) => CoverPhotoPage(
          bookId: widget.bookId,
          onlySuffix: isCover ? 'cover' : 'back',
          initialImagePath: hasExisting ? existingPath : null,
        ),
      ),
    );
    if (!mounted || result == null) return;
    if (isCover && result.coverPath != null) {
      await context.read<BookService>().updateBookCoverFromScan(widget.bookId, result.coverPath!);
    }
    setState(() {
      if (isCover) {
        _coverImageVersion++;
      } else {
        _backImageVersion++;
      }
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
          child: AspectRatio(
            aspectRatio: _coverDisplayAspectRatio,
            child: Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _coverPlaceholder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _coverPlaceholder() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(child: Icon(Icons.photo_library_outlined, size: 48)),
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
              final onlyDefault = bookShelves.length == 1 &&
                  shelf.id == DefaultUnclassifiedShelf.id;
              return Chip(
                avatar: CircleAvatar(backgroundColor: color),
                label: Text(shelf.name),
                onDeleted: onlyDefault
                    ? null
                    : () => _removeFromShelf(context, shelf.id),
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

    // Groupement pour affichage hiérarchique
    final roots = allShelves.where((s) => s.parentId == null).toList();
    final byParent = <String, List<Shelf>>{};
    for (final s in allShelves.where((s) => s.parentId != null)) {
      byParent.putIfAbsent(s.parentId!, () => []).add(s);
    }

    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            final items = <Widget>[];
            for (final root in roots) {
              final children = byParent[root.id] ?? [];
              final rootColor = _colorFromHex(root.color);
              if (children.isEmpty) {
                // Étagère racine sans enfants
                final on = selectedIds.contains(root.id);
                items.add(CheckboxListTile(
                  value: on,
                  secondary: CircleAvatar(backgroundColor: rootColor, radius: 14),
                  title: Text(root.name),
                  onChanged: (v) => setModalState(() {
                    if (v == true) selectedIds.add(root.id);
                    else selectedIds.remove(root.id);
                  }),
                ));
              } else {
                // En-tête de catégorie (non sélectionnable directement)
                items.add(Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(children: [
                    CircleAvatar(backgroundColor: rootColor, radius: 10,
                        child: const Icon(Icons.folder, size: 12, color: Colors.white)),
                    const SizedBox(width: 8),
                    Text(root.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        )),
                  ]),
                ));
                // Sous-étagères indentées
                for (final child in children) {
                  final on = selectedIds.contains(child.id);
                  items.add(CheckboxListTile(
                    value: on,
                    contentPadding: const EdgeInsets.only(left: 32, right: 16),
                    secondary: CircleAvatar(
                        backgroundColor: _colorFromHex(child.color), radius: 14),
                    title: Text(child.name),
                    onChanged: (v) => setModalState(() {
                      if (v == true) selectedIds.add(child.id);
                      else selectedIds.remove(child.id);
                    }),
                  ));
                }
              }
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Étagères pour ce livre',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                if (allShelves.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Créez d\'abord des étagères depuis l\'accueil.'),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: SingleChildScrollView(
                      child: Column(children: items),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await shelfService.setBookShelves(
                          widget.bookId, selectedIds.toList());
                      if (mounted) await _load();
                    },
                    child: const Text('Enregistrer'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
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
