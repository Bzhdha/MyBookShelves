import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:uuid/uuid.dart';

import '../data/books_repository.dart';
import '../data/metadata_service.dart';
import '../data/cover_cache_service.dart';
import '../../../core/app_logger.dart';
import '../../../db/app_db.dart';

class BookService {
  final BooksRepository _repo;
  final MetadataService _metadata;
  final CoverCacheService _covers;
  final AppLogger? _logger;
  final _uuid = const Uuid();

  BookService(this._repo, this._metadata, this._covers, [this._logger]);

  /// Flux de tous les livres.
  Stream<List<Book>> watchAllBooks() => _repo.watchAllBooks();

  /// Flux des livres avec le nom de la série (pour affichage liste).
  Stream<List<(Book, String?)>> watchAllBooksWithSeriesNames() =>
      _repo.watchAllBooksWithSeriesNames();

  /// Détails d'un livre + exemplaires.
  Future<Book?> getBook(String id) {
    _logger?.log('BookService.getBook', {'id': id});
    return _repo.getBookById(id);
  }
  Future<List<Copy>> getCopies(String bookId) => _repo.getCopiesByBook(bookId);

  /// Recherche par titre, auteur ou ISBN (même partiel). Retourne les livres avec le nom de série.
  Future<List<(Book, String?)>> searchBooksWithSeriesNames(String query) async {
    _logger?.log('BookService.searchBooksWithSeriesNames', {'query': query});
    final list = await _repo.searchBooks(query);
    if (list.isEmpty) return [];
    final allSeries = await _repo.getSeriesAll();
    final seriesNameById = {for (final s in allSeries) s.id: s.name};
    return list
        .map((b) => (
              b,
              b.seriesId != null ? seriesNameById[b.seriesId] : null,
            ))
        .toList();
  }

  Future<void> deleteBook(String id) {
    _logger?.log('BookService.deleteBook', {'id': id});
    return _repo.deleteBookById(id);
  }

  Future<void> deleteCopy(String id) {
    _logger?.log('BookService.deleteCopy', {'id': id});
    return _repo.deleteCopyById(id);
  }

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
    _logger?.log('BookService.addBookManually', {
      'isbn': isbn,
      'title': title,
      'authors': authors,
    });
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
  /// Retourne l'id du livre (œuvre) pour permettre la mise à jour des photos couverture/dos.
  Future<String> addOrUpdateFromIsbnScan(String isbn) async {
    _logger?.log('BookService.addOrUpdateFromIsbnScan', {'isbn': isbn});
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
      final volumeNumber = meta?.volumeNumber != null &&
              meta!.volumeNumber!.trim().isNotEmpty
          ? int.tryParse(meta.volumeNumber!)
          : null;
      final newBookId = _uuid.v4();

      final coverLocalPath = await _covers.downloadCoverToLocalPath(
        bookId: newBookId,
        coverUrl: coverUrl,
      );

      final summaryText = meta?.description?.trim().isNotEmpty == true
          ? meta!.description!.trim()
          : '';

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
          volumeNumber: Value(volumeNumber),
          summary: Value(summaryText),
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
          (existing.coverUrl == null || existing.coverUrl!.trim().isEmpty) ||
          existing.volumeNumber == null;

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

          final newVolumeNumber = (existing.volumeNumber == null &&
                  meta.volumeNumber != null &&
                  meta.volumeNumber!.trim().isNotEmpty)
              ? int.tryParse(meta.volumeNumber!)
              : existing.volumeNumber;

          String? newCoverLocalPath = existing.coverLocalPath;
          if ((newCoverLocalPath == null || newCoverLocalPath.trim().isEmpty) &&
              (newCoverUrl != null && newCoverUrl.trim().isNotEmpty)) {
            newCoverLocalPath = await _covers.downloadCoverToLocalPath(
              bookId: bookId,
              coverUrl: newCoverUrl,
            );
          }

          final newSummary = existing.summary.trim().isNotEmpty
              ? existing.summary
              : (meta.description?.trim().isNotEmpty == true
                  ? meta.description!.trim()
                  : existing.summary);

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
              volumeNumber: Value(newVolumeNumber),
              summary: Value(newSummary),
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
    return bookId;
  }

  /// Met à jour la couverture du livre après prise de photo au scan.
  Future<void> updateBookCoverFromScan(String bookId, String coverLocalPath) async {
    _logger?.log('BookService.updateBookCoverFromScan', {
      'bookId': bookId,
      'coverLocalPath': coverLocalPath,
    });
    await _repo.updateBookCoverLocalPath(bookId, coverLocalPath);
  }

  /// Met à jour les champs métadonnées d'un livre (titre, auteurs, isbn, etc.).
  Future<void> updateBookDetails(
    String id, {
    String? title,
    String? authors,
    String? isbn,
    String? publisher,
    String? publishedDate,
    int? volumeNumber,
    String? summary,
  }) async {
    _logger?.log('BookService.updateBookDetails', {'id': id});
    final existing = await _repo.getBookById(id);
    if (existing == null) return;
    await _repo.upsertBook(
      BooksCompanion(
        id: Value(id),
        isbn: Value(isbn ?? existing.isbn),
        title: Value(title ?? existing.title),
        seriesId: Value(existing.seriesId),
        volumeNumber: Value(volumeNumber ?? existing.volumeNumber),
        authors: Value(authors ?? existing.authors),
        publisher: Value(publisher ?? existing.publisher),
        publishedDate: Value(publishedDate ?? existing.publishedDate),
        coverUrl: Value(existing.coverUrl),
        coverLocalPath: Value(existing.coverLocalPath),
        tags: Value(existing.tags),
        summary: Value(summary ?? existing.summary),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Inverse la couverture et le dos (échange le contenu des deux images).
  Future<void> swapCoverAndBack(String bookId) async {
    _logger?.log('BookService.swapCoverAndBack', {'bookId': bookId});
    final b = await _repo.getBookById(bookId);
    if (b?.coverLocalPath == null || b!.coverLocalPath!.trim().isEmpty) return;
    final backPath = await _covers.backCoverPathForBook(bookId);
    final backFile = File(backPath);
    if (!await backFile.exists()) return;
    await _covers.swapCoverAndBack(b.coverLocalPath!, backPath);
  }
}

