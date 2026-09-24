import 'package:drift/drift.dart';

/// 书籍表
class Books extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get author => text().withDefault(const Constant('佚名'))();
  TextColumn get format => text()();
  TextColumn get source => text().withDefault(const Constant('local'))();
  TextColumn get localPath => text()();
  TextColumn get contentDir => text().nullable()();
  TextColumn get coverPath => text().nullable()();
  TextColumn get sourceUri => text().nullable()();
  TextColumn get language => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get publisher => text().nullable()();
  IntColumn get totalChars => integer().withDefault(const Constant(0))();
  IntColumn get totalPages => integer().withDefault(const Constant(0))();
  IntColumn get addedAt => integer()();
  IntColumn get lastReadAt => integer().nullable()();
  RealColumn get progress => real().withDefault(const Constant(0))();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  TextColumn get tags => text().withDefault(const Constant('[]'))();

  @override
  Set<Column<Object>>? get primaryKey => <Column<Object>>{id};
}

/// 章节表
class Chapters extends Table {
  TextColumn get id => text()();
  TextColumn get bookId =>
      text().references(Books, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  IntColumn get idx => integer().withDefault(const Constant(0))();
  TextColumn get href => text().nullable()();
  TextColumn get contentPath => text().nullable()();
  IntColumn get startChar => integer().withDefault(const Constant(0))();
  IntColumn get endChar => integer().withDefault(const Constant(0))();
  IntColumn get pageStart => integer().nullable()();
  IntColumn get pageEnd => integer().nullable()();
  IntColumn get level => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>>? get primaryKey => <Column<Object>>{id};
}

/// 阅读进度表（一书一条）
class ReadingProgresses extends Table {
  TextColumn get bookId =>
      text().references(Books, #id, onDelete: KeyAction.cascade)();
  TextColumn get chapterId => text()();
  IntColumn get chapterIndex => integer().withDefault(const Constant(0))();
  RealColumn get chapterRatio => real().withDefault(const Constant(0))();
  RealColumn get bookRatio => real().withDefault(const Constant(0))();
  IntColumn get position => integer().withDefault(const Constant(0))();
  IntColumn get page => integer().withDefault(const Constant(0))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>>? get primaryKey => <Column<Object>>{bookId};
}

/// 书签表
class Bookmarks extends Table {
  TextColumn get id => text()();
  TextColumn get bookId =>
      text().references(Books, #id, onDelete: KeyAction.cascade)();
  TextColumn get chapterId => text()();
  TextColumn get chapterTitle => text()();
  IntColumn get position => integer().withDefault(const Constant(0))();
  RealColumn get chapterRatio => real().withDefault(const Constant(0))();
  TextColumn get excerpt => text().withDefault(const Constant(''))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>>? get primaryKey => <Column<Object>>{id};
}

/// 笔记表
class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get bookId =>
      text().references(Books, #id, onDelete: KeyAction.cascade)();
  TextColumn get chapterId => text()();
  TextColumn get chapterTitle => text()();
  TextColumn get quote => text()();
  TextColumn get content => text().withDefault(const Constant(''))();
  IntColumn get startPos => integer().withDefault(const Constant(0))();
  IntColumn get endPos => integer().withDefault(const Constant(0))();
  IntColumn get color => integer().withDefault(const Constant(0xFFE8A33D))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>>? get primaryKey => <Column<Object>>{id};
}

/// 阅读 / 听书会话表
class ReadingSessions extends Table {
  TextColumn get id => text()();
  TextColumn get bookId =>
      text().references(Books, #id, onDelete: KeyAction.cascade)();
  IntColumn get startedAt => integer()();
  IntColumn get endedAt => integer().nullable()();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
  IntColumn get charsRead => integer().withDefault(const Constant(0))();
  TextColumn get mode => text().withDefault(const Constant('read'))();

  @override
  Set<Column<Object>>? get primaryKey => <Column<Object>>{id};
}

/// 在线下载任务表（断点续传 / 离线缓存状态）
class Downloads extends Table {
  TextColumn get id => text()();
  TextColumn get bookId => text()();
  TextColumn get url => text()();
  TextColumn get savePath => text()();
  IntColumn get totalBytes => integer().withDefault(const Constant(0))();
  IntColumn get receivedBytes => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>>? get primaryKey => <Column<Object>>{id};
}
