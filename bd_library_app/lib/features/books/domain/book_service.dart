import 'package:drift/drift.dart' hide Column;
import 'package:uuid/uuid.dart';

import '../data/books_repository.dart';
import '../../../services/metadata_service.dart';
import '../../../services/cover_cache_service.dart';
import '../../../db/app_db.dart';

class BookService {
  final BooksRepository _repo;
  final MetadataService _metadata;
  final CoverCacheService _covers;
  final _uuid = const Uuid();

  BookService(this._repo, this._metadata, this._covers);

  /// Flux de tous les livres.
  Stream<List<Book>> watchAllBooks() => _repo.watchAllBooks();

  /// Flux des livres avec le nom de la série (pour affichage liste).
  Stream<List<(Book, String?)>> watchAllBooksWithSeriesNames() =>
      _repo.watchAllBooksWithSeriesNames();

  /// Détails d'un livre + exemplaires.
  Future<Book?> getBook(String id) => _repo.getBookById(id);
  Future<List<Copy>> getCopies(String bookId) => _repo.getCopiesByBook(bookId);

  Future<void> deleteBook(String id) => _repo.deleteBookById(id);

  /// Création / mise à jour d'un exemplaire (formulaire exemplaire).
  Future<void> upsertCopy(CopiesCompanion copy) => _repo.upsertCopy(copy);

  /// Création manuelle d'un livre depuis le formulaire.
  Future<void> addBookManually({
    String? isbn,
    required String title,
    required String authors,
    String? publisher,
    String? publishedDate,
    String? coverUrl,
  }) async {
    final id = _uuid.v4();

    await _repo.upsertBook(
      BooksCompanion.insert(
        id: id,
        isbn: Value(isbn?.trim().isEmpty ?? true ? null : isbn!.trim()),
        title: title,
        authors: Value(authors),
        publisher: Value(
          publisher?.trim().isNotEmpty == true ? publisher!.trim() : null,
        ),
        publishedDate: Value(
          publishedDate?.trim().isNotEmpty == true ? publishedDate!.trim() : null,
        ),
        coverUrl: Value(coverUrl),
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Ajout ou enrichissement via scan ISBN, puis création d'un exemplaire.
  Future<void> addOrUpdateFromIsbnScan(String isbn) async {
    final works = await _repo.findWorksByIsbn(isbn);

    late String bookId;

    if (works.isEmpty) {
      final meta = await _metadata.enrichFromIsbn(isbn);

      final title = (meta?.title?.trim().isNotEmpty ?? false)
          ? meta!.title!.trim()
          : 'ISBN $isbn';

      final authorsCsv = (meta?.authors != null && meta!.authors!.isNotEmpty)
          ? meta.authors!.join(', ')
          : '';

      final coverUrl = meta?.coverUrl;
      final newBookId = _uuid.v4();

      final coverLocalPath = await _covers.downloadCoverToLocalPath(
        bookId: newBookId,
        coverUrl: coverUrl,
      );

      await _repo.upsertBook(
        BooksCompanion.insert(
          id: newBookId,
          isbn: Value(isbn),
          title: title,
          authors: Value(authorsCsv),
          publisher: Value(meta?.publisher),
          publishedDate: Value(meta?.publishedDate),
          coverUrl: Value(coverUrl),
          coverLocalPath: Value(coverLocalPath),
          updatedAt: DateTime.now(),
        ),
      );

      bookId = newBookId;
    } else {
      final existing = works.first;
      bookId = existing.id;

      final isPlaceholderTitle = existing.title.trim() == 'ISBN $isbn';
      final missingCoreInfo = isPlaceholderTitle ||
          (existing.publisher == null || existing.publisher!.trim().isEmpty) ||
          (existing.publishedDate == null ||
              existing.publishedDate!.trim().isEmpty) ||
          (existing.coverUrl == null || existing.coverUrl!.trim().isEmpty);

      if (missingCoreInfo) {
        final meta = await _metadata.enrichFromIsbn(isbn);
        if (meta != null) {
          final newTitle = isPlaceholderTitle &&
                  (meta.title?.trim().isNotEmpty ?? false)
              ? meta.title!.trim()
              : existing.title;

          final newAuthors = (existing.authors.trim().isEmpty &&
                  meta.authors != null &&
                  meta.authors!.isNotEmpty)
              ? meta.authors!.join(', ')
              : existing.authors;

          final newCoverUrl =
              (existing.coverUrl == null || existing.coverUrl!.trim().isEmpty)
                  ? meta.coverUrl
                  : existing.coverUrl;

          String? newCoverLocalPath = existing.coverLocalPath;
          if ((newCoverLocalPath == null || newCoverLocalPath.trim().isEmpty) &&
              (newCoverUrl != null && newCoverUrl.trim().isNotEmpty)) {
            newCoverLocalPath = await _covers.downloadCoverToLocalPath(
              bookId: bookId,
              coverUrl: newCoverUrl,
            );
          }

          await _repo.upsertBook(
            BooksCompanion(
              id: Value(bookId),
              isbn: Value(isbn),
              title: Value(newTitle),
              authors: Value(newAuthors),
              publisher: Value(
                existing.publisher?.trim().isNotEmpty == true
                    ? existing.publisher
                    : meta.publisher,
              ),
              publishedDate: Value(
                existing.publishedDate?.trim().isNotEmpty == true
                    ? existing.publishedDate
                    : meta.publishedDate,
              ),
              coverUrl: Value(newCoverUrl),
              coverLocalPath: Value(newCoverLocalPath),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      }
    }

    await _repo.upsertCopy(
      CopiesCompanion.insert(
        id: _uuid.v4(),
        bookId: bookId,
        updatedAt: DateTime.now(),
      ),
    );
  }
}

