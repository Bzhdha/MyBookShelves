import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../db/app_db.dart';
import '../data/cover_cache_service.dart';
import '../data/cover_search_service.dart';
import '../domain/book_service.dart';

class CoverSearchSheet extends StatefulWidget {
  final Book book;
  const CoverSearchSheet({super.key, required this.book});

  static Future<bool?> show(BuildContext context, Book book) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, ctrl) => CoverSearchSheet(book: book),
      ),
    );
  }

  @override
  State<CoverSearchSheet> createState() => _CoverSearchSheetState();
}

class _CoverSearchSheetState extends State<CoverSearchSheet> {
  List<CoverCandidate>? _candidates;
  bool _loading = false;
  String? _error;
  int? _selected;
  bool _applying = false;

  bool get _hasIsbn => widget.book.isbn?.trim().isNotEmpty == true;

  @override
  void initState() {
    super.initState();
    if (_hasIsbn) _search();
  }

  Future<void> _search() async {
    setState(() { _loading = true; _error = null; _candidates = null; _selected = null; });
    try {
      final svc = context.read<CoverSearchService>();
      final res = await svc.searchByIsbn(widget.book.isbn!.trim());
      if (!mounted) return;
      setState(() { _loading = false; _candidates = res; _error = res.isEmpty ? 'Aucune couverture trouvée pour cet ISBN.' : null; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _apply(String suffix) async {
    final idx = _selected;
    if (idx == null || _candidates == null) return;
    final candidate = _candidates![idx];
    setState(() => _applying = true);
    try {
      final cache = context.read<CoverCacheService>();
      final bookSvc = context.read<BookService>();
      if (suffix == 'cover') {
        final path = await cache.downloadCoverToLocalPath(bookId: widget.book.id, coverUrl: candidate.url);
        if (path != null && mounted) await bookSvc.updateBookCoverFromScan(widget.book.id, path);
      } else {
        final bytes = await _downloadBytes(candidate.url);
        if (bytes != null && mounted) {
          await cache.saveLocalImage(bookId: widget.book.id, imageBytes: bytes, suffix: 'back');
        }
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() { _applying = false; _error = e.toString(); });
    }
  }

  Future<Uint8List?> _downloadBytes(String url) async {
    try {
      final r = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 20));
      if (r.statusCode != 200 || r.bodyBytes.isEmpty) return null;
      return r.bodyBytes;
    } catch (_) { return null; }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildHeader(),
      Expanded(child: _buildBody()),
      if (_selected != null) _buildActions(),
    ]);
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(children: [
        Expanded(child: Text('Rechercher une couverture', style: Theme.of(context).textTheme.titleLarge)),
        if (_hasIsbn && !_loading)
          IconButton(icon: const Icon(Icons.refresh), tooltip: 'Relancer', onPressed: _search),
      ]),
    );
  }

  Widget _buildBody() {
    if (!_hasIsbn) return const Center(child: Padding(
      padding: EdgeInsets.all(24),
      child: Text('Ce livre n\'a pas d\'ISBN. Ajoutez un ISBN pour rechercher des couvertures en ligne.', textAlign: TextAlign.center),
    ));
    if (_loading) return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      CircularProgressIndicator(),
      SizedBox(height: 12),
      Text('Recherche en cours…', style: TextStyle(color: Colors.grey)),
    ]));
    if (_error != null) return Center(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error)),
    ));
    if (_candidates == null || _candidates!.isEmpty) return const SizedBox.shrink();
    return _buildGrid();
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
        childAspectRatio: 0.62,
      ),
      itemCount: _candidates!.length,
      itemBuilder: (_, i) => _CoverCard(
        candidate: _candidates![i],
        selected: _selected == i,
        onTap: _applying ? null : () => setState(() => _selected = _selected == i ? null : i),
      ),
    );
  }

  Widget _buildActions() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: _applying
            ? const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()))
            : Wrap(spacing: 8, runSpacing: 8, children: [
                FilledButton.icon(
                  icon: const Icon(Icons.image, size: 18),
                  label: const Text('Couverture'),
                  onPressed: () => _apply('cover'),
                ),
                FilledButton.tonal(
                  onPressed: () => _apply('back'),
                  child: const Text('Dos du livre'),
                ),
              ]),
      ),
    );
  }
}

class _CoverCard extends StatelessWidget {
  final CoverCandidate candidate;
  final bool selected;
  final VoidCallback? onTap;

  const _CoverCard({required this.candidate, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
            width: selected ? 3 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Stack(fit: StackFit.expand, children: [
            Image.network(
              candidate.url,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, prog) => prog == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              errorBuilder: (_, _, _) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Center(child: Icon(Icons.broken_image_outlined, size: 32)),
              ),
            ),
            Positioned(bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                color: Colors.black54,
                child: Text(candidate.source, style: const TextStyle(color: Colors.white, fontSize: 11), overflow: TextOverflow.ellipsis),
              ),
            ),
            if (selected)
              Positioned(top: 6, right: 6,
                child: Container(
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                  padding: const EdgeInsets.all(2),
                  child: Icon(Icons.check, size: 16, color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
