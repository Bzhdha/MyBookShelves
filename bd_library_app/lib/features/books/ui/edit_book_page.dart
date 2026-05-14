import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/speech_dictation.dart';
import '../../../db/app_db.dart';
import '../data/llm_metadata_provider.dart';
import '../data/metadata_service.dart';
import '../domain/book_service.dart';

/// Page d'édition des métadonnées d'un livre (titre, auteurs, ISBN, etc.).
class EditBookPage extends StatefulWidget {
  final Book book;

  const EditBookPage({super.key, required this.book});

  @override
  State<EditBookPage> createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _authorsCtrl;
  late final TextEditingController _isbnCtrl;
  late final TextEditingController _publisherCtrl;
  late final TextEditingController _publishedDateCtrl;
  late final TextEditingController _volumeNumberCtrl;
  late final TextEditingController _seriesNameCtrl;
  late final TextEditingController _summaryCtrl;
  late final TextEditingController _promptCtrl;
  late final TextEditingController _pageCountCtrl;
  late final TextEditingController _retailPriceCtrl;

  final _speechSummary = SpeechDictation();
  bool _summaryListening = false;

  bool _searchLoading = false;
  LlmPromptResult? _lastSearchResult;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _titleCtrl = TextEditingController(text: b.title);
    _authorsCtrl = TextEditingController(text: b.authors);
    _isbnCtrl = TextEditingController(text: b.isbn ?? '');
    _publisherCtrl = TextEditingController(text: b.publisher ?? '');
    _publishedDateCtrl = TextEditingController(text: b.publishedDate ?? '');
    _volumeNumberCtrl = TextEditingController(
      text: b.volumeNumber != null ? b.volumeNumber.toString() : '',
    );
    _seriesNameCtrl = TextEditingController();
    _summaryCtrl = TextEditingController(text: b.summary);
    _pageCountCtrl = TextEditingController(text: b.pageCount != null ? b.pageCount.toString() : '');
    _retailPriceCtrl = TextEditingController(text: b.retailPrice != null ? b.retailPrice!.toStringAsFixed(2) : '');
    final defaultPrompt = llmIsbnSearchUserPromptTemplate.replaceAll(
      '[INSÉRER_ISBN_ICI]',
      b.isbn?.trim().isNotEmpty == true ? b.isbn!.trim() : '',
    );
    _promptCtrl = TextEditingController(text: defaultPrompt);
    _speechSummary.initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrateSeriesField());
  }

  Future<void> _hydrateSeriesField() async {
    final svc = context.read<BookService>();
    final name = await svc.getSeriesNameForBookId(widget.book.seriesId);
    if (mounted) {
      _seriesNameCtrl.text = name ?? '';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorsCtrl.dispose();
    _isbnCtrl.dispose();
    _publisherCtrl.dispose();
    _publishedDateCtrl.dispose();
    _volumeNumberCtrl.dispose();
    _seriesNameCtrl.dispose();
    _summaryCtrl.dispose();
    _promptCtrl.dispose();
    _pageCountCtrl.dispose();
    _retailPriceCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleSummaryVoice() async {
    if (_summaryListening) {
      await _speechSummary.stop();
      if (mounted) setState(() => _summaryListening = false);
      return;
    }
    final ok = await _speechSummary.initialize();
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Reconnaissance vocale indisponible (micro ou permissions).',
          ),
        ),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _summaryListening = true);
    final base = _summaryCtrl.text;
    await _speechSummary.startListening(
      baseText: base,
      onText: (text) {
        _summaryCtrl.text = text;
        _summaryCtrl.selection = TextSelection.collapsed(
          offset: _summaryCtrl.text.length,
        );
      },
    );
    if (mounted) setState(() => _summaryListening = false);
  }

  Future<void> _runSearch() async {
    final prompt = _promptCtrl.text.trim();
    if (prompt.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saisissez un prompt.')),
        );
      }
      return;
    }
    setState(() {
      _searchLoading = true;
      _lastSearchResult = null;
      _searchError = null;
    });
    try {
      final metadataService = context.read<MetadataService>();
      final result = await metadataService.enrichFromCustomUserPrompt(prompt);
      if (!mounted) return;
      setState(() {
        _searchLoading = false;
        _lastSearchResult = result;
        _searchError = result == null ? 'Aucun résultat (vérifiez les clés API).' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searchLoading = false;
        _lastSearchResult = null;
        _searchError = e.toString();
      });
    }
  }

  void _applySearchResult() {
    final meta = _lastSearchResult?.parsed;
    if (meta == null) return;
    if (meta.title != null && meta.title!.trim().isNotEmpty) {
      _titleCtrl.text = meta.title!.trim();
    }
    if (meta.authors != null && meta.authors!.isNotEmpty) {
      _authorsCtrl.text = meta.authors!.join(', ');
    }
    if (meta.publisher != null && meta.publisher!.trim().isNotEmpty) {
      _publisherCtrl.text = meta.publisher!.trim();
    }
    if (meta.publishedDate != null && meta.publishedDate!.trim().isNotEmpty) {
      _publishedDateCtrl.text = meta.publishedDate!.trim();
    }
    if (meta.volumeNumber != null && meta.volumeNumber!.trim().isNotEmpty) {
      _volumeNumberCtrl.text = meta.volumeNumber!.trim();
    }
    if (meta.seriesTitle != null && meta.seriesTitle!.trim().isNotEmpty) {
      _seriesNameCtrl.text = meta.seriesTitle!.trim();
    }
    if (meta.description != null && meta.description!.trim().isNotEmpty) {
      _summaryCtrl.text = meta.description!.trim();
    }
    if (meta.pageCount != null) {
      _pageCountCtrl.text = meta.pageCount.toString();
    }
    if (meta.retailPrice != null) {
      _retailPriceCtrl.text = meta.retailPrice!.toStringAsFixed(2);
    }
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le titre est obligatoire.')),
        );
      }
      return;
    }
    final bookService = context.read<BookService>();
    final volStr = _volumeNumberCtrl.text.trim();
    final volumeNumber = volStr.isEmpty ? null : int.tryParse(volStr);
    final pcStr = _pageCountCtrl.text.trim();
    final pageCount = pcStr.isEmpty ? null : int.tryParse(pcStr);
    final rpStr = _retailPriceCtrl.text.trim();
    final retailPrice = rpStr.isEmpty ? null : double.tryParse(rpStr.replaceAll(',', '.'));

    await bookService.updateBookDetails(
      widget.book.id,
      title: title,
      authors: _authorsCtrl.text.trim().isEmpty ? null : _authorsCtrl.text.trim(),
      isbn: _isbnCtrl.text.trim().isEmpty ? null : _isbnCtrl.text.trim(),
      publisher: _publisherCtrl.text.trim().isEmpty ? null : _publisherCtrl.text.trim(),
      publishedDate: _publishedDateCtrl.text.trim().isEmpty ? null : _publishedDateCtrl.text.trim(),
      volumeNumber: volumeNumber,
      summary: _summaryCtrl.text.trim(),
      seriesNameOverride: _seriesNameCtrl.text.trim(),
      pageCount: pageCount,
      clearPageCount: pcStr.isEmpty,
      retailPrice: retailPrice,
      clearRetailPrice: rpStr.isEmpty,
    );
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le livre')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(onPressed: _save, child: const Text('Enregistrer')),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Titre',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _authorsCtrl,
            decoration: const InputDecoration(
              labelText: 'Auteur(s)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _isbnCtrl,
            decoration: const InputDecoration(
              labelText: 'ISBN',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _publisherCtrl,
            decoration: const InputDecoration(
              labelText: 'Éditeur',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _publishedDateCtrl,
            decoration: const InputDecoration(
              labelText: 'Date de publication',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _seriesNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Série',
              hintText: 'Même nom pour tous les tomes d\'une série',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _volumeNumberCtrl,
            decoration: const InputDecoration(
              labelText: 'Numéro de tome',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pageCountCtrl,
            decoration: const InputDecoration(
              labelText: 'Nombre de pages',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _retailPriceCtrl,
            decoration: const InputDecoration(
              labelText: 'Prix public conseillé (€)',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _summaryCtrl,
            decoration: InputDecoration(
              labelText: 'Résumé',
              hintText: 'Synopsis ou notes sur l\'histoire…',
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
              suffixIcon: IconButton(
                tooltip: _summaryListening ? 'Arrêter la dictée' : 'Dictée vocale',
                icon: Icon(
                  _summaryListening ? Icons.mic : Icons.mic_none_outlined,
                  color: _summaryListening
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                onPressed: _toggleSummaryVoice,
              ),
            ),
            minLines: 3,
            maxLines: 8,
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 12),
          const Text(
            'Recherche des métadonnées par IA',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Modifiez le prompt si besoin, puis lancez la recherche. Les données retournées s\'affichent ci-dessous.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
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
            maxLines: 8,
            minLines: 4,
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _searchLoading ? null : _runSearch,
            icon: _searchLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search, size: 20),
            label: Text(_searchLoading ? 'Recherche…' : 'Lancer la recherche'),
          ),
          if (_searchError != null) ...[
            const SizedBox(height: 12),
            Text(
              _searchError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
            ),
          ],
          if (_lastSearchResult != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Données retournées',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              constraints: const BoxConstraints(minHeight: 80, maxHeight: 240),
              child: SingleChildScrollView(
                child: SelectableText(
                  _lastSearchResult!.rawResponse,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
            if (_lastSearchResult!.parsed != null) ...[
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                onPressed: _applySearchResult,
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: const Text('Appliquer au formulaire'),
              ),
            ] else
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Le JSON n\'a pas pu être interprété (titre manquant ou format non reconnu). Vous pouvez copier les données ci-dessus.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
