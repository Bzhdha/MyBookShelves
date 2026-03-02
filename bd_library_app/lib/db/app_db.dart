import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
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

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
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

/// --------------------
/// DB
/// --------------------
@DriftDatabase(tables: [Books, Series, Copies, Users, UserCopyMetas])
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  /// Migration strategy (v1 -> v2)
  /// - crée Copies
  /// - ajoute tags sur Series/Books si besoin
  ///
  /// NOTE: si tu avais rating/review en v1 dans Books,
  /// on ne peut pas les migrer automatiquement sans conserver l'ancien schéma.
  /// En pratique: fais une migration manuelle si tu as déjà des données.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(copies);
            // Si tu ajoutes tags après coup, Drift gérera via addColumn.
            // Ici, on suppose que v2 crée tags dès le départ.
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
    // supprimer d'abord les copies
    await (delete(copies)..where((c) => c.bookId.equals(id))).go();
    await (delete(books)..where((t) => t.id.equals(id))).go();
  }

  /// Recherche d'un work par ISBN (peut retourner plusieurs, mais souvent 0/1).
  Future<List<Book>> findWorksByIsbn(String isbn) =>
      (select(books)..where((t) => t.isbn.equals(isbn))).get();

  Future<List<Book>> getBooksBySeries(String seriesId) =>
      (select(books)
            ..where((t) => t.seriesId.equals(seriesId))
            ..orderBy([(t) => OrderingTerm.asc(t.volumeNumber)]))
          .get();

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
  Stream<List<Book>> watchAllBooks() =>
    (select(books)..orderBy([(t) => OrderingTerm.asc(t.title)])).watch();

}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'bd_library.sqlite'));
    return NativeDatabase(file);
  });
}
