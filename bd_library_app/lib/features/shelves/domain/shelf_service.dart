import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../db/app_db.dart';
import '../data/shelves_repository.dart';

class ShelfService {
  final ShelvesRepository _repo;
  final _uuid = const Uuid();

  ShelfService(this._repo);

  Stream<List<Shelf>> watchAllShelves() => _repo.watchAllShelves();

  Future<List<Shelf>> getAllShelves() => _repo.getAllShelves();

  Future<Shelf?> getShelfById(String id) => _repo.getShelfById(id);

  Future<void> createShelf({required String name, required String color}) async {
    await _repo.upsertShelf(
      ShelvesCompanion.insert(
        id: _uuid.v4(),
        name: name,
        color: Value(color),
        sortOrder: Value(await _repo.getAllShelves().then((s) => s.length)),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> updateShelf(String id,
      {String? name, String? color, int? sortOrder}) async {
    final existing = await _repo.getShelfById(id);
    if (existing == null) return;
    await _repo.upsertShelf(
      ShelvesCompanion(
        id: Value(id),
        name: name != null ? Value(name) : const Value.absent(),
        color: color != null ? Value(color) : const Value.absent(),
        sortOrder: sortOrder != null ? Value(sortOrder) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Retourne false si l'étagère est l'étagère système « Livres à classer ».
  Future<bool> deleteShelf(String id) async {
    if (id == DefaultUnclassifiedShelf.id) return false;
    await _repo.deleteShelfById(id);
    return true;
  }

  Future<List<String>> getShelfIdsForBook(String bookId) =>
      _repo.getShelfIdsByBook(bookId);

  Future<void> setBookShelves(String bookId, List<String> shelfIds) =>
      _repo.setBookShelves(bookId, shelfIds);

  Future<List<Book>> getBooksByShelf(String shelfId) =>
      _repo.getBooksByShelf(shelfId);

  Stream<List<Book>> watchBooksByShelf(String shelfId) =>
      _repo.watchBooksByShelf(shelfId);
}
