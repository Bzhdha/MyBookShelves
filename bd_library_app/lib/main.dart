import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';

import 'db/app_db.dart';
import 'features/books/data/books_repository.dart';
import 'features/books/data/metadata_service.dart';
import 'features/books/data/cover_cache_service.dart';
import 'features/books/data/open_library_provider.dart';
import 'features/books/data/bdtheque_provider.dart';
import 'features/books/data/google_books_provider.dart';
import 'features/books/data/goodreads_provider.dart';
import 'features/books/data/amazon_provider.dart';
import 'features/books/data/chatgpt_provider.dart';
import 'features/books/data/claude_provider.dart';
import 'features/books/data/mistral_provider.dart';
import 'features/books/data/groq_provider.dart';
import 'features/books/domain/book_service.dart';
import 'features/users/domain/active_user_store.dart';
import 'features/import_export/data/imported_library_store.dart';
import 'features/settings/data/llm_key_store.dart';
import 'features/settings/data/scan_settings_store.dart';
import 'features/settings/data/app_lock_store.dart';
import 'features/auth/ui/app_lock_screen.dart';
import 'features/books/data/cover_scan_service.dart';
import 'features/books/data/cover_search_service.dart';
import 'features/shelves/data/shelves_repository.dart';
import 'features/shelves/domain/shelf_service.dart';
import 'core/app_logger.dart';
import 'features/reading/data/reading_repository.dart';
import 'features/reading/domain/reading_badge_evaluator.dart';
import 'features/reading/domain/reading_session_store.dart';
import 'features/home/new_home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appLogger = AppLogger();
  final appLockStore = AppLockStore();
  await appLockStore.load();
  final db = AppDb();
  final booksRepository = BooksRepository(db);
  final shelvesRepository = ShelvesRepository(db);
  final shelfService = ShelfService(shelvesRepository);
  final llmKeyStore = LlmKeyStore();
  await llmKeyStore.load();
  final scanSettingsStore = ScanSettingsStore();
  await scanSettingsStore.load();
  final openLibraryProvider = OpenLibraryProvider(logger: appLogger);
  final bdThequeProvider = BdThequeProvider();
  final googleBooksProvider = GoogleBooksProvider(logger: appLogger);
  final coverSearchService = CoverSearchService(
    google: googleBooksProvider,
    bdTheque: bdThequeProvider,
    openLib: openLibraryProvider,
  );
  final metadataService = MetadataService(
    openLibrary: openLibraryProvider,
    bdTheque: bdThequeProvider,
    googleBooks: googleBooksProvider,
    goodreads: GoodreadsProvider(logger: appLogger),
    amazon: AmazonProvider(logger: appLogger),
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
    shelvesRepository,
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
        Provider<CoverSearchService>.value(value: coverSearchService),
        Provider<BookService>.value(value: bookService),
        Provider<ShelfService>.value(value: shelfService),
        ChangeNotifierProvider<ScanSettingsStore>.value(value: scanSettingsStore),
        Provider<CoverScanService>.value(value: CoverScanService()),
        Provider<ImportedLibraryStore>.value(value: ImportedLibraryStore()),
        ChangeNotifierProvider(create: (_) => ActiveUserStore()..load()),
        ChangeNotifierProvider<AppLogger>.value(value: appLogger),
        ChangeNotifierProvider<AppLockStore>.value(value: appLockStore),
        Provider<ReadingRepository>.value(value: readingRepository),
        ChangeNotifierProvider<ReadingSessionStore>(
          create: (context) => ReadingSessionStore(
            context.read<ReadingRepository>(),
            ReadingBadgeEvaluator(context.read<AppDb>()),
          )..load(),
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
      theme: buildBdTheme(),
      home: const _AppLockGate(),
    );
  }
}

/// Shows [AppLockScreen] on first launch and on resume when lock is enabled.
class _AppLockGate extends StatefulWidget {
  const _AppLockGate();

  @override
  State<_AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<_AppLockGate> with WidgetsBindingObserver {
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkLock());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      final lockEnabled = context.read<AppLockStore>().enabled;
      if (lockEnabled && mounted) setState(() => _locked = true);
    } else if (state == AppLifecycleState.resumed && _locked) {
      // keep showing lock screen — user must authenticate
    }
  }

  void _checkLock() {
    final lockEnabled = context.read<AppLockStore>().enabled;
    if (lockEnabled && mounted) setState(() => _locked = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_locked) {
      return AppLockScreen(onUnlocked: () {
        if (mounted) setState(() => _locked = false);
      });
    }
    return const NewHomePage();
  }
}
