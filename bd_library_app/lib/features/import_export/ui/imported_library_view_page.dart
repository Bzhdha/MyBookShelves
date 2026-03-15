import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/export_model.dart';
import '../data/imported_library_store.dart';
import 'imported_book_detail_page.dart';

/// Affichage en lecture seule d'une bibliothèque importée (ami).
class ImportedLibraryViewPage extends StatefulWidget {
  final String importId;
  final String libraryName;

  const ImportedLibraryViewPage({
    super.key,
    required this.importId,
    required this.libraryName,
  });

  @override
  State<ImportedLibraryViewPage> createState() => _ImportedLibraryViewPageState();
}

class _ImportedLibraryViewPageState extends State<ImportedLibraryViewPage> {
  ExportLibrary? _lib;
  bool _loading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    final store = context.read<ImportedLibraryStore>();
    final lib = await store.getImportedLibrary(widget.importId);
    if (!mounted) return;
    setState(() {
      _lib = lib;
      _loading = false;
      _error = lib == null ? 'Bibliothèque introuvable' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.libraryName)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _lib == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.libraryName)),
        body: Center(child: Text(_error ?? 'Erreur')),
      );
    }

    final lib = _lib!;
    final seriesById = {for (final s in lib.series) s.id: s.name};
    final booksWithSeries = lib.books
        .map((b) => (
              b,
              b.seriesId != null ? seriesById[b.seriesId] : null,
            ))
        .toList()
      ..sort((a, b) => a.$1.title.compareTo(b.$1.title));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.libraryName),
            Text(
              '${lib.books.length} livre(s) — lecture seule',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: booksWithSeries.length,
        itemBuilder: (context, index) {
          final entry = booksWithSeries[index];
          final b = entry.$1;
          final seriesName = entry.$2;
          final subtitle = [
            if (b.volumeNumber != null) 'T. ${b.volumeNumber}',
            if (seriesName != null && seriesName.isNotEmpty) seriesName,
            if (b.authors.isNotEmpty) b.authors,
          ].join(' · ');
          return ListTile(
            title: Text(b.title),
            subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ImportedBookDetailPage(
                  libraryName: widget.libraryName,
                  book: b,
                  copies: lib.copies.where((c) => c.bookId == b.id).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
