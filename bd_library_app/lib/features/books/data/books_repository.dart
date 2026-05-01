
import '../../../db/app_db.dart';

class BooksRepository {
  final AppDb _db;

  BooksRepository(this._db);

  Future<List<SeriesData>> getSeriesAll() => _db.getAllSeries();

  Future<SeriesData?> findSeriesByNameInsensitive(String name) =>
      _db.findSeriesByNameInsensitive(name);

  Future<SeriesData?> getSeriesById(String id) => _db.getSeriesById(id);

  Future<void> upsertSeries(SeriesCompanion s) => _db.upsertSeries(s);

  Future<List<Book>> getBooksBySeries(String seriesId) =>
      _db.getBooksBySeries(seriesId);

  /// Flux de tous les livres ordonnés par titre.
  Stream<List<Book>> watchAllBooks() => _db.watchAllBooks();

  /// Flux des livres avec le nom de la série (pour affichage liste).
  Stream<List<(Book, String?)>> watchAllBooksWithSeriesNames() =>
      _db.watchAllBooksWithSeriesNames();

  /// Détails d'un livre.
  Future<Book?> getBookById(String id) => _db.getBookById(id);

  /// Exemplaires pour un livre donné.
  Future<List<Copy>> getCopiesByBook(String bookId) =>
      _db.getCopiesByBook(bookId);

  /// Création / mise à jour d'un livre.
  Future<void> upsertBook(BooksCompanion book) => _db.upsertBook(book);

  /// Suppression d'un livre (et de ses exemplaires via la logique DB).
  Future<void> deleteBookById(String id) => _db.deleteBookById(id);

  /// Création / mise à jour d'un exemplaire.
  Future<void> upsertCopy(CopiesCompanion copy) => _db.upsertCopy(copy);

  /// Suppression d'un exemplaire.
  Future<void> deleteCopyById(String id) => _db.deleteCopyById(id);

  /// Recherche d'œuvres par ISBN.
  Future<List<Book>> findWorksByIsbn(String isbn) =>
      _db.findWorksByIsbn(isbn);

  /// Recherche partielle par titre, auteur ou ISBN.
  Future<List<Book>> searchBooks(String query) => _db.searchBooks(query);

  /// Met à jour le chemin de la couverture locale (après prise au scan).
  Future<void> updateBookCoverLocalPath(String bookId, String? coverLocalPath) =>
      _db.updateBookCoverLocalPath(bookId, coverLocalPath);
}

