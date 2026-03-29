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
import 'core/speech_dictation.dart';
import 'features/logs/ui/logs_page.dart';
import 'features/settings/ui/scan_settings_page.dart';
import 'features/reading/data/reading_repository.dart';
import 'features/reading/domain/reading_session_store.dart';
import 'features/reading/ui/reading_active_banner.dart';
import 'features/reading/ui/reading_status_page.dart';
import 'features/reading/ui/reading_progress_page.dart';
import 'features/reading/ui/reading_goals_page.dart';
import 'features/reading/ui/reading_history_page.dart';
import 'features/reading/ui/reading_stats_page.dart';
import 'features/reading/ui/start_reading_session_page.dart';

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
      MistralProvider(llmKeyStore, appLogger),
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
  final readingRepository = ReadingRepository(db);

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
        Provider<ReadingRepository>.value(value: readingRepository),
        ChangeNotifierProvider<ReadingSessionStore>(
          create: (context) =>
              ReadingSessionStore(context.read<ReadingRepository>())..load(),
        ),
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

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final _speechSearch = SpeechDictation();
  bool _searchListening = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim());
    });
    _speechSearch.initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ReadingSessionStore>().load();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<ReadingSessionStore>().load();
    }
  }

  Future<void> _toggleVoiceSearch() async {
    if (_searchListening) {
      await _speechSearch.stop();
      if (mounted) setState(() => _searchListening = false);
      return;
    }
    final ok = await _speechSearch.initialize();
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
    setState(() => _searchListening = true);
    await _speechSearch.startListening(
      baseText: '',
      onText: (text) {
        _searchController.text = text;
        _searchController.selection = TextSelection.collapsed(
          offset: _searchController.text.length,
        );
      },
    );
    if (mounted) setState(() => _searchListening = false);
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
            ExpansionTile(
              leading: const Icon(Icons.auto_stories),
              title: const Text('Suivi de lecture'),
              children: [
                ListTile(
                  leading: const Icon(Icons.play_circle_outline),
                  title: const Text('Débuter une séance'),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<AppLogger>().log('Débuter séance lecture');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StartReadingSessionPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.label_outline),
                  title: const Text('Statuts de lecture'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReadingStatusPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.linear_scale),
                  title: const Text('Progression'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReadingProgressPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: const Text('Objectifs'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReadingGoalsPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Historique'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReadingHistoryPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bar_chart_outlined),
                  title: const Text('Statistiques'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReadingStatsPage(),
                      ),
                    );
                  },
                ),
              ],
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
          const ReadingActiveBanner(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText:
                    'Rechercher (auteur, titre, ISBN, résumé) — icône micro pour la voix',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: _searchListening
                          ? 'Arrêter la dictée'
                          : 'Recherche vocale',
                      icon: Icon(
                        _searchListening ? Icons.mic : Icons.mic_none_outlined,
                        color: _searchListening
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      onPressed: _toggleVoiceSearch,
                    ),
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      ),
                  ],
                ),
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'fab_start_reading',
            tooltip: 'Démarrer une séance de lecture',
            onPressed: () {
              context.read<AppLogger>().log('Débuter séance lecture (accueil)');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StartReadingSessionPage(),
                ),
              );
            },
            child: const Icon(Icons.auto_stories),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'fab_isbn_scan',
            onPressed: () {
              context.read<AppLogger>().log('Ouvrir scan ISBN');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const IsbnScannerPage()),
              );
            },
            child: const Icon(Icons.qr_code_scanner),
          ),
        ],
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