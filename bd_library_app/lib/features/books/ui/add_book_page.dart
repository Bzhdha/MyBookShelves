import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/isbn_validator.dart';
import '../domain/book_service.dart';
import '../data/metadata_service.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _isbnCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _authorsCtrl = TextEditingController();
  final _publisherCtrl = TextEditingController();
  final _publishedDateCtrl = TextEditingController();
  final _seriesNameCtrl = TextEditingController();

  bool _loadingIsbn = false;

  Future<void> _searchByIsbn() async {
    final raw = _isbnCtrl.text.trim();
    if (raw.isEmpty) return;

    final normalized = IsbnValidator.normalize(raw);
    final validationError = IsbnValidator.validate(raw);
    if (validationError != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ISBN invalide : $validationError')),
        );
      }
      return;
    }

    setState(() => _loadingIsbn = true);
    try {
      final metadataService = context.read<MetadataService>();
      final meta = await metadataService.enrichFromIsbn(normalized);

      if (meta != null) {
        // Ne pas écraser si l'utilisateur a déjà saisi
        if (_titleCtrl.text.trim().isEmpty && meta.title != null) {
          _titleCtrl.text = meta.title!;
        }
        if (_authorsCtrl.text.trim().isEmpty &&
            meta.authors != null &&
            meta.authors!.isNotEmpty) {
          _authorsCtrl.text = meta.authors!.join(', ');
        }
        if (_publisherCtrl.text.trim().isEmpty && meta.publisher != null) {
          _publisherCtrl.text = meta.publisher!;
        }
        if (_publishedDateCtrl.text.trim().isEmpty &&
            meta.publishedDate != null) {
          _publishedDateCtrl.text = meta.publishedDate!;
        }
        if (_seriesNameCtrl.text.trim().isEmpty &&
            meta.seriesTitle != null &&
            meta.seriesTitle!.trim().isNotEmpty) {
          _seriesNameCtrl.text = meta.seriesTitle!.trim();
        }

        // Si tu veux aussi stocker la coverUrl, on la gardera lors du save
        // (on ne l'affiche pas forcément dans le formulaire)
        _lastCoverUrl = meta.coverUrl;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Aucune info trouvée pour cet ISBN.")),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de la recherche ISBN.")),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingIsbn = false);
    }
  }

  String? _lastCoverUrl;

  @override
  Widget build(BuildContext context) {
    final bookService = context.read<BookService>();

    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter un livre")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _isbnCtrl,
              decoration: InputDecoration(
                labelText: "ISBN",
                suffixIcon: _loadingIsbn
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        tooltip: "Rechercher via ISBN",
                        onPressed: _searchByIsbn,
                      ),
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: "Titre"),
            ),
            TextField(
              controller: _authorsCtrl,
              decoration: const InputDecoration(labelText: "Auteur(s)"),
            ),
            TextField(
              controller: _publisherCtrl,
              decoration: const InputDecoration(labelText: "Éditeur"),
            ),
            TextField(
              controller: _publishedDateCtrl,
              decoration: const InputDecoration(labelText: "Date de publication"),
            ),
            TextField(
              controller: _seriesNameCtrl,
              decoration: const InputDecoration(
                labelText: "Série",
                hintText: "Optionnel — regroupe les tomes",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await bookService.addBookManually(
                  isbn: _isbnCtrl.text.trim().isEmpty
                      ? null
                      : _isbnCtrl.text.trim(),
                  title: _titleCtrl.text,
                  authors: _authorsCtrl.text,
                  publisher: _publisherCtrl.text,
                  publishedDate: _publishedDateCtrl.text,
                  coverUrl: _lastCoverUrl,
                  seriesName: _seriesNameCtrl.text.trim().isEmpty
                      ? null
                      : _seriesNameCtrl.text.trim(),
                );

                if (mounted) Navigator.pop(context);
              },
              child: const Text("Enregistrer"),
            )
          ],
        ),
      ),
    );
  }
}
