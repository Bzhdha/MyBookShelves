import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../db/app_db.dart';
import '../data/shelves_repository.dart';

class ShelfService {
  final ShelvesRepository _repo;
  final _uuid = const Uuid();

  ShelfService(this._repo);

  // ── Streams ──────────────────────────────────────────────────────────────
  Stream<List<Shelf>> watchAllShelves() => _repo.watchAllShelves();
  Stream<List<Shelf>> watchRootShelves() => _repo.watchRootShelves();
  Stream<List<Shelf>> watchChildShelves(String parentId) =>
      _repo.watchChildShelves(parentId);

  // ── Lectures ─────────────────────────────────────────────────────────────
  Future<List<Shelf>> getAllShelves() => _repo.getAllShelves();
  Future<List<Shelf>> getRootShelves() => _repo.getRootShelves();
  Future<List<Shelf>> getChildShelves(String parentId) =>
      _repo.getChildShelves(parentId);
  Future<Shelf?> getShelfById(String id) => _repo.getShelfById(id);

  // ── Écriture ─────────────────────────────────────────────────────────────

  Future<void> createShelf({
    required String name,
    required String color,
    String? parentId,
  }) async {
    await _repo.upsertShelf(
      ShelvesCompanion.insert(
        id: _uuid.v4(),
        name: name,
        color: Value(color),
        sortOrder: Value(await _repo.getAllShelves().then((s) => s.length)),
        parentId: Value(parentId),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> updateShelf(
    String id, {
    String? name,
    String? color,
    int? sortOrder,
    Value<String?> parentId = const Value.absent(),
  }) async {
    final existing = await _repo.getShelfById(id);
    if (existing == null) return;
    await _repo.upsertShelf(
      ShelvesCompanion(
        id: Value(id),
        name: name != null ? Value(name) : const Value.absent(),
        color: color != null ? Value(color) : const Value.absent(),
        sortOrder: sortOrder != null ? Value(sortOrder) : const Value.absent(),
        parentId: parentId,
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Retourne false si l'étagère est l'étagère système « Livres à classer ».
  /// Les sous-étagères sont promues à la racine avant suppression.
  Future<bool> deleteShelf(String id) async {
    if (id == DefaultUnclassifiedShelf.id) return false;
    await _repo.deleteShelfById(id);
    return true;
  }

  // ── Livres ────────────────────────────────────────────────────────────────
  Future<List<String>> getShelfIdsForBook(String bookId) =>
      _repo.getShelfIdsByBook(bookId);

  Future<void> setBookShelves(String bookId, List<String> shelfIds) =>
      _repo.setBookShelves(bookId, shelfIds);

  Future<List<Book>> getBooksByShelf(String shelfId) =>
      _repo.getBooksByShelf(shelfId);

  Stream<List<Book>> watchBooksByShelf(String shelfId) =>
      _repo.watchBooksByShelf(shelfId);

  /// Livres directement dans [shelfId] + ceux de ses sous-étagères.
  Future<List<Book>> getBooksInShelfWithChildren(String shelfId) =>
      _repo.getBooksInShelfWithChildren(shelfId);

  Stream<List<Book>> watchBooksInShelfWithChildren(String shelfId) =>
      _repo.watchBooksInShelfWithChildren(shelfId);
}
