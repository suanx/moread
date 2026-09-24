import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../core/error/failure.dart';
import '../../core/logging/app_logger.dart';
import '../../core/utils/text_utils.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/chapter_content.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/reading_progress.dart';
import '../../domain/entities/reading_session.dart';
import '../../domain/repositories/book_repository.dart';
import '../../domain/repositories/reading_repository.dart';

/// 阅读页状态机。
///
/// 负责：加载书籍/目录/正文、章节切换、进度保存、书签、笔记、阅读会话计时。
/// 与 WebView 的交互（翻页、高亮、取选区）由 `ReaderPage` 负责，
/// 控制器只接收「结果」并落库，保证状态单一来源。
class ReaderController extends ChangeNotifier {
  ReaderController({
    required this.bookId,
    required BookRepository bookRepository,
    required ReadingRepository readingRepository,
    Uuid? uuid,
  })  : _books = bookRepository,
        _reading = readingRepository,
        _uuid = uuid ?? const Uuid();

  static const String _tag = 'ReaderController';

  final String bookId;
  final BookRepository _books;
  final ReadingRepository _reading;
  final Uuid _uuid;

  Book? _book;
  List<Chapter> _chapters = <Chapter>[];
  ChapterContent? _content;
  ReadingProgress? _progress;
  List<Bookmark> _bookmarks = <Bookmark>[];
  List<Note> _notes = <Note>[];

  bool _loading = true;
  String? _error;
  int _chapterIndex = 0;
  double _chapterRatio = 0;
  double _bookRatio = 0;
  int _pages = 1;
  int _page = 0;
  String? _sessionId;
  Timer? _autoSaveTimer;

  // =========================================================================
  // 对外状态
  // =========================================================================

  Book? get book => _book;
  List<Chapter> get chapters => _chapters;
  ChapterContent? get content => _content;
  ReadingProgress? get progress => _progress;
  List<Bookmark> get bookmarks => _bookmarks;
  List<Note> get notes => _notes;
  bool get loading => _loading;
  String? get error => _error;
  int get chapterIndex => _chapterIndex;
  int get pages => _pages;
  int get page => _page;
  double get bookRatio => _bookRatio;

  Chapter? get currentChapter =>
      (_chapterIndex >= 0 && _chapterIndex < _chapters.length)
          ? _chapters[_chapterIndex]
          : null;

  bool get isPdf => _book?.format == BookFormat.pdf;

  /// 当前阅读位置对应的「章节内字符偏移」（用于书签 / 笔记定位）
  int get currentChar {
    final String text = _content?.plainText ?? '';
    final int raw = (_chapterRatio * text.length).round();
    return raw < 0 ? 0 : (raw > text.length ? text.length : raw);
  }

  /// 全书进度百分比文本，如「已完成 42%」
  String get progressText => '${(_bookRatio * 100).toStringAsFixed(1)}%';

  // =========================================================================
  // 生命周期
  // =========================================================================

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _book = await _books.getById(bookId);
      if (_book == null) {
        throw const Failure(code: Failure.fileNotFound, message: '书籍不存在');
      }
      _chapters = await _books.getChapters(bookId);
      _progress = await _reading.getProgress(bookId);
      _bookmarks = await _reading.getBookmarks(bookId);
      _notes = await _reading.getNotes(bookId);

      final int start = _progress?.chapterIndex ?? 0;
      _chapterIndex = start < 0 ? 0 : (start >= _chapters.length ? 0 : start);
      _chapterRatio = _progress?.chapterRatio ?? 0;
      _bookRatio = _progress?.bookRatio ?? 0;

      await _loadChapter(_chapterIndex, ratio: _chapterRatio);

      _sessionId = await _reading.startSession(bookId, ReadingMode.read);
      _startAutoSave();
    } on Failure catch (e) {
      _error = e.message;
    } catch (e, st) {
      AppLogger.e(_tag, '阅读页加载失败', e, st);
      _error = '加载失败：${e.toString()}';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadChapter(int index, {double ratio = 0}) async {
    if (index < 0 || index >= _chapters.length) return;
    _chapterIndex = index;
    _chapterRatio = ratio;
    _content = null;
    notifyListeners();

    final Chapter chapter = _chapters[index];
    final ChapterContent? c = await _books.loadChapterContent(bookId, chapter);
    _content = c;
    notifyListeners();
  }

  // =========================================================================
  // 章节跳转
  // =========================================================================

  Future<void> goToChapter(int index, {double ratio = 0, int? charOffset}) async {
    if (index == _chapterIndex && charOffset != null) {
      // 同章节内跳转交由页面通过 JS 处理
      return;
    }
    await _loadChapter(index, ratio: ratio);
    await _saveProgress();
  }

  Future<void> nextChapter() async {
    if (_chapterIndex + 1 >= _chapters.length) return;
    await goToChapter(_chapterIndex + 1);
  }

  Future<void> prevChapter() async {
    if (_chapterIndex - 1 < 0) return;
    await goToChapter(_chapterIndex - 1);
  }

  // =========================================================================
  // 进度
  // =========================================================================

  /// WebView 回调：当前页 / 总页数 / 章节内比例
  void onPageChanged({required int page, required int pages, required double ratio}) {
    _page = page;
    _pages = pages;
    _chapterRatio = ratio.isNaN ? 0 : ratio;
    _bookRatio = _computeBookRatio();
    notifyListeners();
    _scheduleSave();
  }

  /// WebView 回调（滚动模式）
  void onScrolled(double ratio) {
    _chapterRatio = ratio.isNaN ? 0 : ratio;
    _bookRatio = _computeBookRatio();
    notifyListeners();
    _scheduleSave();
  }

  /// 全书进度：按「已读章节字数 + 当前章节进度」加权，比按章节数平均更准确
  double _computeBookRatio() {
    if (_chapters.isEmpty) return 0;
    int total = 0;
    int read = 0;
    for (int i = 0; i < _chapters.length; i++) {
      final int len = _chapters[i].charCount;
      total += len;
      if (i < _chapterIndex) {
        read += len;
      } else if (i == _chapterIndex) {
        read += (len * _chapterRatio).round();
      }
    }
    if (total == 0) {
      // EPUB 章节未统计字数时退化为章节数比例
      return (_chapterIndex + _chapterRatio) / _chapters.length;
    }
    final double r = read / total;
    return r < 0 ? 0 : (r > 1 ? 1 : r);
  }

  void _scheduleSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), _saveProgress);
  }

  Future<void> _saveProgress() async {
    final Chapter? c = currentChapter;
    if (c == null) return;
    final int now = DateTime.now().millisecondsSinceEpoch;
    _progress = ReadingProgress(
      bookId: bookId,
      chapterId: c.id,
      chapterIndex: _chapterIndex,
      chapterRatio: _chapterRatio,
      bookRatio: _bookRatio,
      position: currentChar,
      updatedAt: now,
    );
    await _reading.saveProgress(_progress!);
  }

  Future<void> saveProgressNow() async {
    _autoSaveTimer?.cancel();
    await _saveProgress();
  }

  // =========================================================================
  // 书签 / 笔记
  // =========================================================================

  Future<void> addBookmark() async {
    final Chapter? c = currentChapter;
    if (c == null) return;
    final int pos = currentChar;
    final Bookmark b = Bookmark(
      id: _uuid.v4(),
      bookId: bookId,
      chapterId: c.id,
      chapterTitle: c.title,
      position: pos,
      chapterRatio: _chapterRatio,
      excerpt: TextUtils.excerpt(_content?.plainText ?? '', pos, length: 30),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _reading.addBookmark(b);
    _bookmarks = await _reading.getBookmarks(bookId);
    notifyListeners();
  }

  Future<void> removeBookmark(String id) async {
    await _reading.removeBookmark(id);
    _bookmarks = await _reading.getBookmarks(bookId);
    notifyListeners();
  }

  bool isBookmarkedHere() {
    final Chapter? c = currentChapter;
    if (c == null) return false;
    final int pos = currentChar;
    return _bookmarks.any(
      (Bookmark b) => b.chapterId == c.id && (b.position - pos).abs() < 200,
    );
  }

  Future<void> addNote({
    required String quote,
    required int start,
    required int end,
    String comment = '',
    int color = 0xFFE8A33D,
  }) async {
    final Chapter? c = currentChapter;
    if (c == null) return;
    final Note n = Note(
      id: _uuid.v4(),
      bookId: bookId,
      chapterId: c.id,
      chapterTitle: c.title,
      quote: quote,
      content: comment,
      start: start,
      end: end,
      color: color,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _reading.addNote(n);
    _notes = await _reading.getNotes(bookId);
    notifyListeners();
  }

  Future<void> removeNote(String id) async {
    await _reading.removeNote(id);
    _notes = await _reading.getNotes(bookId);
    notifyListeners();
  }

  /// 本页需要回显的划线
  List<Note> notesInCurrentChapter() {
    final Chapter? c = currentChapter;
    if (c == null) return const <Note>[];
    return _notes.where((Note n) => n.chapterId == c.id).toList();
  }

  // =========================================================================

  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer =
        Timer.periodic(const Duration(seconds: 30), (_) => _saveProgress());
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    final String? sid = _sessionId;
    if (sid != null) {
      _sessionId = null;
      unawaited(_reading.endSession(sid));
    }
    super.dispose();
  }
}
