import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../core/error/failure.dart';
import '../../core/logging/app_logger.dart';
import '../../core/storage/app_paths.dart';
import '../../core/theme/reader_themes.dart';
import '../../core/utils/text_utils.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/chapter_content.dart';
import '../../domain/entities/reader_settings.dart';
import '../../domain/repositories/book_repository.dart';
import '../local/db/app_database.dart';
import '../mappers/entity_mapper.dart';
import '../../services/import/book_importer.dart';
import '../../services/parser/content_html_builder.dart';
import '../../services/parser/epub_parser.dart';
import '../../services/parser/parsed_book.dart';
import '../../services/parser/txt_parser.dart';

/// 书籍仓储实现（本地数据库 + 文件系统 + 在线下载）。
class BookRepositoryImpl implements BookRepository {
  BookRepositoryImpl({
    required AppDatabase db,
    required BookImporter importer,
    required AppPaths paths,
    Dio? dio,
  })  : _db = db,
        _importer = importer,
        _paths = paths,
        _dio = dio ?? Dio();

  static const String _tag = 'BookRepositoryImpl';

  final AppDatabase _db;
  final BookImporter _importer;
  final AppPaths _paths;
  final Dio _dio;

  /// 章节正文缓存（避免来回翻页时重复解析）
  final Map<String, String> _plainCache = <String, String>{};

  @override
  Stream<List<Book>> watchShelf({BookSource? source}) => _db
      .watchBooks(source: source?.name)
      .map((rows) => rows.map(EntityMapper.book).toList());

  @override
  Future<Book?> getById(String id) async {
    final row = await _db.getBook(id);
    return row == null ? null : EntityMapper.book(row);
  }

  @override
  Future<List<Chapter>> getChapters(String bookId) async =>
      (await _db.getChapters(bookId)).map(EntityMapper.chapter).toList();

  @override
  Future<Chapter?> getChapter(String bookId, String chapterId) async {
    final row = await _db.getChapter(bookId, chapterId);
    return row == null ? null : EntityMapper.chapter(row);
  }

  @override
  Future<void> saveBook(Book book, List<Chapter> chapters) async {
    await _db.upsertBook(EntityMapper.bookCompanion(book));
    await _db.replaceChapters(
      book.id,
      chapters.map(EntityMapper.chapterCompanion).toList(),
    );
  }

  @override
  Future<void> updateBook(Book book) =>
      _db.upsertBook(EntityMapper.bookCompanion(book));

  @override
  Future<void> removeBook(String bookId) async {
    final book = await _db.getBook(bookId);
    if (book != null) {
      await _safeDeleteDirectory(book.contentDir);
      await _safeDeleteFile(book.localPath);
      await _safeDeleteFile(book.coverPath);
    }
    await _db.deleteBook(bookId);
  }

  // =========================================================================
  // 正文
  // =========================================================================

  @override
  Future<ChapterContent?> loadChapterContent(
    String bookId,
    Chapter chapter, {
    ReaderSettings settings = const ReaderSettings(),
    ReaderTheme theme = ReaderTheme.light,
  }) async {
    final book = await _db.getBook(bookId);
    if (book == null) return null;

    if (book.format == BookFormat.pdf) {
      return null; // PDF 由原生渲染器处理
    }

    final String? path = chapter.contentPath;
    if (path == null) return null;
    final File file = File(path);
    if (!file.existsSync()) {
      throw const Failure(
        code: Failure.fileNotFound,
        message: '章节内容缺失，请重新导入该书',
      );
    }

    final String raw = await file.readAsString();
    final String bodyHtml;
    if (book.format == BookFormat.epub) {
      bodyHtml = EpubParser.extractBodyHtml(raw, baseDir: file.parent);
    } else {
      // TXT：整本一个文件，按章节区间截取
      final String all = await file.readAsString();
      final int end =
          chapter.endChar > all.length ? all.length : chapter.endChar;
      final int start = chapter.startChar > end ? end : chapter.startChar;
      bodyHtml = TxtHtml.toBodyHtml(all.substring(start, end));
    }

    final ReaderDocument doc = ContentHtmlBuilder.build(
      bodyHtml: bodyHtml,
      settings: settings,
      theme: theme,
      chapterTitle: chapter.title,
    );
    return ChapterContent(
      html: doc.html,
      plainText: doc.plainText,
      sentences: doc.sentences,
    );
  }

  @override
  Future<String> loadChapterText(String bookId, Chapter chapter) async {
    final String? cached = _plainCache['$bookId/${chapter.id}'];
    if (cached != null) return cached;

    final book = await _db.getBook(bookId);
    if (book == null) return '';

    String text = '';
    if (book.format == BookFormat.pdf) {
      // TODO(phase-3)：接入 pdfrx 文本层，实现 PDF 正文抽取
      text = '';
    } else if (chapter.contentPath != null) {
      final File file = File(chapter.contentPath!);
      if (file.existsSync()) {
        if (book.format == BookFormat.epub) {
          text = TextUtils.stripHtml(await file.readAsString());
        } else {
          final String all = await file.readAsString();
          final int end =
              chapter.endChar > all.length ? all.length : chapter.endChar;
          final int start = chapter.startChar > end ? end : chapter.startChar;
          text = all.substring(start, end);
        }
      }
    }

    _plainCache['$bookId/${chapter.id}'] = text;
    return text;
  }

  // =========================================================================
  // 导入 / 下载
  // =========================================================================

  @override
  Future<Book> importLocalFile(String path) async {
    final ParsedBook parsed = await _importer.import(path);
    await saveBook(parsed.book, parsed.chapters);
    return parsed.book;
  }

  @override
  Future<Book> downloadOnline({
    required String url,
    required String title,
    String? author,
    String? coverUrl,
    void Function(double progress)? onProgress,
  }) async {
    final String ext = p.extension(Uri.parse(url).path).replaceAll('.', '');
    final String safeExt = ext.isEmpty ? 'epub' : ext;
    final String bookId = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final String savePath = _paths.bookFile(bookId, safeExt);

    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (int received, int total) {
          if (onProgress != null && total > 0) {
            onProgress(received / total);
          }
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 5),
          headers: <String, dynamic>{'Accept': '*/*'},
        ),
      );
    } on DioException catch (e) {
      AppLogger.e(_tag, '在线书籍下载失败', e);
      throw Failure(
        code: Failure.networkError,
        message: '下载失败：${e.message ?? '网络异常'}',
        cause: e,
      );
    }

    final ParsedBook parsed = await _importer.import(
      savePath,
      title: title,
      author: author,
    );

    Book book = parsed.book.copyWith(sourceUri: url);
    if (coverUrl != null && coverUrl.isNotEmpty) {
      final String? local = await _downloadCover(coverUrl, bookId);
      if (local != null) {
        book = book.copyWith(coverPath: local);
      }
    }
    await saveBook(book, parsed.chapters);
    return book;
  }

  Future<String?> _downloadCover(String url, String bookId) async {
    try {
      final String ext = p.extension(Uri.parse(url).path).replaceAll('.', '');
      final String path = _paths.coverFile(bookId, ext.isEmpty ? 'jpg' : ext);
      await _dio.download(url, path);
      return path;
    } catch (e) {
      AppLogger.w(_tag, '封面下载失败：${e.toString()}');
      return null;
    }
  }

  Future<void> _safeDeleteFile(String? path) async {
    if (path == null) return;
    try {
      final File f = File(path);
      if (f.existsSync()) await f.delete();
    } catch (_) {
      // 文件删除失败不影响数据库清理
    }
  }

  Future<void> _safeDeleteDirectory(String? path) async {
    if (path == null) return;
    try {
      final Directory d = Directory(path);
      if (d.existsSync()) await d.delete(recursive: true);
    } catch (_) {
      // 同上
    }
  }
}
