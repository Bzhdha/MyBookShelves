import 'package:flutter_test/flutter_test.dart';
import 'package:bd_library_app/models/export_model.dart';

void main() {
  final now = DateTime.utc(2024, 6, 15, 10, 0, 0);

  group('ExportSeries', () {
    test('toJson / fromJson round-trip', () {
      final s = ExportSeries(id: 'sid', name: 'Astérix', tags: 'bd,hc', updatedAt: now, expectedVolumes: 40);
      final s2 = ExportSeries.fromJson(s.toJson());
      expect(s2.id, s.id);
      expect(s2.name, s.name);
      expect(s2.tags, s.tags);
      expect(s2.expectedVolumes, s.expectedVolumes);
      expect(s2.updatedAt, s.updatedAt);
    });
    test('optional expectedVolumes can be null', () {
      final s = ExportSeries(id: 'x', name: 'y', tags: '', updatedAt: now);
      expect(ExportSeries.fromJson(s.toJson()).expectedVolumes, isNull);
    });
    test('missing tags defaults to empty string', () {
      final json = {'id': 'x', 'name': 'y', 'updatedAt': now.toIso8601String()};
      expect(ExportSeries.fromJson(json).tags, '');
    });
  });

  group('ExportBook', () {
    test('toJson / fromJson round-trip with all fields', () {
      final b = ExportBook(
        id: 'bid', title: 'Lucky Luke', authors: 'Morris', tags: 'bd',
        updatedAt: now, isbn: '9782756018096', seriesId: 'sid', volumeNumber: 3,
        publisher: 'Dupuis', publishedDate: '2020-01', coverUrl: 'https://example.com/cover.jpg',
        summary: 'Un résumé', pageCount: 48, retailPrice: 12.50, registeredAt: now,
      );
      final b2 = ExportBook.fromJson(b.toJson());
      expect(b2.id, b.id);
      expect(b2.title, b.title);
      expect(b2.authors, b.authors);
      expect(b2.isbn, b.isbn);
      expect(b2.seriesId, b.seriesId);
      expect(b2.volumeNumber, b.volumeNumber);
      expect(b2.publisher, b.publisher);
      expect(b2.publishedDate, b.publishedDate);
      expect(b2.coverUrl, b.coverUrl);
      expect(b2.tags, b.tags);
      expect(b2.summary, b.summary);
      expect(b2.pageCount, b.pageCount);
      expect(b2.retailPrice, b.retailPrice);
      expect(b2.registeredAt, b.registeredAt);
      expect(b2.updatedAt, b.updatedAt);
    });
    test('nullable fields can be null', () {
      final b = ExportBook(id: 'b', title: 'T', authors: '', tags: '', updatedAt: now);
      final b2 = ExportBook.fromJson(b.toJson());
      expect(b2.isbn, isNull);
      expect(b2.seriesId, isNull);
      expect(b2.volumeNumber, isNull);
      expect(b2.publisher, isNull);
      expect(b2.retailPrice, isNull);
      expect(b2.registeredAt, isNull);
    });
    test('missing authors defaults to empty string', () {
      final json = {'id': 'b', 'title': 'T', 'tags': '', 'updatedAt': now.toIso8601String()};
      expect(ExportBook.fromJson(json).authors, '');
    });
  });

  group('ExportCopy', () {
    test('toJson / fromJson round-trip', () {
      final c = ExportCopy(id: 'cid', bookId: 'bid', rating: 4, review: 'super', condition: 2, notes: 'note', updatedAt: now, location: 'salon');
      final c2 = ExportCopy.fromJson(c.toJson());
      expect(c2.id, c.id);
      expect(c2.bookId, c.bookId);
      expect(c2.rating, c.rating);
      expect(c2.review, c.review);
      expect(c2.condition, c.condition);
      expect(c2.notes, c.notes);
      expect(c2.location, c.location);
      expect(c2.updatedAt, c.updatedAt);
    });
    test('missing rating defaults to 0', () {
      final json = {'id': 'c', 'bookId': 'b', 'review': '', 'condition': 3, 'notes': '', 'updatedAt': now.toIso8601String()};
      expect(ExportCopy.fromJson(json).rating, 0);
    });
    test('missing condition defaults to 3', () {
      final json = {'id': 'c', 'bookId': 'b', 'rating': 0, 'review': '', 'notes': '', 'updatedAt': now.toIso8601String()};
      expect(ExportCopy.fromJson(json).condition, 3);
    });
  });

  group('ExportShelf', () {
    test('toJson / fromJson round-trip', () {
      final s = ExportShelf(id: 'sh1', name: 'Cuisine', color: '#FF0000', sortOrder: 2, updatedAt: now, parentId: 'p1');
      final s2 = ExportShelf.fromJson(s.toJson());
      expect(s2.id, s.id);
      expect(s2.name, s.name);
      expect(s2.color, s.color);
      expect(s2.sortOrder, s.sortOrder);
      expect(s2.parentId, s.parentId);
      expect(s2.updatedAt, s.updatedAt);
    });
    test('missing color defaults to #6200EE', () {
      final json = {'id': 's', 'name': 'n', 'sortOrder': 0, 'updatedAt': now.toIso8601String()};
      expect(ExportShelf.fromJson(json).color, '#6200EE');
    });
    test('missing sortOrder defaults to 0', () {
      final json = {'id': 's', 'name': 'n', 'color': '#000', 'updatedAt': now.toIso8601String()};
      expect(ExportShelf.fromJson(json).sortOrder, 0);
    });
  });

  group('ExportBookShelf', () {
    test('toJson / fromJson round-trip', () {
      final bs = ExportBookShelf(bookId: 'bid', shelfId: 'sid');
      final bs2 = ExportBookShelf.fromJson(bs.toJson());
      expect(bs2.bookId, bs.bookId);
      expect(bs2.shelfId, bs.shelfId);
    });
  });

  group('ExportReadingProgress', () {
    test('round-trip with all fields', () {
      final r = ExportReadingProgress(bookId: 'bid', status: 2, currentPage: 30, usePercentage: false, totalPages: 48, progressPercent: 62, readingStartedAt: now, readingFinishedAt: now);
      final r2 = ExportReadingProgress.fromJson(r.toJson());
      expect(r2.bookId, r.bookId);
      expect(r2.status, r.status);
      expect(r2.currentPage, r.currentPage);
      expect(r2.usePercentage, r.usePercentage);
      expect(r2.totalPages, r.totalPages);
      expect(r2.progressPercent, r.progressPercent);
      expect(r2.readingStartedAt, r.readingStartedAt);
      expect(r2.readingFinishedAt, r.readingFinishedAt);
    });
    test('nullable dates can be null', () {
      final r = ExportReadingProgress(bookId: 'b', status: 0, currentPage: 0, usePercentage: false);
      final r2 = ExportReadingProgress.fromJson(r.toJson());
      expect(r2.readingStartedAt, isNull);
      expect(r2.readingFinishedAt, isNull);
    });
    test('missing status defaults to 0', () {
      final json = {'bookId': 'b', 'currentPage': 0, 'usePercentage': false};
      expect(ExportReadingProgress.fromJson(json).status, 0);
    });
  });

  group('ExportReadingSession', () {
    test('round-trip with all fields', () {
      final s = ExportReadingSession(id: 'sid', bookId: 'bid', startedAt: now, startPage: 5, finishedBook: true, endedAt: now, endPage: 48, durationSeconds: 3600);
      final s2 = ExportReadingSession.fromJson(s.toJson());
      expect(s2.id, s.id);
      expect(s2.bookId, s.bookId);
      expect(s2.startedAt, s.startedAt);
      expect(s2.startPage, s.startPage);
      expect(s2.finishedBook, s.finishedBook);
      expect(s2.endedAt, s.endedAt);
      expect(s2.endPage, s.endPage);
      expect(s2.durationSeconds, s.durationSeconds);
    });
    test('nullable fields can be null', () {
      final s = ExportReadingSession(id: 's', bookId: 'b', startedAt: now, startPage: 0, finishedBook: false);
      final s2 = ExportReadingSession.fromJson(s.toJson());
      expect(s2.endedAt, isNull);
      expect(s2.endPage, isNull);
      expect(s2.durationSeconds, isNull);
    });
  });

  group('ExportReadingGoals', () {
    test('round-trip with all fields', () {
      final g = ExportReadingGoals(id: 'gid', booksPerMonth: 2, booksPerYear: 24);
      final g2 = ExportReadingGoals.fromJson(g.toJson());
      expect(g2.id, g.id);
      expect(g2.booksPerMonth, g.booksPerMonth);
      expect(g2.booksPerYear, g.booksPerYear);
    });
    test('nullable goals can be null', () {
      final g = ExportReadingGoals(id: 'g');
      final g2 = ExportReadingGoals.fromJson(g.toJson());
      expect(g2.booksPerMonth, isNull);
      expect(g2.booksPerYear, isNull);
    });
  });

  group('ExportLibrary', () {
    test('round-trip with minimal data', () {
      final lib = ExportLibrary(version: 3, exportedAt: now, series: [], books: [], copies: []);
      final lib2 = ExportLibrary.fromJson(lib.toJson());
      expect(lib2.version, lib.version);
      expect(lib2.exportedAt, lib.exportedAt);
      expect(lib2.series, isEmpty);
      expect(lib2.books, isEmpty);
      expect(lib2.copies, isEmpty);
      expect(lib2.shelves, isEmpty);
      expect(lib2.bookShelves, isEmpty);
      expect(lib2.readingProgress, isEmpty);
      expect(lib2.readingSessions, isEmpty);
      expect(lib2.readingGoals, isEmpty);
    });
    test('round-trip preserves nested objects', () {
      final lib = ExportLibrary(
        version: 3,
        exportedAt: now,
        series: [ExportSeries(id: 's1', name: 'Tintin', tags: '', updatedAt: now)],
        books: [ExportBook(id: 'b1', title: 'Le Lotus Bleu', authors: 'Hergé', tags: '', updatedAt: now)],
        copies: [ExportCopy(id: 'c1', bookId: 'b1', rating: 5, review: '', condition: 1, notes: '', updatedAt: now)],
        shelves: [ExportShelf(id: 'sh1', name: 'Étagère', color: '#000', sortOrder: 0, updatedAt: now)],
        bookShelves: [ExportBookShelf(bookId: 'b1', shelfId: 'sh1')],
        readingProgress: [ExportReadingProgress(bookId: 'b1', status: 2, currentPage: 48, usePercentage: false)],
        readingGoals: [ExportReadingGoals(id: 'g1', booksPerYear: 12)],
      );
      final lib2 = ExportLibrary.fromJson(lib.toJson());
      expect(lib2.series.length, 1);
      expect(lib2.series.first.name, 'Tintin');
      expect(lib2.books.length, 1);
      expect(lib2.books.first.title, 'Le Lotus Bleu');
      expect(lib2.copies.length, 1);
      expect(lib2.copies.first.rating, 5);
      expect(lib2.shelves.length, 1);
      expect(lib2.bookShelves.length, 1);
      expect(lib2.readingProgress.length, 1);
      expect(lib2.readingGoals.first.booksPerYear, 12);
    });
    test('missing optional lists default to empty', () {
      final json = {
        'version': 3,
        'exportedAt': now.toIso8601String(),
        'series': [],
        'books': [],
        'copies': [],
      };
      final lib = ExportLibrary.fromJson(json);
      expect(lib.shelves, isEmpty);
      expect(lib.readingProgress, isEmpty);
      expect(lib.readingGoals, isEmpty);
    });
  });
}
