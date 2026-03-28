class ExportLibrary {
  final int version;
  final DateTime exportedAt;
  final List<ExportSeries> series;
  final List<ExportBook> books;   // works
  final List<ExportCopy> copies;  // exemplaires

  ExportLibrary({
    required this.version,
    required this.exportedAt,
    required this.series,
    required this.books,
    required this.copies,
  });

  Map<String, dynamic> toJson() => {
        'version': version,
        'exportedAt': exportedAt.toIso8601String(),
        'series': series.map((s) => s.toJson()).toList(),
        'books': books.map((b) => b.toJson()).toList(),
        'copies': copies.map((c) => c.toJson()).toList(),
      };

  static ExportLibrary fromJson(Map<String, dynamic> json) {
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
  final String tags; // CSV

  /// Résumé / synopsis de l'œuvre.
  final String summary;

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
