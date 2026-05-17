import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'family_tables.dart';

part 'app_db.g.dart';

/// Étagère système : les œuvres sans autre classement y sont rattachées.
abstract class DefaultUnclassifiedShelf {
  static const String id = 'a1b2c3d4-e5f6-47a8-8c9d-0e1f2a3b4c5d';
  static const String name = 'Livres à classer';
  static const String color = '#78909C';
  static const int sortOrder = -1000;
}

/// --------------------
/// Tables
/// --------------------

@DataClassName('SeriesData')
class Series extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();

  /// Mode A: nombre total attendu de tomes (si null => inconnu)
  IntColumn get expectedVolumes => integer().nullable()();

  /// Tags optionnels (CSV) pour recommandations thématiques (offline)
  TextColumn get tags => text().withDefault(const Constant(''))();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Représente l'œuvre / édition (métadonnées partagées).
/// Note/avis ne sont PAS ici (ils sont au niveau exemplaire dans Copies).
class Books extends Table {
  TextColumn get id => text()(); // UUID (œuvre)

  TextColumn get isbn => text().nullable()(); // EAN-13 / ISBN-10/13 (non unique)
  TextColumn get title => text()();

  TextColumn get seriesId => text().nullable().references(Series, #id)();
  IntColumn get volumeNumber => integer().nullable()();

  TextColumn get authors => text().withDefault(const Constant(''))(); // CSV simple
  TextColumn get publisher => text().nullable()();
  TextColumn get publishedDate => text().nullable()(); // string (API varie)
  TextColumn get coverUrl => text().nullable()();
  TextColumn get coverLocalPath => text().nullable()();
  TextColumn get tags => text().withDefault(const Constant(''))();
  TextColumn get summary => text().withDefault(const Constant(''))();
  IntColumn get pageCount => integer().nullable()();
  RealColumn get retailPrice => real().nullable()();
  DateTimeColumn get registeredAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Étagères thématiques pour classer les livres (nom + couleur).
/// parentId null = étagère racine ; non-null = sous-étagère (max 2 niveaux).
@DataClassName('Shelf')
class Shelves extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get color => text().withDefault(const Constant('#6200EE'))(); // hex
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get parentId => text().nullable()(); // UUID étagère parente (null = racine)
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Association livre ↔ étagère (N-N).
class BookShelf extends Table {
  TextColumn get bookId => text().references(Books, #id)();
  TextColumn get shelfId => text().references(Shelves, #id)();

  @override
  Set<Column> get primaryKey => {bookId, shelfId};
}

/// Représente un exemplaire (doublons gérés ici).
/// Note + avis au niveau exemplaire.
class Copies extends Table {
  TextColumn get id => text()(); // UUID (exemplaire)
  TextColumn get bookId => text().references(Books, #id)(); // FK œuvre

  IntColumn get rating => integer().withDefault(const Constant(0))(); // 0..5
  TextColumn get review => text().withDefault(const Constant(''))();

  /// Etat (1..5) : 1=abîmé, 5=neuf
  IntColumn get condition => integer().withDefault(const Constant(3))();

  /// Localisation (étagère, pièce)
  TextColumn get location => text().nullable()();

  /// Notes exemplaire (ex: dédicace, achat, etc.)
  TextColumn get notes => text().withDefault(const Constant(''))();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Progression de lecture par livre (œuvre).
@DataClassName('ReadingProgressRow')
class ReadingProgress extends Table {
  TextColumn get bookId => text()();
  /// 0 = à lire, 1 = en cours, 2 = terminé
  IntColumn get status => integer().withDefault(const Constant(0))();
  IntColumn get currentPage => integer().withDefault(const Constant(0))();
  IntColumn get totalPages => integer().nullable()();
  BoolColumn get usePercentage =>
      boolean().withDefault(const Constant(false))();
  IntColumn get progressPercent => integer().nullable()();
  DateTimeColumn get readingStartedAt => dateTime().nullable()();
  DateTimeColumn get readingFinishedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {bookId};
}

@DataClassName('ReadingSession')
class ReadingSessions extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get startPage => integer().withDefault(const Constant(0))();
  IntColumn get endPage => integer().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  BoolColumn get finishedBook => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ReadingGoalsRow')
class ReadingGoals extends Table {
  TextColumn get id => text()();
  IntColumn get booksPerMonth => integer().nullable()();
  IntColumn get booksPerYear => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Badges de lecture débloqués (clé stable + période pour les badges récurrents).
@DataClassName('EarnedBadgeRow')
class EarnedBadges extends Table {
  TextColumn get id => text()();
  TextColumn get badgeId => text()();
  /// Ex. clé semaine `2026-05-04` (lundi), mois `2026-05`, année `2026`, ou `''` pour badges vie entière.
  TextColumn get periodKey => text().withDefault(const Constant(''))();
  DateTimeColumn get unlockedAt => dateTime()();
  TextColumn get contextJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// --------------------
/// DB
/// --------------------
@DriftDatabase(tables: [
  Books,
  Series,
  Copies,
  Shelves,
  BookShelf,
  Users,
  UserCopyMetas,
  ReadingProgress,
  ReadingSessions,
  ReadingGoals,
  EarnedBadges,
])
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());
  AppDb.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 9;

  /// v2: Copies. v3: Shelves + BookShelf. v4: Books.summary. v5: suivi lecture.
  /// v6: étagère par défaut. v7: parentId Shelves. v8: EarnedBadges.
  /// v9: Books.pageCount, retailPrice, registeredAt.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(copies);
          }
          if (from < 3) {
            await m.createTable(shelves);
            await m.createTable(bookShelf);
          }
          if (from < 4) {
            await m.addColumn(books, books.summary);
          }
          if (from < 5) {
            await m.createTable(readingProgress);
            await m.createTable(readingSessions);
            await m.createTable(readingGoals);
            await into(readingGoals).insert(
              ReadingGoalsCompanion.insert(id: 'default'),
            );
          }
          if (from < 6) {
            await ensureDefaultUnclassifiedShelfExists();
            await assignDefaultShelfToBooksWithoutShelves();
          }
          if (from < 7) {
            await m.addColumn(shelves, shelves.parentId);
          }
          if (from < 8) {
            await m.createTable(earnedBadges);
          }
          if (from < 9) {
            await m.addColumn(books, books.pageCount);
            await m.addColumn(books, books.retailPrice);
            await m.addColumn(books, books.registeredAt);
            await customStatement(
              'UPDATE books SET registered_at = updated_at WHERE registered_at IS NULL',
            );
          }
        },
        beforeOpen: (details) async {
          await ensureDefaultUnclassifiedShelfExists();
        },
      );

  /// --------------------
  /// Series
  /// --------------------
  Future<List<SeriesData>> getAllSeries() =>
      (select(series)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();

  Future<SeriesData?> getSeriesById(String id) =>
      (select(series)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Trouve une série par nom (insensible à la casse, espaces bords ignorés côté appelant).
  Future<SeriesData?> findSeriesByNameInsensitive(String name) {
    final n = name.trim();
    if (n.isEmpty) {
      return Future.value(null);
    }
    return (select(series)..where((t) => t.name.lower().equals(n.toLowerCase())))
        .getSingleOrNull();
  }

  Future<void> upsertSeries(SeriesCompanion s) =>
      into(series).insertOnConflictUpdate(s);

  Future<void> deleteSeriesById(String id) async {
    await (delete(series)..where((t) => t.id.equals(id))).go();
  }

  /// --------------------
  /// Books (works)
  /// --------------------
  Future<List<Book>> getAllBooks() =>
      (select(books)..orderBy([(t) => OrderingTerm.asc(t.title)])).get();

  Future<Book?> getBookById(String id) =>
      (select(books)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertBook(BooksCompanion b) =>
      into(books).insertOnConflictUpdate(b);

  Future<void> deleteBookById(String id) async {
    await (delete(readingSessions)..where((s) => s.bookId.equals(id))).go();
    await (delete(readingProgress)..where((p) => p.bookId.equals(id))).go();
    await (delete(bookShelf)..where((t) => t.bookId.equals(id))).go();
    await (delete(copies)..where((c) => c.bookId.equals(id))).go();
    await (delete(books)..where((t) => t.id.equals(id))).go();
  }

  /// Crée l'étagère « Livres à classer » si elle n'existe pas (id stable, ne réécrit pas un nom modifié).
  Future<void> ensureDefaultUnclassifiedShelfExists() async {
    final existing = await getShelfById(DefaultUnclassifiedShelf.id);
    if (existing != null) return;
    await into(shelves).insert(
      ShelvesCompanion.insert(
        id: DefaultUnclassifiedShelf.id,
        name: DefaultUnclassifiedShelf.name,
        color: const Value(DefaultUnclassifiedShelf.color),
        sortOrder: const Value(DefaultUnclassifiedShelf.sortOrder),
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Rattache l'étagère par défaut aux œuvres qui n'ont aucun lien [BookShelf].
  Future<void> assignDefaultShelfToBooksWithoutShelves() async {
    await ensureDefaultUnclassifiedShelfExists();
    final allBooks = await getAllBooks();
    for (final b in allBooks) {
      final ids = await getShelfIdsByBook(b.id);
      if (ids.isEmpty) {
        await into(bookShelf).insert(
          BookShelfCompanion.insert(
            bookId: b.id,
            shelfId: DefaultUnclassifiedShelf.id,
          ),
        );
      }
    }
  }

  /// Recherche d'un work par ISBN (peut retourner plusieurs, mais souvent 0/1).
  Future<List<Book>> findWorksByIsbn(String isbn) =>
      (select(books)..where((t) => t.isbn.equals(isbn))).get();

  /// Recherche partielle par titre, auteur ou ISBN (sensible à la casse selon le moteur).
  Future<List<Book>> searchBooks(String query) {
    final q = query.trim();
    if (q.isEmpty) return getAllBooks();
    final pattern = '%${_escapeLike(q)}%';
    return (select(books)
          ..where((t) =>
              t.title.like(pattern) |
              t.authors.like(pattern) |
              t.summary.like(pattern) |
              (t.isbn.isNotNull() & t.isbn.like(pattern)))
          ..orderBy([(t) => OrderingTerm.asc(t.title)]))
        .get();
  }

  static String _escapeLike(String s) {
    return s
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
  }

  Future<List<Book>> getBooksBySeries(String seriesId) =>
      (select(books)
            ..where((t) => t.seriesId.equals(seriesId))
            ..orderBy([(t) => OrderingTerm.asc(t.volumeNumber)]))
          .get();

  /// Met à jour uniquement le chemin de la couverture (après prise au scan).
  Future<void> updateBookCoverLocalPath(String bookId, String? coverLocalPath) async {
    await (update(books)..where((t) => t.id.equals(bookId))).write(
      BooksCompanion(
        coverLocalPath: coverLocalPath != null ? Value(coverLocalPath) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// --------------------
  /// Copies (exemplaires)
  /// --------------------
  Future<List<Copy>> getCopiesByBook(String bookId) =>
      (select(copies)
            ..where((c) => c.bookId.equals(bookId))
            ..orderBy([(c) => OrderingTerm.desc(c.updatedAt)]))
          .get();

  Future<int> countCopiesForBook(String bookId) async {
    final q = selectOnly(copies)
      ..addColumns([copies.id.count()])
      ..where(copies.bookId.equals(bookId));
    final row = await q.getSingle();
    return row.read(copies.id.count()) ?? 0;
  }

  Future<void> upsertCopy(CopiesCompanion c) =>
      into(copies).insertOnConflictUpdate(c);

  Future<void> deleteCopyById(String id) async {
    await (delete(copies)..where((c) => c.id.equals(id))).go();
  }

  /// --------------------
  /// Shelves (étagères thématiques)
  /// --------------------
  Future<List<Shelf>> getAllShelves() =>
      (select(shelves)..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.name)])).get();

  Future<List<Shelf>> getRootShelves() =>
      (select(shelves)
        ..where((t) => t.parentId.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.name)]))
      .get();

  Stream<List<Shelf>> watchRootShelves() =>
      (select(shelves)
        ..where((t) => t.parentId.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.name)]))
      .watch();

  Future<List<Shelf>> getChildShelves(String parentId) =>
      (select(shelves)
        ..where((t) => t.parentId.equals(parentId))
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.name)]))
      .get();

  Stream<List<Shelf>> watchChildShelves(String parentId) =>
      (select(shelves)
        ..where((t) => t.parentId.equals(parentId))
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.name)]))
      .watch();

  Future<Shelf?> getShelfById(String id) =>
      (select(shelves)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertShelf(ShelvesCompanion s) =>
      into(shelves).insertOnConflictUpdate(s);

  /// Supprime une étagère. Les sous-étagères sont promues à la racine.
  Future<void> deleteShelfById(String id) async {
    if (id == DefaultUnclassifiedShelf.id) return;
    // Promouvoir les enfants à la racine avant suppression
    await (update(shelves)..where((t) => t.parentId.equals(id)))
        .write(const ShelvesCompanion(parentId: Value(null)));
    await (delete(bookShelf)..where((t) => t.shelfId.equals(id))).go();
    await (delete(shelves)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<Shelf>> watchAllShelves() =>
      (select(shelves)..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.name)])).watch();

  /// Retourne les livres directement dans [shelfId] + ceux de ses sous-étagères.
  Future<List<Book>> getBooksInShelfWithChildren(String shelfId) async {
    final bookIds = <String>{};
    final direct = await (select(bookShelf)..where((t) => t.shelfId.equals(shelfId))).get();
    for (final r in direct) bookIds.add(r.bookId);
    final children = await getChildShelves(shelfId);
    for (final child in children) {
      final rows = await (select(bookShelf)..where((t) => t.shelfId.equals(child.id))).get();
      for (final r in rows) bookIds.add(r.bookId);
    }
    if (bookIds.isEmpty) return [];
    return (select(books)
      ..where((t) => t.id.isIn(bookIds.toList()))
      ..orderBy([(t) => OrderingTerm.asc(t.title)]))
    .get();
  }

  Stream<List<Book>> watchBooksInShelfWithChildren(String shelfId) =>
      (select(bookShelf)).watch().asyncExpand((_) async* {
        yield await getBooksInShelfWithChildren(shelfId);
      });

  /// --------------------
  /// BookShelf (livre ↔ étagère)
  /// --------------------
  Future<List<String>> getShelfIdsByBook(String bookId) async {
    final rows = await (select(bookShelf)..where((t) => t.bookId.equals(bookId))).get();
    return rows.map((r) => r.shelfId).toList();
  }

  Future<void> setBookShelves(String bookId, List<String> shelfIds) async {
    await ensureDefaultUnclassifiedShelfExists();
    final unique = <String>{...shelfIds}.toList();
    final effective =
        unique.isEmpty ? <String>[DefaultUnclassifiedShelf.id] : unique;
    await (delete(bookShelf)..where((t) => t.bookId.equals(bookId))).go();
    for (final shelfId in effective) {
      await into(bookShelf).insert(BookShelfCompanion.insert(bookId: bookId, shelfId: shelfId));
    }
  }

  Future<List<Book>> getBooksByShelf(String shelfId) async {
    final ids = await (select(bookShelf)..where((t) => t.shelfId.equals(shelfId))).get();
    if (ids.isEmpty) return [];
    final bookIds = ids.map((r) => r.bookId).toList();
    return (select(books)..where((t) => t.id.isIn(bookIds))..orderBy([(t) => OrderingTerm.asc(t.title)])).get();
  }

  Stream<List<Book>> watchBooksByShelf(String shelfId) {
    return (select(bookShelf)..where((t) => t.shelfId.equals(shelfId)))
        .watch()
        .asyncExpand((_) async* {
      yield await getBooksByShelf(shelfId);
    });
  }

  /// --------------------
  /// Users (membres famille)
  /// --------------------
  Future<List<User>> getAllUsers() =>
      (select(users)..orderBy([(t) => OrderingTerm.asc(t.displayName)])).get();

  Future<void> deleteUserById(String id) async {
    await (delete(userCopyMetas)..where((t) => t.userId.equals(id))).go();
    await (delete(users)..where((t) => t.id.equals(id))).go();
  }

  /// --------------------
  /// Series incomplete (Mode A)
  /// --------------------
  Future<List<SeriesData>> getIncompleteSeriesModeA() async {
    final all = await getAllSeries();
    final result = <SeriesData>[];

    for (final s in all) {
      final expected = s.expectedVolumes;
      if (expected == null || expected <= 0) continue;

      final works = await getBooksBySeries(s.id);
      final ownedNums = works
          .map((b) => b.volumeNumber)
          .whereType<int>()
          .toSet();

      if (ownedNums.length < expected) {
        result.add(s);
      }
    }
    return result;
  }


  // refresh the list of books
  /// Métas (avis / prêt) de l'utilisateur pour une liste d'exemplaires.
  Future<List<UserCopyMeta>> getMetasForUserForCopies(
    String userId,
    List<String> copyIds,
  ) {
    if (copyIds.isEmpty) return Future.value([]);
    return (select(userCopyMetas)
          ..where((t) =>
              t.userId.equals(userId) & t.copyId.isIn(copyIds)))
        .get();
  }

  Stream<List<Book>> watchAllBooks() =>
    (select(books)..orderBy([(t) => OrderingTerm.asc(t.title)])).watch();

  /// Flux des livres avec le nom de la série (pour affichage liste).
  Stream<List<(Book, String?)>> watchAllBooksWithSeriesNames() async* {
    await for (final bookList in watchAllBooks()) {
      final allSeries = await getAllSeries();
      final seriesNameById = {for (final s in allSeries) s.id: s.name};
      yield bookList.map((b) => (
        b,
        b.seriesId != null ? seriesNameById[b.seriesId] : null,
      )).toList();
    }
  }

  /// --------------------
  /// Suivi de lecture
  /// --------------------
  Future<ReadingProgressRow?> readingProgressForBook(String bookId) =>
      (select(readingProgress)..where((t) => t.bookId.equals(bookId)))
          .getSingleOrNull();

  Future<ReadingProgressRow> getOrCreateReadingProgress(String bookId) async {
    final existing = await readingProgressForBook(bookId);
    if (existing != null) return existing;
    await into(readingProgress).insert(
      ReadingProgressCompanion.insert(
        bookId: bookId,
      ),
    );
    return (await readingProgressForBook(bookId))!;
  }

  Future<void> upsertReadingProgress(ReadingProgressCompanion c) =>
      into(readingProgress).insertOnConflictUpdate(c);

  Stream<List<ReadingProgressRow>> watchReadingProgress() =>
      select(readingProgress).watch();

  Future<List<ReadingProgressRow>> allReadingProgressRows() =>
      select(readingProgress).get();

  Future<ReadingSession?> getActiveReadingSession() async {
    final rows = await (select(readingSessions)
          ..where((t) => t.endedAt.isNull())
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> insertReadingSession(ReadingSessionsCompanion row) =>
      into(readingSessions).insert(row);

  Future<void> updateReadingSession(
    String id,
    ReadingSessionsCompanion patch,
  ) async {
    await (update(readingSessions)..where((t) => t.id.equals(id)))
        .write(patch);
  }

  Future<List<ReadingSession>> completedReadingSessions({
    int limit = 500,
  }) =>
      (select(readingSessions)
            ..where((t) => t.endedAt.isNotNull())
            ..orderBy([(t) => OrderingTerm.desc(t.endedAt)])
            ..limit(limit))
          .get();

  /// Pour chaque `bookId`, la date de fin de séance la plus récente (sessions terminées uniquement).
  Future<Map<String, DateTime>> lastCompletedSessionEndByBookIds(
    List<String> bookIds,
  ) async {
    if (bookIds.isEmpty) return {};
    final rows = await (select(readingSessions)
          ..where((t) => t.bookId.isIn(bookIds) & t.endedAt.isNotNull()))
        .get();
    final map = <String, DateTime>{};
    for (final s in rows) {
      final ended = s.endedAt!;
      final prev = map[s.bookId];
      if (prev == null || ended.isAfter(prev)) {
        map[s.bookId] = ended;
      }
    }
    return map;
  }

  Future<int> totalCompletedReadingSeconds() async {
    final sessions = await (select(readingSessions)
          ..where((t) => t.endedAt.isNotNull()))
        .get();
    var total = 0;
    for (final s in sessions) {
      total += s.durationSeconds ?? 0;
    }
    return total;
  }

  Future<ReadingGoalsRow?> readingGoalsRow() =>
      (select(readingGoals)..where((t) => t.id.equals('default')))
          .getSingleOrNull();

  Future<ReadingGoalsRow> getOrCreateReadingGoals() async {
    final g = await readingGoalsRow();
    if (g != null) return g;
    await into(readingGoals).insert(
      ReadingGoalsCompanion.insert(id: 'default'),
    );
    return (await readingGoalsRow())!;
  }

  Future<void> upsertReadingGoals(ReadingGoalsCompanion g) =>
      into(readingGoals).insertOnConflictUpdate(g);

  /// --------------------
  /// Badges de lecture
  /// --------------------
  Future<EarnedBadgeRow?> earnedBadgeByBadgeAndPeriod(
    String badgeId,
    String periodKey,
  ) =>
      (select(earnedBadges)
            ..where(
              (t) => t.badgeId.equals(badgeId) & t.periodKey.equals(periodKey),
            ))
          .getSingleOrNull();

  Future<bool> insertEarnedBadgeIfAbsent(EarnedBadgesCompanion row) async {
    if (!row.badgeId.present) return false;
    final badgeId = row.badgeId.value;
    final periodKey = row.periodKey.present ? row.periodKey.value : '';
    final existing = await earnedBadgeByBadgeAndPeriod(badgeId, periodKey);
    if (existing != null) return false;
    await into(earnedBadges).insert(row);
    return true;
  }

  Future<List<EarnedBadgeRow>> allEarnedBadgesOrdered() =>
      (select(earnedBadges)..orderBy([(t) => OrderingTerm.desc(t.unlockedAt)]))
          .get();

  Stream<List<EarnedBadgeRow>> watchEarnedBadges() =>
      (select(earnedBadges)..orderBy([(t) => OrderingTerm.desc(t.unlockedAt)]))
          .watch();

  /// Livres terminés (sessions avec [finishedBook]) dans l’intervalle [from, to].
  Future<int> countFinishedBooksBetween(DateTime from, DateTime to) async {
    final rows = await (select(readingSessions)
          ..where(
            (t) =>
                t.endedAt.isNotNull() &
                t.finishedBook.equals(true) &
                t.endedAt.isBiggerOrEqualValue(from) &
                t.endedAt.isSmallerOrEqualValue(to),
          ))
        .get();
    return rows.length;
  }

  Future<Book?> getLastFinishedBook() async {
    final rows = await (select(readingProgress)..where((t)=>t.status.equals(2)&t.readingFinishedAt.isNotNull())..orderBy([(t)=>OrderingTerm.desc(t.readingFinishedAt)])..limit(1)).get();
    if(rows.isEmpty)return null;
    return getBookById(rows.first.bookId);
  }

  Future<List<(Book,ReadingProgressRow)>> getBooksInProgress() async {
    final rows = await (select(readingProgress)..where((t)=>t.status.equals(1))).get();
    final out=<(Book,ReadingProgressRow)>[];
    for(final r in rows){final b=await getBookById(r.bookId);if(b!=null)out.add((b,r));}
    return out;
  }

  Future<List<Book>> getUnclassifiedBooks() async {
    final allBooks = await getAllBooks();
    final classified = <String>{};
    final bsRows = await select(bookShelf).get();
    for (final r in bsRows) classified.add(r.bookId);
    return allBooks.where((b) => !classified.contains(b.id)).toList();
  }

  Future<List<(SeriesData,List<int>)>> getSeriesWithMissingVolumes() async {
    final all=await getAllSeries();final out=<(SeriesData,List<int>)>[];
    for(final s in all){
      final exp=s.expectedVolumes;if(exp==null||exp<=0)continue;
      final books=await getBooksBySeries(s.id);
      final owned=books.map((b)=>b.volumeNumber).whereType<int>().toSet();
      final missing=<int>[];for(int i=1;i<=exp;i++){if(!owned.contains(i))missing.add(i);}
      if(missing.isNotEmpty)out.add((s,missing));
    }
    return out;
  }

  /// Séries incomplètes avec au moins 1 tome possédé, triées par taux de complétion décroissant.
  Future<List<({SeriesData series,int owned,List<int> missing})>> getSeriesCompletionSuggestions()async{
    final all=await getAllSeries();
    final result=<({SeriesData series,int owned,List<int> missing})>[];
    for(final s in all){
      final exp=s.expectedVolumes;if(exp==null||exp<=0)continue;
      final bks=await getBooksBySeries(s.id);
      final ownedNums=bks.map((b)=>b.volumeNumber).whereType<int>().toSet();
      if(ownedNums.isEmpty)continue;
      final missing=<int>[];for(int i=1;i<=exp;i++){if(!ownedNums.contains(i))missing.add(i);}
      if(missing.isEmpty)continue;
      result.add((series:s,owned:ownedNums.length,missing:missing));
    }
    result.sort((a,b){
      final pA=a.owned/a.series.expectedVolumes!;
      final pB=b.owned/b.series.expectedVolumes!;
      return pB.compareTo(pA);
    });
    return result;
  }

  /// Détecte automatiquement les lacunes entre le premier et le dernier tome
  /// possédé, sans nécessiter que [expectedVolumes] soit renseigné.
  Future<List<({SeriesData series,List<int> gaps})>> getAutoDetectedSeriesGaps()async{
    final all=await getAllSeries();
    final result=<({SeriesData series,List<int> gaps})>[];
    for(final s in all){
      final books=await getBooksBySeries(s.id);
      final owned=books.map((b)=>b.volumeNumber).whereType<int>().toSet();
      if(owned.length<2)continue;
      final minV=owned.reduce((a,b)=>a<b?a:b);
      final maxV=owned.reduce((a,b)=>a>b?a:b);
      final gaps=<int>[];
      for(int i=minV+1;i<maxV;i++){if(!owned.contains(i))gaps.add(i);}
      if(gaps.isEmpty)continue;
      result.add((series:s,gaps:gaps));
    }
    result.sort((a,b)=>a.gaps.length.compareTo(b.gaps.length));
    return result;
  }
}

/// Constantes statut de lecture (alignées sur [ReadingProgress.status]).
abstract class ReadingStatusValues {
  static const int toRead = 0;
  static const int inProgress = 1;
  static const int finished = 2;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'bd_library.sqlite'));
    return NativeDatabase(file);
  });
}
