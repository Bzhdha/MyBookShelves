import 'package:drift/drift.dart' hide Column;

import '../../../db/app_db.dart';

class BooksRepository {
  final AppDb _db;

  BooksRepository(this._db);

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
}

