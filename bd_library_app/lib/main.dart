import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'db/app_db.dart';
import 'features/books/data/books_repository.dart';
import 'features/books/data/metadata_service.dart';
import 'features/books/data/cover_cache_service.dart';
import 'features/books/data/open_library_provider.dart';
import 'features/books/data/bdtheque_provider.dart';
import 'features/books/domain/book_service.dart';
import 'features/books/ui/book_detail_page.dart';
import 'features/books/ui/add_book_page.dart';
import 'features/books/ui/isbn_scanner_page.dart';
import 'features/users/domain/active_user_store.dart';
import 'features/users/ui/users_page.dart';
import 'features/import_export/data/library_transfer_service.dart';
import 'features/import_export/ui/import_review_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDb();
  final booksRepository = BooksRepository(db);
  final bookService = BookService(
    booksRepository,
  MetadataService(
    openLibrary: OpenLibraryProvider(),
    bdTheque: BdThequeProvider(),
  ),
  CoverCacheService(),
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDb>.value(value: db),
        Provider<BookService>.value(value: bookService),
        ChangeNotifierProvider(create: (_) => ActiveUserStore()..load()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bibliothèque BD',
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bookService = context.read<BookService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bibliothèque BD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload),
            tooltip: 'Importer depuis JSON',
            onPressed: () async {
              final db = context.read<AppDb>();
              final transfer = LibraryTransferService(db);
              try {
                final file = await transfer.pickJsonFile();
                if (file == null || !context.mounted) return;
                final plan = await transfer.buildImportPlanFromJson(file);
                if (!context.mounted) return;
                await Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ImportReviewPage(
                      plan: plan,
                      onApply: (p) async {
                        await transfer.applyImportPlanFromJson(p);
                      },
                    ),
                  ),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Import terminé')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur import: $e')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Exporter en JSON',
            onPressed: () async {
              final db = context.read<AppDb>();
              final transfer = LibraryTransferService(db);
              try {
                await transfer.shareExportJson();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export JSON partagé')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur export: $e')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.group),
            tooltip: 'Membres de la famille',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UsersPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Ajouter un livre à la main',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddBookPage()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const IsbnScannerPage()),
          );
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
      body: StreamBuilder<List<(Book, String?)>>(
        stream: bookService.watchAllBooksWithSeriesNames(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text("Aucune BD enregistrée"));
          }
          return ListView(
            children: items.map((entry) {
              final b = entry.$1;
              final seriesName = entry.$2;
              final hasTitle = b.title.trim().isNotEmpty;
              final titleDisplay = hasTitle
                  ? b.title
                  : (b.isbn != null && b.isbn!.trim().isNotEmpty
                      ? 'ISBN ${b.isbn}'
                      : 'Sans titre');
              final parts = <String>[
                if (b.volumeNumber != null) 'T. ${b.volumeNumber}',
                if (seriesName != null && seriesName.trim().isNotEmpty) seriesName,
                if (b.authors.trim().isNotEmpty) b.authors,
              ];
              final subtitleDisplay = parts.isNotEmpty
                  ? parts.join(' · ')
                  : (b.isbn != null && b.isbn!.trim().isNotEmpty && hasTitle
                      ? 'ISBN ${b.isbn}'
                      : null);
              return ListTile(
                title: Text(titleDisplay),
                subtitle: subtitleDisplay != null ? Text(subtitleDisplay) : null,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BookDetailPage(bookId: b.id)),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}