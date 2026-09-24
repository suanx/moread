import '../entities/bookmark.dart';
import '../entities/note.dart';
import '../entities/reading_progress.dart';
import '../entities/reading_session.dart';

/// 阅读行为仓储：进度、书签、笔记、会话统计。
abstract interface class ReadingRepository {
  // ---------- 进度 ----------
  Future<ReadingProgress?> getProgress(String bookId);

  Future<void> saveProgress(ReadingProgress progress);

  // ---------- 书签 ----------
  Future<List<Bookmark>> getBookmarks(String bookId);

  Future<void> addBookmark(Bookmark bookmark);

  Future<void> removeBookmark(String bookmarkId);

  // ---------- 笔记 ----------
  Future<List<Note>> getNotes(String bookId);

  Future<List<Note>> getAllNotes();

  Future<void> addNote(Note note);

  Future<void> updateNote(Note note);

  Future<void> removeNote(String noteId);

  // ---------- 会话 / 统计 ----------
  Future<String> startSession(String bookId, ReadingMode mode);

  Future<void> endSession(String sessionId, {int charsRead = 0});

  Future<ReadingStats> getStats({int days = 7});

  /// 全文搜索：在指定书籍内检索关键词，返回 (章节, 偏移) 命中列表
  Future<List<SearchHit>> searchInBook(String bookId, String keyword, {int limit = 50});
}

/// 搜索命中项。
class SearchHit {
  const SearchHit({
    required this.bookId,
    required this.chapterId,
    required this.chapterTitle,
    required this.position,
    required this.snippet,
  });

  final String bookId;
  final String chapterId;
  final String chapterTitle;
  final int position;
  final String snippet;
}
