import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../db/app_db.dart';
import '../data/llm_metadata_provider.dart';
import '../data/metadata_service.dart';
import '../domain/book_service.dart';
import '../../../models/bd_metadata.dart';

/// Type de recherche : Web (BdTheque, Open Library) ou IA (LLM avec prompt modifiable).
enum MetadataSearchMode { web, llm }

/// Bottom sheet permettant de relancer une recherche de métadonnées (Web ou LLM)
/// depuis la page de détail d'un livre, puis d'appliquer le résultat au livre.
class MetadataSearchSheet extends StatefulWidget {
  final Book book;

  const MetadataSearchSheet({super.key, required this.book});

  /// Affiche la sheet et retourne true si des métadonnées ont été appliquées (pour rafraîchir la page).
  static Future<bool?> show(BuildContext context, Book book) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          // viewInsets.bottom = clavier ; padding.bottom = nav bar (0 si clavier la couvre)
          bottom: MediaQuery.of(ctx).viewInsets.bottom +
              MediaQuery.of(ctx).padding.bottom,
        ),
        child: MetadataSearchSheet(book: book),
      ),
    );
  }

  @override
  State<MetadataSearchSheet> createState() => _MetadataSearchSheetState();
}

class _MetadataSearchSheetState extends State<MetadataSearchSheet> {
  MetadataSearchMode _mode = MetadataSearchMode.web;
  bool _loading = false;
  String? _error;

  BdMetadata? _webResult;
  LlmPromptResult? _llmResult;

  late final TextEditingController _promptCtrl;

  bool get _hasIsbn =>
      widget.book.isbn != null && widget.book.isbn!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    final defaultPrompt = llmIsbnSearchUserPromptTemplate.replaceAll(
      '[INSÉRER_ISBN_ICI]',
      _hasIsbn ? widget.book.isbn!.trim() : '',
    );
    _promptCtrl = TextEditingController(text: defaultPrompt);
  }

  @override
  void dispose() {
    _promptCtrl.dispose();
    super.dispose();
  }

  Future<void> _runWebSearch() async {
    if (!_hasIsbn) return;
    setState(() {
      _loading = true;
      _error = null;
      _webResult = null;
      _llmResult = null;
    });
    try {
      final metadataService = context.read<MetadataService>();
      final result = await metadataService.enrichFromIsbnWebOnly(widget.book.isbn!);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _webResult = result;
        _error = result == null ? 'Aucun résultat trouvé sur BdTheque ni Open Library.' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _webResult = null;
        _error = e.toString();
      });
    }
  }

  Future<void> _runLlmSearch() async {
    final prompt = _promptCtrl.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saisissez un prompt.')),
      );
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _webResult = null;
      _llmResult = null;
    });
    try {
      final metadataService = context.read<MetadataService>();
      final result = await metadataService.enrichFromCustomUserPrompt(prompt);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _llmResult = result;
        _error = result == null ? 'Aucun résultat (vérifiez les clés API).' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _llmResult = null;
        _error = e.toString();
      });
    }
  }

  BdMetadata? get _currentMeta {
    if (_webResult != null) return _webResult;
    return _llmResult?.parsed;
  }

  Future<void> _applyToBook() async {
    final meta = _currentMeta;
    if (meta == null || (meta.title == null || meta.title!.trim().isEmpty)) return;

    final bookService = context.read<BookService>();
    final authorsStr = meta.authors != null && meta.authors!.isNotEmpty
        ? meta.authors!.join(', ')
        : null;
    final volumeNumber = meta.volumeNumber != null && meta.volumeNumber!.trim().isNotEmpty
        ? int.tryParse(meta.volumeNumber!.trim())
        : null;

    await bookService.updateBookDetails(
      widget.book.id,
      title: meta.title!.trim(),
      authors: authorsStr,
      publisher: meta.publisher?.trim().isEmpty == true ? null : meta.publisher?.trim(),
      publishedDate: meta.publishedDate?.trim().isEmpty == true ? null : meta.publishedDate?.trim(),
      volumeNumber: volumeNumber,
      summary: (meta.description?.trim().isNotEmpty == true)
          ? meta.description!.trim()
          : null,
      seriesNameOverride: meta.seriesTitle?.trim().isNotEmpty == true
          ? meta.seriesTitle!.trim()
          : null,
    );
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final metadataService = context.read<MetadataService>();
    final hasLlm = metadataService.hasAnyConfiguredLlm;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Rechercher des métadonnées',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (!_hasIsbn)
            const Text(
              'Ce livre n\'a pas d\'ISBN. Vous pouvez utiliser la recherche par IA avec un prompt personnalisé, ou ajouter un ISBN dans « Modifier le livre » pour la recherche Web.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            )
          else
            Text(
              'Relancez une recherche pour compléter ou corriger les informations (titre, auteurs, éditeur, etc.).',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
            ),
          const SizedBox(height: 16),
          if (_hasIsbn && hasLlm)
            SegmentedButton<MetadataSearchMode>(
              segments: const [
                ButtonSegment<MetadataSearchMode>(
                  value: MetadataSearchMode.web,
                  label: Text('Recherche Web'),
                  icon: Icon(Icons.public, size: 18),
                ),
                ButtonSegment<MetadataSearchMode>(
                  value: MetadataSearchMode.llm,
                  label: Text('Recherche IA'),
                  icon: Icon(Icons.smart_toy_outlined, size: 18),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() => _mode = s.first),
            ),
          if (_hasIsbn && !hasLlm)
            Text(
              'Recherche Web (BdTheque, Open Library)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          if (!_hasIsbn && hasLlm)
            Text(
              'Recherche par IA (prompt modifiable)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          if (!_hasIsbn && !hasLlm) ...[
            const Text(
              'Ajoutez un ISBN au livre et configurez au moins une clé API (Paramètres) pour utiliser la recherche.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
          const SizedBox(height: 16),
          if (hasLlm && (_mode == MetadataSearchMode.llm || !_hasIsbn)) ...[
            Text(
              'Modifiez le prompt si besoin, puis lancez la recherche.',
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _promptCtrl,
              decoration: const InputDecoration(
                labelText: 'Prompt',
                hintText: 'Message envoyé à l\'IA…',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              minLines: 3,
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _loading ? null : _runLlmSearch,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search, size: 20),
              label: Text(_loading ? 'Recherche…' : 'Lancer la recherche IA'),
            ),
          ] else if (_hasIsbn && (_mode == MetadataSearchMode.web || !hasLlm)) ...[
            FilledButton.icon(
              onPressed: _loading ? null : _runWebSearch,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.public, size: 20),
              label: Text(_loading ? 'Recherche…' : 'Lancer la recherche Web'),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
            ),
          ],
          if (_currentMeta != null) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Résultat',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            _ResultSummary(meta: _currentMeta!, rawResponse: _llmResult?.rawResponse),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: _applyToBook,
              icon: const Icon(Icons.check_circle_outline, size: 20),
              label: const Text('Appliquer au livre'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultSummary extends StatelessWidget {
  final BdMetadata meta;
  final String? rawResponse;

  const _ResultSummary({required this.meta, this.rawResponse});

  @override
  Widget build(BuildContext context) {
    final lines = <String>[
      if (meta.title != null && meta.title!.isNotEmpty) 'Titre: ${meta.title}',
      if (meta.authors != null && meta.authors!.isNotEmpty) 'Auteurs: ${meta.authors!.join(", ")}',
      if (meta.publisher != null && meta.publisher!.isNotEmpty) 'Éditeur: ${meta.publisher}',
      if (meta.publishedDate != null && meta.publishedDate!.isNotEmpty) 'Date: ${meta.publishedDate}',
      if (meta.seriesTitle != null && meta.seriesTitle!.isNotEmpty) 'Série: ${meta.seriesTitle}',
      if (meta.volumeNumber != null && meta.volumeNumber!.isNotEmpty) 'Tome: ${meta.volumeNumber}',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: SelectableText(
            lines.isEmpty ? '—' : lines.join('\n'),
            style: const TextStyle(fontSize: 13),
          ),
        ),
        if (rawResponse != null && rawResponse!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          ExpansionTile(
            title: const Text('Réponse brute de l\'IA', style: TextStyle(fontSize: 13)),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: SelectableText(
                    rawResponse!,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
