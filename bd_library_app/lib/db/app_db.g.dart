// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// ignore_for_file: type=lint
class $SeriesTable extends Series with TableInfo<$SeriesTable, SeriesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedVolumesMeta = const VerificationMeta(
    'expectedVolumes',
  );
  @override
  late final GeneratedColumn<int> expectedVolumes = GeneratedColumn<int>(
    'expected_volumes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    expectedVolumes,
    tags,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeriesData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('expected_volumes')) {
      context.handle(
        _expectedVolumesMeta,
        expectedVolumes.isAcceptableOrUnknown(
          data['expected_volumes']!,
          _expectedVolumesMeta,
        ),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SeriesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeriesData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      expectedVolumes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_volumes'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SeriesTable createAlias(String alias) {
    return $SeriesTable(attachedDatabase, alias);
  }
}

class SeriesData extends DataClass implements Insertable<SeriesData> {
  final String id;
  final String name;

  /// Mode A: nombre total attendu de tomes (si null => inconnu)
  final int? expectedVolumes;

  /// Tags optionnels (CSV) pour recommandations thématiques (offline)
  final String tags;
  final DateTime updatedAt;
  const SeriesData({
    required this.id,
    required this.name,
    this.expectedVolumes,
    required this.tags,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || expectedVolumes != null) {
      map['expected_volumes'] = Variable<int>(expectedVolumes);
    }
    map['tags'] = Variable<String>(tags);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SeriesCompanion toCompanion(bool nullToAbsent) {
    return SeriesCompanion(
      id: Value(id),
      name: Value(name),
      expectedVolumes: expectedVolumes == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedVolumes),
      tags: Value(tags),
      updatedAt: Value(updatedAt),
    );
  }

  factory SeriesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeriesData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      expectedVolumes: serializer.fromJson<int?>(json['expectedVolumes']),
      tags: serializer.fromJson<String>(json['tags']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'expectedVolumes': serializer.toJson<int?>(expectedVolumes),
      'tags': serializer.toJson<String>(tags),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SeriesData copyWith({
    String? id,
    String? name,
    Value<int?> expectedVolumes = const Value.absent(),
    String? tags,
    DateTime? updatedAt,
  }) => SeriesData(
    id: id ?? this.id,
    name: name ?? this.name,
    expectedVolumes: expectedVolumes.present
        ? expectedVolumes.value
        : this.expectedVolumes,
    tags: tags ?? this.tags,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SeriesData copyWithCompanion(SeriesCompanion data) {
    return SeriesData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      expectedVolumes: data.expectedVolumes.present
          ? data.expectedVolumes.value
          : this.expectedVolumes,
      tags: data.tags.present ? data.tags.value : this.tags,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeriesData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('expectedVolumes: $expectedVolumes, ')
          ..write('tags: $tags, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, expectedVolumes, tags, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeriesData &&
          other.id == this.id &&
          other.name == this.name &&
          other.expectedVolumes == this.expectedVolumes &&
          other.tags == this.tags &&
          other.updatedAt == this.updatedAt);
}

class SeriesCompanion extends UpdateCompanion<SeriesData> {
  final Value<String> id;
  final Value<String> name;
  final Value<int?> expectedVolumes;
  final Value<String> tags;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SeriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.expectedVolumes = const Value.absent(),
    this.tags = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeriesCompanion.insert({
    required String id,
    required String name,
    this.expectedVolumes = const Value.absent(),
    this.tags = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<SeriesData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? expectedVolumes,
    Expression<String>? tags,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (expectedVolumes != null) 'expected_volumes': expectedVolumes,
      if (tags != null) 'tags': tags,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int?>? expectedVolumes,
    Value<String>? tags,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SeriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      expectedVolumes: expectedVolumes ?? this.expectedVolumes,
      tags: tags ?? this.tags,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (expectedVolumes.present) {
      map['expected_volumes'] = Variable<int>(expectedVolumes.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('expectedVolumes: $expectedVolumes, ')
          ..write('tags: $tags, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isbnMeta = const VerificationMeta('isbn');
  @override
  late final GeneratedColumn<String> isbn = GeneratedColumn<String>(
    'isbn',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<String> seriesId = GeneratedColumn<String>(
    'series_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES series (id)',
    ),
  );
  static const VerificationMeta _volumeNumberMeta = const VerificationMeta(
    'volumeNumber',
  );
  @override
  late final GeneratedColumn<int> volumeNumber = GeneratedColumn<int>(
    'volume_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorsMeta = const VerificationMeta(
    'authors',
  );
  @override
  late final GeneratedColumn<String> authors = GeneratedColumn<String>(
    'authors',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _publisherMeta = const VerificationMeta(
    'publisher',
  );
  @override
  late final GeneratedColumn<String> publisher = GeneratedColumn<String>(
    'publisher',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publishedDateMeta = const VerificationMeta(
    'publishedDate',
  );
  @override
  late final GeneratedColumn<String> publishedDate = GeneratedColumn<String>(
    'published_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverLocalPathMeta = const VerificationMeta(
    'coverLocalPath',
  );
  @override
  late final GeneratedColumn<String> coverLocalPath = GeneratedColumn<String>(
    'cover_local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    isbn,
    title,
    seriesId,
    volumeNumber,
    authors,
    publisher,
    publishedDate,
    coverUrl,
    coverLocalPath,
    tags,
    summary,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<Book> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('isbn')) {
      context.handle(
        _isbnMeta,
        isbn.isAcceptableOrUnknown(data['isbn']!, _isbnMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    }
    if (data.containsKey('volume_number')) {
      context.handle(
        _volumeNumberMeta,
        volumeNumber.isAcceptableOrUnknown(
          data['volume_number']!,
          _volumeNumberMeta,
        ),
      );
    }
    if (data.containsKey('authors')) {
      context.handle(
        _authorsMeta,
        authors.isAcceptableOrUnknown(data['authors']!, _authorsMeta),
      );
    }
    if (data.containsKey('publisher')) {
      context.handle(
        _publisherMeta,
        publisher.isAcceptableOrUnknown(data['publisher']!, _publisherMeta),
      );
    }
    if (data.containsKey('published_date')) {
      context.handle(
        _publishedDateMeta,
        publishedDate.isAcceptableOrUnknown(
          data['published_date']!,
          _publishedDateMeta,
        ),
      );
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    if (data.containsKey('cover_local_path')) {
      context.handle(
        _coverLocalPathMeta,
        coverLocalPath.isAcceptableOrUnknown(
          data['cover_local_path']!,
          _coverLocalPathMeta,
        ),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      isbn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isbn'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      ),
      volumeNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}volume_number'],
      ),
      authors: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}authors'],
      )!,
      publisher: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}publisher'],
      ),
      publishedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}published_date'],
      ),
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      ),
      coverLocalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_local_path'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  final String id;
  final String? isbn;
  final String title;
  final String? seriesId;
  final int? volumeNumber;
  final String authors;
  final String? publisher;
  final String? publishedDate;
  final String? coverUrl;
  final String? coverLocalPath;

  /// Tags perso (CSV) : "SF, Aventure, Humour"
  final String tags;

  /// Résumé / synopsis (saisi à la main ou issu d'une recherche IA).
  final String summary;
  final DateTime updatedAt;
  const Book({
    required this.id,
    this.isbn,
    required this.title,
    this.seriesId,
    this.volumeNumber,
    required this.authors,
    this.publisher,
    this.publishedDate,
    this.coverUrl,
    this.coverLocalPath,
    required this.tags,
    required this.summary,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || isbn != null) {
      map['isbn'] = Variable<String>(isbn);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || seriesId != null) {
      map['series_id'] = Variable<String>(seriesId);
    }
    if (!nullToAbsent || volumeNumber != null) {
      map['volume_number'] = Variable<int>(volumeNumber);
    }
    map['authors'] = Variable<String>(authors);
    if (!nullToAbsent || publisher != null) {
      map['publisher'] = Variable<String>(publisher);
    }
    if (!nullToAbsent || publishedDate != null) {
      map['published_date'] = Variable<String>(publishedDate);
    }
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    if (!nullToAbsent || coverLocalPath != null) {
      map['cover_local_path'] = Variable<String>(coverLocalPath);
    }
    map['tags'] = Variable<String>(tags);
    map['summary'] = Variable<String>(summary);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      isbn: isbn == null && nullToAbsent ? const Value.absent() : Value(isbn),
      title: Value(title),
      seriesId: seriesId == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesId),
      volumeNumber: volumeNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(volumeNumber),
      authors: Value(authors),
      publisher: publisher == null && nullToAbsent
          ? const Value.absent()
          : Value(publisher),
      publishedDate: publishedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(publishedDate),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      coverLocalPath: coverLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverLocalPath),
      tags: Value(tags),
      summary: Value(summary),
      updatedAt: Value(updatedAt),
    );
  }

  factory Book.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<String>(json['id']),
      isbn: serializer.fromJson<String?>(json['isbn']),
      title: serializer.fromJson<String>(json['title']),
      seriesId: serializer.fromJson<String?>(json['seriesId']),
      volumeNumber: serializer.fromJson<int?>(json['volumeNumber']),
      authors: serializer.fromJson<String>(json['authors']),
      publisher: serializer.fromJson<String?>(json['publisher']),
      publishedDate: serializer.fromJson<String?>(json['publishedDate']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      coverLocalPath: serializer.fromJson<String?>(json['coverLocalPath']),
      tags: serializer.fromJson<String>(json['tags']),
      summary: serializer.fromJson<String>(json['summary']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'isbn': serializer.toJson<String?>(isbn),
      'title': serializer.toJson<String>(title),
      'seriesId': serializer.toJson<String?>(seriesId),
      'volumeNumber': serializer.toJson<int?>(volumeNumber),
      'authors': serializer.toJson<String>(authors),
      'publisher': serializer.toJson<String?>(publisher),
      'publishedDate': serializer.toJson<String?>(publishedDate),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'coverLocalPath': serializer.toJson<String?>(coverLocalPath),
      'tags': serializer.toJson<String>(tags),
      'summary': serializer.toJson<String>(summary),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Book copyWith({
    String? id,
    Value<String?> isbn = const Value.absent(),
    String? title,
    Value<String?> seriesId = const Value.absent(),
    Value<int?> volumeNumber = const Value.absent(),
    String? authors,
    Value<String?> publisher = const Value.absent(),
    Value<String?> publishedDate = const Value.absent(),
    Value<String?> coverUrl = const Value.absent(),
    Value<String?> coverLocalPath = const Value.absent(),
    String? tags,
    String? summary,
    DateTime? updatedAt,
  }) => Book(
    id: id ?? this.id,
    isbn: isbn.present ? isbn.value : this.isbn,
    title: title ?? this.title,
    seriesId: seriesId.present ? seriesId.value : this.seriesId,
    volumeNumber: volumeNumber.present ? volumeNumber.value : this.volumeNumber,
    authors: authors ?? this.authors,
    publisher: publisher.present ? publisher.value : this.publisher,
    publishedDate: publishedDate.present
        ? publishedDate.value
        : this.publishedDate,
    coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
    coverLocalPath: coverLocalPath.present
        ? coverLocalPath.value
        : this.coverLocalPath,
    tags: tags ?? this.tags,
    summary: summary ?? this.summary,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      isbn: data.isbn.present ? data.isbn.value : this.isbn,
      title: data.title.present ? data.title.value : this.title,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      volumeNumber: data.volumeNumber.present
          ? data.volumeNumber.value
          : this.volumeNumber,
      authors: data.authors.present ? data.authors.value : this.authors,
      publisher: data.publisher.present ? data.publisher.value : this.publisher,
      publishedDate: data.publishedDate.present
          ? data.publishedDate.value
          : this.publishedDate,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      coverLocalPath: data.coverLocalPath.present
          ? data.coverLocalPath.value
          : this.coverLocalPath,
      tags: data.tags.present ? data.tags.value : this.tags,
      summary: data.summary.present ? data.summary.value : this.summary,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('isbn: $isbn, ')
          ..write('title: $title, ')
          ..write('seriesId: $seriesId, ')
          ..write('volumeNumber: $volumeNumber, ')
          ..write('authors: $authors, ')
          ..write('publisher: $publisher, ')
          ..write('publishedDate: $publishedDate, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('coverLocalPath: $coverLocalPath, ')
          ..write('tags: $tags, ')
          ..write('summary: $summary, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    isbn,
    title,
    seriesId,
    volumeNumber,
    authors,
    publisher,
    publishedDate,
    coverUrl,
    coverLocalPath,
    tags,
    summary,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.isbn == this.isbn &&
          other.title == this.title &&
          other.seriesId == this.seriesId &&
          other.volumeNumber == this.volumeNumber &&
          other.authors == this.authors &&
          other.publisher == this.publisher &&
          other.publishedDate == this.publishedDate &&
          other.coverUrl == this.coverUrl &&
          other.coverLocalPath == this.coverLocalPath &&
          other.tags == this.tags &&
          other.summary == this.summary &&
          other.updatedAt == this.updatedAt);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<String> id;
  final Value<String?> isbn;
  final Value<String> title;
  final Value<String?> seriesId;
  final Value<int?> volumeNumber;
  final Value<String> authors;
  final Value<String?> publisher;
  final Value<String?> publishedDate;
  final Value<String?> coverUrl;
  final Value<String?> coverLocalPath;
  final Value<String> tags;
  final Value<String> summary;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.isbn = const Value.absent(),
    this.title = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.volumeNumber = const Value.absent(),
    this.authors = const Value.absent(),
    this.publisher = const Value.absent(),
    this.publishedDate = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.coverLocalPath = const Value.absent(),
    this.tags = const Value.absent(),
    this.summary = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BooksCompanion.insert({
    required String id,
    this.isbn = const Value.absent(),
    required String title,
    this.seriesId = const Value.absent(),
    this.volumeNumber = const Value.absent(),
    this.authors = const Value.absent(),
    this.publisher = const Value.absent(),
    this.publishedDate = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.coverLocalPath = const Value.absent(),
    this.tags = const Value.absent(),
    this.summary = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       updatedAt = Value(updatedAt);
  static Insertable<Book> custom({
    Expression<String>? id,
    Expression<String>? isbn,
    Expression<String>? title,
    Expression<String>? seriesId,
    Expression<int>? volumeNumber,
    Expression<String>? authors,
    Expression<String>? publisher,
    Expression<String>? publishedDate,
    Expression<String>? coverUrl,
    Expression<String>? coverLocalPath,
    Expression<String>? tags,
    Expression<String>? summary,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (isbn != null) 'isbn': isbn,
      if (title != null) 'title': title,
      if (seriesId != null) 'series_id': seriesId,
      if (volumeNumber != null) 'volume_number': volumeNumber,
      if (authors != null) 'authors': authors,
      if (publisher != null) 'publisher': publisher,
      if (publishedDate != null) 'published_date': publishedDate,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (coverLocalPath != null) 'cover_local_path': coverLocalPath,
      if (tags != null) 'tags': tags,
      if (summary != null) 'summary': summary,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BooksCompanion copyWith({
    Value<String>? id,
    Value<String?>? isbn,
    Value<String>? title,
    Value<String?>? seriesId,
    Value<int?>? volumeNumber,
    Value<String>? authors,
    Value<String?>? publisher,
    Value<String?>? publishedDate,
    Value<String?>? coverUrl,
    Value<String?>? coverLocalPath,
    Value<String>? tags,
    Value<String>? summary,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      isbn: isbn ?? this.isbn,
      title: title ?? this.title,
      seriesId: seriesId ?? this.seriesId,
      volumeNumber: volumeNumber ?? this.volumeNumber,
      authors: authors ?? this.authors,
      publisher: publisher ?? this.publisher,
      publishedDate: publishedDate ?? this.publishedDate,
      coverUrl: coverUrl ?? this.coverUrl,
      coverLocalPath: coverLocalPath ?? this.coverLocalPath,
      tags: tags ?? this.tags,
      summary: summary ?? this.summary,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (isbn.present) {
      map['isbn'] = Variable<String>(isbn.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (volumeNumber.present) {
      map['volume_number'] = Variable<int>(volumeNumber.value);
    }
    if (authors.present) {
      map['authors'] = Variable<String>(authors.value);
    }
    if (publisher.present) {
      map['publisher'] = Variable<String>(publisher.value);
    }
    if (publishedDate.present) {
      map['published_date'] = Variable<String>(publishedDate.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (coverLocalPath.present) {
      map['cover_local_path'] = Variable<String>(coverLocalPath.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('isbn: $isbn, ')
          ..write('title: $title, ')
          ..write('seriesId: $seriesId, ')
          ..write('volumeNumber: $volumeNumber, ')
          ..write('authors: $authors, ')
          ..write('publisher: $publisher, ')
          ..write('publishedDate: $publishedDate, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('coverLocalPath: $coverLocalPath, ')
          ..write('tags: $tags, ')
          ..write('summary: $summary, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CopiesTable extends Copies with TableInfo<$CopiesTable, Copy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CopiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reviewMeta = const VerificationMeta('review');
  @override
  late final GeneratedColumn<String> review = GeneratedColumn<String>(
    'review',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _conditionMeta = const VerificationMeta(
    'condition',
  );
  @override
  late final GeneratedColumn<int> condition = GeneratedColumn<int>(
    'condition',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    rating,
    review,
    condition,
    location,
    notes,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'copies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Copy> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('review')) {
      context.handle(
        _reviewMeta,
        review.isAcceptableOrUnknown(data['review']!, _reviewMeta),
      );
    }
    if (data.containsKey('condition')) {
      context.handle(
        _conditionMeta,
        condition.isAcceptableOrUnknown(data['condition']!, _conditionMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Copy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Copy(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      )!,
      review: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review'],
      )!,
      condition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}condition'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CopiesTable createAlias(String alias) {
    return $CopiesTable(attachedDatabase, alias);
  }
}

class Copy extends DataClass implements Insertable<Copy> {
  final String id;
  final String bookId;
  final int rating;
  final String review;

  /// Etat (1..5) : 1=abîmé, 5=neuf
  final int condition;

  /// Localisation (étagère, pièce)
  final String? location;

  /// Notes exemplaire (ex: dédicace, achat, etc.)
  final String notes;
  final DateTime updatedAt;
  const Copy({
    required this.id,
    required this.bookId,
    required this.rating,
    required this.review,
    required this.condition,
    this.location,
    required this.notes,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['rating'] = Variable<int>(rating);
    map['review'] = Variable<String>(review);
    map['condition'] = Variable<int>(condition);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['notes'] = Variable<String>(notes);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CopiesCompanion toCompanion(bool nullToAbsent) {
    return CopiesCompanion(
      id: Value(id),
      bookId: Value(bookId),
      rating: Value(rating),
      review: Value(review),
      condition: Value(condition),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      notes: Value(notes),
      updatedAt: Value(updatedAt),
    );
  }

  factory Copy.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Copy(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      rating: serializer.fromJson<int>(json['rating']),
      review: serializer.fromJson<String>(json['review']),
      condition: serializer.fromJson<int>(json['condition']),
      location: serializer.fromJson<String?>(json['location']),
      notes: serializer.fromJson<String>(json['notes']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'rating': serializer.toJson<int>(rating),
      'review': serializer.toJson<String>(review),
      'condition': serializer.toJson<int>(condition),
      'location': serializer.toJson<String?>(location),
      'notes': serializer.toJson<String>(notes),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Copy copyWith({
    String? id,
    String? bookId,
    int? rating,
    String? review,
    int? condition,
    Value<String?> location = const Value.absent(),
    String? notes,
    DateTime? updatedAt,
  }) => Copy(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    rating: rating ?? this.rating,
    review: review ?? this.review,
    condition: condition ?? this.condition,
    location: location.present ? location.value : this.location,
    notes: notes ?? this.notes,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Copy copyWithCompanion(CopiesCompanion data) {
    return Copy(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      rating: data.rating.present ? data.rating.value : this.rating,
      review: data.review.present ? data.review.value : this.review,
      condition: data.condition.present ? data.condition.value : this.condition,
      location: data.location.present ? data.location.value : this.location,
      notes: data.notes.present ? data.notes.value : this.notes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Copy(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('rating: $rating, ')
          ..write('review: $review, ')
          ..write('condition: $condition, ')
          ..write('location: $location, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    rating,
    review,
    condition,
    location,
    notes,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Copy &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.rating == this.rating &&
          other.review == this.review &&
          other.condition == this.condition &&
          other.location == this.location &&
          other.notes == this.notes &&
          other.updatedAt == this.updatedAt);
}

class CopiesCompanion extends UpdateCompanion<Copy> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<int> rating;
  final Value<String> review;
  final Value<int> condition;
  final Value<String?> location;
  final Value<String> notes;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CopiesCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.rating = const Value.absent(),
    this.review = const Value.absent(),
    this.condition = const Value.absent(),
    this.location = const Value.absent(),
    this.notes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CopiesCompanion.insert({
    required String id,
    required String bookId,
    this.rating = const Value.absent(),
    this.review = const Value.absent(),
    this.condition = const Value.absent(),
    this.location = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bookId = Value(bookId),
       updatedAt = Value(updatedAt);
  static Insertable<Copy> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<int>? rating,
    Expression<String>? review,
    Expression<int>? condition,
    Expression<String>? location,
    Expression<String>? notes,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (rating != null) 'rating': rating,
      if (review != null) 'review': review,
      if (condition != null) 'condition': condition,
      if (location != null) 'location': location,
      if (notes != null) 'notes': notes,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CopiesCompanion copyWith({
    Value<String>? id,
    Value<String>? bookId,
    Value<int>? rating,
    Value<String>? review,
    Value<int>? condition,
    Value<String?>? location,
    Value<String>? notes,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CopiesCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      condition: condition ?? this.condition,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (review.present) {
      map['review'] = Variable<String>(review.value);
    }
    if (condition.present) {
      map['condition'] = Variable<int>(condition.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CopiesCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('rating: $rating, ')
          ..write('review: $review, ')
          ..write('condition: $condition, ')
          ..write('location: $location, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShelvesTable extends Shelves with TableInfo<$ShelvesTable, Shelf> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShelvesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#6200EE'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, color, sortOrder, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shelves';
  @override
  VerificationContext validateIntegrity(
    Insertable<Shelf> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shelf map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shelf(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ShelvesTable createAlias(String alias) {
    return $ShelvesTable(attachedDatabase, alias);
  }
}

class Shelf extends DataClass implements Insertable<Shelf> {
  final String id;
  final String name;
  final String color;
  final int sortOrder;
  final DateTime updatedAt;
  const Shelf({
    required this.id,
    required this.name,
    required this.color,
    required this.sortOrder,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    map['sort_order'] = Variable<int>(sortOrder);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ShelvesCompanion toCompanion(bool nullToAbsent) {
    return ShelvesCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      sortOrder: Value(sortOrder),
      updatedAt: Value(updatedAt),
    );
  }

  factory Shelf.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shelf(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Shelf copyWith({
    String? id,
    String? name,
    String? color,
    int? sortOrder,
    DateTime? updatedAt,
  }) => Shelf(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color ?? this.color,
    sortOrder: sortOrder ?? this.sortOrder,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Shelf copyWithCompanion(ShelvesCompanion data) {
    return Shelf(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shelf(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color, sortOrder, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shelf &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder &&
          other.updatedAt == this.updatedAt);
}

class ShelvesCompanion extends UpdateCompanion<Shelf> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> color;
  final Value<int> sortOrder;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ShelvesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShelvesCompanion.insert({
    required String id,
    required String name,
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<Shelf> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? color,
    Expression<int>? sortOrder,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShelvesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? color,
    Value<int>? sortOrder,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ShelvesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShelvesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookShelfTable extends BookShelf
    with TableInfo<$BookShelfTable, BookShelfData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookShelfTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _shelfIdMeta = const VerificationMeta(
    'shelfId',
  );
  @override
  late final GeneratedColumn<String> shelfId = GeneratedColumn<String>(
    'shelf_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shelves (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [bookId, shelfId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_shelf';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookShelfData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('shelf_id')) {
      context.handle(
        _shelfIdMeta,
        shelfId.isAcceptableOrUnknown(data['shelf_id']!, _shelfIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shelfIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId, shelfId};
  @override
  BookShelfData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookShelfData(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      shelfId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shelf_id'],
      )!,
    );
  }

  @override
  $BookShelfTable createAlias(String alias) {
    return $BookShelfTable(attachedDatabase, alias);
  }
}

class BookShelfData extends DataClass implements Insertable<BookShelfData> {
  final String bookId;
  final String shelfId;
  const BookShelfData({required this.bookId, required this.shelfId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    map['shelf_id'] = Variable<String>(shelfId);
    return map;
  }

  BookShelfCompanion toCompanion(bool nullToAbsent) {
    return BookShelfCompanion(bookId: Value(bookId), shelfId: Value(shelfId));
  }

  factory BookShelfData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookShelfData(
      bookId: serializer.fromJson<String>(json['bookId']),
      shelfId: serializer.fromJson<String>(json['shelfId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'shelfId': serializer.toJson<String>(shelfId),
    };
  }

  BookShelfData copyWith({String? bookId, String? shelfId}) => BookShelfData(
    bookId: bookId ?? this.bookId,
    shelfId: shelfId ?? this.shelfId,
  );
  BookShelfData copyWithCompanion(BookShelfCompanion data) {
    return BookShelfData(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      shelfId: data.shelfId.present ? data.shelfId.value : this.shelfId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookShelfData(')
          ..write('bookId: $bookId, ')
          ..write('shelfId: $shelfId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, shelfId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookShelfData &&
          other.bookId == this.bookId &&
          other.shelfId == this.shelfId);
}

class BookShelfCompanion extends UpdateCompanion<BookShelfData> {
  final Value<String> bookId;
  final Value<String> shelfId;
  final Value<int> rowid;
  const BookShelfCompanion({
    this.bookId = const Value.absent(),
    this.shelfId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookShelfCompanion.insert({
    required String bookId,
    required String shelfId,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       shelfId = Value(shelfId);
  static Insertable<BookShelfData> custom({
    Expression<String>? bookId,
    Expression<String>? shelfId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (shelfId != null) 'shelf_id': shelfId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookShelfCompanion copyWith({
    Value<String>? bookId,
    Value<String>? shelfId,
    Value<int>? rowid,
  }) {
    return BookShelfCompanion(
      bookId: bookId ?? this.bookId,
      shelfId: shelfId ?? this.shelfId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (shelfId.present) {
      map['shelf_id'] = Variable<String>(shelfId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookShelfCompanion(')
          ..write('bookId: $bookId, ')
          ..write('shelfId: $shelfId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
    'avatar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, displayName, avatar, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('avatar')) {
      context.handle(
        _avatarMeta,
        avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      avatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String displayName;

  /// Couleur/emoji optionnels pour différencier rapidement
  final String avatar;
  final DateTime updatedAt;
  const User({
    required this.id,
    required this.displayName,
    required this.avatar,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    map['avatar'] = Variable<String>(avatar);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      displayName: Value(displayName),
      avatar: Value(avatar),
      updatedAt: Value(updatedAt),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      avatar: serializer.fromJson<String>(json['avatar']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'avatar': serializer.toJson<String>(avatar),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  User copyWith({
    String? id,
    String? displayName,
    String? avatar,
    DateTime? updatedAt,
  }) => User(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    avatar: avatar ?? this.avatar,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('avatar: $avatar, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, displayName, avatar, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.avatar == this.avatar &&
          other.updatedAt == this.updatedAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<String> avatar;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatar = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String displayName,
    this.avatar = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       updatedAt = Value(updatedAt);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? avatar,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (avatar != null) 'avatar': avatar,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<String>? avatar,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('avatar: $avatar, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserCopyMetasTable extends UserCopyMetas
    with TableInfo<$UserCopyMetasTable, UserCopyMeta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserCopyMetasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _copyIdMeta = const VerificationMeta('copyId');
  @override
  late final GeneratedColumn<String> copyId = GeneratedColumn<String>(
    'copy_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reviewMeta = const VerificationMeta('review');
  @override
  late final GeneratedColumn<String> review = GeneratedColumn<String>(
    'review',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('owned'),
  );
  static const VerificationMeta _loanedToUserIdMeta = const VerificationMeta(
    'loanedToUserId',
  );
  @override
  late final GeneratedColumn<String> loanedToUserId = GeneratedColumn<String>(
    'loaned_to_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loanedAtMeta = const VerificationMeta(
    'loanedAt',
  );
  @override
  late final GeneratedColumn<DateTime> loanedAt = GeneratedColumn<DateTime>(
    'loaned_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    copyId,
    rating,
    review,
    status,
    loanedToUserId,
    loanedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_copy_metas';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserCopyMeta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('copy_id')) {
      context.handle(
        _copyIdMeta,
        copyId.isAcceptableOrUnknown(data['copy_id']!, _copyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_copyIdMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('review')) {
      context.handle(
        _reviewMeta,
        review.isAcceptableOrUnknown(data['review']!, _reviewMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('loaned_to_user_id')) {
      context.handle(
        _loanedToUserIdMeta,
        loanedToUserId.isAcceptableOrUnknown(
          data['loaned_to_user_id']!,
          _loanedToUserIdMeta,
        ),
      );
    }
    if (data.containsKey('loaned_at')) {
      context.handle(
        _loanedAtMeta,
        loanedAt.isAcceptableOrUnknown(data['loaned_at']!, _loanedAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserCopyMeta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserCopyMeta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      copyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}copy_id'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      )!,
      review: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}review'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      loanedToUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}loaned_to_user_id'],
      ),
      loanedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}loaned_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserCopyMetasTable createAlias(String alias) {
    return $UserCopyMetasTable(attachedDatabase, alias);
  }
}

class UserCopyMeta extends DataClass implements Insertable<UserCopyMeta> {
  final String id;
  final String userId;
  final String copyId;

  /// Données "pour moi"
  final int rating;
  final String review;

  /// Statut perso (lu, à lire, wishlist, etc.)
  final String status;

  /// Prêt : si cet utilisateur prête/reçoit l'exemplaire
  final String? loanedToUserId;
  final DateTime? loanedAt;
  final DateTime updatedAt;
  const UserCopyMeta({
    required this.id,
    required this.userId,
    required this.copyId,
    required this.rating,
    required this.review,
    required this.status,
    this.loanedToUserId,
    this.loanedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['copy_id'] = Variable<String>(copyId);
    map['rating'] = Variable<int>(rating);
    map['review'] = Variable<String>(review);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || loanedToUserId != null) {
      map['loaned_to_user_id'] = Variable<String>(loanedToUserId);
    }
    if (!nullToAbsent || loanedAt != null) {
      map['loaned_at'] = Variable<DateTime>(loanedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserCopyMetasCompanion toCompanion(bool nullToAbsent) {
    return UserCopyMetasCompanion(
      id: Value(id),
      userId: Value(userId),
      copyId: Value(copyId),
      rating: Value(rating),
      review: Value(review),
      status: Value(status),
      loanedToUserId: loanedToUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(loanedToUserId),
      loanedAt: loanedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(loanedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserCopyMeta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserCopyMeta(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      copyId: serializer.fromJson<String>(json['copyId']),
      rating: serializer.fromJson<int>(json['rating']),
      review: serializer.fromJson<String>(json['review']),
      status: serializer.fromJson<String>(json['status']),
      loanedToUserId: serializer.fromJson<String?>(json['loanedToUserId']),
      loanedAt: serializer.fromJson<DateTime?>(json['loanedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'copyId': serializer.toJson<String>(copyId),
      'rating': serializer.toJson<int>(rating),
      'review': serializer.toJson<String>(review),
      'status': serializer.toJson<String>(status),
      'loanedToUserId': serializer.toJson<String?>(loanedToUserId),
      'loanedAt': serializer.toJson<DateTime?>(loanedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserCopyMeta copyWith({
    String? id,
    String? userId,
    String? copyId,
    int? rating,
    String? review,
    String? status,
    Value<String?> loanedToUserId = const Value.absent(),
    Value<DateTime?> loanedAt = const Value.absent(),
    DateTime? updatedAt,
  }) => UserCopyMeta(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    copyId: copyId ?? this.copyId,
    rating: rating ?? this.rating,
    review: review ?? this.review,
    status: status ?? this.status,
    loanedToUserId: loanedToUserId.present
        ? loanedToUserId.value
        : this.loanedToUserId,
    loanedAt: loanedAt.present ? loanedAt.value : this.loanedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserCopyMeta copyWithCompanion(UserCopyMetasCompanion data) {
    return UserCopyMeta(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      copyId: data.copyId.present ? data.copyId.value : this.copyId,
      rating: data.rating.present ? data.rating.value : this.rating,
      review: data.review.present ? data.review.value : this.review,
      status: data.status.present ? data.status.value : this.status,
      loanedToUserId: data.loanedToUserId.present
          ? data.loanedToUserId.value
          : this.loanedToUserId,
      loanedAt: data.loanedAt.present ? data.loanedAt.value : this.loanedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserCopyMeta(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('copyId: $copyId, ')
          ..write('rating: $rating, ')
          ..write('review: $review, ')
          ..write('status: $status, ')
          ..write('loanedToUserId: $loanedToUserId, ')
          ..write('loanedAt: $loanedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    copyId,
    rating,
    review,
    status,
    loanedToUserId,
    loanedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserCopyMeta &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.copyId == this.copyId &&
          other.rating == this.rating &&
          other.review == this.review &&
          other.status == this.status &&
          other.loanedToUserId == this.loanedToUserId &&
          other.loanedAt == this.loanedAt &&
          other.updatedAt == this.updatedAt);
}

class UserCopyMetasCompanion extends UpdateCompanion<UserCopyMeta> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> copyId;
  final Value<int> rating;
  final Value<String> review;
  final Value<String> status;
  final Value<String?> loanedToUserId;
  final Value<DateTime?> loanedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserCopyMetasCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.copyId = const Value.absent(),
    this.rating = const Value.absent(),
    this.review = const Value.absent(),
    this.status = const Value.absent(),
    this.loanedToUserId = const Value.absent(),
    this.loanedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserCopyMetasCompanion.insert({
    required String id,
    required String userId,
    required String copyId,
    this.rating = const Value.absent(),
    this.review = const Value.absent(),
    this.status = const Value.absent(),
    this.loanedToUserId = const Value.absent(),
    this.loanedAt = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       copyId = Value(copyId),
       updatedAt = Value(updatedAt);
  static Insertable<UserCopyMeta> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? copyId,
    Expression<int>? rating,
    Expression<String>? review,
    Expression<String>? status,
    Expression<String>? loanedToUserId,
    Expression<DateTime>? loanedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (copyId != null) 'copy_id': copyId,
      if (rating != null) 'rating': rating,
      if (review != null) 'review': review,
      if (status != null) 'status': status,
      if (loanedToUserId != null) 'loaned_to_user_id': loanedToUserId,
      if (loanedAt != null) 'loaned_at': loanedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserCopyMetasCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? copyId,
    Value<int>? rating,
    Value<String>? review,
    Value<String>? status,
    Value<String?>? loanedToUserId,
    Value<DateTime?>? loanedAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserCopyMetasCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      copyId: copyId ?? this.copyId,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      status: status ?? this.status,
      loanedToUserId: loanedToUserId ?? this.loanedToUserId,
      loanedAt: loanedAt ?? this.loanedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (copyId.present) {
      map['copy_id'] = Variable<String>(copyId.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (review.present) {
      map['review'] = Variable<String>(review.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (loanedToUserId.present) {
      map['loaned_to_user_id'] = Variable<String>(loanedToUserId.value);
    }
    if (loanedAt.present) {
      map['loaned_at'] = Variable<DateTime>(loanedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserCopyMetasCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('copyId: $copyId, ')
          ..write('rating: $rating, ')
          ..write('review: $review, ')
          ..write('status: $status, ')
          ..write('loanedToUserId: $loanedToUserId, ')
          ..write('loanedAt: $loanedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingProgressTable extends ReadingProgress
    with TableInfo<$ReadingProgressTable, ReadingProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currentPageMeta = const VerificationMeta(
    'currentPage',
  );
  @override
  late final GeneratedColumn<int> currentPage = GeneratedColumn<int>(
    'current_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalPagesMeta = const VerificationMeta(
    'totalPages',
  );
  @override
  late final GeneratedColumn<int> totalPages = GeneratedColumn<int>(
    'total_pages',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usePercentageMeta = const VerificationMeta(
    'usePercentage',
  );
  @override
  late final GeneratedColumn<bool> usePercentage = GeneratedColumn<bool>(
    'use_percentage',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("use_percentage" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _progressPercentMeta = const VerificationMeta(
    'progressPercent',
  );
  @override
  late final GeneratedColumn<int> progressPercent = GeneratedColumn<int>(
    'progress_percent',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readingStartedAtMeta = const VerificationMeta(
    'readingStartedAt',
  );
  @override
  late final GeneratedColumn<DateTime> readingStartedAt =
      GeneratedColumn<DateTime>(
        'reading_started_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _readingFinishedAtMeta = const VerificationMeta(
    'readingFinishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> readingFinishedAt =
      GeneratedColumn<DateTime>(
        'reading_finished_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    bookId,
    status,
    currentPage,
    totalPages,
    usePercentage,
    progressPercent,
    readingStartedAt,
    readingFinishedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingProgressRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('current_page')) {
      context.handle(
        _currentPageMeta,
        currentPage.isAcceptableOrUnknown(
          data['current_page']!,
          _currentPageMeta,
        ),
      );
    }
    if (data.containsKey('total_pages')) {
      context.handle(
        _totalPagesMeta,
        totalPages.isAcceptableOrUnknown(data['total_pages']!, _totalPagesMeta),
      );
    }
    if (data.containsKey('use_percentage')) {
      context.handle(
        _usePercentageMeta,
        usePercentage.isAcceptableOrUnknown(
          data['use_percentage']!,
          _usePercentageMeta,
        ),
      );
    }
    if (data.containsKey('progress_percent')) {
      context.handle(
        _progressPercentMeta,
        progressPercent.isAcceptableOrUnknown(
          data['progress_percent']!,
          _progressPercentMeta,
        ),
      );
    }
    if (data.containsKey('reading_started_at')) {
      context.handle(
        _readingStartedAtMeta,
        readingStartedAt.isAcceptableOrUnknown(
          data['reading_started_at']!,
          _readingStartedAtMeta,
        ),
      );
    }
    if (data.containsKey('reading_finished_at')) {
      context.handle(
        _readingFinishedAtMeta,
        readingFinishedAt.isAcceptableOrUnknown(
          data['reading_finished_at']!,
          _readingFinishedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId};
  @override
  ReadingProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingProgressRow(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      currentPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_page'],
      )!,
      totalPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_pages'],
      ),
      usePercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}use_percentage'],
      )!,
      progressPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress_percent'],
      ),
      readingStartedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reading_started_at'],
      ),
      readingFinishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reading_finished_at'],
      ),
    );
  }

  @override
  $ReadingProgressTable createAlias(String alias) {
    return $ReadingProgressTable(attachedDatabase, alias);
  }
}

class ReadingProgressRow extends DataClass
    implements Insertable<ReadingProgressRow> {
  final String bookId;

  /// 0 = à lire, 1 = en cours, 2 = terminé
  final int status;
  final int currentPage;
  final int? totalPages;
  final bool usePercentage;
  final int? progressPercent;
  final DateTime? readingStartedAt;
  final DateTime? readingFinishedAt;
  const ReadingProgressRow({
    required this.bookId,
    required this.status,
    required this.currentPage,
    this.totalPages,
    required this.usePercentage,
    this.progressPercent,
    this.readingStartedAt,
    this.readingFinishedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    map['status'] = Variable<int>(status);
    map['current_page'] = Variable<int>(currentPage);
    if (!nullToAbsent || totalPages != null) {
      map['total_pages'] = Variable<int>(totalPages);
    }
    map['use_percentage'] = Variable<bool>(usePercentage);
    if (!nullToAbsent || progressPercent != null) {
      map['progress_percent'] = Variable<int>(progressPercent);
    }
    if (!nullToAbsent || readingStartedAt != null) {
      map['reading_started_at'] = Variable<DateTime>(readingStartedAt);
    }
    if (!nullToAbsent || readingFinishedAt != null) {
      map['reading_finished_at'] = Variable<DateTime>(readingFinishedAt);
    }
    return map;
  }

  ReadingProgressCompanion toCompanion(bool nullToAbsent) {
    return ReadingProgressCompanion(
      bookId: Value(bookId),
      status: Value(status),
      currentPage: Value(currentPage),
      totalPages: totalPages == null && nullToAbsent
          ? const Value.absent()
          : Value(totalPages),
      usePercentage: Value(usePercentage),
      progressPercent: progressPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(progressPercent),
      readingStartedAt: readingStartedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readingStartedAt),
      readingFinishedAt: readingFinishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readingFinishedAt),
    );
  }

  factory ReadingProgressRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingProgressRow(
      bookId: serializer.fromJson<String>(json['bookId']),
      status: serializer.fromJson<int>(json['status']),
      currentPage: serializer.fromJson<int>(json['currentPage']),
      totalPages: serializer.fromJson<int?>(json['totalPages']),
      usePercentage: serializer.fromJson<bool>(json['usePercentage']),
      progressPercent: serializer.fromJson<int?>(json['progressPercent']),
      readingStartedAt: serializer.fromJson<DateTime?>(
        json['readingStartedAt'],
      ),
      readingFinishedAt: serializer.fromJson<DateTime?>(
        json['readingFinishedAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'status': serializer.toJson<int>(status),
      'currentPage': serializer.toJson<int>(currentPage),
      'totalPages': serializer.toJson<int?>(totalPages),
      'usePercentage': serializer.toJson<bool>(usePercentage),
      'progressPercent': serializer.toJson<int?>(progressPercent),
      'readingStartedAt': serializer.toJson<DateTime?>(readingStartedAt),
      'readingFinishedAt': serializer.toJson<DateTime?>(readingFinishedAt),
    };
  }

  ReadingProgressRow copyWith({
    String? bookId,
    int? status,
    int? currentPage,
    Value<int?> totalPages = const Value.absent(),
    bool? usePercentage,
    Value<int?> progressPercent = const Value.absent(),
    Value<DateTime?> readingStartedAt = const Value.absent(),
    Value<DateTime?> readingFinishedAt = const Value.absent(),
  }) => ReadingProgressRow(
    bookId: bookId ?? this.bookId,
    status: status ?? this.status,
    currentPage: currentPage ?? this.currentPage,
    totalPages: totalPages.present ? totalPages.value : this.totalPages,
    usePercentage: usePercentage ?? this.usePercentage,
    progressPercent: progressPercent.present
        ? progressPercent.value
        : this.progressPercent,
    readingStartedAt: readingStartedAt.present
        ? readingStartedAt.value
        : this.readingStartedAt,
    readingFinishedAt: readingFinishedAt.present
        ? readingFinishedAt.value
        : this.readingFinishedAt,
  );
  ReadingProgressRow copyWithCompanion(ReadingProgressCompanion data) {
    return ReadingProgressRow(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      status: data.status.present ? data.status.value : this.status,
      currentPage: data.currentPage.present
          ? data.currentPage.value
          : this.currentPage,
      totalPages: data.totalPages.present
          ? data.totalPages.value
          : this.totalPages,
      usePercentage: data.usePercentage.present
          ? data.usePercentage.value
          : this.usePercentage,
      progressPercent: data.progressPercent.present
          ? data.progressPercent.value
          : this.progressPercent,
      readingStartedAt: data.readingStartedAt.present
          ? data.readingStartedAt.value
          : this.readingStartedAt,
      readingFinishedAt: data.readingFinishedAt.present
          ? data.readingFinishedAt.value
          : this.readingFinishedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressRow(')
          ..write('bookId: $bookId, ')
          ..write('status: $status, ')
          ..write('currentPage: $currentPage, ')
          ..write('totalPages: $totalPages, ')
          ..write('usePercentage: $usePercentage, ')
          ..write('progressPercent: $progressPercent, ')
          ..write('readingStartedAt: $readingStartedAt, ')
          ..write('readingFinishedAt: $readingFinishedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    bookId,
    status,
    currentPage,
    totalPages,
    usePercentage,
    progressPercent,
    readingStartedAt,
    readingFinishedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingProgressRow &&
          other.bookId == this.bookId &&
          other.status == this.status &&
          other.currentPage == this.currentPage &&
          other.totalPages == this.totalPages &&
          other.usePercentage == this.usePercentage &&
          other.progressPercent == this.progressPercent &&
          other.readingStartedAt == this.readingStartedAt &&
          other.readingFinishedAt == this.readingFinishedAt);
}

class ReadingProgressCompanion extends UpdateCompanion<ReadingProgressRow> {
  final Value<String> bookId;
  final Value<int> status;
  final Value<int> currentPage;
  final Value<int?> totalPages;
  final Value<bool> usePercentage;
  final Value<int?> progressPercent;
  final Value<DateTime?> readingStartedAt;
  final Value<DateTime?> readingFinishedAt;
  final Value<int> rowid;
  const ReadingProgressCompanion({
    this.bookId = const Value.absent(),
    this.status = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.usePercentage = const Value.absent(),
    this.progressPercent = const Value.absent(),
    this.readingStartedAt = const Value.absent(),
    this.readingFinishedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingProgressCompanion.insert({
    required String bookId,
    this.status = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.usePercentage = const Value.absent(),
    this.progressPercent = const Value.absent(),
    this.readingStartedAt = const Value.absent(),
    this.readingFinishedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId);
  static Insertable<ReadingProgressRow> custom({
    Expression<String>? bookId,
    Expression<int>? status,
    Expression<int>? currentPage,
    Expression<int>? totalPages,
    Expression<bool>? usePercentage,
    Expression<int>? progressPercent,
    Expression<DateTime>? readingStartedAt,
    Expression<DateTime>? readingFinishedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (status != null) 'status': status,
      if (currentPage != null) 'current_page': currentPage,
      if (totalPages != null) 'total_pages': totalPages,
      if (usePercentage != null) 'use_percentage': usePercentage,
      if (progressPercent != null) 'progress_percent': progressPercent,
      if (readingStartedAt != null) 'reading_started_at': readingStartedAt,
      if (readingFinishedAt != null) 'reading_finished_at': readingFinishedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingProgressCompanion copyWith({
    Value<String>? bookId,
    Value<int>? status,
    Value<int>? currentPage,
    Value<int?>? totalPages,
    Value<bool>? usePercentage,
    Value<int?>? progressPercent,
    Value<DateTime?>? readingStartedAt,
    Value<DateTime?>? readingFinishedAt,
    Value<int>? rowid,
  }) {
    return ReadingProgressCompanion(
      bookId: bookId ?? this.bookId,
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      usePercentage: usePercentage ?? this.usePercentage,
      progressPercent: progressPercent ?? this.progressPercent,
      readingStartedAt: readingStartedAt ?? this.readingStartedAt,
      readingFinishedAt: readingFinishedAt ?? this.readingFinishedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (currentPage.present) {
      map['current_page'] = Variable<int>(currentPage.value);
    }
    if (totalPages.present) {
      map['total_pages'] = Variable<int>(totalPages.value);
    }
    if (usePercentage.present) {
      map['use_percentage'] = Variable<bool>(usePercentage.value);
    }
    if (progressPercent.present) {
      map['progress_percent'] = Variable<int>(progressPercent.value);
    }
    if (readingStartedAt.present) {
      map['reading_started_at'] = Variable<DateTime>(readingStartedAt.value);
    }
    if (readingFinishedAt.present) {
      map['reading_finished_at'] = Variable<DateTime>(readingFinishedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressCompanion(')
          ..write('bookId: $bookId, ')
          ..write('status: $status, ')
          ..write('currentPage: $currentPage, ')
          ..write('totalPages: $totalPages, ')
          ..write('usePercentage: $usePercentage, ')
          ..write('progressPercent: $progressPercent, ')
          ..write('readingStartedAt: $readingStartedAt, ')
          ..write('readingFinishedAt: $readingFinishedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingSessionsTable extends ReadingSessions
    with TableInfo<$ReadingSessionsTable, ReadingSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startPageMeta = const VerificationMeta(
    'startPage',
  );
  @override
  late final GeneratedColumn<int> startPage = GeneratedColumn<int>(
    'start_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _endPageMeta = const VerificationMeta(
    'endPage',
  );
  @override
  late final GeneratedColumn<int> endPage = GeneratedColumn<int>(
    'end_page',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finishedBookMeta = const VerificationMeta(
    'finishedBook',
  );
  @override
  late final GeneratedColumn<bool> finishedBook = GeneratedColumn<bool>(
    'finished_book',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("finished_book" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    startedAt,
    endedAt,
    startPage,
    endPage,
    durationSeconds,
    finishedBook,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('start_page')) {
      context.handle(
        _startPageMeta,
        startPage.isAcceptableOrUnknown(data['start_page']!, _startPageMeta),
      );
    }
    if (data.containsKey('end_page')) {
      context.handle(
        _endPageMeta,
        endPage.isAcceptableOrUnknown(data['end_page']!, _endPageMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('finished_book')) {
      context.handle(
        _finishedBookMeta,
        finishedBook.isAcceptableOrUnknown(
          data['finished_book']!,
          _finishedBookMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      startPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_page'],
      )!,
      endPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_page'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      finishedBook: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}finished_book'],
      )!,
    );
  }

  @override
  $ReadingSessionsTable createAlias(String alias) {
    return $ReadingSessionsTable(attachedDatabase, alias);
  }
}

class ReadingSession extends DataClass implements Insertable<ReadingSession> {
  final String id;
  final String bookId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int startPage;
  final int? endPage;
  final int? durationSeconds;
  final bool finishedBook;
  const ReadingSession({
    required this.id,
    required this.bookId,
    required this.startedAt,
    this.endedAt,
    required this.startPage,
    this.endPage,
    this.durationSeconds,
    required this.finishedBook,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['start_page'] = Variable<int>(startPage);
    if (!nullToAbsent || endPage != null) {
      map['end_page'] = Variable<int>(endPage);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    map['finished_book'] = Variable<bool>(finishedBook);
    return map;
  }

  ReadingSessionsCompanion toCompanion(bool nullToAbsent) {
    return ReadingSessionsCompanion(
      id: Value(id),
      bookId: Value(bookId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      startPage: Value(startPage),
      endPage: endPage == null && nullToAbsent
          ? const Value.absent()
          : Value(endPage),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      finishedBook: Value(finishedBook),
    );
  }

  factory ReadingSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingSession(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      startPage: serializer.fromJson<int>(json['startPage']),
      endPage: serializer.fromJson<int?>(json['endPage']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      finishedBook: serializer.fromJson<bool>(json['finishedBook']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'startPage': serializer.toJson<int>(startPage),
      'endPage': serializer.toJson<int?>(endPage),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'finishedBook': serializer.toJson<bool>(finishedBook),
    };
  }

  ReadingSession copyWith({
    String? id,
    String? bookId,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    int? startPage,
    Value<int?> endPage = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    bool? finishedBook,
  }) => ReadingSession(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    startPage: startPage ?? this.startPage,
    endPage: endPage.present ? endPage.value : this.endPage,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    finishedBook: finishedBook ?? this.finishedBook,
  );
  ReadingSession copyWithCompanion(ReadingSessionsCompanion data) {
    return ReadingSession(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      startPage: data.startPage.present ? data.startPage.value : this.startPage,
      endPage: data.endPage.present ? data.endPage.value : this.endPage,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      finishedBook: data.finishedBook.present
          ? data.finishedBook.value
          : this.finishedBook,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSession(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('startPage: $startPage, ')
          ..write('endPage: $endPage, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('finishedBook: $finishedBook')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    startedAt,
    endedAt,
    startPage,
    endPage,
    durationSeconds,
    finishedBook,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingSession &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.startPage == this.startPage &&
          other.endPage == this.endPage &&
          other.durationSeconds == this.durationSeconds &&
          other.finishedBook == this.finishedBook);
}

class ReadingSessionsCompanion extends UpdateCompanion<ReadingSession> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> startPage;
  final Value<int?> endPage;
  final Value<int?> durationSeconds;
  final Value<bool> finishedBook;
  final Value<int> rowid;
  const ReadingSessionsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.startPage = const Value.absent(),
    this.endPage = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.finishedBook = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingSessionsCompanion.insert({
    required String id,
    required String bookId,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.startPage = const Value.absent(),
    this.endPage = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.finishedBook = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       bookId = Value(bookId),
       startedAt = Value(startedAt);
  static Insertable<ReadingSession> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? startPage,
    Expression<int>? endPage,
    Expression<int>? durationSeconds,
    Expression<bool>? finishedBook,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (startPage != null) 'start_page': startPage,
      if (endPage != null) 'end_page': endPage,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (finishedBook != null) 'finished_book': finishedBook,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? bookId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int>? startPage,
    Value<int?>? endPage,
    Value<int?>? durationSeconds,
    Value<bool>? finishedBook,
    Value<int>? rowid,
  }) {
    return ReadingSessionsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      startPage: startPage ?? this.startPage,
      endPage: endPage ?? this.endPage,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      finishedBook: finishedBook ?? this.finishedBook,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (startPage.present) {
      map['start_page'] = Variable<int>(startPage.value);
    }
    if (endPage.present) {
      map['end_page'] = Variable<int>(endPage.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (finishedBook.present) {
      map['finished_book'] = Variable<bool>(finishedBook.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSessionsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('startPage: $startPage, ')
          ..write('endPage: $endPage, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('finishedBook: $finishedBook, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingGoalsTable extends ReadingGoals
    with TableInfo<$ReadingGoalsTable, ReadingGoalsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _booksPerMonthMeta = const VerificationMeta(
    'booksPerMonth',
  );
  @override
  late final GeneratedColumn<int> booksPerMonth = GeneratedColumn<int>(
    'books_per_month',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _booksPerYearMeta = const VerificationMeta(
    'booksPerYear',
  );
  @override
  late final GeneratedColumn<int> booksPerYear = GeneratedColumn<int>(
    'books_per_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, booksPerMonth, booksPerYear];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingGoalsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('books_per_month')) {
      context.handle(
        _booksPerMonthMeta,
        booksPerMonth.isAcceptableOrUnknown(
          data['books_per_month']!,
          _booksPerMonthMeta,
        ),
      );
    }
    if (data.containsKey('books_per_year')) {
      context.handle(
        _booksPerYearMeta,
        booksPerYear.isAcceptableOrUnknown(
          data['books_per_year']!,
          _booksPerYearMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingGoalsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingGoalsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      booksPerMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}books_per_month'],
      ),
      booksPerYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}books_per_year'],
      ),
    );
  }

  @override
  $ReadingGoalsTable createAlias(String alias) {
    return $ReadingGoalsTable(attachedDatabase, alias);
  }
}

class ReadingGoalsRow extends DataClass implements Insertable<ReadingGoalsRow> {
  final String id;
  final int? booksPerMonth;
  final int? booksPerYear;
  const ReadingGoalsRow({
    required this.id,
    this.booksPerMonth,
    this.booksPerYear,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || booksPerMonth != null) {
      map['books_per_month'] = Variable<int>(booksPerMonth);
    }
    if (!nullToAbsent || booksPerYear != null) {
      map['books_per_year'] = Variable<int>(booksPerYear);
    }
    return map;
  }

  ReadingGoalsCompanion toCompanion(bool nullToAbsent) {
    return ReadingGoalsCompanion(
      id: Value(id),
      booksPerMonth: booksPerMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(booksPerMonth),
      booksPerYear: booksPerYear == null && nullToAbsent
          ? const Value.absent()
          : Value(booksPerYear),
    );
  }

  factory ReadingGoalsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingGoalsRow(
      id: serializer.fromJson<String>(json['id']),
      booksPerMonth: serializer.fromJson<int?>(json['booksPerMonth']),
      booksPerYear: serializer.fromJson<int?>(json['booksPerYear']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'booksPerMonth': serializer.toJson<int?>(booksPerMonth),
      'booksPerYear': serializer.toJson<int?>(booksPerYear),
    };
  }

  ReadingGoalsRow copyWith({
    String? id,
    Value<int?> booksPerMonth = const Value.absent(),
    Value<int?> booksPerYear = const Value.absent(),
  }) => ReadingGoalsRow(
    id: id ?? this.id,
    booksPerMonth: booksPerMonth.present
        ? booksPerMonth.value
        : this.booksPerMonth,
    booksPerYear: booksPerYear.present ? booksPerYear.value : this.booksPerYear,
  );
  ReadingGoalsRow copyWithCompanion(ReadingGoalsCompanion data) {
    return ReadingGoalsRow(
      id: data.id.present ? data.id.value : this.id,
      booksPerMonth: data.booksPerMonth.present
          ? data.booksPerMonth.value
          : this.booksPerMonth,
      booksPerYear: data.booksPerYear.present
          ? data.booksPerYear.value
          : this.booksPerYear,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingGoalsRow(')
          ..write('id: $id, ')
          ..write('booksPerMonth: $booksPerMonth, ')
          ..write('booksPerYear: $booksPerYear')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, booksPerMonth, booksPerYear);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingGoalsRow &&
          other.id == this.id &&
          other.booksPerMonth == this.booksPerMonth &&
          other.booksPerYear == this.booksPerYear);
}

class ReadingGoalsCompanion extends UpdateCompanion<ReadingGoalsRow> {
  final Value<String> id;
  final Value<int?> booksPerMonth;
  final Value<int?> booksPerYear;
  final Value<int> rowid;
  const ReadingGoalsCompanion({
    this.id = const Value.absent(),
    this.booksPerMonth = const Value.absent(),
    this.booksPerYear = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingGoalsCompanion.insert({
    required String id,
    this.booksPerMonth = const Value.absent(),
    this.booksPerYear = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<ReadingGoalsRow> custom({
    Expression<String>? id,
    Expression<int>? booksPerMonth,
    Expression<int>? booksPerYear,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (booksPerMonth != null) 'books_per_month': booksPerMonth,
      if (booksPerYear != null) 'books_per_year': booksPerYear,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingGoalsCompanion copyWith({
    Value<String>? id,
    Value<int?>? booksPerMonth,
    Value<int?>? booksPerYear,
    Value<int>? rowid,
  }) {
    return ReadingGoalsCompanion(
      id: id ?? this.id,
      booksPerMonth: booksPerMonth ?? this.booksPerMonth,
      booksPerYear: booksPerYear ?? this.booksPerYear,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (booksPerMonth.present) {
      map['books_per_month'] = Variable<int>(booksPerMonth.value);
    }
    if (booksPerYear.present) {
      map['books_per_year'] = Variable<int>(booksPerYear.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingGoalsCompanion(')
          ..write('id: $id, ')
          ..write('booksPerMonth: $booksPerMonth, ')
          ..write('booksPerYear: $booksPerYear, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $SeriesTable series = $SeriesTable(this);
  late final $BooksTable books = $BooksTable(this);
  late final $CopiesTable copies = $CopiesTable(this);
  late final $ShelvesTable shelves = $ShelvesTable(this);
  late final $BookShelfTable bookShelf = $BookShelfTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $UserCopyMetasTable userCopyMetas = $UserCopyMetasTable(this);
  late final $ReadingProgressTable readingProgress = $ReadingProgressTable(
    this,
  );
  late final $ReadingSessionsTable readingSessions = $ReadingSessionsTable(
    this,
  );
  late final $ReadingGoalsTable readingGoals = $ReadingGoalsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    series,
    books,
    copies,
    shelves,
    bookShelf,
    users,
    userCopyMetas,
    readingProgress,
    readingSessions,
    readingGoals,
  ];
}

typedef $$SeriesTableCreateCompanionBuilder =
    SeriesCompanion Function({
      required String id,
      required String name,
      Value<int?> expectedVolumes,
      Value<String> tags,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SeriesTableUpdateCompanionBuilder =
    SeriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int?> expectedVolumes,
      Value<String> tags,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$SeriesTableReferences
    extends BaseReferences<_$AppDb, $SeriesTable, SeriesData> {
  $$SeriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BooksTable, List<Book>> _booksRefsTable(
    _$AppDb db,
  ) => MultiTypedResultKey.fromTable(
    db.books,
    aliasName: $_aliasNameGenerator(db.series.id, db.books.seriesId),
  );

  $$BooksTableProcessedTableManager get booksRefs {
    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.seriesId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_booksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SeriesTableFilterComposer extends Composer<_$AppDb, $SeriesTable> {
  $$SeriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedVolumes => $composableBuilder(
    column: $table.expectedVolumes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> booksRefs(
    Expression<bool> Function($$BooksTableFilterComposer f) f,
  ) {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SeriesTableOrderingComposer extends Composer<_$AppDb, $SeriesTable> {
  $$SeriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedVolumes => $composableBuilder(
    column: $table.expectedVolumes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeriesTableAnnotationComposer extends Composer<_$AppDb, $SeriesTable> {
  $$SeriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get expectedVolumes => $composableBuilder(
    column: $table.expectedVolumes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> booksRefs<T extends Object>(
    Expression<T> Function($$BooksTableAnnotationComposer a) f,
  ) {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SeriesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $SeriesTable,
          SeriesData,
          $$SeriesTableFilterComposer,
          $$SeriesTableOrderingComposer,
          $$SeriesTableAnnotationComposer,
          $$SeriesTableCreateCompanionBuilder,
          $$SeriesTableUpdateCompanionBuilder,
          (SeriesData, $$SeriesTableReferences),
          SeriesData,
          PrefetchHooks Function({bool booksRefs})
        > {
  $$SeriesTableTableManager(_$AppDb db, $SeriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> expectedVolumes = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeriesCompanion(
                id: id,
                name: name,
                expectedVolumes: expectedVolumes,
                tags: tags,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int?> expectedVolumes = const Value.absent(),
                Value<String> tags = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SeriesCompanion.insert(
                id: id,
                name: name,
                expectedVolumes: expectedVolumes,
                tags: tags,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$SeriesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({booksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (booksRefs) db.books],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (booksRefs)
                    await $_getPrefetchedData<SeriesData, $SeriesTable, Book>(
                      currentTable: table,
                      referencedTable: $$SeriesTableReferences._booksRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$SeriesTableReferences(db, table, p0).booksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.seriesId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SeriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $SeriesTable,
      SeriesData,
      $$SeriesTableFilterComposer,
      $$SeriesTableOrderingComposer,
      $$SeriesTableAnnotationComposer,
      $$SeriesTableCreateCompanionBuilder,
      $$SeriesTableUpdateCompanionBuilder,
      (SeriesData, $$SeriesTableReferences),
      SeriesData,
      PrefetchHooks Function({bool booksRefs})
    >;
typedef $$BooksTableCreateCompanionBuilder =
    BooksCompanion Function({
      required String id,
      Value<String?> isbn,
      required String title,
      Value<String?> seriesId,
      Value<int?> volumeNumber,
      Value<String> authors,
      Value<String?> publisher,
      Value<String?> publishedDate,
      Value<String?> coverUrl,
      Value<String?> coverLocalPath,
      Value<String> tags,
      Value<String> summary,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$BooksTableUpdateCompanionBuilder =
    BooksCompanion Function({
      Value<String> id,
      Value<String?> isbn,
      Value<String> title,
      Value<String?> seriesId,
      Value<int?> volumeNumber,
      Value<String> authors,
      Value<String?> publisher,
      Value<String?> publishedDate,
      Value<String?> coverUrl,
      Value<String?> coverLocalPath,
      Value<String> tags,
      Value<String> summary,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$BooksTableReferences
    extends BaseReferences<_$AppDb, $BooksTable, Book> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SeriesTable _seriesIdTable(_$AppDb db) => db.series.createAlias(
    $_aliasNameGenerator(db.books.seriesId, db.series.id),
  );

  $$SeriesTableProcessedTableManager? get seriesId {
    final $_column = $_itemColumn<String>('series_id');
    if ($_column == null) return null;
    final manager = $$SeriesTableTableManager(
      $_db,
      $_db.series,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seriesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CopiesTable, List<Copy>> _copiesRefsTable(
    _$AppDb db,
  ) => MultiTypedResultKey.fromTable(
    db.copies,
    aliasName: $_aliasNameGenerator(db.books.id, db.copies.bookId),
  );

  $$CopiesTableProcessedTableManager get copiesRefs {
    final manager = $$CopiesTableTableManager(
      $_db,
      $_db.copies,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_copiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BookShelfTable, List<BookShelfData>>
  _bookShelfRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.bookShelf,
    aliasName: $_aliasNameGenerator(db.books.id, db.bookShelf.bookId),
  );

  $$BookShelfTableProcessedTableManager get bookShelfRefs {
    final manager = $$BookShelfTableTableManager(
      $_db,
      $_db.bookShelf,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookShelfRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BooksTableFilterComposer extends Composer<_$AppDb, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isbn => $composableBuilder(
    column: $table.isbn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get volumeNumber => $composableBuilder(
    column: $table.volumeNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publishedDate => $composableBuilder(
    column: $table.publishedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverLocalPath => $composableBuilder(
    column: $table.coverLocalPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SeriesTableFilterComposer get seriesId {
    final $$SeriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.series,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesTableFilterComposer(
            $db: $db,
            $table: $db.series,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> copiesRefs(
    Expression<bool> Function($$CopiesTableFilterComposer f) f,
  ) {
    final $$CopiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.copies,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CopiesTableFilterComposer(
            $db: $db,
            $table: $db.copies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bookShelfRefs(
    Expression<bool> Function($$BookShelfTableFilterComposer f) f,
  ) {
    final $$BookShelfTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookShelf,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookShelfTableFilterComposer(
            $db: $db,
            $table: $db.bookShelf,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableOrderingComposer extends Composer<_$AppDb, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isbn => $composableBuilder(
    column: $table.isbn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get volumeNumber => $composableBuilder(
    column: $table.volumeNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publishedDate => $composableBuilder(
    column: $table.publishedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverLocalPath => $composableBuilder(
    column: $table.coverLocalPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SeriesTableOrderingComposer get seriesId {
    final $$SeriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.series,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesTableOrderingComposer(
            $db: $db,
            $table: $db.series,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BooksTableAnnotationComposer extends Composer<_$AppDb, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get isbn =>
      $composableBuilder(column: $table.isbn, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get volumeNumber => $composableBuilder(
    column: $table.volumeNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authors =>
      $composableBuilder(column: $table.authors, builder: (column) => column);

  GeneratedColumn<String> get publisher =>
      $composableBuilder(column: $table.publisher, builder: (column) => column);

  GeneratedColumn<String> get publishedDate => $composableBuilder(
    column: $table.publishedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get coverLocalPath => $composableBuilder(
    column: $table.coverLocalPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SeriesTableAnnotationComposer get seriesId {
    final $$SeriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.series,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesTableAnnotationComposer(
            $db: $db,
            $table: $db.series,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> copiesRefs<T extends Object>(
    Expression<T> Function($$CopiesTableAnnotationComposer a) f,
  ) {
    final $$CopiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.copies,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CopiesTableAnnotationComposer(
            $db: $db,
            $table: $db.copies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bookShelfRefs<T extends Object>(
    Expression<T> Function($$BookShelfTableAnnotationComposer a) f,
  ) {
    final $$BookShelfTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookShelf,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookShelfTableAnnotationComposer(
            $db: $db,
            $table: $db.bookShelf,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $BooksTable,
          Book,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (Book, $$BooksTableReferences),
          Book,
          PrefetchHooks Function({
            bool seriesId,
            bool copiesRefs,
            bool bookShelfRefs,
          })
        > {
  $$BooksTableTableManager(_$AppDb db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> isbn = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> seriesId = const Value.absent(),
                Value<int?> volumeNumber = const Value.absent(),
                Value<String> authors = const Value.absent(),
                Value<String?> publisher = const Value.absent(),
                Value<String?> publishedDate = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String?> coverLocalPath = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                isbn: isbn,
                title: title,
                seriesId: seriesId,
                volumeNumber: volumeNumber,
                authors: authors,
                publisher: publisher,
                publishedDate: publishedDate,
                coverUrl: coverUrl,
                coverLocalPath: coverLocalPath,
                tags: tags,
                summary: summary,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> isbn = const Value.absent(),
                required String title,
                Value<String?> seriesId = const Value.absent(),
                Value<int?> volumeNumber = const Value.absent(),
                Value<String> authors = const Value.absent(),
                Value<String?> publisher = const Value.absent(),
                Value<String?> publishedDate = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String?> coverLocalPath = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<String> summary = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                isbn: isbn,
                title: title,
                seriesId: seriesId,
                volumeNumber: volumeNumber,
                authors: authors,
                publisher: publisher,
                publishedDate: publishedDate,
                coverUrl: coverUrl,
                coverLocalPath: coverLocalPath,
                tags: tags,
                summary: summary,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BooksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({seriesId = false, copiesRefs = false, bookShelfRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (copiesRefs) db.copies,
                    if (bookShelfRefs) db.bookShelf,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (seriesId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.seriesId,
                                    referencedTable: $$BooksTableReferences
                                        ._seriesIdTable(db),
                                    referencedColumn: $$BooksTableReferences
                                        ._seriesIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (copiesRefs)
                        await $_getPrefetchedData<Book, $BooksTable, Copy>(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._copiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(db, table, p0).copiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (bookShelfRefs)
                        await $_getPrefetchedData<
                          Book,
                          $BooksTable,
                          BookShelfData
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._bookShelfRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).bookShelfRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $BooksTable,
      Book,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (Book, $$BooksTableReferences),
      Book,
      PrefetchHooks Function({
        bool seriesId,
        bool copiesRefs,
        bool bookShelfRefs,
      })
    >;
typedef $$CopiesTableCreateCompanionBuilder =
    CopiesCompanion Function({
      required String id,
      required String bookId,
      Value<int> rating,
      Value<String> review,
      Value<int> condition,
      Value<String?> location,
      Value<String> notes,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CopiesTableUpdateCompanionBuilder =
    CopiesCompanion Function({
      Value<String> id,
      Value<String> bookId,
      Value<int> rating,
      Value<String> review,
      Value<int> condition,
      Value<String?> location,
      Value<String> notes,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CopiesTableReferences
    extends BaseReferences<_$AppDb, $CopiesTable, Copy> {
  $$CopiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDb db) =>
      db.books.createAlias($_aliasNameGenerator(db.copies.bookId, db.books.id));

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CopiesTableFilterComposer extends Composer<_$AppDb, $CopiesTable> {
  $$CopiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CopiesTableOrderingComposer extends Composer<_$AppDb, $CopiesTable> {
  $$CopiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CopiesTableAnnotationComposer extends Composer<_$AppDb, $CopiesTable> {
  $$CopiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get review =>
      $composableBuilder(column: $table.review, builder: (column) => column);

  GeneratedColumn<int> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CopiesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $CopiesTable,
          Copy,
          $$CopiesTableFilterComposer,
          $$CopiesTableOrderingComposer,
          $$CopiesTableAnnotationComposer,
          $$CopiesTableCreateCompanionBuilder,
          $$CopiesTableUpdateCompanionBuilder,
          (Copy, $$CopiesTableReferences),
          Copy,
          PrefetchHooks Function({bool bookId})
        > {
  $$CopiesTableTableManager(_$AppDb db, $CopiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CopiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CopiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CopiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<String> review = const Value.absent(),
                Value<int> condition = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CopiesCompanion(
                id: id,
                bookId: bookId,
                rating: rating,
                review: review,
                condition: condition,
                location: location,
                notes: notes,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bookId,
                Value<int> rating = const Value.absent(),
                Value<String> review = const Value.absent(),
                Value<int> condition = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String> notes = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CopiesCompanion.insert(
                id: id,
                bookId: bookId,
                rating: rating,
                review: review,
                condition: condition,
                location: location,
                notes: notes,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$CopiesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable: $$CopiesTableReferences
                                    ._bookIdTable(db),
                                referencedColumn: $$CopiesTableReferences
                                    ._bookIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CopiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $CopiesTable,
      Copy,
      $$CopiesTableFilterComposer,
      $$CopiesTableOrderingComposer,
      $$CopiesTableAnnotationComposer,
      $$CopiesTableCreateCompanionBuilder,
      $$CopiesTableUpdateCompanionBuilder,
      (Copy, $$CopiesTableReferences),
      Copy,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$ShelvesTableCreateCompanionBuilder =
    ShelvesCompanion Function({
      required String id,
      required String name,
      Value<String> color,
      Value<int> sortOrder,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ShelvesTableUpdateCompanionBuilder =
    ShelvesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> color,
      Value<int> sortOrder,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ShelvesTableReferences
    extends BaseReferences<_$AppDb, $ShelvesTable, Shelf> {
  $$ShelvesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BookShelfTable, List<BookShelfData>>
  _bookShelfRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.bookShelf,
    aliasName: $_aliasNameGenerator(db.shelves.id, db.bookShelf.shelfId),
  );

  $$BookShelfTableProcessedTableManager get bookShelfRefs {
    final manager = $$BookShelfTableTableManager(
      $_db,
      $_db.bookShelf,
    ).filter((f) => f.shelfId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookShelfRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ShelvesTableFilterComposer extends Composer<_$AppDb, $ShelvesTable> {
  $$ShelvesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> bookShelfRefs(
    Expression<bool> Function($$BookShelfTableFilterComposer f) f,
  ) {
    final $$BookShelfTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookShelf,
      getReferencedColumn: (t) => t.shelfId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookShelfTableFilterComposer(
            $db: $db,
            $table: $db.bookShelf,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShelvesTableOrderingComposer extends Composer<_$AppDb, $ShelvesTable> {
  $$ShelvesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShelvesTableAnnotationComposer
    extends Composer<_$AppDb, $ShelvesTable> {
  $$ShelvesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> bookShelfRefs<T extends Object>(
    Expression<T> Function($$BookShelfTableAnnotationComposer a) f,
  ) {
    final $$BookShelfTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookShelf,
      getReferencedColumn: (t) => t.shelfId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookShelfTableAnnotationComposer(
            $db: $db,
            $table: $db.bookShelf,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShelvesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ShelvesTable,
          Shelf,
          $$ShelvesTableFilterComposer,
          $$ShelvesTableOrderingComposer,
          $$ShelvesTableAnnotationComposer,
          $$ShelvesTableCreateCompanionBuilder,
          $$ShelvesTableUpdateCompanionBuilder,
          (Shelf, $$ShelvesTableReferences),
          Shelf,
          PrefetchHooks Function({bool bookShelfRefs})
        > {
  $$ShelvesTableTableManager(_$AppDb db, $ShelvesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShelvesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShelvesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShelvesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShelvesCompanion(
                id: id,
                name: name,
                color: color,
                sortOrder: sortOrder,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ShelvesCompanion.insert(
                id: id,
                name: name,
                color: color,
                sortOrder: sortOrder,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ShelvesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookShelfRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (bookShelfRefs) db.bookShelf],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bookShelfRefs)
                    await $_getPrefetchedData<
                      Shelf,
                      $ShelvesTable,
                      BookShelfData
                    >(
                      currentTable: table,
                      referencedTable: $$ShelvesTableReferences
                          ._bookShelfRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ShelvesTableReferences(db, table, p0).bookShelfRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.shelfId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ShelvesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ShelvesTable,
      Shelf,
      $$ShelvesTableFilterComposer,
      $$ShelvesTableOrderingComposer,
      $$ShelvesTableAnnotationComposer,
      $$ShelvesTableCreateCompanionBuilder,
      $$ShelvesTableUpdateCompanionBuilder,
      (Shelf, $$ShelvesTableReferences),
      Shelf,
      PrefetchHooks Function({bool bookShelfRefs})
    >;
typedef $$BookShelfTableCreateCompanionBuilder =
    BookShelfCompanion Function({
      required String bookId,
      required String shelfId,
      Value<int> rowid,
    });
typedef $$BookShelfTableUpdateCompanionBuilder =
    BookShelfCompanion Function({
      Value<String> bookId,
      Value<String> shelfId,
      Value<int> rowid,
    });

final class $$BookShelfTableReferences
    extends BaseReferences<_$AppDb, $BookShelfTable, BookShelfData> {
  $$BookShelfTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDb db) => db.books.createAlias(
    $_aliasNameGenerator(db.bookShelf.bookId, db.books.id),
  );

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ShelvesTable _shelfIdTable(_$AppDb db) => db.shelves.createAlias(
    $_aliasNameGenerator(db.bookShelf.shelfId, db.shelves.id),
  );

  $$ShelvesTableProcessedTableManager get shelfId {
    final $_column = $_itemColumn<String>('shelf_id')!;

    final manager = $$ShelvesTableTableManager(
      $_db,
      $_db.shelves,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shelfIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookShelfTableFilterComposer
    extends Composer<_$AppDb, $BookShelfTable> {
  $$BookShelfTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShelvesTableFilterComposer get shelfId {
    final $$ShelvesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableFilterComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookShelfTableOrderingComposer
    extends Composer<_$AppDb, $BookShelfTable> {
  $$BookShelfTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShelvesTableOrderingComposer get shelfId {
    final $$ShelvesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableOrderingComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookShelfTableAnnotationComposer
    extends Composer<_$AppDb, $BookShelfTable> {
  $$BookShelfTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShelvesTableAnnotationComposer get shelfId {
    final $$ShelvesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableAnnotationComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookShelfTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $BookShelfTable,
          BookShelfData,
          $$BookShelfTableFilterComposer,
          $$BookShelfTableOrderingComposer,
          $$BookShelfTableAnnotationComposer,
          $$BookShelfTableCreateCompanionBuilder,
          $$BookShelfTableUpdateCompanionBuilder,
          (BookShelfData, $$BookShelfTableReferences),
          BookShelfData,
          PrefetchHooks Function({bool bookId, bool shelfId})
        > {
  $$BookShelfTableTableManager(_$AppDb db, $BookShelfTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookShelfTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookShelfTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookShelfTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> bookId = const Value.absent(),
                Value<String> shelfId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookShelfCompanion(
                bookId: bookId,
                shelfId: shelfId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bookId,
                required String shelfId,
                Value<int> rowid = const Value.absent(),
              }) => BookShelfCompanion.insert(
                bookId: bookId,
                shelfId: shelfId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BookShelfTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false, shelfId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.bookId,
                                referencedTable: $$BookShelfTableReferences
                                    ._bookIdTable(db),
                                referencedColumn: $$BookShelfTableReferences
                                    ._bookIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (shelfId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.shelfId,
                                referencedTable: $$BookShelfTableReferences
                                    ._shelfIdTable(db),
                                referencedColumn: $$BookShelfTableReferences
                                    ._shelfIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BookShelfTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $BookShelfTable,
      BookShelfData,
      $$BookShelfTableFilterComposer,
      $$BookShelfTableOrderingComposer,
      $$BookShelfTableAnnotationComposer,
      $$BookShelfTableCreateCompanionBuilder,
      $$BookShelfTableUpdateCompanionBuilder,
      (BookShelfData, $$BookShelfTableReferences),
      BookShelfData,
      PrefetchHooks Function({bool bookId, bool shelfId})
    >;
typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      required String displayName,
      Value<String> avatar,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<String> avatar,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$UsersTableReferences
    extends BaseReferences<_$AppDb, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserCopyMetasTable, List<UserCopyMeta>>
  _userCopyMetasRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.userCopyMetas,
    aliasName: $_aliasNameGenerator(db.users.id, db.userCopyMetas.userId),
  );

  $$UserCopyMetasTableProcessedTableManager get userCopyMetasRefs {
    final manager = $$UserCopyMetasTableTableManager(
      $_db,
      $_db.userCopyMetas,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_userCopyMetasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDb, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> userCopyMetasRefs(
    Expression<bool> Function($$UserCopyMetasTableFilterComposer f) f,
  ) {
    final $$UserCopyMetasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userCopyMetas,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserCopyMetasTableFilterComposer(
            $db: $db,
            $table: $db.userCopyMetas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableOrderingComposer extends Composer<_$AppDb, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer extends Composer<_$AppDb, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> userCopyMetasRefs<T extends Object>(
    Expression<T> Function($$UserCopyMetasTableAnnotationComposer a) f,
  ) {
    final $$UserCopyMetasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userCopyMetas,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserCopyMetasTableAnnotationComposer(
            $db: $db,
            $table: $db.userCopyMetas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, $$UsersTableReferences),
          User,
          PrefetchHooks Function({bool userCopyMetasRefs})
        > {
  $$UsersTableTableManager(_$AppDb db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> avatar = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                displayName: displayName,
                avatar: avatar,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                Value<String> avatar = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                displayName: displayName,
                avatar: avatar,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$UsersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({userCopyMetasRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (userCopyMetasRefs) db.userCopyMetas,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userCopyMetasRefs)
                    await $_getPrefetchedData<User, $UsersTable, UserCopyMeta>(
                      currentTable: table,
                      referencedTable: $$UsersTableReferences
                          ._userCopyMetasRefsTable(db),
                      managerFromTypedResult: (p0) => $$UsersTableReferences(
                        db,
                        table,
                        p0,
                      ).userCopyMetasRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.userId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, $$UsersTableReferences),
      User,
      PrefetchHooks Function({bool userCopyMetasRefs})
    >;
typedef $$UserCopyMetasTableCreateCompanionBuilder =
    UserCopyMetasCompanion Function({
      required String id,
      required String userId,
      required String copyId,
      Value<int> rating,
      Value<String> review,
      Value<String> status,
      Value<String?> loanedToUserId,
      Value<DateTime?> loanedAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UserCopyMetasTableUpdateCompanionBuilder =
    UserCopyMetasCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> copyId,
      Value<int> rating,
      Value<String> review,
      Value<String> status,
      Value<String?> loanedToUserId,
      Value<DateTime?> loanedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$UserCopyMetasTableReferences
    extends BaseReferences<_$AppDb, $UserCopyMetasTable, UserCopyMeta> {
  $$UserCopyMetasTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTable _userIdTable(_$AppDb db) => db.users.createAlias(
    $_aliasNameGenerator(db.userCopyMetas.userId, db.users.id),
  );

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<String>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserCopyMetasTableFilterComposer
    extends Composer<_$AppDb, $UserCopyMetasTable> {
  $$UserCopyMetasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get copyId => $composableBuilder(
    column: $table.copyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loanedToUserId => $composableBuilder(
    column: $table.loanedToUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loanedAt => $composableBuilder(
    column: $table.loanedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserCopyMetasTableOrderingComposer
    extends Composer<_$AppDb, $UserCopyMetasTable> {
  $$UserCopyMetasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get copyId => $composableBuilder(
    column: $table.copyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get review => $composableBuilder(
    column: $table.review,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loanedToUserId => $composableBuilder(
    column: $table.loanedToUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loanedAt => $composableBuilder(
    column: $table.loanedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserCopyMetasTableAnnotationComposer
    extends Composer<_$AppDb, $UserCopyMetasTable> {
  $$UserCopyMetasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get copyId =>
      $composableBuilder(column: $table.copyId, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get review =>
      $composableBuilder(column: $table.review, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get loanedToUserId => $composableBuilder(
    column: $table.loanedToUserId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get loanedAt =>
      $composableBuilder(column: $table.loanedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserCopyMetasTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $UserCopyMetasTable,
          UserCopyMeta,
          $$UserCopyMetasTableFilterComposer,
          $$UserCopyMetasTableOrderingComposer,
          $$UserCopyMetasTableAnnotationComposer,
          $$UserCopyMetasTableCreateCompanionBuilder,
          $$UserCopyMetasTableUpdateCompanionBuilder,
          (UserCopyMeta, $$UserCopyMetasTableReferences),
          UserCopyMeta,
          PrefetchHooks Function({bool userId})
        > {
  $$UserCopyMetasTableTableManager(_$AppDb db, $UserCopyMetasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserCopyMetasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserCopyMetasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserCopyMetasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> copyId = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<String> review = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> loanedToUserId = const Value.absent(),
                Value<DateTime?> loanedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserCopyMetasCompanion(
                id: id,
                userId: userId,
                copyId: copyId,
                rating: rating,
                review: review,
                status: status,
                loanedToUserId: loanedToUserId,
                loanedAt: loanedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String copyId,
                Value<int> rating = const Value.absent(),
                Value<String> review = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> loanedToUserId = const Value.absent(),
                Value<DateTime?> loanedAt = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UserCopyMetasCompanion.insert(
                id: id,
                userId: userId,
                copyId: copyId,
                rating: rating,
                review: review,
                status: status,
                loanedToUserId: loanedToUserId,
                loanedAt: loanedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserCopyMetasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$UserCopyMetasTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$UserCopyMetasTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UserCopyMetasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $UserCopyMetasTable,
      UserCopyMeta,
      $$UserCopyMetasTableFilterComposer,
      $$UserCopyMetasTableOrderingComposer,
      $$UserCopyMetasTableAnnotationComposer,
      $$UserCopyMetasTableCreateCompanionBuilder,
      $$UserCopyMetasTableUpdateCompanionBuilder,
      (UserCopyMeta, $$UserCopyMetasTableReferences),
      UserCopyMeta,
      PrefetchHooks Function({bool userId})
    >;
typedef $$ReadingProgressTableCreateCompanionBuilder =
    ReadingProgressCompanion Function({
      required String bookId,
      Value<int> status,
      Value<int> currentPage,
      Value<int?> totalPages,
      Value<bool> usePercentage,
      Value<int?> progressPercent,
      Value<DateTime?> readingStartedAt,
      Value<DateTime?> readingFinishedAt,
      Value<int> rowid,
    });
typedef $$ReadingProgressTableUpdateCompanionBuilder =
    ReadingProgressCompanion Function({
      Value<String> bookId,
      Value<int> status,
      Value<int> currentPage,
      Value<int?> totalPages,
      Value<bool> usePercentage,
      Value<int?> progressPercent,
      Value<DateTime?> readingStartedAt,
      Value<DateTime?> readingFinishedAt,
      Value<int> rowid,
    });

class $$ReadingProgressTableFilterComposer
    extends Composer<_$AppDb, $ReadingProgressTable> {
  $$ReadingProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get usePercentage => $composableBuilder(
    column: $table.usePercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progressPercent => $composableBuilder(
    column: $table.progressPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readingStartedAt => $composableBuilder(
    column: $table.readingStartedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readingFinishedAt => $composableBuilder(
    column: $table.readingFinishedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingProgressTableOrderingComposer
    extends Composer<_$AppDb, $ReadingProgressTable> {
  $$ReadingProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get usePercentage => $composableBuilder(
    column: $table.usePercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progressPercent => $composableBuilder(
    column: $table.progressPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readingStartedAt => $composableBuilder(
    column: $table.readingStartedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readingFinishedAt => $composableBuilder(
    column: $table.readingFinishedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingProgressTableAnnotationComposer
    extends Composer<_$AppDb, $ReadingProgressTable> {
  $$ReadingProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalPages => $composableBuilder(
    column: $table.totalPages,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get usePercentage => $composableBuilder(
    column: $table.usePercentage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get progressPercent => $composableBuilder(
    column: $table.progressPercent,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get readingStartedAt => $composableBuilder(
    column: $table.readingStartedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get readingFinishedAt => $composableBuilder(
    column: $table.readingFinishedAt,
    builder: (column) => column,
  );
}

class $$ReadingProgressTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ReadingProgressTable,
          ReadingProgressRow,
          $$ReadingProgressTableFilterComposer,
          $$ReadingProgressTableOrderingComposer,
          $$ReadingProgressTableAnnotationComposer,
          $$ReadingProgressTableCreateCompanionBuilder,
          $$ReadingProgressTableUpdateCompanionBuilder,
          (
            ReadingProgressRow,
            BaseReferences<_$AppDb, $ReadingProgressTable, ReadingProgressRow>,
          ),
          ReadingProgressRow,
          PrefetchHooks Function()
        > {
  $$ReadingProgressTableTableManager(_$AppDb db, $ReadingProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> bookId = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int> currentPage = const Value.absent(),
                Value<int?> totalPages = const Value.absent(),
                Value<bool> usePercentage = const Value.absent(),
                Value<int?> progressPercent = const Value.absent(),
                Value<DateTime?> readingStartedAt = const Value.absent(),
                Value<DateTime?> readingFinishedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingProgressCompanion(
                bookId: bookId,
                status: status,
                currentPage: currentPage,
                totalPages: totalPages,
                usePercentage: usePercentage,
                progressPercent: progressPercent,
                readingStartedAt: readingStartedAt,
                readingFinishedAt: readingFinishedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bookId,
                Value<int> status = const Value.absent(),
                Value<int> currentPage = const Value.absent(),
                Value<int?> totalPages = const Value.absent(),
                Value<bool> usePercentage = const Value.absent(),
                Value<int?> progressPercent = const Value.absent(),
                Value<DateTime?> readingStartedAt = const Value.absent(),
                Value<DateTime?> readingFinishedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingProgressCompanion.insert(
                bookId: bookId,
                status: status,
                currentPage: currentPage,
                totalPages: totalPages,
                usePercentage: usePercentage,
                progressPercent: progressPercent,
                readingStartedAt: readingStartedAt,
                readingFinishedAt: readingFinishedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ReadingProgressTable,
      ReadingProgressRow,
      $$ReadingProgressTableFilterComposer,
      $$ReadingProgressTableOrderingComposer,
      $$ReadingProgressTableAnnotationComposer,
      $$ReadingProgressTableCreateCompanionBuilder,
      $$ReadingProgressTableUpdateCompanionBuilder,
      (
        ReadingProgressRow,
        BaseReferences<_$AppDb, $ReadingProgressTable, ReadingProgressRow>,
      ),
      ReadingProgressRow,
      PrefetchHooks Function()
    >;
typedef $$ReadingSessionsTableCreateCompanionBuilder =
    ReadingSessionsCompanion Function({
      required String id,
      required String bookId,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<int> startPage,
      Value<int?> endPage,
      Value<int?> durationSeconds,
      Value<bool> finishedBook,
      Value<int> rowid,
    });
typedef $$ReadingSessionsTableUpdateCompanionBuilder =
    ReadingSessionsCompanion Function({
      Value<String> id,
      Value<String> bookId,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<int> startPage,
      Value<int?> endPage,
      Value<int?> durationSeconds,
      Value<bool> finishedBook,
      Value<int> rowid,
    });

class $$ReadingSessionsTableFilterComposer
    extends Composer<_$AppDb, $ReadingSessionsTable> {
  $$ReadingSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startPage => $composableBuilder(
    column: $table.startPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endPage => $composableBuilder(
    column: $table.endPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get finishedBook => $composableBuilder(
    column: $table.finishedBook,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingSessionsTableOrderingComposer
    extends Composer<_$AppDb, $ReadingSessionsTable> {
  $$ReadingSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startPage => $composableBuilder(
    column: $table.startPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endPage => $composableBuilder(
    column: $table.endPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get finishedBook => $composableBuilder(
    column: $table.finishedBook,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingSessionsTableAnnotationComposer
    extends Composer<_$AppDb, $ReadingSessionsTable> {
  $$ReadingSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get startPage =>
      $composableBuilder(column: $table.startPage, builder: (column) => column);

  GeneratedColumn<int> get endPage =>
      $composableBuilder(column: $table.endPage, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get finishedBook => $composableBuilder(
    column: $table.finishedBook,
    builder: (column) => column,
  );
}

class $$ReadingSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ReadingSessionsTable,
          ReadingSession,
          $$ReadingSessionsTableFilterComposer,
          $$ReadingSessionsTableOrderingComposer,
          $$ReadingSessionsTableAnnotationComposer,
          $$ReadingSessionsTableCreateCompanionBuilder,
          $$ReadingSessionsTableUpdateCompanionBuilder,
          (
            ReadingSession,
            BaseReferences<_$AppDb, $ReadingSessionsTable, ReadingSession>,
          ),
          ReadingSession,
          PrefetchHooks Function()
        > {
  $$ReadingSessionsTableTableManager(_$AppDb db, $ReadingSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> startPage = const Value.absent(),
                Value<int?> endPage = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<bool> finishedBook = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingSessionsCompanion(
                id: id,
                bookId: bookId,
                startedAt: startedAt,
                endedAt: endedAt,
                startPage: startPage,
                endPage: endPage,
                durationSeconds: durationSeconds,
                finishedBook: finishedBook,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String bookId,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> startPage = const Value.absent(),
                Value<int?> endPage = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<bool> finishedBook = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingSessionsCompanion.insert(
                id: id,
                bookId: bookId,
                startedAt: startedAt,
                endedAt: endedAt,
                startPage: startPage,
                endPage: endPage,
                durationSeconds: durationSeconds,
                finishedBook: finishedBook,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ReadingSessionsTable,
      ReadingSession,
      $$ReadingSessionsTableFilterComposer,
      $$ReadingSessionsTableOrderingComposer,
      $$ReadingSessionsTableAnnotationComposer,
      $$ReadingSessionsTableCreateCompanionBuilder,
      $$ReadingSessionsTableUpdateCompanionBuilder,
      (
        ReadingSession,
        BaseReferences<_$AppDb, $ReadingSessionsTable, ReadingSession>,
      ),
      ReadingSession,
      PrefetchHooks Function()
    >;
typedef $$ReadingGoalsTableCreateCompanionBuilder =
    ReadingGoalsCompanion Function({
      required String id,
      Value<int?> booksPerMonth,
      Value<int?> booksPerYear,
      Value<int> rowid,
    });
typedef $$ReadingGoalsTableUpdateCompanionBuilder =
    ReadingGoalsCompanion Function({
      Value<String> id,
      Value<int?> booksPerMonth,
      Value<int?> booksPerYear,
      Value<int> rowid,
    });

class $$ReadingGoalsTableFilterComposer
    extends Composer<_$AppDb, $ReadingGoalsTable> {
  $$ReadingGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get booksPerMonth => $composableBuilder(
    column: $table.booksPerMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get booksPerYear => $composableBuilder(
    column: $table.booksPerYear,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingGoalsTableOrderingComposer
    extends Composer<_$AppDb, $ReadingGoalsTable> {
  $$ReadingGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get booksPerMonth => $composableBuilder(
    column: $table.booksPerMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get booksPerYear => $composableBuilder(
    column: $table.booksPerYear,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingGoalsTableAnnotationComposer
    extends Composer<_$AppDb, $ReadingGoalsTable> {
  $$ReadingGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get booksPerMonth => $composableBuilder(
    column: $table.booksPerMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get booksPerYear => $composableBuilder(
    column: $table.booksPerYear,
    builder: (column) => column,
  );
}

class $$ReadingGoalsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ReadingGoalsTable,
          ReadingGoalsRow,
          $$ReadingGoalsTableFilterComposer,
          $$ReadingGoalsTableOrderingComposer,
          $$ReadingGoalsTableAnnotationComposer,
          $$ReadingGoalsTableCreateCompanionBuilder,
          $$ReadingGoalsTableUpdateCompanionBuilder,
          (
            ReadingGoalsRow,
            BaseReferences<_$AppDb, $ReadingGoalsTable, ReadingGoalsRow>,
          ),
          ReadingGoalsRow,
          PrefetchHooks Function()
        > {
  $$ReadingGoalsTableTableManager(_$AppDb db, $ReadingGoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int?> booksPerMonth = const Value.absent(),
                Value<int?> booksPerYear = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingGoalsCompanion(
                id: id,
                booksPerMonth: booksPerMonth,
                booksPerYear: booksPerYear,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int?> booksPerMonth = const Value.absent(),
                Value<int?> booksPerYear = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingGoalsCompanion.insert(
                id: id,
                booksPerMonth: booksPerMonth,
                booksPerYear: booksPerYear,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ReadingGoalsTable,
      ReadingGoalsRow,
      $$ReadingGoalsTableFilterComposer,
      $$ReadingGoalsTableOrderingComposer,
      $$ReadingGoalsTableAnnotationComposer,
      $$ReadingGoalsTableCreateCompanionBuilder,
      $$ReadingGoalsTableUpdateCompanionBuilder,
      (
        ReadingGoalsRow,
        BaseReferences<_$AppDb, $ReadingGoalsTable, ReadingGoalsRow>,
      ),
      ReadingGoalsRow,
      PrefetchHooks Function()
    >;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$SeriesTableTableManager get series =>
      $$SeriesTableTableManager(_db, _db.series);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$CopiesTableTableManager get copies =>
      $$CopiesTableTableManager(_db, _db.copies);
  $$ShelvesTableTableManager get shelves =>
      $$ShelvesTableTableManager(_db, _db.shelves);
  $$BookShelfTableTableManager get bookShelf =>
      $$BookShelfTableTableManager(_db, _db.bookShelf);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$UserCopyMetasTableTableManager get userCopyMetas =>
      $$UserCopyMetasTableTableManager(_db, _db.userCopyMetas);
  $$ReadingProgressTableTableManager get readingProgress =>
      $$ReadingProgressTableTableManager(_db, _db.readingProgress);
  $$ReadingSessionsTableTableManager get readingSessions =>
      $$ReadingSessionsTableTableManager(_db, _db.readingSessions);
  $$ReadingGoalsTableTableManager get readingGoals =>
      $$ReadingGoalsTableTableManager(_db, _db.readingGoals);
}
