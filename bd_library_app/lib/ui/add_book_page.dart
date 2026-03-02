import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' hide Column;

import '../db/app_db.dart';
import '../services/metadata_service.dart';
import '../services/open_library_provider.dart';

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

  final _metadataService =
      MetadataService(openLibrary: OpenLibraryProvider());

  bool _loadingIsbn = false;

  Future<void> _searchByIsbn() async {
    final raw = _isbnCtrl.text.trim();
    if (raw.isEmpty) return;

    setState(() => _loadingIsbn = true);
    try {
      final meta = await _metadataService.enrichFromIsbn(raw);

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
    final db = context.read<AppDb>();

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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final id = const Uuid().v4();

                await db.upsertBook(
                  BooksCompanion.insert(
                    id: id,
                    isbn: Value(_isbnCtrl.text.trim().isEmpty ? null : _isbnCtrl.text.trim()),
                    title: _titleCtrl.text,
                    authors: Value(_authorsCtrl.text),
                    publisher: Value(_publisherCtrl.text.trim().isEmpty ? null : _publisherCtrl.text.trim()),
                    publishedDate: Value(_publishedDateCtrl.text.trim().isEmpty ? null : _publishedDateCtrl.text.trim()),
                    coverUrl: Value(_lastCoverUrl),
                    updatedAt: DateTime.now(),
                  ),
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
