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

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $SeriesTable series = $SeriesTable(this);
  late final $BooksTable books = $BooksTable(this);
  late final $CopiesTable copies = $CopiesTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $UserCopyMetasTable userCopyMetas = $UserCopyMetasTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    series,
    books,
    copies,
    users,
    userCopyMetas,
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
          PrefetchHooks Function({bool seriesId, bool copiesRefs})
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
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BooksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({seriesId = false, copiesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (copiesRefs) db.copies],
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
                      referencedTable: $$BooksTableReferences._copiesRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$BooksTableReferences(db, table, p0).copiesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.bookId == item.id),
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
      PrefetchHooks Function({bool seriesId, bool copiesRefs})
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

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$SeriesTableTableManager get series =>
      $$SeriesTableTableManager(_db, _db.series);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$CopiesTableTableManager get copies =>
      $$CopiesTableTableManager(_db, _db.copies);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$UserCopyMetasTableTableManager get userCopyMetas =>
      $$UserCopyMetasTableTableManager(_db, _db.userCopyMetas);
}
