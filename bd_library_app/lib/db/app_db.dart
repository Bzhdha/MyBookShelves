import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'family_tables.dart';

part 'app_db.g.dart';

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

  /// Tags perso (CSV) : "SF, Aventure, Humour"
  TextColumn get tags => text().withDefault(const Constant(''))();

  /// Résumé / synopsis (saisi à la main ou issu d'une recherche IA).
  TextColumn get summary => text().withDefault(const Constant(''))();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Étagères thématiques pour classer les livres (nom + couleur).
@DataClassName('Shelf')
class Shelves extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get color => text().withDefault(const Constant('#6200EE'))(); // hex
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
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
])
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  /// Migration strategy (v1 -> … -> v5)
  /// v2: Copies. v3: Shelves + BookShelf. v4: Books.summary. v5: suivi lecture.
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
        },
      );

  /// --------------------
  /// Series
  /// --------------------
  Future<List<SeriesData>> getAllSeries() =>
      (select(series)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();

  Future<SeriesData?> getSeriesById(String id) =>
      (select(series)..where((t) => t.id.equals(id))).getSingleOrNull();

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
    await (delete(copies)..where((c) => c.bookId.equals(id))).go();
    await (delete(books)..where((t) => t.id.equals(id))).go();
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

  Future<Shelf?> getShelfById(String id) =>
      (select(shelves)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertShelf(ShelvesCompanion s) =>
      into(shelves).insertOnConflictUpdate(s);

  Future<void> deleteShelfById(String id) async {
    await (delete(bookShelf)..where((t) => t.shelfId.equals(id))).go();
    await (delete(shelves)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<Shelf>> watchAllShelves() =>
      (select(shelves)..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.name)])).watch();

  /// --------------------
  /// BookShelf (livre ↔ étagère)
  /// --------------------
  Future<List<String>> getShelfIdsByBook(String bookId) async {
    final rows = await (select(bookShelf)..where((t) => t.bookId.equals(bookId))).get();
    return rows.map((r) => r.shelfId).toList();
  }

  Future<void> setBookShelves(String bookId, List<String> shelfIds) async {
    await (delete(bookShelf)..where((t) => t.bookId.equals(bookId))).go();
    for (final shelfId in shelfIds) {
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
