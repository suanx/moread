// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BooksTable extends Books with TableInfo<$BooksTable, BookRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('佚名'));
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
      'format', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local'));
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentDirMeta =
      const VerificationMeta('contentDir');
  @override
  late final GeneratedColumn<String> contentDir = GeneratedColumn<String>(
      'content_dir', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _coverPathMeta =
      const VerificationMeta('coverPath');
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
      'cover_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceUriMeta =
      const VerificationMeta('sourceUri');
  @override
  late final GeneratedColumn<String> sourceUri = GeneratedColumn<String>(
      'source_uri', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _publisherMeta =
      const VerificationMeta('publisher');
  @override
  late final GeneratedColumn<String> publisher = GeneratedColumn<String>(
      'publisher', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _totalCharsMeta =
      const VerificationMeta('totalChars');
  @override
  late final GeneratedColumn<int> totalChars = GeneratedColumn<int>(
      'total_chars', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalPagesMeta =
      const VerificationMeta('totalPages');
  @override
  late final GeneratedColumn<int> totalPages = GeneratedColumn<int>(
      'total_pages', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<int> addedAt = GeneratedColumn<int>(
      'added_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastReadAtMeta =
      const VerificationMeta('lastReadAt');
  @override
  late final GeneratedColumn<int> lastReadAt = GeneratedColumn<int>(
      'last_read_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _progressMeta =
      const VerificationMeta('progress');
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
      'progress', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _favoriteMeta =
      const VerificationMeta('favorite');
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
      'favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        author,
        format,
        source,
        localPath,
        contentDir,
        coverPath,
        sourceUri,
        language,
        description,
        publisher,
        totalChars,
        totalPages,
        addedAt,
        lastReadAt,
        progress,
        favorite,
        tags
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(Insertable<BookRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    }
    if (data.containsKey('format')) {
      context.handle(_formatMeta,
          format.isAcceptableOrUnknown(data['format']!, _formatMeta));
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('content_dir')) {
      context.handle(
          _contentDirMeta,
          contentDir.isAcceptableOrUnknown(
              data['content_dir']!, _contentDirMeta));
    }
    if (data.containsKey('cover_path')) {
      context.handle(_coverPathMeta,
          coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta));
    }
    if (data.containsKey('source_uri')) {
      context.handle(_sourceUriMeta,
          sourceUri.isAcceptableOrUnknown(data['source_uri']!, _sourceUriMeta));
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('publisher')) {
      context.handle(_publisherMeta,
          publisher.isAcceptableOrUnknown(data['publisher']!, _publisherMeta));
    }
    if (data.containsKey('total_chars')) {
      context.handle(
          _totalCharsMeta,
          totalChars.isAcceptableOrUnknown(
              data['total_chars']!, _totalCharsMeta));
    }
    if (data.containsKey('total_pages')) {
      context.handle(
          _totalPagesMeta,
          totalPages.isAcceptableOrUnknown(
              data['total_pages']!, _totalPagesMeta));
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('last_read_at')) {
      context.handle(
          _lastReadAtMeta,
          lastReadAt.isAcceptableOrUnknown(
              data['last_read_at']!, _lastReadAtMeta));
    }
    if (data.containsKey('progress')) {
      context.handle(_progressMeta,
          progress.isAcceptableOrUnknown(data['progress']!, _progressMeta));
    }
    if (data.containsKey('favorite')) {
      context.handle(_favoriteMeta,
          favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author'])!,
      format: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}format'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path'])!,
      contentDir: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content_dir']),
      coverPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_path']),
      sourceUri: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_uri']),
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      publisher: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}publisher']),
      totalChars: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_chars'])!,
      totalPages: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_pages'])!,
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}added_at'])!,
      lastReadAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_read_at']),
      progress: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}progress'])!,
      favorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}favorite'])!,
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class BookRow extends DataClass implements Insertable<BookRow> {
  final String id;
  final String title;
  final String author;
  final String format;
  final String source;
  final String localPath;
  final String? contentDir;
  final String? coverPath;
  final String? sourceUri;
  final String? language;
  final String? description;
  final String? publisher;
  final int totalChars;
  final int totalPages;
  final int addedAt;
  final int? lastReadAt;
  final double progress;
  final bool favorite;
  final String tags;
  const BookRow(
      {required this.id,
      required this.title,
      required this.author,
      required this.format,
      required this.source,
      required this.localPath,
      this.contentDir,
      this.coverPath,
      this.sourceUri,
      this.language,
      this.description,
      this.publisher,
      required this.totalChars,
      required this.totalPages,
      required this.addedAt,
      this.lastReadAt,
      required this.progress,
      required this.favorite,
      required this.tags});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['author'] = Variable<String>(author);
    map['format'] = Variable<String>(format);
    map['source'] = Variable<String>(source);
    map['local_path'] = Variable<String>(localPath);
    if (!nullToAbsent || contentDir != null) {
      map['content_dir'] = Variable<String>(contentDir);
    }
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    if (!nullToAbsent || sourceUri != null) {
      map['source_uri'] = Variable<String>(sourceUri);
    }
    if (!nullToAbsent || language != null) {
      map['language'] = Variable<String>(language);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || publisher != null) {
      map['publisher'] = Variable<String>(publisher);
    }
    map['total_chars'] = Variable<int>(totalChars);
    map['total_pages'] = Variable<int>(totalPages);
    map['added_at'] = Variable<int>(addedAt);
    if (!nullToAbsent || lastReadAt != null) {
      map['last_read_at'] = Variable<int>(lastReadAt);
    }
    map['progress'] = Variable<double>(progress);
    map['favorite'] = Variable<bool>(favorite);
    map['tags'] = Variable<String>(tags);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      title: Value(title),
      author: Value(author),
      format: Value(format),
      source: Value(source),
      localPath: Value(localPath),
      contentDir: contentDir == null && nullToAbsent
          ? const Value.absent()
          : Value(contentDir),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
      sourceUri: sourceUri == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUri),
      language: language == null && nullToAbsent
          ? const Value.absent()
          : Value(language),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      publisher: publisher == null && nullToAbsent
          ? const Value.absent()
          : Value(publisher),
      totalChars: Value(totalChars),
      totalPages: Value(totalPages),
      addedAt: Value(addedAt),
      lastReadAt: lastReadAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReadAt),
      progress: Value(progress),
      favorite: Value(favorite),
      tags: Value(tags),
    );
  }

  factory BookRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String>(json['author']),
      format: serializer.fromJson<String>(json['format']),
      source: serializer.fromJson<String>(json['source']),
      localPath: serializer.fromJson<String>(json['localPath']),
      contentDir: serializer.fromJson<String?>(json['contentDir']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
      sourceUri: serializer.fromJson<String?>(json['sourceUri']),
      language: serializer.fromJson<String?>(json['language']),
      description: serializer.fromJson<String?>(json['description']),
      publisher: serializer.fromJson<String?>(json['publisher']),
      totalChars: serializer.fromJson<int>(json['totalChars']),
      totalPages: serializer.fromJson<int>(json['totalPages']),
      addedAt: serializer.fromJson<int>(json['addedAt']),
      lastReadAt: serializer.fromJson<int?>(json['lastReadAt']),
      progress: serializer.fromJson<double>(json['progress']),
      favorite: serializer.fromJson<bool>(json['favorite']),
      tags: serializer.fromJson<String>(json['tags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String>(author),
      'format': serializer.toJson<String>(format),
      'source': serializer.toJson<String>(source),
      'localPath': serializer.toJson<String>(localPath),
      'contentDir': serializer.toJson<String?>(contentDir),
      'coverPath': serializer.toJson<String?>(coverPath),
      'sourceUri': serializer.toJson<String?>(sourceUri),
      'language': serializer.toJson<String?>(language),
      'description': serializer.toJson<String?>(description),
      'publisher': serializer.toJson<String?>(publisher),
      'totalChars': serializer.toJson<int>(totalChars),
      'totalPages': serializer.toJson<int>(totalPages),
      'addedAt': serializer.toJson<int>(addedAt),
      'lastReadAt': serializer.toJson<int?>(lastReadAt),
      'progress': serializer.toJson<double>(progress),
      'favorite': serializer.toJson<bool>(favorite),
      'tags': serializer.toJson<String>(tags),
    };
  }

  BookRow copyWith(
          {String? id,
          String? title,
          String? author,
          String? format,
          String? source,
          String? localPath,
          Value<String?> contentDir = const Value.absent(),
          Value<String?> coverPath = const Value.absent(),
          Value<String?> sourceUri = const Value.absent(),
          Value<String?> language = const Value.absent(),
          Value<String?> description = const Value.absent(),
          Value<String?> publisher = const Value.absent(),
          int? totalChars,
          int? totalPages,
          int? addedAt,
          Value<int?> lastReadAt = const Value.absent(),
          double? progress,
          bool? favorite,
          String? tags}) =>
      BookRow(
        id: id ?? this.id,
        title: title ?? this.title,
        author: author ?? this.author,
        format: format ?? this.format,
        source: source ?? this.source,
        localPath: localPath ?? this.localPath,
        contentDir: contentDir.present ? contentDir.value : this.contentDir,
        coverPath: coverPath.present ? coverPath.value : this.coverPath,
        sourceUri: sourceUri.present ? sourceUri.value : this.sourceUri,
        language: language.present ? language.value : this.language,
        description: description.present ? description.value : this.description,
        publisher: publisher.present ? publisher.value : this.publisher,
        totalChars: totalChars ?? this.totalChars,
        totalPages: totalPages ?? this.totalPages,
        addedAt: addedAt ?? this.addedAt,
        lastReadAt: lastReadAt.present ? lastReadAt.value : this.lastReadAt,
        progress: progress ?? this.progress,
        favorite: favorite ?? this.favorite,
        tags: tags ?? this.tags,
      );
  BookRow copyWithCompanion(BooksCompanion data) {
    return BookRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      format: data.format.present ? data.format.value : this.format,
      source: data.source.present ? data.source.value : this.source,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      contentDir:
          data.contentDir.present ? data.contentDir.value : this.contentDir,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
      sourceUri: data.sourceUri.present ? data.sourceUri.value : this.sourceUri,
      language: data.language.present ? data.language.value : this.language,
      description:
          data.description.present ? data.description.value : this.description,
      publisher: data.publisher.present ? data.publisher.value : this.publisher,
      totalChars:
          data.totalChars.present ? data.totalChars.value : this.totalChars,
      totalPages:
          data.totalPages.present ? data.totalPages.value : this.totalPages,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      lastReadAt:
          data.lastReadAt.present ? data.lastReadAt.value : this.lastReadAt,
      progress: data.progress.present ? data.progress.value : this.progress,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
      tags: data.tags.present ? data.tags.value : this.tags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('format: $format, ')
          ..write('source: $source, ')
          ..write('localPath: $localPath, ')
          ..write('contentDir: $contentDir, ')
          ..write('coverPath: $coverPath, ')
          ..write('sourceUri: $sourceUri, ')
          ..write('language: $language, ')
          ..write('description: $description, ')
          ..write('publisher: $publisher, ')
          ..write('totalChars: $totalChars, ')
          ..write('totalPages: $totalPages, ')
          ..write('addedAt: $addedAt, ')
          ..write('lastReadAt: $lastReadAt, ')
          ..write('progress: $progress, ')
          ..write('favorite: $favorite, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      author,
      format,
      source,
      localPath,
      contentDir,
      coverPath,
      sourceUri,
      language,
      description,
      publisher,
      totalChars,
      totalPages,
      addedAt,
      lastReadAt,
      progress,
      favorite,
      tags);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.author == this.author &&
          other.format == this.format &&
          other.source == this.source &&
          other.localPath == this.localPath &&
          other.contentDir == this.contentDir &&
          other.coverPath == this.coverPath &&
          other.sourceUri == this.sourceUri &&
          other.language == this.language &&
          other.description == this.description &&
          other.publisher == this.publisher &&
          other.totalChars == this.totalChars &&
          other.totalPages == this.totalPages &&
          other.addedAt == this.addedAt &&
          other.lastReadAt == this.lastReadAt &&
          other.progress == this.progress &&
          other.favorite == this.favorite &&
          other.tags == this.tags);
}

class BooksCompanion extends UpdateCompanion<BookRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> author;
  final Value<String> format;
  final Value<String> source;
  final Value<String> localPath;
  final Value<String?> contentDir;
  final Value<String?> coverPath;
  final Value<String?> sourceUri;
  final Value<String?> language;
  final Value<String?> description;
  final Value<String?> publisher;
  final Value<int> totalChars;
  final Value<int> totalPages;
  final Value<int> addedAt;
  final Value<int?> lastReadAt;
  final Value<double> progress;
  final Value<bool> favorite;
  final Value<String> tags;
  final Value<int> rowid;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.format = const Value.absent(),
    this.source = const Value.absent(),
    this.localPath = const Value.absent(),
    this.contentDir = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.sourceUri = const Value.absent(),
    this.language = const Value.absent(),
    this.description = const Value.absent(),
    this.publisher = const Value.absent(),
    this.totalChars = const Value.absent(),
    this.totalPages = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.lastReadAt = const Value.absent(),
    this.progress = const Value.absent(),
    this.favorite = const Value.absent(),
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BooksCompanion.insert({
    required String id,
    required String title,
    this.author = const Value.absent(),
    required String format,
    this.source = const Value.absent(),
    required String localPath,
    this.contentDir = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.sourceUri = const Value.absent(),
    this.language = const Value.absent(),
    this.description = const Value.absent(),
    this.publisher = const Value.absent(),
    this.totalChars = const Value.absent(),
    this.totalPages = const Value.absent(),
    required int addedAt,
    this.lastReadAt = const Value.absent(),
    this.progress = const Value.absent(),
    this.favorite = const Value.absent(),
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        format = Value(format),
        localPath = Value(localPath),
        addedAt = Value(addedAt);
  static Insertable<BookRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? format,
    Expression<String>? source,
    Expression<String>? localPath,
    Expression<String>? contentDir,
    Expression<String>? coverPath,
    Expression<String>? sourceUri,
    Expression<String>? language,
    Expression<String>? description,
    Expression<String>? publisher,
    Expression<int>? totalChars,
    Expression<int>? totalPages,
    Expression<int>? addedAt,
    Expression<int>? lastReadAt,
    Expression<double>? progress,
    Expression<bool>? favorite,
    Expression<String>? tags,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (format != null) 'format': format,
      if (source != null) 'source': source,
      if (localPath != null) 'local_path': localPath,
      if (contentDir != null) 'content_dir': contentDir,
      if (coverPath != null) 'cover_path': coverPath,
      if (sourceUri != null) 'source_uri': sourceUri,
      if (language != null) 'language': language,
      if (description != null) 'description': description,
      if (publisher != null) 'publisher': publisher,
      if (totalChars != null) 'total_chars': totalChars,
      if (totalPages != null) 'total_pages': totalPages,
      if (addedAt != null) 'added_at': addedAt,
      if (lastReadAt != null) 'last_read_at': lastReadAt,
      if (progress != null) 'progress': progress,
      if (favorite != null) 'favorite': favorite,
      if (tags != null) 'tags': tags,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BooksCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? author,
      Value<String>? format,
      Value<String>? source,
      Value<String>? localPath,
      Value<String?>? contentDir,
      Value<String?>? coverPath,
      Value<String?>? sourceUri,
      Value<String?>? language,
      Value<String?>? description,
      Value<String?>? publisher,
      Value<int>? totalChars,
      Value<int>? totalPages,
      Value<int>? addedAt,
      Value<int?>? lastReadAt,
      Value<double>? progress,
      Value<bool>? favorite,
      Value<String>? tags,
      Value<int>? rowid}) {
    return BooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      format: format ?? this.format,
      source: source ?? this.source,
      localPath: localPath ?? this.localPath,
      contentDir: contentDir ?? this.contentDir,
      coverPath: coverPath ?? this.coverPath,
      sourceUri: sourceUri ?? this.sourceUri,
      language: language ?? this.language,
      description: description ?? this.description,
      publisher: publisher ?? this.publisher,
      totalChars: totalChars ?? this.totalChars,
      totalPages: totalPages ?? this.totalPages,
      addedAt: addedAt ?? this.addedAt,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      progress: progress ?? this.progress,
      favorite: favorite ?? this.favorite,
      tags: tags ?? this.tags,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (contentDir.present) {
      map['content_dir'] = Variable<String>(contentDir.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (sourceUri.present) {
      map['source_uri'] = Variable<String>(sourceUri.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (publisher.present) {
      map['publisher'] = Variable<String>(publisher.value);
    }
    if (totalChars.present) {
      map['total_chars'] = Variable<int>(totalChars.value);
    }
    if (totalPages.present) {
      map['total_pages'] = Variable<int>(totalPages.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<int>(addedAt.value);
    }
    if (lastReadAt.present) {
      map['last_read_at'] = Variable<int>(lastReadAt.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
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
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('format: $format, ')
          ..write('source: $source, ')
          ..write('localPath: $localPath, ')
          ..write('contentDir: $contentDir, ')
          ..write('coverPath: $coverPath, ')
          ..write('sourceUri: $sourceUri, ')
          ..write('language: $language, ')
          ..write('description: $description, ')
          ..write('publisher: $publisher, ')
          ..write('totalChars: $totalChars, ')
          ..write('totalPages: $totalPages, ')
          ..write('addedAt: $addedAt, ')
          ..write('lastReadAt: $lastReadAt, ')
          ..write('progress: $progress, ')
          ..write('favorite: $favorite, ')
          ..write('tags: $tags, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChaptersTable extends Chapters
    with TableInfo<$ChaptersTable, ChapterRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES books (id) ON DELETE CASCADE'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idxMeta = const VerificationMeta('idx');
  @override
  late final GeneratedColumn<int> idx = GeneratedColumn<int>(
      'idx', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _hrefMeta = const VerificationMeta('href');
  @override
  late final GeneratedColumn<String> href = GeneratedColumn<String>(
      'href', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contentPathMeta =
      const VerificationMeta('contentPath');
  @override
  late final GeneratedColumn<String> contentPath = GeneratedColumn<String>(
      'content_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startCharMeta =
      const VerificationMeta('startChar');
  @override
  late final GeneratedColumn<int> startChar = GeneratedColumn<int>(
      'start_char', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _endCharMeta =
      const VerificationMeta('endChar');
  @override
  late final GeneratedColumn<int> endChar = GeneratedColumn<int>(
      'end_char', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _pageStartMeta =
      const VerificationMeta('pageStart');
  @override
  late final GeneratedColumn<int> pageStart = GeneratedColumn<int>(
      'page_start', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _pageEndMeta =
      const VerificationMeta('pageEnd');
  @override
  late final GeneratedColumn<int> pageEnd = GeneratedColumn<int>(
      'page_end', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
      'level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookId,
        title,
        idx,
        href,
        contentPath,
        startChar,
        endChar,
        pageStart,
        pageEnd,
        level
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapters';
  @override
  VerificationContext validateIntegrity(Insertable<ChapterRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('idx')) {
      context.handle(
          _idxMeta, idx.isAcceptableOrUnknown(data['idx']!, _idxMeta));
    }
    if (data.containsKey('href')) {
      context.handle(
          _hrefMeta, href.isAcceptableOrUnknown(data['href']!, _hrefMeta));
    }
    if (data.containsKey('content_path')) {
      context.handle(
          _contentPathMeta,
          contentPath.isAcceptableOrUnknown(
              data['content_path']!, _contentPathMeta));
    }
    if (data.containsKey('start_char')) {
      context.handle(_startCharMeta,
          startChar.isAcceptableOrUnknown(data['start_char']!, _startCharMeta));
    }
    if (data.containsKey('end_char')) {
      context.handle(_endCharMeta,
          endChar.isAcceptableOrUnknown(data['end_char']!, _endCharMeta));
    }
    if (data.containsKey('page_start')) {
      context.handle(_pageStartMeta,
          pageStart.isAcceptableOrUnknown(data['page_start']!, _pageStartMeta));
    }
    if (data.containsKey('page_end')) {
      context.handle(_pageEndMeta,
          pageEnd.isAcceptableOrUnknown(data['page_end']!, _pageEndMeta));
    }
    if (data.containsKey('level')) {
      context.handle(
          _levelMeta, level.isAcceptableOrUnknown(data['level']!, _levelMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChapterRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      idx: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}idx'])!,
      href: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}href']),
      contentPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content_path']),
      startChar: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_char'])!,
      endChar: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_char'])!,
      pageStart: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_start']),
      pageEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_end']),
      level: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}level'])!,
    );
  }

  @override
  $ChaptersTable createAlias(String alias) {
    return $ChaptersTable(attachedDatabase, alias);
  }
}

class ChapterRow extends DataClass implements Insertable<ChapterRow> {
  final String id;
  final String bookId;
  final String title;
  final int idx;
  final String? href;
  final String? contentPath;
  final int startChar;
  final int endChar;
  final int? pageStart;
  final int? pageEnd;
  final int level;
  const ChapterRow(
      {required this.id,
      required this.bookId,
      required this.title,
      required this.idx,
      this.href,
      this.contentPath,
      required this.startChar,
      required this.endChar,
      this.pageStart,
      this.pageEnd,
      required this.level});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['title'] = Variable<String>(title);
    map['idx'] = Variable<int>(idx);
    if (!nullToAbsent || href != null) {
      map['href'] = Variable<String>(href);
    }
    if (!nullToAbsent || contentPath != null) {
      map['content_path'] = Variable<String>(contentPath);
    }
    map['start_char'] = Variable<int>(startChar);
    map['end_char'] = Variable<int>(endChar);
    if (!nullToAbsent || pageStart != null) {
      map['page_start'] = Variable<int>(pageStart);
    }
    if (!nullToAbsent || pageEnd != null) {
      map['page_end'] = Variable<int>(pageEnd);
    }
    map['level'] = Variable<int>(level);
    return map;
  }

  ChaptersCompanion toCompanion(bool nullToAbsent) {
    return ChaptersCompanion(
      id: Value(id),
      bookId: Value(bookId),
      title: Value(title),
      idx: Value(idx),
      href: href == null && nullToAbsent ? const Value.absent() : Value(href),
      contentPath: contentPath == null && nullToAbsent
          ? const Value.absent()
          : Value(contentPath),
      startChar: Value(startChar),
      endChar: Value(endChar),
      pageStart: pageStart == null && nullToAbsent
          ? const Value.absent()
          : Value(pageStart),
      pageEnd: pageEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(pageEnd),
      level: Value(level),
    );
  }

  factory ChapterRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterRow(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      title: serializer.fromJson<String>(json['title']),
      idx: serializer.fromJson<int>(json['idx']),
      href: serializer.fromJson<String?>(json['href']),
      contentPath: serializer.fromJson<String?>(json['contentPath']),
      startChar: serializer.fromJson<int>(json['startChar']),
      endChar: serializer.fromJson<int>(json['endChar']),
      pageStart: serializer.fromJson<int?>(json['pageStart']),
      pageEnd: serializer.fromJson<int?>(json['pageEnd']),
      level: serializer.fromJson<int>(json['level']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'title': serializer.toJson<String>(title),
      'idx': serializer.toJson<int>(idx),
      'href': serializer.toJson<String?>(href),
      'contentPath': serializer.toJson<String?>(contentPath),
      'startChar': serializer.toJson<int>(startChar),
      'endChar': serializer.toJson<int>(endChar),
      'pageStart': serializer.toJson<int?>(pageStart),
      'pageEnd': serializer.toJson<int?>(pageEnd),
      'level': serializer.toJson<int>(level),
    };
  }

  ChapterRow copyWith(
          {String? id,
          String? bookId,
          String? title,
          int? idx,
          Value<String?> href = const Value.absent(),
          Value<String?> contentPath = const Value.absent(),
          int? startChar,
          int? endChar,
          Value<int?> pageStart = const Value.absent(),
          Value<int?> pageEnd = const Value.absent(),
          int? level}) =>
      ChapterRow(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        title: title ?? this.title,
        idx: idx ?? this.idx,
        href: href.present ? href.value : this.href,
        contentPath: contentPath.present ? contentPath.value : this.contentPath,
        startChar: startChar ?? this.startChar,
        endChar: endChar ?? this.endChar,
        pageStart: pageStart.present ? pageStart.value : this.pageStart,
        pageEnd: pageEnd.present ? pageEnd.value : this.pageEnd,
        level: level ?? this.level,
      );
  ChapterRow copyWithCompanion(ChaptersCompanion data) {
    return ChapterRow(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      title: data.title.present ? data.title.value : this.title,
      idx: data.idx.present ? data.idx.value : this.idx,
      href: data.href.present ? data.href.value : this.href,
      contentPath:
          data.contentPath.present ? data.contentPath.value : this.contentPath,
      startChar: data.startChar.present ? data.startChar.value : this.startChar,
      endChar: data.endChar.present ? data.endChar.value : this.endChar,
      pageStart: data.pageStart.present ? data.pageStart.value : this.pageStart,
      pageEnd: data.pageEnd.present ? data.pageEnd.value : this.pageEnd,
      level: data.level.present ? data.level.value : this.level,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapterRow(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('title: $title, ')
          ..write('idx: $idx, ')
          ..write('href: $href, ')
          ..write('contentPath: $contentPath, ')
          ..write('startChar: $startChar, ')
          ..write('endChar: $endChar, ')
          ..write('pageStart: $pageStart, ')
          ..write('pageEnd: $pageEnd, ')
          ..write('level: $level')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, title, idx, href, contentPath,
      startChar, endChar, pageStart, pageEnd, level);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapterRow &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.title == this.title &&
          other.idx == this.idx &&
          other.href == this.href &&
          other.contentPath == this.contentPath &&
          other.startChar == this.startChar &&
          other.endChar == this.endChar &&
          other.pageStart == this.pageStart &&
          other.pageEnd == this.pageEnd &&
          other.level == this.level);
}

class ChaptersCompanion extends UpdateCompanion<ChapterRow> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<String> title;
  final Value<int> idx;
  final Value<String?> href;
  final Value<String?> contentPath;
  final Value<int> startChar;
  final Value<int> endChar;
  final Value<int?> pageStart;
  final Value<int?> pageEnd;
  final Value<int> level;
  final Value<int> rowid;
  const ChaptersCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.title = const Value.absent(),
    this.idx = const Value.absent(),
    this.href = const Value.absent(),
    this.contentPath = const Value.absent(),
    this.startChar = const Value.absent(),
    this.endChar = const Value.absent(),
    this.pageStart = const Value.absent(),
    this.pageEnd = const Value.absent(),
    this.level = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChaptersCompanion.insert({
    required String id,
    required String bookId,
    required String title,
    this.idx = const Value.absent(),
    this.href = const Value.absent(),
    this.contentPath = const Value.absent(),
    this.startChar = const Value.absent(),
    this.endChar = const Value.absent(),
    this.pageStart = const Value.absent(),
    this.pageEnd = const Value.absent(),
    this.level = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        bookId = Value(bookId),
        title = Value(title);
  static Insertable<ChapterRow> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<String>? title,
    Expression<int>? idx,
    Expression<String>? href,
    Expression<String>? contentPath,
    Expression<int>? startChar,
    Expression<int>? endChar,
    Expression<int>? pageStart,
    Expression<int>? pageEnd,
    Expression<int>? level,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (title != null) 'title': title,
      if (idx != null) 'idx': idx,
      if (href != null) 'href': href,
      if (contentPath != null) 'content_path': contentPath,
      if (startChar != null) 'start_char': startChar,
      if (endChar != null) 'end_char': endChar,
      if (pageStart != null) 'page_start': pageStart,
      if (pageEnd != null) 'page_end': pageEnd,
      if (level != null) 'level': level,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChaptersCompanion copyWith(
      {Value<String>? id,
      Value<String>? bookId,
      Value<String>? title,
      Value<int>? idx,
      Value<String?>? href,
      Value<String?>? contentPath,
      Value<int>? startChar,
      Value<int>? endChar,
      Value<int?>? pageStart,
      Value<int?>? pageEnd,
      Value<int>? level,
      Value<int>? rowid}) {
    return ChaptersCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      idx: idx ?? this.idx,
      href: href ?? this.href,
      contentPath: contentPath ?? this.contentPath,
      startChar: startChar ?? this.startChar,
      endChar: endChar ?? this.endChar,
      pageStart: pageStart ?? this.pageStart,
      pageEnd: pageEnd ?? this.pageEnd,
      level: level ?? this.level,
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
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (idx.present) {
      map['idx'] = Variable<int>(idx.value);
    }
    if (href.present) {
      map['href'] = Variable<String>(href.value);
    }
    if (contentPath.present) {
      map['content_path'] = Variable<String>(contentPath.value);
    }
    if (startChar.present) {
      map['start_char'] = Variable<int>(startChar.value);
    }
    if (endChar.present) {
      map['end_char'] = Variable<int>(endChar.value);
    }
    if (pageStart.present) {
      map['page_start'] = Variable<int>(pageStart.value);
    }
    if (pageEnd.present) {
      map['page_end'] = Variable<int>(pageEnd.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChaptersCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('title: $title, ')
          ..write('idx: $idx, ')
          ..write('href: $href, ')
          ..write('contentPath: $contentPath, ')
          ..write('startChar: $startChar, ')
          ..write('endChar: $endChar, ')
          ..write('pageStart: $pageStart, ')
          ..write('pageEnd: $pageEnd, ')
          ..write('level: $level, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingProgressesTable extends ReadingProgresses
    with TableInfo<$ReadingProgressesTable, ReadingProgressRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingProgressesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES books (id) ON DELETE CASCADE'));
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
      'chapter_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterIndexMeta =
      const VerificationMeta('chapterIndex');
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
      'chapter_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _chapterRatioMeta =
      const VerificationMeta('chapterRatio');
  @override
  late final GeneratedColumn<double> chapterRatio = GeneratedColumn<double>(
      'chapter_ratio', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _bookRatioMeta =
      const VerificationMeta('bookRatio');
  @override
  late final GeneratedColumn<double> bookRatio = GeneratedColumn<double>(
      'book_ratio', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
      'page', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        bookId,
        chapterId,
        chapterIndex,
        chapterRatio,
        bookRatio,
        position,
        page,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_progresses';
  @override
  VerificationContext validateIntegrity(Insertable<ReadingProgressRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
          _chapterIndexMeta,
          chapterIndex.isAcceptableOrUnknown(
              data['chapter_index']!, _chapterIndexMeta));
    }
    if (data.containsKey('chapter_ratio')) {
      context.handle(
          _chapterRatioMeta,
          chapterRatio.isAcceptableOrUnknown(
              data['chapter_ratio']!, _chapterRatioMeta));
    }
    if (data.containsKey('book_ratio')) {
      context.handle(_bookRatioMeta,
          bookRatio.isAcceptableOrUnknown(data['book_ratio']!, _bookRatioMeta));
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    }
    if (data.containsKey('page')) {
      context.handle(
          _pageMeta, page.isAcceptableOrUnknown(data['page']!, _pageMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId};
  @override
  ReadingProgressRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingProgressRow(
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_id'])!,
      chapterIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_index'])!,
      chapterRatio: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}chapter_ratio'])!,
      bookRatio: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}book_ratio'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      page: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ReadingProgressesTable createAlias(String alias) {
    return $ReadingProgressesTable(attachedDatabase, alias);
  }
}

class ReadingProgressRow extends DataClass
    implements Insertable<ReadingProgressRow> {
  final String bookId;
  final String chapterId;
  final int chapterIndex;
  final double chapterRatio;
  final double bookRatio;
  final int position;
  final int page;
  final int updatedAt;
  const ReadingProgressRow(
      {required this.bookId,
      required this.chapterId,
      required this.chapterIndex,
      required this.chapterRatio,
      required this.bookRatio,
      required this.position,
      required this.page,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    map['chapter_id'] = Variable<String>(chapterId);
    map['chapter_index'] = Variable<int>(chapterIndex);
    map['chapter_ratio'] = Variable<double>(chapterRatio);
    map['book_ratio'] = Variable<double>(bookRatio);
    map['position'] = Variable<int>(position);
    map['page'] = Variable<int>(page);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ReadingProgressesCompanion toCompanion(bool nullToAbsent) {
    return ReadingProgressesCompanion(
      bookId: Value(bookId),
      chapterId: Value(chapterId),
      chapterIndex: Value(chapterIndex),
      chapterRatio: Value(chapterRatio),
      bookRatio: Value(bookRatio),
      position: Value(position),
      page: Value(page),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReadingProgressRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingProgressRow(
      bookId: serializer.fromJson<String>(json['bookId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
      chapterRatio: serializer.fromJson<double>(json['chapterRatio']),
      bookRatio: serializer.fromJson<double>(json['bookRatio']),
      position: serializer.fromJson<int>(json['position']),
      page: serializer.fromJson<int>(json['page']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'chapterId': serializer.toJson<String>(chapterId),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
      'chapterRatio': serializer.toJson<double>(chapterRatio),
      'bookRatio': serializer.toJson<double>(bookRatio),
      'position': serializer.toJson<int>(position),
      'page': serializer.toJson<int>(page),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  ReadingProgressRow copyWith(
          {String? bookId,
          String? chapterId,
          int? chapterIndex,
          double? chapterRatio,
          double? bookRatio,
          int? position,
          int? page,
          int? updatedAt}) =>
      ReadingProgressRow(
        bookId: bookId ?? this.bookId,
        chapterId: chapterId ?? this.chapterId,
        chapterIndex: chapterIndex ?? this.chapterIndex,
        chapterRatio: chapterRatio ?? this.chapterRatio,
        bookRatio: bookRatio ?? this.bookRatio,
        position: position ?? this.position,
        page: page ?? this.page,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ReadingProgressRow copyWithCompanion(ReadingProgressesCompanion data) {
    return ReadingProgressRow(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      chapterRatio: data.chapterRatio.present
          ? data.chapterRatio.value
          : this.chapterRatio,
      bookRatio: data.bookRatio.present ? data.bookRatio.value : this.bookRatio,
      position: data.position.present ? data.position.value : this.position,
      page: data.page.present ? data.page.value : this.page,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressRow(')
          ..write('bookId: $bookId, ')
          ..write('chapterId: $chapterId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('chapterRatio: $chapterRatio, ')
          ..write('bookRatio: $bookRatio, ')
          ..write('position: $position, ')
          ..write('page: $page, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, chapterId, chapterIndex, chapterRatio,
      bookRatio, position, page, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingProgressRow &&
          other.bookId == this.bookId &&
          other.chapterId == this.chapterId &&
          other.chapterIndex == this.chapterIndex &&
          other.chapterRatio == this.chapterRatio &&
          other.bookRatio == this.bookRatio &&
          other.position == this.position &&
          other.page == this.page &&
          other.updatedAt == this.updatedAt);
}

class ReadingProgressesCompanion extends UpdateCompanion<ReadingProgressRow> {
  final Value<String> bookId;
  final Value<String> chapterId;
  final Value<int> chapterIndex;
  final Value<double> chapterRatio;
  final Value<double> bookRatio;
  final Value<int> position;
  final Value<int> page;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const ReadingProgressesCompanion({
    this.bookId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.chapterRatio = const Value.absent(),
    this.bookRatio = const Value.absent(),
    this.position = const Value.absent(),
    this.page = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingProgressesCompanion.insert({
    required String bookId,
    required String chapterId,
    this.chapterIndex = const Value.absent(),
    this.chapterRatio = const Value.absent(),
    this.bookRatio = const Value.absent(),
    this.position = const Value.absent(),
    this.page = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : bookId = Value(bookId),
        chapterId = Value(chapterId),
        updatedAt = Value(updatedAt);
  static Insertable<ReadingProgressRow> custom({
    Expression<String>? bookId,
    Expression<String>? chapterId,
    Expression<int>? chapterIndex,
    Expression<double>? chapterRatio,
    Expression<double>? bookRatio,
    Expression<int>? position,
    Expression<int>? page,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (chapterRatio != null) 'chapter_ratio': chapterRatio,
      if (bookRatio != null) 'book_ratio': bookRatio,
      if (position != null) 'position': position,
      if (page != null) 'page': page,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingProgressesCompanion copyWith(
      {Value<String>? bookId,
      Value<String>? chapterId,
      Value<int>? chapterIndex,
      Value<double>? chapterRatio,
      Value<double>? bookRatio,
      Value<int>? position,
      Value<int>? page,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return ReadingProgressesCompanion(
      bookId: bookId ?? this.bookId,
      chapterId: chapterId ?? this.chapterId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      chapterRatio: chapterRatio ?? this.chapterRatio,
      bookRatio: bookRatio ?? this.bookRatio,
      position: position ?? this.position,
      page: page ?? this.page,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (chapterRatio.present) {
      map['chapter_ratio'] = Variable<double>(chapterRatio.value);
    }
    if (bookRatio.present) {
      map['book_ratio'] = Variable<double>(bookRatio.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressesCompanion(')
          ..write('bookId: $bookId, ')
          ..write('chapterId: $chapterId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('chapterRatio: $chapterRatio, ')
          ..write('bookRatio: $bookRatio, ')
          ..write('position: $position, ')
          ..write('page: $page, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, BookmarkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES books (id) ON DELETE CASCADE'));
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
      'chapter_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterTitleMeta =
      const VerificationMeta('chapterTitle');
  @override
  late final GeneratedColumn<String> chapterTitle = GeneratedColumn<String>(
      'chapter_title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _chapterRatioMeta =
      const VerificationMeta('chapterRatio');
  @override
  late final GeneratedColumn<double> chapterRatio = GeneratedColumn<double>(
      'chapter_ratio', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _excerptMeta =
      const VerificationMeta('excerpt');
  @override
  late final GeneratedColumn<String> excerpt = GeneratedColumn<String>(
      'excerpt', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookId,
        chapterId,
        chapterTitle,
        position,
        chapterRatio,
        excerpt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(Insertable<BookmarkRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('chapter_title')) {
      context.handle(
          _chapterTitleMeta,
          chapterTitle.isAcceptableOrUnknown(
              data['chapter_title']!, _chapterTitleMeta));
    } else if (isInserting) {
      context.missing(_chapterTitleMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    }
    if (data.containsKey('chapter_ratio')) {
      context.handle(
          _chapterRatioMeta,
          chapterRatio.isAcceptableOrUnknown(
              data['chapter_ratio']!, _chapterRatioMeta));
    }
    if (data.containsKey('excerpt')) {
      context.handle(_excerptMeta,
          excerpt.isAcceptableOrUnknown(data['excerpt']!, _excerptMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookmarkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_id'])!,
      chapterTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_title'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      chapterRatio: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}chapter_ratio'])!,
      excerpt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}excerpt'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class BookmarkRow extends DataClass implements Insertable<BookmarkRow> {
  final String id;
  final String bookId;
  final String chapterId;
  final String chapterTitle;
  final int position;
  final double chapterRatio;
  final String excerpt;
  final int createdAt;
  const BookmarkRow(
      {required this.id,
      required this.bookId,
      required this.chapterId,
      required this.chapterTitle,
      required this.position,
      required this.chapterRatio,
      required this.excerpt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['chapter_id'] = Variable<String>(chapterId);
    map['chapter_title'] = Variable<String>(chapterTitle);
    map['position'] = Variable<int>(position);
    map['chapter_ratio'] = Variable<double>(chapterRatio);
    map['excerpt'] = Variable<String>(excerpt);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      id: Value(id),
      bookId: Value(bookId),
      chapterId: Value(chapterId),
      chapterTitle: Value(chapterTitle),
      position: Value(position),
      chapterRatio: Value(chapterRatio),
      excerpt: Value(excerpt),
      createdAt: Value(createdAt),
    );
  }

  factory BookmarkRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkRow(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      chapterTitle: serializer.fromJson<String>(json['chapterTitle']),
      position: serializer.fromJson<int>(json['position']),
      chapterRatio: serializer.fromJson<double>(json['chapterRatio']),
      excerpt: serializer.fromJson<String>(json['excerpt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'chapterId': serializer.toJson<String>(chapterId),
      'chapterTitle': serializer.toJson<String>(chapterTitle),
      'position': serializer.toJson<int>(position),
      'chapterRatio': serializer.toJson<double>(chapterRatio),
      'excerpt': serializer.toJson<String>(excerpt),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  BookmarkRow copyWith(
          {String? id,
          String? bookId,
          String? chapterId,
          String? chapterTitle,
          int? position,
          double? chapterRatio,
          String? excerpt,
          int? createdAt}) =>
      BookmarkRow(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        chapterId: chapterId ?? this.chapterId,
        chapterTitle: chapterTitle ?? this.chapterTitle,
        position: position ?? this.position,
        chapterRatio: chapterRatio ?? this.chapterRatio,
        excerpt: excerpt ?? this.excerpt,
        createdAt: createdAt ?? this.createdAt,
      );
  BookmarkRow copyWithCompanion(BookmarksCompanion data) {
    return BookmarkRow(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      chapterTitle: data.chapterTitle.present
          ? data.chapterTitle.value
          : this.chapterTitle,
      position: data.position.present ? data.position.value : this.position,
      chapterRatio: data.chapterRatio.present
          ? data.chapterRatio.value
          : this.chapterRatio,
      excerpt: data.excerpt.present ? data.excerpt.value : this.excerpt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkRow(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterId: $chapterId, ')
          ..write('chapterTitle: $chapterTitle, ')
          ..write('position: $position, ')
          ..write('chapterRatio: $chapterRatio, ')
          ..write('excerpt: $excerpt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, chapterId, chapterTitle, position,
      chapterRatio, excerpt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkRow &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.chapterId == this.chapterId &&
          other.chapterTitle == this.chapterTitle &&
          other.position == this.position &&
          other.chapterRatio == this.chapterRatio &&
          other.excerpt == this.excerpt &&
          other.createdAt == this.createdAt);
}

class BookmarksCompanion extends UpdateCompanion<BookmarkRow> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<String> chapterId;
  final Value<String> chapterTitle;
  final Value<int> position;
  final Value<double> chapterRatio;
  final Value<String> excerpt;
  final Value<int> createdAt;
  final Value<int> rowid;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.chapterTitle = const Value.absent(),
    this.position = const Value.absent(),
    this.chapterRatio = const Value.absent(),
    this.excerpt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarksCompanion.insert({
    required String id,
    required String bookId,
    required String chapterId,
    required String chapterTitle,
    this.position = const Value.absent(),
    this.chapterRatio = const Value.absent(),
    this.excerpt = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        bookId = Value(bookId),
        chapterId = Value(chapterId),
        chapterTitle = Value(chapterTitle),
        createdAt = Value(createdAt);
  static Insertable<BookmarkRow> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<String>? chapterId,
    Expression<String>? chapterTitle,
    Expression<int>? position,
    Expression<double>? chapterRatio,
    Expression<String>? excerpt,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (chapterTitle != null) 'chapter_title': chapterTitle,
      if (position != null) 'position': position,
      if (chapterRatio != null) 'chapter_ratio': chapterRatio,
      if (excerpt != null) 'excerpt': excerpt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarksCompanion copyWith(
      {Value<String>? id,
      Value<String>? bookId,
      Value<String>? chapterId,
      Value<String>? chapterTitle,
      Value<int>? position,
      Value<double>? chapterRatio,
      Value<String>? excerpt,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return BookmarksCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterId: chapterId ?? this.chapterId,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      position: position ?? this.position,
      chapterRatio: chapterRatio ?? this.chapterRatio,
      excerpt: excerpt ?? this.excerpt,
      createdAt: createdAt ?? this.createdAt,
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
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (chapterTitle.present) {
      map['chapter_title'] = Variable<String>(chapterTitle.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (chapterRatio.present) {
      map['chapter_ratio'] = Variable<double>(chapterRatio.value);
    }
    if (excerpt.present) {
      map['excerpt'] = Variable<String>(excerpt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterId: $chapterId, ')
          ..write('chapterTitle: $chapterTitle, ')
          ..write('position: $position, ')
          ..write('chapterRatio: $chapterRatio, ')
          ..write('excerpt: $excerpt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, NoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES books (id) ON DELETE CASCADE'));
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
      'chapter_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterTitleMeta =
      const VerificationMeta('chapterTitle');
  @override
  late final GeneratedColumn<String> chapterTitle = GeneratedColumn<String>(
      'chapter_title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quoteMeta = const VerificationMeta('quote');
  @override
  late final GeneratedColumn<String> quote = GeneratedColumn<String>(
      'quote', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _startPosMeta =
      const VerificationMeta('startPos');
  @override
  late final GeneratedColumn<int> startPos = GeneratedColumn<int>(
      'start_pos', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _endPosMeta = const VerificationMeta('endPos');
  @override
  late final GeneratedColumn<int> endPos = GeneratedColumn<int>(
      'end_pos', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0xFFE8A33D));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookId,
        chapterId,
        chapterTitle,
        quote,
        content,
        startPos,
        endPos,
        color,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(Insertable<NoteRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('chapter_title')) {
      context.handle(
          _chapterTitleMeta,
          chapterTitle.isAcceptableOrUnknown(
              data['chapter_title']!, _chapterTitleMeta));
    } else if (isInserting) {
      context.missing(_chapterTitleMeta);
    }
    if (data.containsKey('quote')) {
      context.handle(
          _quoteMeta, quote.isAcceptableOrUnknown(data['quote']!, _quoteMeta));
    } else if (isInserting) {
      context.missing(_quoteMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    if (data.containsKey('start_pos')) {
      context.handle(_startPosMeta,
          startPos.isAcceptableOrUnknown(data['start_pos']!, _startPosMeta));
    }
    if (data.containsKey('end_pos')) {
      context.handle(_endPosMeta,
          endPos.isAcceptableOrUnknown(data['end_pos']!, _endPosMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_id'])!,
      chapterTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_title'])!,
      quote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quote'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      startPos: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_pos'])!,
      endPos: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_pos'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class NoteRow extends DataClass implements Insertable<NoteRow> {
  final String id;
  final String bookId;
  final String chapterId;
  final String chapterTitle;
  final String quote;
  final String content;
  final int startPos;
  final int endPos;
  final int color;
  final int createdAt;
  final int updatedAt;
  const NoteRow(
      {required this.id,
      required this.bookId,
      required this.chapterId,
      required this.chapterTitle,
      required this.quote,
      required this.content,
      required this.startPos,
      required this.endPos,
      required this.color,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['chapter_id'] = Variable<String>(chapterId);
    map['chapter_title'] = Variable<String>(chapterTitle);
    map['quote'] = Variable<String>(quote);
    map['content'] = Variable<String>(content);
    map['start_pos'] = Variable<int>(startPos);
    map['end_pos'] = Variable<int>(endPos);
    map['color'] = Variable<int>(color);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      bookId: Value(bookId),
      chapterId: Value(chapterId),
      chapterTitle: Value(chapterTitle),
      quote: Value(quote),
      content: Value(content),
      startPos: Value(startPos),
      endPos: Value(endPos),
      color: Value(color),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory NoteRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteRow(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      chapterTitle: serializer.fromJson<String>(json['chapterTitle']),
      quote: serializer.fromJson<String>(json['quote']),
      content: serializer.fromJson<String>(json['content']),
      startPos: serializer.fromJson<int>(json['startPos']),
      endPos: serializer.fromJson<int>(json['endPos']),
      color: serializer.fromJson<int>(json['color']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'chapterId': serializer.toJson<String>(chapterId),
      'chapterTitle': serializer.toJson<String>(chapterTitle),
      'quote': serializer.toJson<String>(quote),
      'content': serializer.toJson<String>(content),
      'startPos': serializer.toJson<int>(startPos),
      'endPos': serializer.toJson<int>(endPos),
      'color': serializer.toJson<int>(color),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  NoteRow copyWith(
          {String? id,
          String? bookId,
          String? chapterId,
          String? chapterTitle,
          String? quote,
          String? content,
          int? startPos,
          int? endPos,
          int? color,
          int? createdAt,
          int? updatedAt}) =>
      NoteRow(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        chapterId: chapterId ?? this.chapterId,
        chapterTitle: chapterTitle ?? this.chapterTitle,
        quote: quote ?? this.quote,
        content: content ?? this.content,
        startPos: startPos ?? this.startPos,
        endPos: endPos ?? this.endPos,
        color: color ?? this.color,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  NoteRow copyWithCompanion(NotesCompanion data) {
    return NoteRow(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      chapterTitle: data.chapterTitle.present
          ? data.chapterTitle.value
          : this.chapterTitle,
      quote: data.quote.present ? data.quote.value : this.quote,
      content: data.content.present ? data.content.value : this.content,
      startPos: data.startPos.present ? data.startPos.value : this.startPos,
      endPos: data.endPos.present ? data.endPos.value : this.endPos,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteRow(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterId: $chapterId, ')
          ..write('chapterTitle: $chapterTitle, ')
          ..write('quote: $quote, ')
          ..write('content: $content, ')
          ..write('startPos: $startPos, ')
          ..write('endPos: $endPos, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, chapterId, chapterTitle, quote,
      content, startPos, endPos, color, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteRow &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.chapterId == this.chapterId &&
          other.chapterTitle == this.chapterTitle &&
          other.quote == this.quote &&
          other.content == this.content &&
          other.startPos == this.startPos &&
          other.endPos == this.endPos &&
          other.color == this.color &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NotesCompanion extends UpdateCompanion<NoteRow> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<String> chapterId;
  final Value<String> chapterTitle;
  final Value<String> quote;
  final Value<String> content;
  final Value<int> startPos;
  final Value<int> endPos;
  final Value<int> color;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.chapterTitle = const Value.absent(),
    this.quote = const Value.absent(),
    this.content = const Value.absent(),
    this.startPos = const Value.absent(),
    this.endPos = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    required String id,
    required String bookId,
    required String chapterId,
    required String chapterTitle,
    required String quote,
    this.content = const Value.absent(),
    this.startPos = const Value.absent(),
    this.endPos = const Value.absent(),
    this.color = const Value.absent(),
    required int createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        bookId = Value(bookId),
        chapterId = Value(chapterId),
        chapterTitle = Value(chapterTitle),
        quote = Value(quote),
        createdAt = Value(createdAt);
  static Insertable<NoteRow> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<String>? chapterId,
    Expression<String>? chapterTitle,
    Expression<String>? quote,
    Expression<String>? content,
    Expression<int>? startPos,
    Expression<int>? endPos,
    Expression<int>? color,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (chapterTitle != null) 'chapter_title': chapterTitle,
      if (quote != null) 'quote': quote,
      if (content != null) 'content': content,
      if (startPos != null) 'start_pos': startPos,
      if (endPos != null) 'end_pos': endPos,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith(
      {Value<String>? id,
      Value<String>? bookId,
      Value<String>? chapterId,
      Value<String>? chapterTitle,
      Value<String>? quote,
      Value<String>? content,
      Value<int>? startPos,
      Value<int>? endPos,
      Value<int>? color,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return NotesCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterId: chapterId ?? this.chapterId,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      quote: quote ?? this.quote,
      content: content ?? this.content,
      startPos: startPos ?? this.startPos,
      endPos: endPos ?? this.endPos,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
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
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (chapterTitle.present) {
      map['chapter_title'] = Variable<String>(chapterTitle.value);
    }
    if (quote.present) {
      map['quote'] = Variable<String>(quote.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (startPos.present) {
      map['start_pos'] = Variable<int>(startPos.value);
    }
    if (endPos.present) {
      map['end_pos'] = Variable<int>(endPos.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterId: $chapterId, ')
          ..write('chapterTitle: $chapterTitle, ')
          ..write('quote: $quote, ')
          ..write('content: $content, ')
          ..write('startPos: $startPos, ')
          ..write('endPos: $endPos, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingSessionsTable extends ReadingSessions
    with TableInfo<$ReadingSessionsTable, ReadingSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES books (id) ON DELETE CASCADE'));
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
      'started_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endedAtMeta =
      const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<int> endedAt = GeneratedColumn<int>(
      'ended_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _charsReadMeta =
      const VerificationMeta('charsRead');
  @override
  late final GeneratedColumn<int> charsRead = GeneratedColumn<int>(
      'chars_read', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
      'mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('read'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, bookId, startedAt, endedAt, durationSeconds, charsRead, mode];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<ReadingSessionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta,
          endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    }
    if (data.containsKey('chars_read')) {
      context.handle(_charsReadMeta,
          charsRead.isAcceptableOrUnknown(data['chars_read']!, _charsReadMeta));
    }
    if (data.containsKey('mode')) {
      context.handle(
          _modeMeta, mode.isAcceptableOrUnknown(data['mode']!, _modeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingSessionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}started_at'])!,
      endedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ended_at']),
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
      charsRead: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chars_read'])!,
      mode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mode'])!,
    );
  }

  @override
  $ReadingSessionsTable createAlias(String alias) {
    return $ReadingSessionsTable(attachedDatabase, alias);
  }
}

class ReadingSessionRow extends DataClass
    implements Insertable<ReadingSessionRow> {
  final String id;
  final String bookId;
  final int startedAt;
  final int? endedAt;
  final int durationSeconds;
  final int charsRead;
  final String mode;
  const ReadingSessionRow(
      {required this.id,
      required this.bookId,
      required this.startedAt,
      this.endedAt,
      required this.durationSeconds,
      required this.charsRead,
      required this.mode});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<int>(endedAt);
    }
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['chars_read'] = Variable<int>(charsRead);
    map['mode'] = Variable<String>(mode);
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
      durationSeconds: Value(durationSeconds),
      charsRead: Value(charsRead),
      mode: Value(mode),
    );
  }

  factory ReadingSessionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingSessionRow(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      endedAt: serializer.fromJson<int?>(json['endedAt']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      charsRead: serializer.fromJson<int>(json['charsRead']),
      mode: serializer.fromJson<String>(json['mode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'startedAt': serializer.toJson<int>(startedAt),
      'endedAt': serializer.toJson<int?>(endedAt),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'charsRead': serializer.toJson<int>(charsRead),
      'mode': serializer.toJson<String>(mode),
    };
  }

  ReadingSessionRow copyWith(
          {String? id,
          String? bookId,
          int? startedAt,
          Value<int?> endedAt = const Value.absent(),
          int? durationSeconds,
          int? charsRead,
          String? mode}) =>
      ReadingSessionRow(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt.present ? endedAt.value : this.endedAt,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        charsRead: charsRead ?? this.charsRead,
        mode: mode ?? this.mode,
      );
  ReadingSessionRow copyWithCompanion(ReadingSessionsCompanion data) {
    return ReadingSessionRow(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      charsRead: data.charsRead.present ? data.charsRead.value : this.charsRead,
      mode: data.mode.present ? data.mode.value : this.mode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSessionRow(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('charsRead: $charsRead, ')
          ..write('mode: $mode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, bookId, startedAt, endedAt, durationSeconds, charsRead, mode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingSessionRow &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.charsRead == this.charsRead &&
          other.mode == this.mode);
}

class ReadingSessionsCompanion extends UpdateCompanion<ReadingSessionRow> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<int> startedAt;
  final Value<int?> endedAt;
  final Value<int> durationSeconds;
  final Value<int> charsRead;
  final Value<String> mode;
  final Value<int> rowid;
  const ReadingSessionsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.charsRead = const Value.absent(),
    this.mode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingSessionsCompanion.insert({
    required String id,
    required String bookId,
    required int startedAt,
    this.endedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.charsRead = const Value.absent(),
    this.mode = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        bookId = Value(bookId),
        startedAt = Value(startedAt);
  static Insertable<ReadingSessionRow> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<int>? startedAt,
    Expression<int>? endedAt,
    Expression<int>? durationSeconds,
    Expression<int>? charsRead,
    Expression<String>? mode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (charsRead != null) 'chars_read': charsRead,
      if (mode != null) 'mode': mode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingSessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? bookId,
      Value<int>? startedAt,
      Value<int?>? endedAt,
      Value<int>? durationSeconds,
      Value<int>? charsRead,
      Value<String>? mode,
      Value<int>? rowid}) {
    return ReadingSessionsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      charsRead: charsRead ?? this.charsRead,
      mode: mode ?? this.mode,
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
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(endedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (charsRead.present) {
      map['chars_read'] = Variable<int>(charsRead.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
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
          ..write('durationSeconds: $durationSeconds, ')
          ..write('charsRead: $charsRead, ')
          ..write('mode: $mode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadsTable extends Downloads
    with TableInfo<$DownloadsTable, DownloadRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _savePathMeta =
      const VerificationMeta('savePath');
  @override
  late final GeneratedColumn<String> savePath = GeneratedColumn<String>(
      'save_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalBytesMeta =
      const VerificationMeta('totalBytes');
  @override
  late final GeneratedColumn<int> totalBytes = GeneratedColumn<int>(
      'total_bytes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _receivedBytesMeta =
      const VerificationMeta('receivedBytes');
  @override
  late final GeneratedColumn<int> receivedBytes = GeneratedColumn<int>(
      'received_bytes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, bookId, url, savePath, totalBytes, receivedBytes, status, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloads';
  @override
  VerificationContext validateIntegrity(Insertable<DownloadRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('save_path')) {
      context.handle(_savePathMeta,
          savePath.isAcceptableOrUnknown(data['save_path']!, _savePathMeta));
    } else if (isInserting) {
      context.missing(_savePathMeta);
    }
    if (data.containsKey('total_bytes')) {
      context.handle(
          _totalBytesMeta,
          totalBytes.isAcceptableOrUnknown(
              data['total_bytes']!, _totalBytesMeta));
    }
    if (data.containsKey('received_bytes')) {
      context.handle(
          _receivedBytesMeta,
          receivedBytes.isAcceptableOrUnknown(
              data['received_bytes']!, _receivedBytesMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      savePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}save_path'])!,
      totalBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_bytes'])!,
      receivedBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}received_bytes'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DownloadsTable createAlias(String alias) {
    return $DownloadsTable(attachedDatabase, alias);
  }
}

class DownloadRow extends DataClass implements Insertable<DownloadRow> {
  final String id;
  final String bookId;
  final String url;
  final String savePath;
  final int totalBytes;
  final int receivedBytes;
  final String status;
  final int updatedAt;
  const DownloadRow(
      {required this.id,
      required this.bookId,
      required this.url,
      required this.savePath,
      required this.totalBytes,
      required this.receivedBytes,
      required this.status,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['url'] = Variable<String>(url);
    map['save_path'] = Variable<String>(savePath);
    map['total_bytes'] = Variable<int>(totalBytes);
    map['received_bytes'] = Variable<int>(receivedBytes);
    map['status'] = Variable<String>(status);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  DownloadsCompanion toCompanion(bool nullToAbsent) {
    return DownloadsCompanion(
      id: Value(id),
      bookId: Value(bookId),
      url: Value(url),
      savePath: Value(savePath),
      totalBytes: Value(totalBytes),
      receivedBytes: Value(receivedBytes),
      status: Value(status),
      updatedAt: Value(updatedAt),
    );
  }

  factory DownloadRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadRow(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      url: serializer.fromJson<String>(json['url']),
      savePath: serializer.fromJson<String>(json['savePath']),
      totalBytes: serializer.fromJson<int>(json['totalBytes']),
      receivedBytes: serializer.fromJson<int>(json['receivedBytes']),
      status: serializer.fromJson<String>(json['status']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'url': serializer.toJson<String>(url),
      'savePath': serializer.toJson<String>(savePath),
      'totalBytes': serializer.toJson<int>(totalBytes),
      'receivedBytes': serializer.toJson<int>(receivedBytes),
      'status': serializer.toJson<String>(status),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  DownloadRow copyWith(
          {String? id,
          String? bookId,
          String? url,
          String? savePath,
          int? totalBytes,
          int? receivedBytes,
          String? status,
          int? updatedAt}) =>
      DownloadRow(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        url: url ?? this.url,
        savePath: savePath ?? this.savePath,
        totalBytes: totalBytes ?? this.totalBytes,
        receivedBytes: receivedBytes ?? this.receivedBytes,
        status: status ?? this.status,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DownloadRow copyWithCompanion(DownloadsCompanion data) {
    return DownloadRow(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      url: data.url.present ? data.url.value : this.url,
      savePath: data.savePath.present ? data.savePath.value : this.savePath,
      totalBytes:
          data.totalBytes.present ? data.totalBytes.value : this.totalBytes,
      receivedBytes: data.receivedBytes.present
          ? data.receivedBytes.value
          : this.receivedBytes,
      status: data.status.present ? data.status.value : this.status,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadRow(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('url: $url, ')
          ..write('savePath: $savePath, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('receivedBytes: $receivedBytes, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, bookId, url, savePath, totalBytes, receivedBytes, status, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadRow &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.url == this.url &&
          other.savePath == this.savePath &&
          other.totalBytes == this.totalBytes &&
          other.receivedBytes == this.receivedBytes &&
          other.status == this.status &&
          other.updatedAt == this.updatedAt);
}

class DownloadsCompanion extends UpdateCompanion<DownloadRow> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<String> url;
  final Value<String> savePath;
  final Value<int> totalBytes;
  final Value<int> receivedBytes;
  final Value<String> status;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const DownloadsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.url = const Value.absent(),
    this.savePath = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.receivedBytes = const Value.absent(),
    this.status = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadsCompanion.insert({
    required String id,
    required String bookId,
    required String url,
    required String savePath,
    this.totalBytes = const Value.absent(),
    this.receivedBytes = const Value.absent(),
    this.status = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        bookId = Value(bookId),
        url = Value(url),
        savePath = Value(savePath),
        updatedAt = Value(updatedAt);
  static Insertable<DownloadRow> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<String>? url,
    Expression<String>? savePath,
    Expression<int>? totalBytes,
    Expression<int>? receivedBytes,
    Expression<String>? status,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (url != null) 'url': url,
      if (savePath != null) 'save_path': savePath,
      if (totalBytes != null) 'total_bytes': totalBytes,
      if (receivedBytes != null) 'received_bytes': receivedBytes,
      if (status != null) 'status': status,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadsCompanion copyWith(
      {Value<String>? id,
      Value<String>? bookId,
      Value<String>? url,
      Value<String>? savePath,
      Value<int>? totalBytes,
      Value<int>? receivedBytes,
      Value<String>? status,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return DownloadsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      url: url ?? this.url,
      savePath: savePath ?? this.savePath,
      totalBytes: totalBytes ?? this.totalBytes,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      status: status ?? this.status,
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
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (savePath.present) {
      map['save_path'] = Variable<String>(savePath.value);
    }
    if (totalBytes.present) {
      map['total_bytes'] = Variable<int>(totalBytes.value);
    }
    if (receivedBytes.present) {
      map['received_bytes'] = Variable<int>(receivedBytes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('url: $url, ')
          ..write('savePath: $savePath, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('receivedBytes: $receivedBytes, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BooksTable books = $BooksTable(this);
  late final $ChaptersTable chapters = $ChaptersTable(this);
  late final $ReadingProgressesTable readingProgresses =
      $ReadingProgressesTable(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $ReadingSessionsTable readingSessions =
      $ReadingSessionsTable(this);
  late final $DownloadsTable downloads = $DownloadsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        books,
        chapters,
        readingProgresses,
        bookmarks,
        notes,
        readingSessions,
        downloads
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('books',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('chapters', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('books',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('reading_progresses', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('books',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('bookmarks', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('books',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('notes', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('books',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('reading_sessions', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$BooksTableCreateCompanionBuilder = BooksCompanion Function({
  required String id,
  required String title,
  Value<String> author,
  required String format,
  Value<String> source,
  required String localPath,
  Value<String?> contentDir,
  Value<String?> coverPath,
  Value<String?> sourceUri,
  Value<String?> language,
  Value<String?> description,
  Value<String?> publisher,
  Value<int> totalChars,
  Value<int> totalPages,
  required int addedAt,
  Value<int?> lastReadAt,
  Value<double> progress,
  Value<bool> favorite,
  Value<String> tags,
  Value<int> rowid,
});
typedef $$BooksTableUpdateCompanionBuilder = BooksCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> author,
  Value<String> format,
  Value<String> source,
  Value<String> localPath,
  Value<String?> contentDir,
  Value<String?> coverPath,
  Value<String?> sourceUri,
  Value<String?> language,
  Value<String?> description,
  Value<String?> publisher,
  Value<int> totalChars,
  Value<int> totalPages,
  Value<int> addedAt,
  Value<int?> lastReadAt,
  Value<double> progress,
  Value<bool> favorite,
  Value<String> tags,
  Value<int> rowid,
});

final class $$BooksTableReferences
    extends BaseReferences<_$AppDatabase, $BooksTable, BookRow> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ChaptersTable, List<ChapterRow>>
      _chaptersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.chapters,
              aliasName: 'books__id__chapters__book_id');

  $$ChaptersTableProcessedTableManager get chaptersRefs {
    final manager = $$ChaptersTableTableManager($_db, $_db.chapters)
        .filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_chaptersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ReadingProgressesTable, List<ReadingProgressRow>>
      _readingProgressesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.readingProgresses,
              aliasName: 'books__id__reading_progresses__book_id');

  $$ReadingProgressesTableProcessedTableManager get readingProgressesRefs {
    final manager =
        $$ReadingProgressesTableTableManager($_db, $_db.readingProgresses)
            .filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_readingProgressesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BookmarksTable, List<BookmarkRow>>
      _bookmarksRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.bookmarks,
              aliasName: 'books__id__bookmarks__book_id');

  $$BookmarksTableProcessedTableManager get bookmarksRefs {
    final manager = $$BookmarksTableTableManager($_db, $_db.bookmarks)
        .filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookmarksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$NotesTable, List<NoteRow>> _notesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.notes,
          aliasName: 'books__id__notes__book_id');

  $$NotesTableProcessedTableManager get notesRefs {
    final manager = $$NotesTableTableManager($_db, $_db.notes)
        .filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_notesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ReadingSessionsTable, List<ReadingSessionRow>>
      _readingSessionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.readingSessions,
              aliasName: 'books__id__reading_sessions__book_id');

  $$ReadingSessionsTableProcessedTableManager get readingSessionsRefs {
    final manager =
        $$ReadingSessionsTableTableManager($_db, $_db.readingSessions)
            .filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_readingSessionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get format => $composableBuilder(
      column: $table.format, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contentDir => $composableBuilder(
      column: $table.contentDir, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverPath => $composableBuilder(
      column: $table.coverPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceUri => $composableBuilder(
      column: $table.sourceUri, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get publisher => $composableBuilder(
      column: $table.publisher, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalChars => $composableBuilder(
      column: $table.totalChars, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalPages => $composableBuilder(
      column: $table.totalPages, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastReadAt => $composableBuilder(
      column: $table.lastReadAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get progress => $composableBuilder(
      column: $table.progress, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get favorite => $composableBuilder(
      column: $table.favorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  Expression<bool> chaptersRefs(
      Expression<bool> Function($$ChaptersTableFilterComposer f) f) {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.bookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableFilterComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> readingProgressesRefs(
      Expression<bool> Function($$ReadingProgressesTableFilterComposer f) f) {
    final $$ReadingProgressesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.readingProgresses,
        getReferencedColumn: (t) => t.bookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingProgressesTableFilterComposer(
              $db: $db,
              $table: $db.readingProgresses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> bookmarksRefs(
      Expression<bool> Function($$BookmarksTableFilterComposer f) f) {
    final $$BookmarksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bookmarks,
        getReferencedColumn: (t) => t.bookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookmarksTableFilterComposer(
              $db: $db,
              $table: $db.bookmarks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> notesRefs(
      Expression<bool> Function($$NotesTableFilterComposer f) f) {
    final $$NotesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.notes,
        getReferencedColumn: (t) => t.bookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NotesTableFilterComposer(
              $db: $db,
              $table: $db.notes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> readingSessionsRefs(
      Expression<bool> Function($$ReadingSessionsTableFilterComposer f) f) {
    final $$ReadingSessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.readingSessions,
        getReferencedColumn: (t) => t.bookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingSessionsTableFilterComposer(
              $db: $db,
              $table: $db.readingSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get format => $composableBuilder(
      column: $table.format, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contentDir => $composableBuilder(
      column: $table.contentDir, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverPath => $composableBuilder(
      column: $table.coverPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceUri => $composableBuilder(
      column: $table.sourceUri, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get publisher => $composableBuilder(
      column: $table.publisher, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalChars => $composableBuilder(
      column: $table.totalChars, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalPages => $composableBuilder(
      column: $table.totalPages, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastReadAt => $composableBuilder(
      column: $table.lastReadAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get progress => $composableBuilder(
      column: $table.progress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get favorite => $composableBuilder(
      column: $table.favorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get contentDir => $composableBuilder(
      column: $table.contentDir, builder: (column) => column);

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<String> get sourceUri =>
      $composableBuilder(column: $table.sourceUri, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get publisher =>
      $composableBuilder(column: $table.publisher, builder: (column) => column);

  GeneratedColumn<int> get totalChars => $composableBuilder(
      column: $table.totalChars, builder: (column) => column);

  GeneratedColumn<int> get totalPages => $composableBuilder(
      column: $table.totalPages, builder: (column) => column);

  GeneratedColumn<int> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<int> get lastReadAt => $composableBuilder(
      column: $table.lastReadAt, builder: (column) => column);

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<bool> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  Expression<T> chaptersRefs<T extends Object>(
      Expression<T> Function($$ChaptersTableAnnotationComposer a) f) {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.bookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableAnnotationComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> readingProgressesRefs<T extends Object>(
      Expression<T> Function($$ReadingProgressesTableAnnotationComposer a) f) {
    final $$ReadingProgressesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.readingProgresses,
            getReferencedColumn: (t) => t.bookId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ReadingProgressesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.readingProgresses,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> bookmarksRefs<T extends Object>(
      Expression<T> Function($$BookmarksTableAnnotationComposer a) f) {
    final $$BookmarksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.bookmarks,
        getReferencedColumn: (t) => t.bookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BookmarksTableAnnotationComposer(
              $db: $db,
              $table: $db.bookmarks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> notesRefs<T extends Object>(
      Expression<T> Function($$NotesTableAnnotationComposer a) f) {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.notes,
        getReferencedColumn: (t) => t.bookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$NotesTableAnnotationComposer(
              $db: $db,
              $table: $db.notes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> readingSessionsRefs<T extends Object>(
      Expression<T> Function($$ReadingSessionsTableAnnotationComposer a) f) {
    final $$ReadingSessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.readingSessions,
        getReferencedColumn: (t) => t.bookId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReadingSessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.readingSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BooksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BooksTable,
    BookRow,
    $$BooksTableFilterComposer,
    $$BooksTableOrderingComposer,
    $$BooksTableAnnotationComposer,
    $$BooksTableCreateCompanionBuilder,
    $$BooksTableUpdateCompanionBuilder,
    (BookRow, $$BooksTableReferences),
    BookRow,
    PrefetchHooks Function(
        {bool chaptersRefs,
        bool readingProgressesRefs,
        bool bookmarksRefs,
        bool notesRefs,
        bool readingSessionsRefs})> {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> author = const Value.absent(),
            Value<String> format = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String> localPath = const Value.absent(),
            Value<String?> contentDir = const Value.absent(),
            Value<String?> coverPath = const Value.absent(),
            Value<String?> sourceUri = const Value.absent(),
            Value<String?> language = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> publisher = const Value.absent(),
            Value<int> totalChars = const Value.absent(),
            Value<int> totalPages = const Value.absent(),
            Value<int> addedAt = const Value.absent(),
            Value<int?> lastReadAt = const Value.absent(),
            Value<double> progress = const Value.absent(),
            Value<bool> favorite = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BooksCompanion(
            id: id,
            title: title,
            author: author,
            format: format,
            source: source,
            localPath: localPath,
            contentDir: contentDir,
            coverPath: coverPath,
            sourceUri: sourceUri,
            language: language,
            description: description,
            publisher: publisher,
            totalChars: totalChars,
            totalPages: totalPages,
            addedAt: addedAt,
            lastReadAt: lastReadAt,
            progress: progress,
            favorite: favorite,
            tags: tags,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String> author = const Value.absent(),
            required String format,
            Value<String> source = const Value.absent(),
            required String localPath,
            Value<String?> contentDir = const Value.absent(),
            Value<String?> coverPath = const Value.absent(),
            Value<String?> sourceUri = const Value.absent(),
            Value<String?> language = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> publisher = const Value.absent(),
            Value<int> totalChars = const Value.absent(),
            Value<int> totalPages = const Value.absent(),
            required int addedAt,
            Value<int?> lastReadAt = const Value.absent(),
            Value<double> progress = const Value.absent(),
            Value<bool> favorite = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BooksCompanion.insert(
            id: id,
            title: title,
            author: author,
            format: format,
            source: source,
            localPath: localPath,
            contentDir: contentDir,
            coverPath: coverPath,
            sourceUri: sourceUri,
            language: language,
            description: description,
            publisher: publisher,
            totalChars: totalChars,
            totalPages: totalPages,
            addedAt: addedAt,
            lastReadAt: lastReadAt,
            progress: progress,
            favorite: favorite,
            tags: tags,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$BooksTable, BookRow>(table),
                    $$BooksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {chaptersRefs = false,
              readingProgressesRefs = false,
              bookmarksRefs = false,
              notesRefs = false,
              readingSessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (chaptersRefs) db.chapters,
                if (readingProgressesRefs) db.readingProgresses,
                if (bookmarksRefs) db.bookmarks,
                if (notesRefs) db.notes,
                if (readingSessionsRefs) db.readingSessions
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (chaptersRefs)
                    await $_getPrefetchedData<BookRow, $BooksTable, ChapterRow>(
                        currentTable: table,
                        referencedTable:
                            $$BooksTableReferences._chaptersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BooksTableReferences(db, table, p0).chaptersRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.bookId == item.id),
                        typedResults: items),
                  if (readingProgressesRefs)
                    await $_getPrefetchedData<BookRow, $BooksTable,
                            ReadingProgressRow>(
                        currentTable: table,
                        referencedTable: $$BooksTableReferences
                            ._readingProgressesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BooksTableReferences(db, table, p0)
                                .readingProgressesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.bookId == item.id),
                        typedResults: items),
                  if (bookmarksRefs)
                    await $_getPrefetchedData<BookRow, $BooksTable,
                            BookmarkRow>(
                        currentTable: table,
                        referencedTable:
                            $$BooksTableReferences._bookmarksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BooksTableReferences(db, table, p0).bookmarksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.bookId == item.id),
                        typedResults: items),
                  if (notesRefs)
                    await $_getPrefetchedData<BookRow, $BooksTable, NoteRow>(
                        currentTable: table,
                        referencedTable:
                            $$BooksTableReferences._notesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BooksTableReferences(db, table, p0).notesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.bookId == item.id),
                        typedResults: items),
                  if (readingSessionsRefs)
                    await $_getPrefetchedData<BookRow, $BooksTable,
                            ReadingSessionRow>(
                        currentTable: table,
                        referencedTable: $$BooksTableReferences
                            ._readingSessionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BooksTableReferences(db, table, p0)
                                .readingSessionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.bookId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BooksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BooksTable,
    BookRow,
    $$BooksTableFilterComposer,
    $$BooksTableOrderingComposer,
    $$BooksTableAnnotationComposer,
    $$BooksTableCreateCompanionBuilder,
    $$BooksTableUpdateCompanionBuilder,
    (BookRow, $$BooksTableReferences),
    BookRow,
    PrefetchHooks Function(
        {bool chaptersRefs,
        bool readingProgressesRefs,
        bool bookmarksRefs,
        bool notesRefs,
        bool readingSessionsRefs})>;
typedef $$ChaptersTableCreateCompanionBuilder = ChaptersCompanion Function({
  required String id,
  required String bookId,
  required String title,
  Value<int> idx,
  Value<String?> href,
  Value<String?> contentPath,
  Value<int> startChar,
  Value<int> endChar,
  Value<int?> pageStart,
  Value<int?> pageEnd,
  Value<int> level,
  Value<int> rowid,
});
typedef $$ChaptersTableUpdateCompanionBuilder = ChaptersCompanion Function({
  Value<String> id,
  Value<String> bookId,
  Value<String> title,
  Value<int> idx,
  Value<String?> href,
  Value<String?> contentPath,
  Value<int> startChar,
  Value<int> endChar,
  Value<int?> pageStart,
  Value<int?> pageEnd,
  Value<int> level,
  Value<int> rowid,
});

final class $$ChaptersTableReferences
    extends BaseReferences<_$AppDatabase, $ChaptersTable, ChapterRow> {
  $$ChaptersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('chapters__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$BooksTableTableManager($_db, $_db.books)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get idx => $composableBuilder(
      column: $table.idx, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get href => $composableBuilder(
      column: $table.href, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contentPath => $composableBuilder(
      column: $table.contentPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startChar => $composableBuilder(
      column: $table.startChar, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endChar => $composableBuilder(
      column: $table.endChar, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageStart => $composableBuilder(
      column: $table.pageStart, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageEnd => $composableBuilder(
      column: $table.pageEnd, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnFilters(column));

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableFilterComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get idx => $composableBuilder(
      column: $table.idx, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get href => $composableBuilder(
      column: $table.href, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contentPath => $composableBuilder(
      column: $table.contentPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startChar => $composableBuilder(
      column: $table.startChar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endChar => $composableBuilder(
      column: $table.endChar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageStart => $composableBuilder(
      column: $table.pageStart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageEnd => $composableBuilder(
      column: $table.pageEnd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnOrderings(column));

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableOrderingComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get idx =>
      $composableBuilder(column: $table.idx, builder: (column) => column);

  GeneratedColumn<String> get href =>
      $composableBuilder(column: $table.href, builder: (column) => column);

  GeneratedColumn<String> get contentPath => $composableBuilder(
      column: $table.contentPath, builder: (column) => column);

  GeneratedColumn<int> get startChar =>
      $composableBuilder(column: $table.startChar, builder: (column) => column);

  GeneratedColumn<int> get endChar =>
      $composableBuilder(column: $table.endChar, builder: (column) => column);

  GeneratedColumn<int> get pageStart =>
      $composableBuilder(column: $table.pageStart, builder: (column) => column);

  GeneratedColumn<int> get pageEnd =>
      $composableBuilder(column: $table.pageEnd, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableAnnotationComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ChaptersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChaptersTable,
    ChapterRow,
    $$ChaptersTableFilterComposer,
    $$ChaptersTableOrderingComposer,
    $$ChaptersTableAnnotationComposer,
    $$ChaptersTableCreateCompanionBuilder,
    $$ChaptersTableUpdateCompanionBuilder,
    (ChapterRow, $$ChaptersTableReferences),
    ChapterRow,
    PrefetchHooks Function({bool bookId})> {
  $$ChaptersTableTableManager(_$AppDatabase db, $ChaptersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> bookId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<int> idx = const Value.absent(),
            Value<String?> href = const Value.absent(),
            Value<String?> contentPath = const Value.absent(),
            Value<int> startChar = const Value.absent(),
            Value<int> endChar = const Value.absent(),
            Value<int?> pageStart = const Value.absent(),
            Value<int?> pageEnd = const Value.absent(),
            Value<int> level = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChaptersCompanion(
            id: id,
            bookId: bookId,
            title: title,
            idx: idx,
            href: href,
            contentPath: contentPath,
            startChar: startChar,
            endChar: endChar,
            pageStart: pageStart,
            pageEnd: pageEnd,
            level: level,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String bookId,
            required String title,
            Value<int> idx = const Value.absent(),
            Value<String?> href = const Value.absent(),
            Value<String?> contentPath = const Value.absent(),
            Value<int> startChar = const Value.absent(),
            Value<int> endChar = const Value.absent(),
            Value<int?> pageStart = const Value.absent(),
            Value<int?> pageEnd = const Value.absent(),
            Value<int> level = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChaptersCompanion.insert(
            id: id,
            bookId: bookId,
            title: title,
            idx: idx,
            href: href,
            contentPath: contentPath,
            startChar: startChar,
            endChar: endChar,
            pageStart: pageStart,
            pageEnd: pageEnd,
            level: level,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ChaptersTable, ChapterRow>(table),
                    $$ChaptersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (bookId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.bookId,
                    referencedTable: $$ChaptersTableReferences._bookIdTable(db),
                    referencedColumn:
                        $$ChaptersTableReferences._bookIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ChaptersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChaptersTable,
    ChapterRow,
    $$ChaptersTableFilterComposer,
    $$ChaptersTableOrderingComposer,
    $$ChaptersTableAnnotationComposer,
    $$ChaptersTableCreateCompanionBuilder,
    $$ChaptersTableUpdateCompanionBuilder,
    (ChapterRow, $$ChaptersTableReferences),
    ChapterRow,
    PrefetchHooks Function({bool bookId})>;
typedef $$ReadingProgressesTableCreateCompanionBuilder
    = ReadingProgressesCompanion Function({
  required String bookId,
  required String chapterId,
  Value<int> chapterIndex,
  Value<double> chapterRatio,
  Value<double> bookRatio,
  Value<int> position,
  Value<int> page,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$ReadingProgressesTableUpdateCompanionBuilder
    = ReadingProgressesCompanion Function({
  Value<String> bookId,
  Value<String> chapterId,
  Value<int> chapterIndex,
  Value<double> chapterRatio,
  Value<double> bookRatio,
  Value<int> position,
  Value<int> page,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $$ReadingProgressesTableReferences extends BaseReferences<
    _$AppDatabase, $ReadingProgressesTable, ReadingProgressRow> {
  $$ReadingProgressesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('reading_progresses__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$BooksTableTableManager($_db, $_db.books)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ReadingProgressesTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingProgressesTable> {
  $$ReadingProgressesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chapterId => $composableBuilder(
      column: $table.chapterId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get chapterRatio => $composableBuilder(
      column: $table.chapterRatio, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get bookRatio => $composableBuilder(
      column: $table.bookRatio, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get page => $composableBuilder(
      column: $table.page, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableFilterComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReadingProgressesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingProgressesTable> {
  $$ReadingProgressesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chapterId => $composableBuilder(
      column: $table.chapterId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get chapterRatio => $composableBuilder(
      column: $table.chapterRatio,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get bookRatio => $composableBuilder(
      column: $table.bookRatio, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get page => $composableBuilder(
      column: $table.page, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableOrderingComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReadingProgressesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingProgressesTable> {
  $$ReadingProgressesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex, builder: (column) => column);

  GeneratedColumn<double> get chapterRatio => $composableBuilder(
      column: $table.chapterRatio, builder: (column) => column);

  GeneratedColumn<double> get bookRatio =>
      $composableBuilder(column: $table.bookRatio, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableAnnotationComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReadingProgressesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReadingProgressesTable,
    ReadingProgressRow,
    $$ReadingProgressesTableFilterComposer,
    $$ReadingProgressesTableOrderingComposer,
    $$ReadingProgressesTableAnnotationComposer,
    $$ReadingProgressesTableCreateCompanionBuilder,
    $$ReadingProgressesTableUpdateCompanionBuilder,
    (ReadingProgressRow, $$ReadingProgressesTableReferences),
    ReadingProgressRow,
    PrefetchHooks Function({bool bookId})> {
  $$ReadingProgressesTableTableManager(
      _$AppDatabase db, $ReadingProgressesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingProgressesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingProgressesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingProgressesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> bookId = const Value.absent(),
            Value<String> chapterId = const Value.absent(),
            Value<int> chapterIndex = const Value.absent(),
            Value<double> chapterRatio = const Value.absent(),
            Value<double> bookRatio = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<int> page = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingProgressesCompanion(
            bookId: bookId,
            chapterId: chapterId,
            chapterIndex: chapterIndex,
            chapterRatio: chapterRatio,
            bookRatio: bookRatio,
            position: position,
            page: page,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String bookId,
            required String chapterId,
            Value<int> chapterIndex = const Value.absent(),
            Value<double> chapterRatio = const Value.absent(),
            Value<double> bookRatio = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<int> page = const Value.absent(),
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingProgressesCompanion.insert(
            bookId: bookId,
            chapterId: chapterId,
            chapterIndex: chapterIndex,
            chapterRatio: chapterRatio,
            bookRatio: bookRatio,
            position: position,
            page: page,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ReadingProgressesTable, ReadingProgressRow>(
                        table),
                    $$ReadingProgressesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (bookId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.bookId,
                    referencedTable:
                        $$ReadingProgressesTableReferences._bookIdTable(db),
                    referencedColumn:
                        $$ReadingProgressesTableReferences._bookIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ReadingProgressesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReadingProgressesTable,
    ReadingProgressRow,
    $$ReadingProgressesTableFilterComposer,
    $$ReadingProgressesTableOrderingComposer,
    $$ReadingProgressesTableAnnotationComposer,
    $$ReadingProgressesTableCreateCompanionBuilder,
    $$ReadingProgressesTableUpdateCompanionBuilder,
    (ReadingProgressRow, $$ReadingProgressesTableReferences),
    ReadingProgressRow,
    PrefetchHooks Function({bool bookId})>;
typedef $$BookmarksTableCreateCompanionBuilder = BookmarksCompanion Function({
  required String id,
  required String bookId,
  required String chapterId,
  required String chapterTitle,
  Value<int> position,
  Value<double> chapterRatio,
  Value<String> excerpt,
  required int createdAt,
  Value<int> rowid,
});
typedef $$BookmarksTableUpdateCompanionBuilder = BookmarksCompanion Function({
  Value<String> id,
  Value<String> bookId,
  Value<String> chapterId,
  Value<String> chapterTitle,
  Value<int> position,
  Value<double> chapterRatio,
  Value<String> excerpt,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $$BookmarksTableReferences
    extends BaseReferences<_$AppDatabase, $BookmarksTable, BookmarkRow> {
  $$BookmarksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('bookmarks__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$BooksTableTableManager($_db, $_db.books)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterId => $composableBuilder(
      column: $table.chapterId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterTitle => $composableBuilder(
      column: $table.chapterTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get chapterRatio => $composableBuilder(
      column: $table.chapterRatio, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get excerpt => $composableBuilder(
      column: $table.excerpt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableFilterComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterId => $composableBuilder(
      column: $table.chapterId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterTitle => $composableBuilder(
      column: $table.chapterTitle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get chapterRatio => $composableBuilder(
      column: $table.chapterRatio,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get excerpt => $composableBuilder(
      column: $table.excerpt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableOrderingComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get chapterTitle => $composableBuilder(
      column: $table.chapterTitle, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<double> get chapterRatio => $composableBuilder(
      column: $table.chapterRatio, builder: (column) => column);

  GeneratedColumn<String> get excerpt =>
      $composableBuilder(column: $table.excerpt, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableAnnotationComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BookmarksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookmarksTable,
    BookmarkRow,
    $$BookmarksTableFilterComposer,
    $$BookmarksTableOrderingComposer,
    $$BookmarksTableAnnotationComposer,
    $$BookmarksTableCreateCompanionBuilder,
    $$BookmarksTableUpdateCompanionBuilder,
    (BookmarkRow, $$BookmarksTableReferences),
    BookmarkRow,
    PrefetchHooks Function({bool bookId})> {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> bookId = const Value.absent(),
            Value<String> chapterId = const Value.absent(),
            Value<String> chapterTitle = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<double> chapterRatio = const Value.absent(),
            Value<String> excerpt = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BookmarksCompanion(
            id: id,
            bookId: bookId,
            chapterId: chapterId,
            chapterTitle: chapterTitle,
            position: position,
            chapterRatio: chapterRatio,
            excerpt: excerpt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String bookId,
            required String chapterId,
            required String chapterTitle,
            Value<int> position = const Value.absent(),
            Value<double> chapterRatio = const Value.absent(),
            Value<String> excerpt = const Value.absent(),
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              BookmarksCompanion.insert(
            id: id,
            bookId: bookId,
            chapterId: chapterId,
            chapterTitle: chapterTitle,
            position: position,
            chapterRatio: chapterRatio,
            excerpt: excerpt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$BookmarksTable, BookmarkRow>(table),
                    $$BookmarksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (bookId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.bookId,
                    referencedTable:
                        $$BookmarksTableReferences._bookIdTable(db),
                    referencedColumn:
                        $$BookmarksTableReferences._bookIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BookmarksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookmarksTable,
    BookmarkRow,
    $$BookmarksTableFilterComposer,
    $$BookmarksTableOrderingComposer,
    $$BookmarksTableAnnotationComposer,
    $$BookmarksTableCreateCompanionBuilder,
    $$BookmarksTableUpdateCompanionBuilder,
    (BookmarkRow, $$BookmarksTableReferences),
    BookmarkRow,
    PrefetchHooks Function({bool bookId})>;
typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  required String id,
  required String bookId,
  required String chapterId,
  required String chapterTitle,
  required String quote,
  Value<String> content,
  Value<int> startPos,
  Value<int> endPos,
  Value<int> color,
  required int createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<String> id,
  Value<String> bookId,
  Value<String> chapterId,
  Value<String> chapterTitle,
  Value<String> quote,
  Value<String> content,
  Value<int> startPos,
  Value<int> endPos,
  Value<int> color,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $$NotesTableReferences
    extends BaseReferences<_$AppDatabase, $NotesTable, NoteRow> {
  $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('notes__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$BooksTableTableManager($_db, $_db.books)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterId => $composableBuilder(
      column: $table.chapterId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterTitle => $composableBuilder(
      column: $table.chapterTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quote => $composableBuilder(
      column: $table.quote, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startPos => $composableBuilder(
      column: $table.startPos, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endPos => $composableBuilder(
      column: $table.endPos, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableFilterComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterId => $composableBuilder(
      column: $table.chapterId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterTitle => $composableBuilder(
      column: $table.chapterTitle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quote => $composableBuilder(
      column: $table.quote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startPos => $composableBuilder(
      column: $table.startPos, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endPos => $composableBuilder(
      column: $table.endPos, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableOrderingComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get chapterTitle => $composableBuilder(
      column: $table.chapterTitle, builder: (column) => column);

  GeneratedColumn<String> get quote =>
      $composableBuilder(column: $table.quote, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get startPos =>
      $composableBuilder(column: $table.startPos, builder: (column) => column);

  GeneratedColumn<int> get endPos =>
      $composableBuilder(column: $table.endPos, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableAnnotationComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$NotesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotesTable,
    NoteRow,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableAnnotationComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder,
    (NoteRow, $$NotesTableReferences),
    NoteRow,
    PrefetchHooks Function({bool bookId})> {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> bookId = const Value.absent(),
            Value<String> chapterId = const Value.absent(),
            Value<String> chapterTitle = const Value.absent(),
            Value<String> quote = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<int> startPos = const Value.absent(),
            Value<int> endPos = const Value.absent(),
            Value<int> color = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotesCompanion(
            id: id,
            bookId: bookId,
            chapterId: chapterId,
            chapterTitle: chapterTitle,
            quote: quote,
            content: content,
            startPos: startPos,
            endPos: endPos,
            color: color,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String bookId,
            required String chapterId,
            required String chapterTitle,
            required String quote,
            Value<String> content = const Value.absent(),
            Value<int> startPos = const Value.absent(),
            Value<int> endPos = const Value.absent(),
            Value<int> color = const Value.absent(),
            required int createdAt,
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotesCompanion.insert(
            id: id,
            bookId: bookId,
            chapterId: chapterId,
            chapterTitle: chapterTitle,
            quote: quote,
            content: content,
            startPos: startPos,
            endPos: endPos,
            color: color,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$NotesTable, NoteRow>(table),
                    $$NotesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (bookId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.bookId,
                    referencedTable: $$NotesTableReferences._bookIdTable(db),
                    referencedColumn:
                        $$NotesTableReferences._bookIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$NotesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NotesTable,
    NoteRow,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableAnnotationComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder,
    (NoteRow, $$NotesTableReferences),
    NoteRow,
    PrefetchHooks Function({bool bookId})>;
typedef $$ReadingSessionsTableCreateCompanionBuilder = ReadingSessionsCompanion
    Function({
  required String id,
  required String bookId,
  required int startedAt,
  Value<int?> endedAt,
  Value<int> durationSeconds,
  Value<int> charsRead,
  Value<String> mode,
  Value<int> rowid,
});
typedef $$ReadingSessionsTableUpdateCompanionBuilder = ReadingSessionsCompanion
    Function({
  Value<String> id,
  Value<String> bookId,
  Value<int> startedAt,
  Value<int?> endedAt,
  Value<int> durationSeconds,
  Value<int> charsRead,
  Value<String> mode,
  Value<int> rowid,
});

final class $$ReadingSessionsTableReferences extends BaseReferences<
    _$AppDatabase, $ReadingSessionsTable, ReadingSessionRow> {
  $$ReadingSessionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('reading_sessions__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$BooksTableTableManager($_db, $_db.books)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ReadingSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get charsRead => $composableBuilder(
      column: $table.charsRead, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mode => $composableBuilder(
      column: $table.mode, builder: (column) => ColumnFilters(column));

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableFilterComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReadingSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get charsRead => $composableBuilder(
      column: $table.charsRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mode => $composableBuilder(
      column: $table.mode, builder: (column) => ColumnOrderings(column));

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableOrderingComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReadingSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<int> get charsRead =>
      $composableBuilder(column: $table.charsRead, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.bookId,
        referencedTable: $db.books,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BooksTableAnnotationComposer(
              $db: $db,
              $table: $db.books,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReadingSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReadingSessionsTable,
    ReadingSessionRow,
    $$ReadingSessionsTableFilterComposer,
    $$ReadingSessionsTableOrderingComposer,
    $$ReadingSessionsTableAnnotationComposer,
    $$ReadingSessionsTableCreateCompanionBuilder,
    $$ReadingSessionsTableUpdateCompanionBuilder,
    (ReadingSessionRow, $$ReadingSessionsTableReferences),
    ReadingSessionRow,
    PrefetchHooks Function({bool bookId})> {
  $$ReadingSessionsTableTableManager(
      _$AppDatabase db, $ReadingSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> bookId = const Value.absent(),
            Value<int> startedAt = const Value.absent(),
            Value<int?> endedAt = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<int> charsRead = const Value.absent(),
            Value<String> mode = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingSessionsCompanion(
            id: id,
            bookId: bookId,
            startedAt: startedAt,
            endedAt: endedAt,
            durationSeconds: durationSeconds,
            charsRead: charsRead,
            mode: mode,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String bookId,
            required int startedAt,
            Value<int?> endedAt = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<int> charsRead = const Value.absent(),
            Value<String> mode = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingSessionsCompanion.insert(
            id: id,
            bookId: bookId,
            startedAt: startedAt,
            endedAt: endedAt,
            durationSeconds: durationSeconds,
            charsRead: charsRead,
            mode: mode,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ReadingSessionsTable, ReadingSessionRow>(
                        table),
                    $$ReadingSessionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (bookId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.bookId,
                    referencedTable:
                        $$ReadingSessionsTableReferences._bookIdTable(db),
                    referencedColumn:
                        $$ReadingSessionsTableReferences._bookIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ReadingSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReadingSessionsTable,
    ReadingSessionRow,
    $$ReadingSessionsTableFilterComposer,
    $$ReadingSessionsTableOrderingComposer,
    $$ReadingSessionsTableAnnotationComposer,
    $$ReadingSessionsTableCreateCompanionBuilder,
    $$ReadingSessionsTableUpdateCompanionBuilder,
    (ReadingSessionRow, $$ReadingSessionsTableReferences),
    ReadingSessionRow,
    PrefetchHooks Function({bool bookId})>;
typedef $$DownloadsTableCreateCompanionBuilder = DownloadsCompanion Function({
  required String id,
  required String bookId,
  required String url,
  required String savePath,
  Value<int> totalBytes,
  Value<int> receivedBytes,
  Value<String> status,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$DownloadsTableUpdateCompanionBuilder = DownloadsCompanion Function({
  Value<String> id,
  Value<String> bookId,
  Value<String> url,
  Value<String> savePath,
  Value<int> totalBytes,
  Value<int> receivedBytes,
  Value<String> status,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$DownloadsTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get savePath => $composableBuilder(
      column: $table.savePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalBytes => $composableBuilder(
      column: $table.totalBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get receivedBytes => $composableBuilder(
      column: $table.receivedBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$DownloadsTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get savePath => $composableBuilder(
      column: $table.savePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalBytes => $composableBuilder(
      column: $table.totalBytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get receivedBytes => $composableBuilder(
      column: $table.receivedBytes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DownloadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableAnnotationComposer({
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

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get savePath =>
      $composableBuilder(column: $table.savePath, builder: (column) => column);

  GeneratedColumn<int> get totalBytes => $composableBuilder(
      column: $table.totalBytes, builder: (column) => column);

  GeneratedColumn<int> get receivedBytes => $composableBuilder(
      column: $table.receivedBytes, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DownloadsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DownloadsTable,
    DownloadRow,
    $$DownloadsTableFilterComposer,
    $$DownloadsTableOrderingComposer,
    $$DownloadsTableAnnotationComposer,
    $$DownloadsTableCreateCompanionBuilder,
    $$DownloadsTableUpdateCompanionBuilder,
    (DownloadRow, BaseReferences<_$AppDatabase, $DownloadsTable, DownloadRow>),
    DownloadRow,
    PrefetchHooks Function()> {
  $$DownloadsTableTableManager(_$AppDatabase db, $DownloadsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> bookId = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<String> savePath = const Value.absent(),
            Value<int> totalBytes = const Value.absent(),
            Value<int> receivedBytes = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadsCompanion(
            id: id,
            bookId: bookId,
            url: url,
            savePath: savePath,
            totalBytes: totalBytes,
            receivedBytes: receivedBytes,
            status: status,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String bookId,
            required String url,
            required String savePath,
            Value<int> totalBytes = const Value.absent(),
            Value<int> receivedBytes = const Value.absent(),
            Value<String> status = const Value.absent(),
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadsCompanion.insert(
            id: id,
            bookId: bookId,
            url: url,
            savePath: savePath,
            totalBytes: totalBytes,
            receivedBytes: receivedBytes,
            status: status,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$DownloadsTable, DownloadRow>(table),
                    BaseReferences<_$AppDatabase, $DownloadsTable, DownloadRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DownloadsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DownloadsTable,
    DownloadRow,
    $$DownloadsTableFilterComposer,
    $$DownloadsTableOrderingComposer,
    $$DownloadsTableAnnotationComposer,
    $$DownloadsTableCreateCompanionBuilder,
    $$DownloadsTableUpdateCompanionBuilder,
    (DownloadRow, BaseReferences<_$AppDatabase, $DownloadsTable, DownloadRow>),
    DownloadRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$ChaptersTableTableManager get chapters =>
      $$ChaptersTableTableManager(_db, _db.chapters);
  $$ReadingProgressesTableTableManager get readingProgresses =>
      $$ReadingProgressesTableTableManager(_db, _db.readingProgresses);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$ReadingSessionsTableTableManager get readingSessions =>
      $$ReadingSessionsTableTableManager(_db, _db.readingSessions);
  $$DownloadsTableTableManager get downloads =>
      $$DownloadsTableTableManager(_db, _db.downloads);
}
