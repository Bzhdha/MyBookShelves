import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../db/app_db.dart';
import '../../../models/export_model.dart';
import '../../reading/domain/reading_badge_evaluator.dart';

/// Couvertures locales + photo dos (`<bookId>_back.jpg`) dans le ZIP sous `covers/`.
Future<void> addLocalCoverImagesToZip(
  ZipFileEncoder encoder,
  List<Book> allBooks,
) async {
  final doc = await getApplicationDocumentsDirectory();
  final coversDir = Directory(p.join(doc.path, 'covers'));
  final addedBasenames = <String>{};

  Future<void> tryAdd(String? filePath) async {
    if (filePath == null || filePath.trim().isEmpty) return;
    final f = File(filePath);
    if (!await f.exists()) return;
    final name = p.basename(f.path);
    if (addedBasenames.contains(name)) return;
    addedBasenames.add(name);
    final bytes = await f.readAsBytes();
    encoder.addArchiveFile(ArchiveFile('covers/$name', bytes.length, bytes));
  }

  for (final b in allBooks) {
    await tryAdd(b.coverLocalPath);
    if (await coversDir.exists()) {
      await tryAdd(p.join(coversDir.path, '${b.id}_back.jpg'));
    }
  }
}

/// ----------------------------
/// Import conflicts
/// ----------------------------

enum ConflictChoice { keepLocal, keepImported, merge }

/// Conflit au niveau "œuvre" (Book/work).
/// Les exemplaires (Copies) sont importés en plus dans tous les cas (upsert par id).
class WorkConflict {
  final String localBookId;
  final ExportBook imported;
  ConflictChoice choice;

  WorkConflict({
    required this.localBookId,
    required this.imported,
    this.choice = ConflictChoice.merge,
  });
}

class ImportPlan {
  final List<ExportSeries> seriesToUpsert;

  /// Œuvres nouvelles
  final List<ExportBook> booksToCreate;

  /// Œuvres qui matchent et peuvent être upsert sans conflit (ou conflits auto-résolus si tu le souhaites)
  final List<MapEntry<String /*localBookId*/, ExportBook /*imported*/>> booksToUpdateNoConflict;

  /// Œuvres en conflit => choix utilisateur requis
  final List<WorkConflict> conflicts;

  /// Exemplaires importés. Le bookId devra être remappé vers le work local cible.
  final List<ExportCopy> copiesToUpsert;

  /// Mapping importBookId -> localBookId (après matching). Rempli lors de buildImportPlan.
  final Map<String, String> importedWorkIdToLocalWorkId;

  /// v3+ : étagères, classement, suivi de lecture (listes vides si export ancien).
  final List<ExportShelf> shelvesToUpsert;
  final List<ExportBookShelf> bookShelfLinks;
  final List<ExportReadingProgress> readingProgressToUpsert;
  final List<ExportReadingSession> readingSessionsToUpsert;
  final List<ExportReadingGoals> readingGoalsToUpsert;

  ImportPlan({
    required this.seriesToUpsert,
    required this.booksToCreate,
    required this.booksToUpdateNoConflict,
    required this.conflicts,
    required this.copiesToUpsert,
    required this.importedWorkIdToLocalWorkId,
    this.shelvesToUpsert = const [],
    this.bookShelfLinks = const [],
    this.readingProgressToUpsert = const [],
    this.readingSessionsToUpsert = const [],
    this.readingGoalsToUpsert = const [],
  });
}

/// ----------------------------
/// Transfer service
/// ----------------------------
class LibraryTransferService {
  final AppDb db;
  LibraryTransferService(this.db);

  /// Charge l’état complet pour [library.json] (v3 : séries, œuvres, exemplaires, étagères, lecture).
  Future<ExportLibrary> buildExportLibraryPayload() async {
    final allSeries = await db.getAllSeries();
    final allBooks = await db.getAllBooks();

    final allCopies = <Copy>[];
    for (final b in allBooks) {
      allCopies.addAll(await db.getCopiesByBook(b.id));
    }

    final allShelves = await db.getAllShelves();
    final bookShelfRows = await db.select(db.bookShelf).get();
    final progressRows = await db.allReadingProgressRows();
    final sessionRows = await db.select(db.readingSessions).get();
    final goalRows = await db.select(db.readingGoals).get();

    return ExportLibrary(
      version: 3,
      exportedAt: DateTime.now(),
      series: allSeries
          .map((s) => ExportSeries(
                id: s.id,
                name: s.name,
                expectedVolumes: s.expectedVolumes,
                tags: s.tags,
                updatedAt: s.updatedAt,
              ))
          .toList(),
      books: allBooks
          .map((b) => ExportBook(
                id: b.id,
                isbn: b.isbn,
                title: b.title,
                seriesId: b.seriesId,
                volumeNumber: b.volumeNumber,
                authors: b.authors,
                publisher: b.publisher,
                publishedDate: b.publishedDate,
                coverUrl: b.coverUrl,
                tags: b.tags,
                summary: b.summary,
                pageCount: b.pageCount,
                retailPrice: b.retailPrice,
                registeredAt: b.registeredAt,
                updatedAt: b.updatedAt,
              ))
          .toList(),
      copies: allCopies
          .map((c) => ExportCopy(
                id: c.id,
                bookId: c.bookId,
                rating: c.rating,
                review: c.review,
                condition: c.condition,
                location: c.location,
                notes: c.notes,
                updatedAt: c.updatedAt,
              ))
          .toList(),
      shelves: allShelves
          .map((s) => ExportShelf(
                id: s.id,
                name: s.name,
                color: s.color,
                sortOrder: s.sortOrder,
                parentId: s.parentId,
                updatedAt: s.updatedAt,
              ))
          .toList(),
      bookShelves: bookShelfRows
          .map((r) => ExportBookShelf(bookId: r.bookId, shelfId: r.shelfId))
          .toList(),
      readingProgress: progressRows
          .map((r) => ExportReadingProgress(
                bookId: r.bookId,
                status: r.status,
                currentPage: r.currentPage,
                totalPages: r.totalPages,
                usePercentage: r.usePercentage,
                progressPercent: r.progressPercent,
                readingStartedAt: r.readingStartedAt,
                readingFinishedAt: r.readingFinishedAt,
              ))
          .toList(),
      readingSessions: sessionRows
          .map((s) => ExportReadingSession(
                id: s.id,
                bookId: s.bookId,
                startedAt: s.startedAt,
                endedAt: s.endedAt,
                startPage: s.startPage,
                endPage: s.endPage,
                durationSeconds: s.durationSeconds,
                finishedBook: s.finishedBook,
              ))
          .toList(),
      readingGoals: goalRows
          .map((g) => ExportReadingGoals(
                id: g.id,
                booksPerMonth: g.booksPerMonth,
                booksPerYear: g.booksPerYear,
              ))
          .toList(),
    );
  }

  /// ----------------------------
  /// EXPORT ZIP (library.json + covers/)
  /// ----------------------------
  Future<File> exportToZipFile() async {
    final allBooks = await db.getAllBooks();
    final payload = await buildExportLibraryPayload();

    final tmp = await getTemporaryDirectory();
    final zipPath = p.join(tmp.path, 'bd_library_export.zip');

    final encoder = ZipFileEncoder();
    encoder.create(zipPath);

    // JSON
    final jsonBytes = utf8.encode(jsonEncode(payload.toJson()));
    encoder.addArchiveFile(ArchiveFile('library.json', jsonBytes.length, jsonBytes));

    await addLocalCoverImagesToZip(encoder, allBooks);

    encoder.close();
    return File(zipPath);
  }

  Future<void> shareExportZip() async {
    final file = await exportToZipFile();
    await Share.shareXFiles([XFile(file.path)], text: 'Export bibliothèque BD (ZIP)');
  }

  /// ----------------------------
  /// EXPORT JSON (contenu BDD seul, sans couvertures)
  /// ----------------------------
  Future<File> exportToJsonFile() async {
    final payload = await buildExportLibraryPayload();

    final tmp = await getTemporaryDirectory();
    final jsonPath = p.join(tmp.path, 'bd_library_export.json');
    final jsonBytes = utf8.encode(const JsonEncoder.withIndent('  ').convert(payload.toJson()));
    final file = File(jsonPath);
    await file.writeAsBytes(jsonBytes);
    return file;
  }

  Future<void> shareExportJson() async {
    final file = await exportToJsonFile();
    await Share.shareXFiles([XFile(file.path)], text: 'Export bibliothèque BD (JSON)');
  }

  /// ----------------------------
  /// PICK ZIP
  /// ----------------------------
  Future<File?> pickZipFile() async {
    final file = await openFile(acceptedTypeGroups: [XTypeGroup(label: 'zip', extensions: ['zip'])]);
    if (file == null) return null;
    return File(file.path);
  }

  /// Charge une bibliothèque depuis un fichier JSON ou ZIP (sans l'importer en BDD).
  Future<ExportLibrary?> readLibraryFromFile(File file) async {
    final path = file.path.toLowerCase();
    if (path.endsWith('.zip')) {
      return _readLibraryJsonFromZip(file);
    }
    return _readLibraryJsonFromFile(file);
  }

  /// Choisir un fichier bibliothèque (JSON ou ZIP).
  Future<File?> pickLibraryFile() async {
    final file = await openFile(acceptedTypeGroups: [XTypeGroup(label: 'bibliothèque', extensions: ['json', 'zip'])]);
    if (file == null) return null;
    return File(file.path);
  }

  /// ----------------------------
  /// PICK JSON
  /// ----------------------------
  Future<File?> pickJsonFile() async {
    final file = await openFile(acceptedTypeGroups: [XTypeGroup(label: 'json', extensions: ['json'])]);
    if (file == null) return null;
    return File(file.path);
  }

  /// ----------------------------
  /// BUILD PLAN (matching + conflits)
  /// ----------------------------
  Future<ImportPlan> buildImportPlanFromZip(File zipFile) async {
    final lib = await _readLibraryJsonFromZip(zipFile);
    return _buildImportPlanFromLibrary(lib);
  }

  Future<ImportPlan> buildImportPlanFromJson(File jsonFile) async {
    final lib = await _readLibraryJsonFromFile(jsonFile);
    return _buildImportPlanFromLibrary(lib);
  }

  Future<ImportPlan> _buildImportPlanFromLibrary(ExportLibrary lib) async {
    // 1) Upsert series (on pourrait détecter conflit de renommage, etc.)
    final seriesToUpsert = lib.series;

    // 2) Charger état local (books + series pour matching)
    final localBooks = await db.getAllBooks();
    final localSeries = await db.getAllSeries();
    final seriesNameById = {for (final s in localSeries) s.id: s.name};

    // helpers
    String norm(String s) => s
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .trim();

    String? localSeriesName(String? seriesId) =>
        (seriesId == null) ? null : seriesNameById[seriesId];

    // index ISBN -> local books
    final Map<String, List<Book>> byIsbn = {};
    for (final b in localBooks) {
      final isbn = b.isbn;
      if (isbn == null || isbn.trim().isEmpty) continue;
      byIsbn.putIfAbsent(isbn.trim(), () => []).add(b);
    }

    // index fallback key -> local book (first)
    final Map<String, Book> byKey = {};
    for (final b in localBooks) {
      final k = _fallbackKey(
        title: b.title,
        seriesName: localSeriesName(b.seriesId),
        volumeNumber: b.volumeNumber,
        norm: norm,
      );
      byKey.putIfAbsent(k, () => b);
    }

    final booksToCreate = <ExportBook>[];
    final booksToUpdateNoConflict = <MapEntry<String, ExportBook>>[];
    final conflicts = <WorkConflict>[];
    final importedWorkIdToLocalWorkId = <String, String>{};

    // 3) Match works
    for (final ib in lib.books) {
      final isbn = (ib.isbn ?? '').trim();
      Book? matched;

      if (isbn.isNotEmpty && byIsbn.containsKey(isbn)) {
        // si plusieurs, on choisit le plus récent
        final candidates = byIsbn[isbn]!;
        candidates.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        matched = candidates.first;
      } else {
        final k = _fallbackKey(
          title: ib.title,
          seriesName: null, // import seriesName peut être résolu plus tard ; ici on reste stable
          volumeNumber: ib.volumeNumber,
          norm: norm,
        );
        matched = byKey[k];
      }

      if (matched == null) {
        booksToCreate.add(ib);
        // local id sera celui importé (tu peux aussi remapper vers un nouvel id côté apply)
        importedWorkIdToLocalWorkId[ib.id] = ib.id;
        continue;
      }

      importedWorkIdToLocalWorkId[ib.id] = matched.id;

      // Détection conflit sur métadonnées (pas de rating/review ici)
      final hasConflict = _workHasConflict(matched, ib);

      if (!hasConflict) {
        booksToUpdateNoConflict.add(MapEntry(matched.id, ib));
      } else {
        conflicts.add(WorkConflict(localBookId: matched.id, imported: ib));
      }
    }

    // 4) Copies (remap bookId later)
    final copiesToUpsert = lib.copies;

    return ImportPlan(
      seriesToUpsert: seriesToUpsert,
      booksToCreate: booksToCreate,
      booksToUpdateNoConflict: booksToUpdateNoConflict,
      conflicts: conflicts,
      copiesToUpsert: copiesToUpsert,
      importedWorkIdToLocalWorkId: importedWorkIdToLocalWorkId,
      shelvesToUpsert: lib.shelves,
      bookShelfLinks: lib.bookShelves,
      readingProgressToUpsert: lib.readingProgress,
      readingSessionsToUpsert: lib.readingSessions,
      readingGoalsToUpsert: lib.readingGoals,
    );
  }

  /// ----------------------------
  /// APPLY PLAN (DB + covers)
  /// ----------------------------
  Future<void> applyImportPlanFromZip({
    required File zipFile,
    required ImportPlan plan,
  }) async {
    await db.ensureDefaultUnclassifiedShelfExists();

    // 1) upsert series (dernière modif gagne)
    for (final s in plan.seriesToUpsert) {
      final existing = await db.getSeriesById(s.id);
      if (existing == null || s.updatedAt.isAfter(existing.updatedAt)) {
        await db.upsertSeries(SeriesCompanion.insert(
          id: s.id,
          name: s.name,
          expectedVolumes: Value(s.expectedVolumes),
          tags: Value(s.tags),
          updatedAt: s.updatedAt,
        ));
      }
    }

    await _applyImportShelves(plan);

    // 2) create works (books)
    for (final b in plan.booksToCreate) {
      await db.upsertBook(BooksCompanion.insert(
        id: b.id,
        isbn: Value(b.isbn),
        title: b.title,
        seriesId: Value(b.seriesId),
        volumeNumber: Value(b.volumeNumber),
        authors: Value(b.authors),
        publisher: Value(b.publisher),
        publishedDate: Value(b.publishedDate),
        coverUrl: Value(b.coverUrl),
        coverLocalPath: Value(null),
        tags: Value(b.tags),
        summary: Value(b.summary),
        pageCount: Value(b.pageCount),
        retailPrice: Value(b.retailPrice),
        registeredAt: Value(b.registeredAt),
        updatedAt: b.updatedAt,
      ));
    }

    // 3) update no-conflict (import wins if newer)
    for (final entry in plan.booksToUpdateNoConflict) {
      final localId = entry.key;
      final imp = entry.value;
      final local = await db.getBookById(localId);
      if (local == null) continue;

      if (imp.updatedAt.isAfter(local.updatedAt)) {
        await db.upsertBook(BooksCompanion(
          id: Value(localId),
          isbn: Value(imp.isbn),
          title: Value(imp.title),
          seriesId: Value(imp.seriesId),
          volumeNumber: Value(imp.volumeNumber),
          authors: Value(imp.authors),
          publisher: Value(imp.publisher),
          publishedDate: Value(imp.publishedDate),
          coverUrl: Value(imp.coverUrl),
          tags: Value(imp.tags),
          summary: Value(imp.summary),
          pageCount: Value(imp.pageCount),
          retailPrice: Value(imp.retailPrice),
          registeredAt: Value(imp.registeredAt),
          updatedAt: Value(imp.updatedAt),
        ));
      }
    }

    // 4) conflicts (respect choice)
    for (final c in plan.conflicts) {
      final localId = c.localBookId;
      final local = await db.getBookById(localId);
      if (local == null) continue;

      switch (c.choice) {
        case ConflictChoice.keepLocal:
          break;

        case ConflictChoice.keepImported:
          await db.upsertBook(BooksCompanion(
            id: Value(localId),
            isbn: Value(c.imported.isbn),
            title: Value(c.imported.title),
            seriesId: Value(c.imported.seriesId),
            volumeNumber: Value(c.imported.volumeNumber),
            authors: Value(c.imported.authors),
            publisher: Value(c.imported.publisher),
            publishedDate: Value(c.imported.publishedDate),
            coverUrl: Value(c.imported.coverUrl),
            tags: Value(c.imported.tags),
            summary: Value(c.imported.summary),
            pageCount: Value(c.imported.pageCount),
            retailPrice: Value(c.imported.retailPrice),
            registeredAt: Value(c.imported.registeredAt),
            updatedAt: Value(c.imported.updatedAt),
          ));
          break;

        case ConflictChoice.merge:
          final merged = _mergeWork(local, c.imported);
          await db.upsertBook(BooksCompanion(
            id: Value(localId),
            isbn: Value(merged.isbn),
            title: Value(merged.title),
            seriesId: Value(merged.seriesId),
            volumeNumber: Value(merged.volumeNumber),
            authors: Value(merged.authors),
            publisher: Value(merged.publisher),
            publishedDate: Value(merged.publishedDate),
            coverUrl: Value(merged.coverUrl),
            tags: Value(merged.tags),
            summary: Value(merged.summary),
            pageCount: Value(merged.pageCount),
            retailPrice: Value(merged.retailPrice),
            registeredAt: Value(merged.registeredAt),
            updatedAt: Value(DateTime.now()),
          ));
          break;
      }
    }

    // 5) extract covers from zip -> /documents/covers (ZIP uniquement)
    await _extractCoversToAppDir(zipFile);

    // 6) relier coverLocalPath (par convention: <bookId>.<ext>) (ZIP uniquement)
    await _linkCoversToBooks();

    await _applyImportPlanCopies(plan);
    await _applyImportBookShelves(plan);
    await _applyImportReading(plan);
    await db.assignDefaultShelfToBooksWithoutShelves();
    await ReadingBadgeEvaluator(db).syncMilestoneBadgesFromProgress();
  }

  /// Applique un plan d'import sans fichier ZIP (JSON seul : pas d'extraction de couvertures).
  /// Complète la base existante (séries, livres, exemplaires).
  Future<void> applyImportPlanFromJson(ImportPlan plan) async {
    await db.ensureDefaultUnclassifiedShelfExists();

    // 1) upsert series (dernière modif gagne)
    for (final s in plan.seriesToUpsert) {
      final existing = await db.getSeriesById(s.id);
      if (existing == null || s.updatedAt.isAfter(existing.updatedAt)) {
        await db.upsertSeries(SeriesCompanion.insert(
          id: s.id,
          name: s.name,
          expectedVolumes: Value(s.expectedVolumes),
          tags: Value(s.tags),
          updatedAt: s.updatedAt,
        ));
      }
    }

    await _applyImportShelves(plan);

    // 2) create works (books)
    for (final b in plan.booksToCreate) {
      await db.upsertBook(BooksCompanion.insert(
        id: b.id,
        isbn: Value(b.isbn),
        title: b.title,
        seriesId: Value(b.seriesId),
        volumeNumber: Value(b.volumeNumber),
        authors: Value(b.authors),
        publisher: Value(b.publisher),
        publishedDate: Value(b.publishedDate),
        coverUrl: Value(b.coverUrl),
        coverLocalPath: Value(null),
        tags: Value(b.tags),
        summary: Value(b.summary),
        pageCount: Value(b.pageCount),
        retailPrice: Value(b.retailPrice),
        registeredAt: Value(b.registeredAt),
        updatedAt: b.updatedAt,
      ));
    }

    // 3) update no-conflict (import wins if newer)
    for (final entry in plan.booksToUpdateNoConflict) {
      final localId = entry.key;
      final imp = entry.value;
      final local = await db.getBookById(localId);
      if (local == null) continue;

      if (imp.updatedAt.isAfter(local.updatedAt)) {
        await db.upsertBook(BooksCompanion(
          id: Value(localId),
          isbn: Value(imp.isbn),
          title: Value(imp.title),
          seriesId: Value(imp.seriesId),
          volumeNumber: Value(imp.volumeNumber),
          authors: Value(imp.authors),
          publisher: Value(imp.publisher),
          publishedDate: Value(imp.publishedDate),
          coverUrl: Value(imp.coverUrl),
          tags: Value(imp.tags),
          summary: Value(imp.summary),
          pageCount: Value(imp.pageCount),
          retailPrice: Value(imp.retailPrice),
          registeredAt: Value(imp.registeredAt),
          updatedAt: Value(imp.updatedAt),
        ));
      }
    }

    // 4) conflicts (respect choice)
    for (final c in plan.conflicts) {
      final localId = c.localBookId;
      final local = await db.getBookById(localId);
      if (local == null) continue;

      switch (c.choice) {
        case ConflictChoice.keepLocal:
          break;
        case ConflictChoice.keepImported:
          await db.upsertBook(BooksCompanion(
            id: Value(localId),
            isbn: Value(c.imported.isbn),
            title: Value(c.imported.title),
            seriesId: Value(c.imported.seriesId),
            volumeNumber: Value(c.imported.volumeNumber),
            authors: Value(c.imported.authors),
            publisher: Value(c.imported.publisher),
            publishedDate: Value(c.imported.publishedDate),
            coverUrl: Value(c.imported.coverUrl),
            tags: Value(c.imported.tags),
            summary: Value(c.imported.summary),
            pageCount: Value(c.imported.pageCount),
            retailPrice: Value(c.imported.retailPrice),
            registeredAt: Value(c.imported.registeredAt),
            updatedAt: Value(c.imported.updatedAt),
          ));
          break;
        case ConflictChoice.merge:
          final merged = _mergeWork(local, c.imported);
          await db.upsertBook(BooksCompanion(
            id: Value(localId),
            isbn: Value(merged.isbn),
            title: Value(merged.title),
            seriesId: Value(merged.seriesId),
            volumeNumber: Value(merged.volumeNumber),
            authors: Value(merged.authors),
            publisher: Value(merged.publisher),
            publishedDate: Value(merged.publishedDate),
            coverUrl: Value(merged.coverUrl),
            tags: Value(merged.tags),
            summary: Value(merged.summary),
            pageCount: Value(merged.pageCount),
            retailPrice: Value(merged.retailPrice),
            registeredAt: Value(merged.registeredAt),
            updatedAt: Value(DateTime.now()),
          ));
          break;
      }
    }

    // 5) upsert copies (rating/review au niveau exemplaire)
    await _applyImportPlanCopies(plan);
    await _applyImportBookShelves(plan);
    await _applyImportReading(plan);
    await db.assignDefaultShelfToBooksWithoutShelves();
    await ReadingBadgeEvaluator(db).syncMilestoneBadgesFromProgress();
  }

  Future<void> _applyImportShelves(ImportPlan plan) async {
    for (final s in plan.shelvesToUpsert) {
      final existing = await db.getShelfById(s.id);
      if (existing == null || s.updatedAt.isAfter(existing.updatedAt)) {
        await db.upsertShelf(ShelvesCompanion.insert(
          id: s.id,
          name: s.name,
          color: Value(s.color),
          sortOrder: Value(s.sortOrder),
          parentId: Value(s.parentId),
          updatedAt: s.updatedAt,
        ));
      }
    }
  }

  Future<void> _applyImportBookShelves(ImportPlan plan) async {
    final byBook = <String, Set<String>>{};
    for (final link in plan.bookShelfLinks) {
      final localBookId =
          plan.importedWorkIdToLocalWorkId[link.bookId] ?? link.bookId;
      if (await db.getBookById(localBookId) == null) continue;
      if (await db.getShelfById(link.shelfId) == null) continue;
      byBook.putIfAbsent(localBookId, () => <String>{});
      byBook[localBookId]!.add(link.shelfId);
    }
    for (final entry in byBook.entries) {
      await db.setBookShelves(entry.key, entry.value.toList());
    }
  }

  Future<void> _applyImportReading(ImportPlan plan) async {
    for (final r in plan.readingProgressToUpsert) {
      final bookId =
          plan.importedWorkIdToLocalWorkId[r.bookId] ?? r.bookId;
      if (await db.getBookById(bookId) == null) continue;
      await db.upsertReadingProgress(ReadingProgressCompanion.insert(
        bookId: bookId,
        status: Value(r.status),
        currentPage: Value(r.currentPage),
        totalPages: Value(r.totalPages),
        usePercentage: Value(r.usePercentage),
        progressPercent: Value(r.progressPercent),
        readingStartedAt: Value(r.readingStartedAt),
        readingFinishedAt: Value(r.readingFinishedAt),
      ));
    }

    for (final s in plan.readingSessionsToUpsert) {
      final bookId =
          plan.importedWorkIdToLocalWorkId[s.bookId] ?? s.bookId;
      if (await db.getBookById(bookId) == null) continue;
      await db.into(db.readingSessions).insertOnConflictUpdate(
            ReadingSessionsCompanion.insert(
              id: s.id,
              bookId: bookId,
              startedAt: s.startedAt,
              endedAt: Value(s.endedAt),
              startPage: Value(s.startPage),
              endPage: Value(s.endPage),
              durationSeconds: Value(s.durationSeconds),
              finishedBook: Value(s.finishedBook),
            ),
          );
    }

    for (final g in plan.readingGoalsToUpsert) {
      await db.upsertReadingGoals(ReadingGoalsCompanion.insert(
        id: g.id,
        booksPerMonth: Value(g.booksPerMonth),
        booksPerYear: Value(g.booksPerYear),
      ));
    }
  }

  Future<void> _applyImportPlanCopies(ImportPlan plan) async {
    for (final cp in plan.copiesToUpsert) {
      final mappedBookId = plan.importedWorkIdToLocalWorkId[cp.bookId] ?? cp.bookId;

      await db.upsertCopy(CopiesCompanion.insert(
        id: cp.id,
        bookId: mappedBookId,
        rating: Value(cp.rating.clamp(0, 5)),
        review: Value(cp.review),
        condition: Value(cp.condition.clamp(1, 5)),
        location: Value(cp.location),
        notes: Value(cp.notes),
        updatedAt: cp.updatedAt,
      ));
    }
  }

  Future<ExportLibrary> _readLibraryJsonFromFile(File jsonFile) async {
    final jsonText = await jsonFile.readAsString();
    final map = jsonDecode(jsonText) as Map<String, dynamic>;
    return ExportLibrary.fromJson(map);
  }

  /// ----------------------------
  /// Helpers
  /// ----------------------------

  Future<ExportLibrary> _readLibraryJsonFromZip(File zipFile) async {
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final jsonEntry = archive.files.firstWhere(
      (f) => f.name == 'library.json',
      orElse: () => throw StateError('library.json introuvable dans le ZIP'),
    );

    final jsonText = utf8.decode(jsonEntry.content as List<int>);
    final map = jsonDecode(jsonText) as Map<String, dynamic>;
    return ExportLibrary.fromJson(map);
  }

  Future<void> _extractCoversToAppDir(File zipFile) async {
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final doc = await getApplicationDocumentsDirectory();
    final coversDir = Directory(p.join(doc.path, 'covers'));
    if (!await coversDir.exists()) await coversDir.create(recursive: true);

    for (final f in archive.files) {
      if (!f.isFile) continue;
      if (!f.name.startsWith('covers/')) continue;

      final filename = p.basename(f.name);
      final out = File(p.join(coversDir.path, filename));
      await out.writeAsBytes(f.content as List<int>, flush: true);
    }
  }

  Future<void> _linkCoversToBooks() async {
    final doc = await getApplicationDocumentsDirectory();
    final coversDir = Directory(p.join(doc.path, 'covers'));
    if (!await coversDir.exists()) return;

    final files = coversDir.listSync().whereType<File>().toList();

    final allBooks = await db.getAllBooks();
    for (final b in allBooks) {
      // Cherche exactement <bookId>.jpg/.png/.webp — pas _back.jpg ni d'autres variantes.
      final match = files.firstWhere(
        (f) => p.basenameWithoutExtension(f.path) == b.id,
        orElse: () => File(''),
      );
      if (match.path.isEmpty) continue;
      await db.updateBookCoverLocalPath(b.id, match.path);
    }
  }

  String _fallbackKey({
    required String title,
    required String? seriesName,
    required int? volumeNumber,
    required String Function(String) norm,
  }) {
    final t = norm(title);
    final s = seriesName == null ? '' : norm(seriesName);
    final v = volumeNumber?.toString() ?? '';
    return '$s|$v|$t';
  }

  bool _workHasConflict(Book local, ExportBook imp) {
    // champs principaux
    if ((local.isbn ?? '') != (imp.isbn ?? '')) return true;
    if (local.title != imp.title) return true;
    if ((local.authors) != imp.authors) return true;
    if ((local.publisher ?? '') != (imp.publisher ?? '')) return true;
    if ((local.publishedDate ?? '') != (imp.publishedDate ?? '')) return true;
    if ((local.seriesId ?? '') != (imp.seriesId ?? '')) return true;
    if ((local.volumeNumber ?? -1) != (imp.volumeNumber ?? -1)) return true;
    if ((local.coverUrl ?? '') != (imp.coverUrl ?? '')) return true;
    if ((local.tags) != imp.tags) return true;
    if (local.summary != imp.summary) return true;
    return false;
  }

  /// Merge: non-vide gagne, tags union (CSV), coverUrl local si présent sinon import.
  ExportBook _mergeWork(Book local, ExportBook imp) {
    String pick(String a, String b) => a.trim().isNotEmpty ? a : b;
    String? pickN(String? a, String? b) {
      final aa = (a ?? '').trim();
      return aa.isNotEmpty ? aa : (b?.trim().isNotEmpty == true ? b!.trim() : null);
    }

    List<String> mergeTags(String localTags, String impTags) {
      final set = <String>{};
      for (final t in localTags.split(',')) {
        final x = t.trim();
        if (x.isNotEmpty) set.add(x);
      }
      for (final t in impTags.split(',')) {
        final x = t.trim();
        if (x.isNotEmpty) set.add(x);
      }
      final list = set.toList()..sort();
      return list;
    }

    final mergedTags = mergeTags(local.tags, imp.tags).join(', ');

    return ExportBook(
      id: local.id,
      isbn: pickN(local.isbn, imp.isbn),
      title: pick(local.title, imp.title),
      seriesId: pickN(local.seriesId, imp.seriesId),
      volumeNumber: local.volumeNumber ?? imp.volumeNumber,
      authors: pick(local.authors, imp.authors),
      publisher: pickN(local.publisher, imp.publisher),
      publishedDate: pickN(local.publishedDate, imp.publishedDate),
      coverUrl: pickN(local.coverUrl, imp.coverUrl),
      tags: mergedTags,
      summary: pick(local.summary, imp.summary),
      pageCount: local.pageCount ?? imp.pageCount,
      retailPrice: local.retailPrice ?? imp.retailPrice,
      registeredAt: local.registeredAt ?? imp.registeredAt,
      updatedAt: DateTime.now(),
    );
  }
}
