import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/entities/book.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/reading_progress.dart';
import '../../domain/entities/reading_session.dart';
import '../local/db/app_database.dart' as db;

/// Drift 行 ↔ 领域实体的双向映射。
///
/// 单独成文件的原因：数据库结构演进时只需改这一处，领域层保持稳定。
/// 注意：Drift 生成的行类带 `Row` 后缀（见 tables.dart 的 `@DataClassName`），
/// 通过 `db.` 前缀引用，与领域实体彻底区分。
abstract final class EntityMapper {
  // ---------- Book ----------
  static Book book(db.BookRow row) => Book(
        id: row.id,
        title: row.title,
        author: row.author,
        format: BookFormat.values.firstWhere(
          (BookFormat e) => e.name == row.format,
          orElse: () => BookFormat.txt,
        ),
        source: BookSource.values.firstWhere(
          (BookSource e) => e.name == row.source,
          orElse: () => BookSource.local,
        ),
        localPath: row.localPath,
        contentDir: row.contentDir,
        coverPath: row.coverPath,
        sourceUri: row.sourceUri,
        language: row.language,
        description: row.description,
        publisher: row.publisher,
        totalChars: row.totalChars,
        totalPages: row.totalPages,
        addedAt: row.addedAt,
        lastReadAt: row.lastReadAt,
        progress: row.progress,
        favorite: row.favorite,
        tags: _stringList(row.tags),
      );

  static db.BooksCompanion bookCompanion(Book e) => db.BooksCompanion(
        id: Value<String>(e.id),
        title: Value<String>(e.title),
        author: Value<String>(e.author),
        format: Value<String>(e.format.name),
        source: Value<String>(e.source.name),
        localPath: Value<String>(e.localPath),
        contentDir: Value<String?>(e.contentDir),
        coverPath: Value<String?>(e.coverPath),
        sourceUri: Value<String?>(e.sourceUri),
        language: Value<String?>(e.language),
        description: Value<String?>(e.description),
        publisher: Value<String?>(e.publisher),
        totalChars: Value<int>(e.totalChars),
        totalPages: Value<int>(e.totalPages),
        addedAt: Value<int>(e.addedAt),
        lastReadAt: Value<int?>(e.lastReadAt),
        progress: Value<double>(e.progress),
        favorite: Value<bool>(e.favorite),
        tags: Value<String>(jsonEncode(e.tags)),
      );

  // ---------- Chapter ----------
  static Chapter chapter(db.ChapterRow row) => Chapter(
        id: row.id,
        bookId: row.bookId,
        index: row.idx,
        title: row.title,
        href: row.href,
        contentPath: row.contentPath,
        startChar: row.startChar,
        endChar: row.endChar,
        pageStart: row.pageStart,
        pageEnd: row.pageEnd,
        level: row.level,
      );

  static db.ChaptersCompanion chapterCompanion(Chapter e) =>
      db.ChaptersCompanion(
        id: Value<String>(e.id),
        bookId: Value<String>(e.bookId),
        title: Value<String>(e.title),
        idx: Value<int>(e.index),
        href: Value<String?>(e.href),
        contentPath: Value<String?>(e.contentPath),
        startChar: Value<int>(e.startChar),
        endChar: Value<int>(e.endChar),
        pageStart: Value<int?>(e.pageStart),
        pageEnd: Value<int?>(e.pageEnd),
        level: Value<int>(e.level),
      );

  // ---------- Progress ----------
  static ReadingProgress progress(db.ReadingProgressRow row) => ReadingProgress(
        bookId: row.bookId,
        chapterId: row.chapterId,
        chapterIndex: row.chapterIndex,
        chapterRatio: row.chapterRatio,
        bookRatio: row.bookRatio,
        position: row.position,
        page: row.page,
        updatedAt: row.updatedAt,
      );

  static db.ReadingProgressesCompanion progressCompanion(ReadingProgress e) =>
      db.ReadingProgressesCompanion(
        bookId: Value<String>(e.bookId),
        chapterId: Value<String>(e.chapterId),
        chapterIndex: Value<int>(e.chapterIndex),
        chapterRatio: Value<double>(e.chapterRatio),
        bookRatio: Value<double>(e.bookRatio),
        position: Value<int>(e.position),
        page: Value<int>(e.page),
        updatedAt: Value<int>(e.updatedAt),
      );

  // ---------- Bookmark ----------
  static Bookmark bookmark(db.BookmarkRow row) => Bookmark(
        id: row.id,
        bookId: row.bookId,
        chapterId: row.chapterId,
        chapterTitle: row.chapterTitle,
        position: row.position,
        chapterRatio: row.chapterRatio,
        excerpt: row.excerpt,
        createdAt: row.createdAt,
      );

  static db.BookmarksCompanion bookmarkCompanion(Bookmark e) =>
      db.BookmarksCompanion(
        id: Value<String>(e.id),
        bookId: Value<String>(e.bookId),
        chapterId: Value<String>(e.chapterId),
        chapterTitle: Value<String>(e.chapterTitle),
        position: Value<int>(e.position),
        chapterRatio: Value<double>(e.chapterRatio),
        excerpt: Value<String>(e.excerpt),
        createdAt: Value<int>(e.createdAt),
      );

  // ---------- Note ----------
  static Note note(db.NoteRow row) => Note(
        id: row.id,
        bookId: row.bookId,
        chapterId: row.chapterId,
        chapterTitle: row.chapterTitle,
        quote: row.quote,
        content: row.content,
        start: row.startPos,
        end: row.endPos,
        color: row.color,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  static db.NotesCompanion noteCompanion(Note e) => db.NotesCompanion(
        id: Value<String>(e.id),
        bookId: Value<String>(e.bookId),
        chapterId: Value<String>(e.chapterId),
        chapterTitle: Value<String>(e.chapterTitle),
        quote: Value<String>(e.quote),
        content: Value<String>(e.content),
        startPos: Value<int>(e.start),
        endPos: Value<int>(e.end),
        color: Value<int>(e.color),
        createdAt: Value<int>(e.createdAt),
        updatedAt: Value<int>(e.updatedAt),
      );

  // ---------- Session ----------
  static ReadingSession session(db.ReadingSessionRow row) => ReadingSession(
        id: row.id,
        bookId: row.bookId,
        startedAt: row.startedAt,
        endedAt: row.endedAt,
        durationSeconds: row.durationSeconds,
        charsRead: row.charsRead,
        mode: ReadingMode.values.firstWhere(
          (ReadingMode m) => m.name == row.mode,
          orElse: () => ReadingMode.read,
        ),
      );

  static db.ReadingSessionsCompanion sessionCompanion(ReadingSession e) =>
      db.ReadingSessionsCompanion(
        id: Value<String>(e.id),
        bookId: Value<String>(e.bookId),
        startedAt: Value<int>(e.startedAt),
        endedAt: Value<int?>(e.endedAt),
        durationSeconds: Value<int>(e.durationSeconds),
        charsRead: Value<int>(e.charsRead),
        mode: Value<String>(e.mode.name),
      );

  static List<String> _stringList(String raw) {
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is List<dynamic>) {
        return decoded.map((dynamic e) => e.toString()).toList();
      }
    } catch (_) {
      // 历史数据格式不兼容时返回空列表
    }
    return const <String>[];
  }
}
