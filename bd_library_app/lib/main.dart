import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'db/app_db.dart';
import 'state/active_user_store.dart';
import 'ui/book_detail_page.dart';
import 'ui/add_book_page.dart';
import 'ui/users_page.dart';
import 'ui/isbn_scanner_page.dart';
import 'features/books/data/books_repository.dart';
import 'features/books/domain/book_service.dart';
import 'services/metadata_service.dart';
import 'services/open_library_provider.dart';
import 'services/cover_cache_service.dart';
import 'services/bdtheque_provider.dart';

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
            icon: const Icon(Icons.group),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UsersPage()),
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
//      floatingActionButtonManual: FloatingActionButton(
//        onPressed: () {
//          Navigator.push(
//            context,
//            MaterialPageRoute(builder: (_) => const AddBookPage()),
//          );
//        },
//        child: const Icon(Icons.add),
//      ),
      body: StreamBuilder<List<Book>>(
        stream: bookService.watchAllBooks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final books = snapshot.data!;
          if (books.isEmpty) {
            return const Center(child: Text("Aucune BD enregistrée"));
          }
          return ListView(
            children: books.map((b) => ListTile(
              title: Text(b.title),
              subtitle: Text(b.authors),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BookDetailPage(bookId: b.id)),
              ),
            )).toList(),
          );
        },
      ),
    );
  }
}