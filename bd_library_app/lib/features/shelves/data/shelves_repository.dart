import '../../../db/app_db.dart';

class ShelvesRepository {
  final AppDb _db;

  ShelvesRepository(this._db);

  Stream<List<Shelf>> watchAllShelves() => _db.watchAllShelves();

  Future<List<Shelf>> getAllShelves() => _db.getAllShelves();

  Future<Shelf?> getShelfById(String id) => _db.getShelfById(id);

  Future<void> upsertShelf(ShelvesCompanion shelf) => _db.upsertShelf(shelf);

  Future<void> deleteShelfById(String id) => _db.deleteShelfById(id);

  Future<List<String>> getShelfIdsByBook(String bookId) =>
      _db.getShelfIdsByBook(bookId);

  Future<void> setBookShelves(String bookId, List<String> shelfIds) =>
      _db.setBookShelves(bookId, shelfIds);

  Future<List<Book>> getBooksByShelf(String shelfId) =>
      _db.getBooksByShelf(shelfId);

  Stream<List<Book>> watchBooksByShelf(String shelfId) =>
      _db.watchBooksByShelf(shelfId);
}
