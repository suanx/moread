import '../../core/theme/reader_themes.dart';
import '../entities/book.dart';
import '../entities/chapter.dart';
import '../entities/chapter_content.dart';
import '../entities/reader_settings.dart';

/// 书籍仓储：书架 CRUD + 目录 + 正文获取 + 在线下载。
abstract interface class BookRepository {
  /// 书架列表（按最近阅读排序），返回可监听的流
  Stream<List<Book>> watchShelf({BookSource? source});

  Future<Book?> getById(String id);

  Future<List<Chapter>> getChapters(String bookId);

  Future<Chapter?> getChapter(String bookId, String chapterId);

  /// 获取章节渲染内容（EPUB/TXT 走 WebView；PDF 返回 null，由原生渲染器处理）
  Future<ChapterContent?> loadChapterContent(
    String bookId,
    Chapter chapter, {
    ReaderSettings settings,
    ReaderTheme theme,
  });

  /// 获取章节纯文本（TTS / 搜索 / 字数统计）
  Future<String> loadChapterText(String bookId, Chapter chapter);

  Future<void> saveBook(Book book, List<Chapter> chapters);

  Future<void> updateBook(Book book);

  Future<void> removeBook(String bookId);

  /// 本地导入：解析 + 落库，返回书籍实体
  Future<Book> importLocalFile(String path);

  /// 在线下载：下载 → 缓存 → 解析 → 落库
  Future<Book> downloadOnline({
    required String url,
    required String title,
    String? author,
    String? coverUrl,
    void Function(double progress)? onProgress,
  });
}
