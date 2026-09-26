import 'dart:io';

import 'package:uuid/uuid.dart';

import '../../core/utils/text_utils.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/reading_progress.dart';
import '../../domain/entities/reading_session.dart';
import '../../domain/repositories/reading_repository.dart';
import '../local/db/app_database.dart';
import '../mappers/entity_mapper.dart';

/// 阅读行为仓储实现。
class ReadingRepositoryImpl implements ReadingRepository {
  ReadingRepositoryImpl({
    required AppDatabase db,
    Uuid? uuid,
  })  : _db = db,
        _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  // ---------- 进度 ----------

  @override
  Future<ReadingProgress?> getProgress(String bookId) async {
    final row = await _db.getProgress(bookId);
    return row == null ? null : EntityMapper.progress(row);
  }

  @override
  Future<void> saveProgress(ReadingProgress progress) async {
    await _db.upsertProgress(EntityMapper.progressCompanion(progress));
    // 冗余更新 books.progress，书架直接排序展示
    final book = await _db.getBook(progress.bookId);
    if (book != null) {
      await _db.upsertBook(
        EntityMapper.bookCompanion(
          EntityMapper.book(book).copyWith(
            progress: progress.bookRatio,
            lastReadAt: progress.updatedAt,
          ),
        ),
      );
    }
  }

  // ---------- 书签 ----------

  @override
  Future<List<Bookmark>> getBookmarks(String bookId) async =>
      (await _db.watchBookmarks(bookId).first)
          .map(EntityMapper.bookmark)
          .toList();

  @override
  Future<void> addBookmark(Bookmark bookmark) =>
      _db.addBookmark(EntityMapper.bookmarkCompanion(bookmark));

  @override
  Future<void> removeBookmark(String bookmarkId) =>
      _db.deleteBookmark(bookmarkId);

  // ---------- 笔记 ----------

  @override
  Future<List<Note>> getNotes(String bookId) async =>
      (await _db.watchNotes(bookId).first).map(EntityMapper.note).toList();

  @override
  Future<List<Note>> getAllNotes() async =>
      (await _db.getAllNotes()).map(EntityMapper.note).toList();

  @override
  Future<void> addNote(Note note) => _db.addNote(EntityMapper.noteCompanion(note));

  @override
  Future<void> updateNote(Note note) =>
      _db.updateNoteById(note.id, EntityMapper.noteCompanion(note));

  @override
  Future<void> removeNote(String noteId) => _db.deleteNote(noteId);

  // ---------- 会话 ----------

  @override
  Future<String> startSession(String bookId, ReadingMode mode) async {
    final String id = _uuid.v4();
    await _db.addSession(
      EntityMapper.sessionCompanion(
        ReadingSession(
          id: id,
          bookId: bookId,
          startedAt: DateTime.now().millisecondsSinceEpoch,
          mode: mode,
        ),
      ),
    );
    return id;
  }

  @override
  Future<void> endSession(String sessionId, {int charsRead = 0}) async {
    final row = await _db.getSession(sessionId);
    if (row == null) return;
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int rawSeconds = (now - row.startedAt) ~/ 1000;
    final int seconds = rawSeconds < 0
        ? 0
        : (rawSeconds > 24 * 3600 ? 24 * 3600 : rawSeconds);
    await _db.updateSession(
      sessionId,
      EntityMapper.sessionCompanion(
        EntityMapper.session(row).copyWith(
          endedAt: now,
          durationSeconds: seconds,
          charsRead: charsRead,
        ),
      ),
    );
  }

  // ---------- 统计 ----------

  @override
  Future<ReadingStats> getStats({int days = 7}) async {
    final DateTime now = DateTime.now();
    final int since =
        now.subtract(Duration(days: days)).millisecondsSinceEpoch;
    final List<ReadingSession> rows =
        (await _db.recentSessions(since)).map(EntityMapper.session).toList();

    int readSeconds = 0;
    int listenSeconds = 0;
    final Map<int, int> daily = <int, int>{};
    for (int i = 0; i < days; i++) {
      daily[i] = 0;
    }

    for (final ReadingSession s in rows) {
      if (s.mode == ReadingMode.listen) {
        listenSeconds += s.durationSeconds;
      } else {
        readSeconds += s.durationSeconds;
      }
      final DateTime start = DateTime.fromMillisecondsSinceEpoch(s.startedAt);
      final int diff = DateTime(now.year, now.month, now.day)
          .difference(DateTime(start.year, start.month, start.day))
          .inDays;
      if (diff >= 0 && diff < days) {
        daily[diff] = (daily[diff] ?? 0) + s.durationSeconds;
      }
    }

    // 连续打卡天数
    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final int v = i < days ? (daily[i] ?? 0) : 0;
      if (i >= days) break;
      if (v > 0) {
        streak++;
      } else if (i > 0) {
        break; // 今天还没读不算断签
      }
    }

    final ({int finished, int reading}) shelf = await _db.countShelfStatus();
    final int noteCount = await _db.countAllNotes();
    final int bookmarkCount = await _db.countAllBookmarks();

    return ReadingStats(
      totalReadSeconds: readSeconds,
      totalListenSeconds: listenSeconds,
      daysInARow: streak,
      booksFinished: shelf.finished,
      booksReading: shelf.reading,
      noteCount: noteCount,
      bookmarkCount: bookmarkCount,
      dailySeconds: daily,
    );
  }

  // ---------- 搜索 ----------

  @override
  Future<List<SearchHit>> searchInBook(
    String bookId,
    String keyword, {
    int limit = 50,
  }) async {
    if (keyword.trim().isEmpty) return const <SearchHit>[];
    final book = await _db.getBook(bookId);
    if (book == null) return const <SearchHit>[];

    final Book entity = EntityMapper.book(book);
    if (entity.format == BookFormat.pdf) {
      // TODO(phase-3)：PDF 全文检索需依赖文本层抽取
      return const <SearchHit>[];
    }

    final List<SearchHit> hits = <SearchHit>[];
    final List<Chapter> chapters =
        (await _db.getChapters(bookId)).map(EntityMapper.chapter).toList();

    for (final Chapter c in chapters) {
      if (hits.length >= limit) break;
      final String text = await _chapterPlain(entity, c);
      if (text.isEmpty) continue;

      int from = 0;
      while (hits.length < limit) {
        final int idx = text.indexOf(keyword, from);
        if (idx < 0) break;
        hits.add(
          SearchHit(
            bookId: bookId,
            chapterId: c.id,
            chapterTitle: c.title,
            position: idx,
            snippet: TextUtils.excerpt(text, (idx - 10 < 0 ? 0 : idx - 10),
                length: 60),
          ),
        );
        from = idx + keyword.length;
      }
    }
    return hits;
  }

  Future<String> _chapterPlain(Book book, Chapter chapter) async {
    if (chapter.contentPath == null) return '';
    final File f = File(chapter.contentPath!);
    if (!f.existsSync()) return '';
    final String raw = await f.readAsString();
    if (book.format == BookFormat.epub) {
      return TextUtils.stripHtml(raw);
    }
    final int end = chapter.endChar > raw.length ? raw.length : chapter.endChar;
    final int start = chapter.startChar > end ? end : chapter.startChar;
    return raw.substring(start, end);
  }
}
