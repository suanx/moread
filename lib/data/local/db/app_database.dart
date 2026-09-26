import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import 'connection/connection.dart' show openConnection;
import 'tables.dart';

part 'app_database.g.dart';

/// 本地数据库（Drift / SQLite）。
///
/// 说明：本文件依赖代码生成，首次拉取代码后需执行
/// `dart run build_runner build --delete-conflicting-outputs`。
@DriftDatabase(
  tables: <Type>[
    Books,
    Chapters,
    ReadingProgresses,
    Bookmarks,
    Notes,
    ReadingSessions,
    Downloads,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection('moread'));

  /// 测试用：注入自定义 executor
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  MigrationStrategy get migrationStrategy => MigrationStrategy(
        onCreate: (Migrator m) async => m.createAll(),
        onUpgrade: (Migrator m, int from, int to) async {
          // v1 → vN：后续版本在此追加 `if (from < N) await m.addColumn(...)`
        },
        beforeOpen: (OpeningDetails d) async {
          // Web 后端（IndexedDB）不支持 PRAGMA，仅在原生 sqlite 下开启外键级联
          if (!kIsWeb) {
            await customStatement('PRAGMA foreign_keys = ON');
          }
        },
      );

  // =========================================================================
  // 书籍
  // =========================================================================

  /// 书架列表：收藏优先，其次最近阅读，最后添加时间
  Stream<List<BookRow>> watchBooks({String? source}) {
    final SimpleSelectStatement<Books, Book> q = select(books);
    if (source != null) {
      q.where((Books tbl) => tbl.source.equals(source));
    }
    q.orderBy(<OrderingTerm Function(Books)>[
      (Books t) => OrderingTerm.desc(t.favorite),
      (Books t) => OrderingTerm.desc(t.lastReadAt),
      (Books t) => OrderingTerm.desc(t.addedAt),
    ]);
    return q.watch();
  }

  Future<List<BookRow>> getAllBooks() => select(books).get();

  Future<BookRow?> getBook(String id) =>
      (select(books)..where((Books t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertBook(BooksCompanion entry) =>
      into(books).insertOnConflictUpdate(entry);

  Future<int> deleteBook(String id) =>
      (delete(books)..where((Books t) => t.id.equals(id))).go();

  // =========================================================================
  // 章节
  // =========================================================================

  Future<List<ChapterRow>> getChapters(String bookId) => (select(chapters)
        ..where((Chapters t) => t.bookId.equals(bookId))
        ..orderBy(<OrderingTerm Function(Chapters)>[
              (Chapters t) => OrderingTerm.asc(t.idx),
            ]))
      .get();

  Future<ChapterRow?> getChapter(String bookId, String chapterId) =>
      (select(chapters)
            ..where((Chapters t) =>
                t.bookId.equals(bookId) & t.id.equals(chapterId)))
          .getSingleOrNull();

  Future<void> replaceChapters(String bookId, List<ChaptersCompanion> list) =>
      transaction(() async {
        await (delete(chapters)..where((Chapters t) => t.bookId.equals(bookId)))
            .go();
        await batch((Batch b) => b.insertAll(chapters, list));
      });

  Future<int> countChapters(String bookId) async {
    final Expression<int> cnt = chapters.id.count();
    final TypedResult row = await (selectOnly(chapters)
          ..addColumns(<Expression<int>>[cnt])
          ..where(chapters.bookId.equals(bookId)))
        .getSingle();
    return row.read(cnt) ?? 0;
  }

  // =========================================================================
  // 阅读进度
  // =========================================================================

  Future<ReadingProgressRow?> getProgress(String bookId) =>
      (select(readingProgresses)
            ..where((ReadingProgresses t) => t.bookId.equals(bookId)))
          .getSingleOrNull();

  Future<void> upsertProgress(ReadingProgressesCompanion entry) =>
      into(readingProgresses).insertOnConflictUpdate(entry);

  // =========================================================================
  // 书签
  // =========================================================================

  Stream<List<BookmarkRow>> watchBookmarks(String bookId) => (select(bookmarks)
        ..where((Bookmarks t) => t.bookId.equals(bookId))
        ..orderBy(<OrderingTerm Function(Bookmarks)>[
              (Bookmarks t) => OrderingTerm.desc(t.createdAt),
            ]))
      .watch();

  Future<int> addBookmark(BookmarksCompanion entry) =>
      into(bookmarks).insert(entry);

  Future<int> deleteBookmark(String id) =>
      (delete(bookmarks)..where((Bookmarks t) => t.id.equals(id))).go();

  // =========================================================================
  // 笔记
  // =========================================================================

  Stream<List<NoteRow>> watchNotes(String bookId) => (select(notes)
        ..where((Notes t) => t.bookId.equals(bookId))
        ..orderBy(<OrderingTerm Function(Notes)>[
              (Notes t) => OrderingTerm.desc(t.createdAt),
            ]))
      .watch();

  Future<List<NoteRow>> getAllNotes() => (select(notes)
        ..orderBy(<OrderingTerm Function(Notes)>[
              (Notes t) => OrderingTerm.desc(t.createdAt),
            ]))
      .get();

  Future<int> addNote(NotesCompanion entry) => into(notes).insert(entry);

  Future<int> updateNoteById(String id, NotesCompanion entry) =>
      (update(notes)..where((Notes t) => t.id.equals(id))).write(entry);

  Future<int> deleteNote(String id) =>
      (delete(notes)..where((Notes t) => t.id.equals(id))).go();

  Future<int> countAllNotes() async {
    final Expression<int> cnt = notes.id.count();
    final TypedResult row =
        await (selectOnly(notes)..addColumns(<Expression<int>>[cnt])).getSingle();
    return row.read(cnt) ?? 0;
  }

  Future<int> countAllBookmarks() async {
    final Expression<int> cnt = bookmarks.id.count();
    final TypedResult row =
        await (selectOnly(bookmarks)..addColumns(<Expression<int>>[cnt]))
            .getSingle();
    return row.read(cnt) ?? 0;
  }

  /// 书架统计：已读完 / 在读 数量
  Future<({int finished, int reading})> countShelfStatus() async {
    final List<BookRow> all = await select(books).get();
    int finished = 0;
    int reading = 0;
    for (final BookRow b in all) {
      if (b.progress >= 0.99) {
        finished++;
      } else if (b.progress > 0) {
        reading++;
      }
    }
    return (finished: finished, reading: reading);
  }

  // =========================================================================
  // 会话 / 统计
  // =========================================================================

  Future<int> addSession(ReadingSessionsCompanion entry) =>
      into(readingSessions).insert(entry);

  Future<int> updateSession(String id, ReadingSessionsCompanion entry) =>
      (update(readingSessions)..where((ReadingSessions t) => t.id.equals(id)))
          .write(entry);

  Future<ReadingSessionRow?> getSession(String id) =>
      (select(readingSessions)..where((ReadingSessions t) => t.id.equals(id)))
          .getSingleOrNull();

  /// 最近 N 天的会话（用于统计页）
  Future<List<ReadingSessionRow>> recentSessions(int sinceMillis) =>
      (select(readingSessions)
            ..where((ReadingSessions t) =>
                t.startedAt.isBiggerOrEqualValue(sinceMillis))
            ..orderBy(<OrderingTerm Function(ReadingSessions)>[
                  (ReadingSessions t) => OrderingTerm.desc(t.startedAt),
                ]))
          .get();

  Future<int> countSessions() async {
    final Expression<int> cnt = readingSessions.id.count();
    final TypedResult row =
        await (selectOnly(readingSessions)..addColumns(<Expression<int>>[cnt]))
            .getSingle();
    return row.read(cnt) ?? 0;
  }

  // =========================================================================
  // 下载任务
  // =========================================================================

  Future<int> upsertDownload(DownloadsCompanion entry) =>
      into(downloads).insertOnConflictUpdate(entry);

  Future<DownloadRow?> getDownload(String id) =>
      (select(downloads)..where((Downloads t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<int> deleteDownload(String id) =>
      (delete(downloads)..where((Downloads t) => t.id.equals(id))).go();
}
