import '../../../db/app_db.dart';

class ReadingRepository {
  final AppDb _db;

  ReadingRepository(this._db);

  Future<ReadingProgressRow?> progressForBook(String bookId) =>
      _db.readingProgressForBook(bookId);

  Future<ReadingProgressRow> getOrCreateProgress(String bookId) =>
      _db.getOrCreateReadingProgress(bookId);

  Future<void> upsertProgress(ReadingProgressCompanion c) =>
      _db.upsertReadingProgress(c);

  Stream<List<ReadingProgressRow>> watchAllProgress() =>
      _db.watchReadingProgress();

  Future<Book?> bookById(String id) => _db.getBookById(id);

  Future<List<Book>> searchBooks(String q) => _db.searchBooks(q);

  Future<List<Book>> findByIsbn(String isbn) => _db.findWorksByIsbn(isbn);

  Future<ReadingSession?> activeSession() => _db.getActiveReadingSession();

  Future<void> insertSession(ReadingSessionsCompanion c) =>
      _db.insertReadingSession(c);

  Future<void> updateSession(String id, ReadingSessionsCompanion c) =>
      _db.updateReadingSession(id, c);

  Future<List<ReadingSession>> completedSessions({int limit = 500}) =>
      _db.completedReadingSessions(limit: limit);

  Future<List<(ReadingSession, Book?)>> completedSessionsWithBooks({
    int limit = 200,
  }) async {
    final sessions = await _db.completedReadingSessions(limit: limit);
    final bookById = <String, Book?>{};
    for (final s in sessions) {
      bookById[s.bookId] ??= await _db.getBookById(s.bookId);
    }
    return sessions.map((s) => (s, bookById[s.bookId])).toList();
  }

  Future<int> totalReadingSeconds() => _db.totalCompletedReadingSeconds();

  Future<ReadingGoalsRow> goals() => _db.getOrCreateReadingGoals();

  Future<void> upsertGoals(ReadingGoalsCompanion g) =>
      _db.upsertReadingGoals(g);

  Future<int> finishedBooksInMonth(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    return _db.countFinishedBooksBetween(start, end);
  }

  Future<int> finishedBooksInYear(int year) {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year, 12, 31, 23, 59, 59);
    return _db.countFinishedBooksBetween(start, end);
  }

  /// Tags (genres) les plus représentés par le temps de lecture (secondes).
  Future<List<(String tag, int seconds)>> genresByReadingTime() async {
    final sessions = await _db.completedReadingSessions(limit: 2000);
    final map = <String, int>{};
    for (final s in sessions) {
      final book = await _db.getBookById(s.bookId);
      if (book == null) continue;
      final dur = s.durationSeconds ?? 0;
      if (dur <= 0) continue;
      final parts = book.tags
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty);
      for (final tag in parts) {
        map[tag] = (map[tag] ?? 0) + dur;
      }
    }
    final list = map.entries.map((e) => (e.key, e.value)).toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));
    return list;
  }

  Future<List<(Book, ReadingProgressRow)>> booksWithProgressForStatus(
    int status,
  ) async {
    final books = await _db.getAllBooks();
    final out = <(Book, ReadingProgressRow)>[];
    for (final b in books) {
      final p = await _db.getOrCreateReadingProgress(b.id);
      if (p.status == status) {
        out.add((b, p));
      }
    }
    out.sort((a, b) => a.$1.title.compareTo(b.$1.title));
    return out;
  }

  Future<List<(Book, ReadingProgressRow)>> allBooksWithProgress() async {
    final books = await _db.getAllBooks();
    final out = <(Book, ReadingProgressRow)>[];
    for (final b in books) {
      final p = await _db.getOrCreateReadingProgress(b.id);
      out.add((b, p));
    }
    out.sort((a, b) => a.$1.title.compareTo(b.$1.title));
    return out;
  }

  Future<Book?> lastFinishedBook()=>_db.getLastFinishedBook();
  Future<List<(Book,ReadingProgressRow)>> booksInProgress()=>_db.getBooksInProgress();

  /// Livres « en cours » avec la date de la dernière séance terminée (si connue).
  Future<List<(Book, ReadingProgressRow, DateTime?)>>
      booksInProgressForResume() async {
    final items = await _db.getBooksInProgress();
    if (items.isEmpty) return [];
    final ids = items.map((e) => e.$1.id).toList();
    final lastById = await _db.lastCompletedSessionEndByBookIds(ids);
    final list = items
        .map(
          (e) => (e.$1, e.$2, lastById[e.$1.id]),
        )
        .toList();
    list.sort((a, b) {
      final la = a.$3;
      final lb = b.$3;
      if (la != null && lb != null) return lb.compareTo(la);
      if (la != null) return -1;
      if (lb != null) return 1;
      return a.$1.title.compareTo(b.$1.title);
    });
    return list;
  }

  Future<List<(SeriesData,List<int>)>> seriesWithMissingVolumes()=>_db.getSeriesWithMissingVolumes();
}
