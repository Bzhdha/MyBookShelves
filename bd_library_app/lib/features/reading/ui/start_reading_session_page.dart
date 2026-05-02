import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../db/app_db.dart';
import '../data/reading_repository.dart';
import '../domain/reading_session_store.dart';
import '../../books/ui/book_detail_page.dart';
import '../../books/ui/isbn_scanner_page.dart';
import 'reading_session_flow.dart';

class StartReadingSessionPage extends StatefulWidget {
  const StartReadingSessionPage({super.key});

  @override
  State<StartReadingSessionPage> createState() =>
      _StartReadingSessionPageState();
}

class _StartReadingSessionPageState extends State<StartReadingSessionPage> {
  final _isbnCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  Future<List<(Book, ReadingProgressRow, DateTime?)>>? _inProgressFuture;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.trim());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _inProgressFuture ??=
        context.read<ReadingRepository>().booksInProgressForResume();
  }

  @override
  void dispose() {
    _isbnCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _scanIsbnField() async {
    final isbn = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const IsbnScannerPage(lookupOnly: true),
      ),
    );
    if (!mounted || isbn == null) return;
    _isbnCtrl.text = isbn;
    await _onIsbnLookup();
  }

  Future<void> _scanSearchField() async {
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const IsbnScannerPage(lookupOnly: true),
      ),
    );
    if (!mounted || code == null) return;
    _searchCtrl.text = code;
  }

  Future<void> _onIsbnLookup() async {
    final raw = _isbnCtrl.text.replaceAll(RegExp(r'[^0-9Xx]'), '');
    if (raw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saisissez un ISBN ou EAN')),
      );
      return;
    }
    final repo = context.read<ReadingRepository>();
    var list = await repo.findByIsbn(raw);
    if (list.isEmpty && raw.length >= 10) {
      list = await repo.searchBooks(raw);
    }
    if (!mounted) return;
    if (list.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun livre avec cet ISBN')),
      );
      return;
    }
    if (list.length == 1) {
      await _pickBook(list.first);
      return;
    }
    await _showBookPicker(list);
  }

  Future<void> _showBookPicker(List<Book> books) async {
    final chosen = await showDialog<Book>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Plusieurs livres correspondent'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: books
                .map(
                  (b) => ListTile(
                    title: Text(b.title.isEmpty ? 'Sans titre' : b.title),
                    subtitle: b.authors.trim().isNotEmpty
                        ? Text(b.authors)
                        : null,
                    onTap: () => Navigator.pop(ctx, b),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
    if (chosen != null && mounted) {
      await startOrResumeReadingSession(context, chosen, popCount: 1);
    }
  }

  Future<void> _pickBook(Book b) =>
      startOrResumeReadingSession(context, b, popCount: 1);

  List<(Book, ReadingProgressRow, DateTime?)> _orderedResumeList(
    List<(Book, ReadingProgressRow, DateTime?)> raw,
    ReadingSessionStore store,
  ) {
    final pinId = store.activeBook?.id;
    if (pinId == null) return raw;
    final list = List<(Book, ReadingProgressRow, DateTime?)>.of(raw);
    list.sort((a, b) {
      final fa = a.$1.id == pinId;
      final fb = b.$1.id == pinId;
      if (fa != fb) return fa ? -1 : 1;
      final la = a.$3;
      final lb = b.$3;
      if (la != null && lb != null) return lb.compareTo(la);
      if (la != null) return -1;
      if (lb != null) return 1;
      return a.$1.title.compareTo(b.$1.title);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ReadingSessionStore>();
    final repo = context.read<ReadingRepository>();
    final sessionStore = context.read<ReadingSessionStore>();
    return Scaffold(
      appBar: AppBar(title: const Text('Démarrer une séance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Identifiez un livre par ISBN ou par la recherche. '
            'La séance reprend à la page enregistrée dans la progression. '
            'Vous pouvez quitter l’app pendant la lecture ; au retour, '
            'indiquez la fin de séance depuis l’accueil ou le menu.',
          ),
          const SizedBox(height: 20),
          Text(
            'En cours de lecture',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<(Book, ReadingProgressRow, DateTime?)>>(
            future: _inProgressFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snap.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Impossible de charger les livres en cours.',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                );
              }
              final rows = _orderedResumeList(snap.data ?? [], sessionStore);
              if (rows.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Aucun livre avec le statut « en cours ». '
                    'Vous pouvez le définir dans la fiche livre ou la progression.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                );
              }
              return Column(
                children: rows.map((tuple) {
                  final b = tuple.$1;
                  final p = tuple.$2;
                  final lastEnd = tuple.$3;
                  final isActive = sessionStore.activeBook?.id == b.id;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        isActive ? Icons.auto_stories : Icons.menu_book_outlined,
                        color: isActive
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      title: Text(b.title.isEmpty ? 'Sans titre' : b.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (b.authors.trim().isNotEmpty) Text(b.authors),
                          const SizedBox(height: 4),
                          Text(readingResumeProgressLabel(p)),
                          Text(
                            readingLastSessionCaption(
                              sessionStore,
                              b.id,
                              lastEnd,
                            ),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      onTap: () => _pickBook(b),
                      onLongPress: () => Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookDetailPage(bookId: b.id),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Autre livre',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _isbnCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'ISBN / EAN',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: 'Scanner le code-barres',
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: _scanIsbnField,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _onIsbnLookup,
                child: const Text('Chercher'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              labelText: 'Recherche (titre, auteur, ISBN…)',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip:
                    'Scanner un code-barres (ISBN / EAN) pour lancer la recherche',
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _scanSearchField,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<Book>>(
            future: _searchQuery.isEmpty
                ? Future.value([])
                : repo.searchBooks(_searchQuery),
            builder: (context, snap) {
              if (_searchQuery.isEmpty) {
                return const SizedBox.shrink();
              }
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final books = snap.data!;
              if (books.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Aucun résultat'),
                );
              }
              return Column(
                children: books.map((b) {
                  return ListTile(
                    leading: const Icon(Icons.menu_book_outlined),
                    title: Text(b.title.isEmpty ? 'Sans titre' : b.title),
                    subtitle: b.authors.trim().isNotEmpty
                        ? Text(b.authors)
                        : null,
                    onTap: () => _pickBook(b),
                    onLongPress: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookDetailPage(bookId: b.id),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
