import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'db/app_db.dart';
import 'features/books/data/books_repository.dart';
import 'features/books/data/metadata_service.dart';
import 'features/books/data/cover_cache_service.dart';
import 'features/books/data/open_library_provider.dart';
import 'features/books/data/bdtheque_provider.dart';
import 'features/books/data/chatgpt_provider.dart';
import 'features/books/data/claude_provider.dart';
import 'features/books/data/mistral_provider.dart';
import 'features/books/data/groq_provider.dart';
import 'features/books/domain/book_service.dart';
import 'features/books/ui/book_detail_page.dart';
import 'features/books/ui/add_book_page.dart';
import 'features/books/ui/isbn_scanner_page.dart';
import 'features/users/domain/active_user_store.dart';
import 'features/users/ui/users_page.dart';
import 'features/import_export/data/imported_library_store.dart';
import 'features/import_export/data/library_transfer_service.dart';
import 'features/import_export/ui/import_review_page.dart';
import 'features/import_export/ui/imported_libraries_list_page.dart';
import 'features/settings/data/llm_key_store.dart';
import 'features/settings/data/scan_settings_store.dart';
import 'features/settings/ui/api_key_page.dart';
import 'features/books/data/cover_scan_service.dart';
import 'features/shelves/data/shelves_repository.dart';
import 'features/shelves/domain/shelf_service.dart';
import 'features/shelves/ui/shelves_page.dart';
import 'core/app_logger.dart';
import 'features/logs/ui/logs_page.dart';
import 'features/settings/ui/scan_settings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appLogger = AppLogger();
  final db = AppDb();
  final booksRepository = BooksRepository(db);
  final shelvesRepository = ShelvesRepository(db);
  final shelfService = ShelfService(shelvesRepository);
  final llmKeyStore = LlmKeyStore();
  await llmKeyStore.load();
  final scanSettingsStore = ScanSettingsStore();
  await scanSettingsStore.load();
  final metadataService = MetadataService(
    openLibrary: OpenLibraryProvider(),
    bdTheque: BdThequeProvider(),
    llmProviders: [
      ChatGptProvider(llmKeyStore),
      ClaudeProvider(llmKeyStore),
      MistralProvider(llmKeyStore),
      GroqProvider(llmKeyStore),
    ],
    logger: appLogger,
  );
  final coverCacheService = CoverCacheService();
  final bookService = BookService(
    booksRepository,
    metadataService,
    coverCacheService,
    appLogger,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDb>.value(value: db),
        ChangeNotifierProvider<LlmKeyStore>.value(value: llmKeyStore),
        Provider<MetadataService>.value(value: metadataService),
        Provider<CoverCacheService>.value(value: coverCacheService),
        Provider<BookService>.value(value: bookService),
        Provider<ShelfService>.value(value: shelfService),
        ChangeNotifierProvider<ScanSettingsStore>.value(value: scanSettingsStore),
        Provider<CoverScanService>.value(value: CoverScanService()),
        Provider<ImportedLibraryStore>.value(value: ImportedLibraryStore()),
        ChangeNotifierProvider(create: (_) => ActiveUserStore()..load()),
        ChangeNotifierProvider<AppLogger>.value(value: appLogger),
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookService = context.read<BookService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bibliothèque BD'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Bibliothèque BD',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.upload),
              title: const Text('Importer depuis JSON'),
              onTap: () async {
                Navigator.pop(context);
                context.read<AppLogger>().log('Import JSON (depuis menu)');
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
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Exporter en JSON'),
              onTap: () async {
                Navigator.pop(context);
                context.read<AppLogger>().log('Export JSON (depuis menu)');
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
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Bibliothèques importées (amis)'),
              onTap: () {
                Navigator.pop(context);
                context.read<AppLogger>().log('Ouvrir Bibliothèques importées');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ImportedLibrariesListPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Membres (utilisateurs)'),
              onTap: () {
                Navigator.pop(context);
                context.read<AppLogger>().log('Ouvrir Membres');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UsersPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Ajouter un livre à la main'),
              onTap: () {
                Navigator.pop(context);
                context.read<AppLogger>().log('Ouvrir Ajouter un livre');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddBookPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Étagères thématiques'),
              onTap: () {
                Navigator.pop(context);
                context.read<AppLogger>().log('Ouvrir Étagères');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ShelvesPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.key),
              title: const Text('Clés API (recherche LLM)'),
              onTap: () {
                Navigator.pop(context);
                context.read<AppLogger>().log('Ouvrir Clés API');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ApiKeyPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres scan ISBN'),
              onTap: () {
                Navigator.pop(context);
                context.read<AppLogger>().log('Ouvrir Paramètres scan');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScanSettingsPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Logs applicatifs'),
              onTap: () {
                Navigator.pop(context);
                context.read<AppLogger>().log('Ouvrir Logs applicatifs');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LogsPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher (auteur, titre ou ISBN)…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
            ),
          ),
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildBookStream(context, bookService)
                : _buildSearchResults(context, bookService),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<AppLogger>().log('Ouvrir scan ISBN');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const IsbnScannerPage()),
          );
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }

  Widget _buildBookStream(BuildContext context, BookService bookService) {
    return StreamBuilder<List<(Book, String?)>>(
      stream: bookService.watchAllBooksWithSeriesNames(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data!;
        return _buildBookList(context, items);
      },
    );
  }

  Widget _buildSearchResults(BuildContext context, BookService bookService) {
    return FutureBuilder<List<(Book, String?)>>(
      future: bookService.searchBooksWithSeriesNames(_searchQuery),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data!;
        return _buildBookList(context, items);
      },
    );
  }

  Widget _buildBookList(
    BuildContext context,
    List<(Book, String?)> items,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty ? 'Aucune BD enregistrée' : 'Aucun résultat',
        ),
      );
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
        final coverPath = b.coverLocalPath;
        final hasCoverPath = coverPath != null && coverPath.trim().isNotEmpty;
        return ListTile(
          leading: SizedBox(
            width: 40,
            height: 56,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: hasCoverPath
                  ? Image.file(
                      File(coverPath),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _coverPlaceholder(),
                    )
                  : _coverPlaceholder(),
            ),
          ),
          title: Text(titleDisplay),
          subtitle: subtitleDisplay != null ? Text(subtitleDisplay) : null,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BookDetailPage(bookId: b.id)),
          ),
        );
      }).toList(),
    );
  }

  static Widget _coverPlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: const Icon(Icons.menu_book, size: 28),
    );
  }
}