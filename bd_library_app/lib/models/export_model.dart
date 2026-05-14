class ExportLibrary {
  final int version;
  final DateTime exportedAt;
  final List<ExportSeries> series;
  final List<ExportBook> books; // works
  final List<ExportCopy> copies; // exemplaires

  /// v3+ : étagères thématiques
  final List<ExportShelf> shelves;

  /// v3+ : associations livre ↔ étagère
  final List<ExportBookShelf> bookShelves;

  /// v3+ : progression de lecture par œuvre
  final List<ExportReadingProgress> readingProgress;

  /// v3+ : sessions de lecture
  final List<ExportReadingSession> readingSessions;

  /// v3+ : objectifs (souvent une seule ligne `default`)
  final List<ExportReadingGoals> readingGoals;

  ExportLibrary({
    required this.version,
    required this.exportedAt,
    required this.series,
    required this.books,
    required this.copies,
    this.shelves = const [],
    this.bookShelves = const [],
    this.readingProgress = const [],
    this.readingSessions = const [],
    this.readingGoals = const [],
  });

  Map<String, dynamic> toJson() => {
        'version': version,
        'exportedAt': exportedAt.toIso8601String(),
        'series': series.map((s) => s.toJson()).toList(),
        'books': books.map((b) => b.toJson()).toList(),
        'copies': copies.map((c) => c.toJson()).toList(),
        'shelves': shelves.map((s) => s.toJson()).toList(),
        'bookShelves': bookShelves.map((l) => l.toJson()).toList(),
        'readingProgress': readingProgress.map((r) => r.toJson()).toList(),
        'readingSessions': readingSessions.map((s) => s.toJson()).toList(),
        'readingGoals': readingGoals.map((g) => g.toJson()).toList(),
      };

  static ExportLibrary fromJson(Map<String, dynamic> json) {
    List<T> mapList<T>(
      String key,
      T Function(Map<String, dynamic>) from,
    ) {
      final raw = json[key];
      if (raw is! List) return [];
      return raw.map((e) => from(e as Map<String, dynamic>)).toList();
    }

    return ExportLibrary(
      version: (json['version'] as num).toInt(),
      exportedAt: DateTime.parse(json['exportedAt'] as String),
      series: (json['series'] as List)
          .map((e) => ExportSeries.fromJson(e as Map<String, dynamic>))
          .toList(),
      books: (json['books'] as List)
          .map((e) => ExportBook.fromJson(e as Map<String, dynamic>))
          .toList(),
      copies: (json['copies'] as List)
          .map((e) => ExportCopy.fromJson(e as Map<String, dynamic>))
          .toList(),
      shelves: mapList('shelves', ExportShelf.fromJson),
      bookShelves: mapList('bookShelves', ExportBookShelf.fromJson),
      readingProgress: mapList('readingProgress', ExportReadingProgress.fromJson),
      readingSessions: mapList('readingSessions', ExportReadingSession.fromJson),
      readingGoals: mapList('readingGoals', ExportReadingGoals.fromJson),
    );
  }
}

class ExportSeries {
  final String id;
  final String name;
  final int? expectedVolumes;
  final String tags; // CSV
  final DateTime updatedAt;

  ExportSeries({
    required this.id,
    required this.name,
    required this.tags,
    required this.updatedAt,
    this.expectedVolumes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'expectedVolumes': expectedVolumes,
        'tags': tags,
        'updatedAt': updatedAt.toIso8601String(),
      };

  static ExportSeries fromJson(Map<String, dynamic> json) => ExportSeries(
        id: json['id'] as String,
        name: json['name'] as String,
        expectedVolumes: json['expectedVolumes'] as int?,
        tags: (json['tags'] as String?) ?? '',
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

/// Work / œuvre
class ExportBook {
  final String id;
  final String? isbn;
  final String title;

  final String? seriesId;
  final int? volumeNumber;

  final String authors;
  final String? publisher;
  final String? publishedDate;

  final String? coverUrl;
  final String tags;
  final String summary;
  final int? pageCount;
  final double? retailPrice;
  final DateTime? registeredAt;
  final DateTime updatedAt;

  ExportBook({
    required this.id,
    required this.title,
    required this.authors,
    required this.tags,
    required this.updatedAt,
    this.isbn,
    this.seriesId,
    this.volumeNumber,
    this.publisher,
    this.publishedDate,
    this.coverUrl,
    this.summary = '',
    this.pageCount,
    this.retailPrice,
    this.registeredAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'isbn': isbn,
        'title': title,
        'seriesId': seriesId,
        'volumeNumber': volumeNumber,
        'authors': authors,
        'publisher': publisher,
        'publishedDate': publishedDate,
        'coverUrl': coverUrl,
        'tags': tags,
        'summary': summary,
        'pageCount': pageCount,
        'retailPrice': retailPrice,
        'registeredAt': registeredAt?.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  static ExportBook fromJson(Map<String, dynamic> json) => ExportBook(
        id: json['id'] as String,
        isbn: json['isbn'] as String?,
        title: json['title'] as String,
        seriesId: json['seriesId'] as String?,
        volumeNumber: json['volumeNumber'] as int?,
        authors: (json['authors'] as String?) ?? '',
        publisher: json['publisher'] as String?,
        publishedDate: json['publishedDate'] as String?,
        coverUrl: json['coverUrl'] as String?,
        tags: (json['tags'] as String?) ?? '',
        summary: (json['summary'] as String?) ?? '',
        pageCount: json['pageCount'] as int?,
        retailPrice: (json['retailPrice'] as num?)?.toDouble(),
        registeredAt: json['registeredAt'] != null ? DateTime.parse(json['registeredAt'] as String) : null,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

/// Exemplaire
class ExportCopy {
  final String id;
  final String bookId; // work id
  final int rating;
  final String review;
  final int condition;
  final String? location;
  final String notes;
  final DateTime updatedAt;

  ExportCopy({
    required this.id,
    required this.bookId,
    required this.rating,
    required this.review,
    required this.condition,
    required this.notes,
    required this.updatedAt,
    this.location,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookId': bookId,
        'rating': rating,
        'review': review,
        'condition': condition,
        'location': location,
        'notes': notes,
        'updatedAt': updatedAt.toIso8601String(),
      };

  static ExportCopy fromJson(Map<String, dynamic> json) => ExportCopy(
        id: json['id'] as String,
        bookId: json['bookId'] as String,
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        review: (json['review'] as String?) ?? '',
        condition: (json['condition'] as num?)?.toInt() ?? 3,
        location: json['location'] as String?,
        notes: (json['notes'] as String?) ?? '',
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

/// Étagère thématique (v3+)
class ExportShelf {
  final String id;
  final String name;
  final String color;
  final int sortOrder;
  final String? parentId;
  final DateTime updatedAt;

  ExportShelf({
    required this.id,
    required this.name,
    required this.color,
    required this.sortOrder,
    required this.updatedAt,
    this.parentId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color,
        'sortOrder': sortOrder,
        'parentId': parentId,
        'updatedAt': updatedAt.toIso8601String(),
      };

  static ExportShelf fromJson(Map<String, dynamic> json) => ExportShelf(
        id: json['id'] as String,
        name: json['name'] as String,
        color: (json['color'] as String?) ?? '#6200EE',
        sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
        parentId: json['parentId'] as String?,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

/// Lien livre (œuvre) ↔ étagère (v3+)
class ExportBookShelf {
  final String bookId;
  final String shelfId;

  ExportBookShelf({required this.bookId, required this.shelfId});

  Map<String, dynamic> toJson() => {
        'bookId': bookId,
        'shelfId': shelfId,
      };

  static ExportBookShelf fromJson(Map<String, dynamic> json) => ExportBookShelf(
        bookId: json['bookId'] as String,
        shelfId: json['shelfId'] as String,
      );
}

class ExportReadingProgress {
  final String bookId;
  final int status;
  final int currentPage;
  final int? totalPages;
  final bool usePercentage;
  final int? progressPercent;
  final DateTime? readingStartedAt;
  final DateTime? readingFinishedAt;

  ExportReadingProgress({
    required this.bookId,
    required this.status,
    required this.currentPage,
    required this.usePercentage,
    this.totalPages,
    this.progressPercent,
    this.readingStartedAt,
    this.readingFinishedAt,
  });

  Map<String, dynamic> toJson() => {
        'bookId': bookId,
        'status': status,
        'currentPage': currentPage,
        'totalPages': totalPages,
        'usePercentage': usePercentage,
        'progressPercent': progressPercent,
        'readingStartedAt': readingStartedAt?.toIso8601String(),
        'readingFinishedAt': readingFinishedAt?.toIso8601String(),
      };

  static ExportReadingProgress fromJson(Map<String, dynamic> json) =>
      ExportReadingProgress(
        bookId: json['bookId'] as String,
        status: (json['status'] as num?)?.toInt() ?? 0,
        currentPage: (json['currentPage'] as num?)?.toInt() ?? 0,
        totalPages: (json['totalPages'] as num?)?.toInt(),
        usePercentage: json['usePercentage'] as bool? ?? false,
        progressPercent: (json['progressPercent'] as num?)?.toInt(),
        readingStartedAt: json['readingStartedAt'] == null
            ? null
            : DateTime.parse(json['readingStartedAt'] as String),
        readingFinishedAt: json['readingFinishedAt'] == null
            ? null
            : DateTime.parse(json['readingFinishedAt'] as String),
      );
}

class ExportReadingSession {
  final String id;
  final String bookId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int startPage;
  final int? endPage;
  final int? durationSeconds;
  final bool finishedBook;

  ExportReadingSession({
    required this.id,
    required this.bookId,
    required this.startedAt,
    required this.startPage,
    required this.finishedBook,
    this.endedAt,
    this.endPage,
    this.durationSeconds,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookId': bookId,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt?.toIso8601String(),
        'startPage': startPage,
        'endPage': endPage,
        'durationSeconds': durationSeconds,
        'finishedBook': finishedBook,
      };

  static ExportReadingSession fromJson(Map<String, dynamic> json) =>
      ExportReadingSession(
        id: json['id'] as String,
        bookId: json['bookId'] as String,
        startedAt: DateTime.parse(json['startedAt'] as String),
        endedAt: json['endedAt'] == null
            ? null
            : DateTime.parse(json['endedAt'] as String),
        startPage: (json['startPage'] as num?)?.toInt() ?? 0,
        endPage: (json['endPage'] as num?)?.toInt(),
        durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
        finishedBook: json['finishedBook'] as bool? ?? false,
      );
}

class ExportReadingGoals {
  final String id;
  final int? booksPerMonth;
  final int? booksPerYear;

  ExportReadingGoals({
    required this.id,
    this.booksPerMonth,
    this.booksPerYear,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'booksPerMonth': booksPerMonth,
        'booksPerYear': booksPerYear,
      };

  static ExportReadingGoals fromJson(Map<String, dynamic> json) =>
      ExportReadingGoals(
        id: json['id'] as String,
        booksPerMonth: (json['booksPerMonth'] as num?)?.toInt(),
        booksPerYear: (json['booksPerYear'] as num?)?.toInt(),
      );
}
