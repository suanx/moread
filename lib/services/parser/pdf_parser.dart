import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pdfrx/pdfrx.dart';

import '../../core/error/failure.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/chapter.dart';
import 'book_parser.dart';
import 'parsed_book.dart';

/// PDF 解析器。
///
/// PDF 与流式文本不同：它天然以「页」为单位，因此
/// - 渲染由原生 `pdfrx` 的 [PdfViewer] 承担（不走 WebView）；
/// - 章节来自 PDF 书签（Outline / 大纲）；
/// - MVP 阶段不做文本层抽取，听书采用「按章节顺序播报」的降级方案
///   （后续可通过 pdfrx 的文本层 + 页内坐标实现精确高亮）。
class PdfParser implements BookParser {
  const PdfParser({this.pagesPerChapter = 20});

  static const String _tag = 'PdfParser';

  /// 无大纲时，每多少页虚拟划分为一章
  final int pagesPerChapter;

  @override
  Set<BookFormat> get supportedFormats => <BookFormat>{BookFormat.pdf};

  @override
  Future<ParsedBook> parse(ParseRequest request) async {
    final File file = File(request.sourcePath);
    if (!file.existsSync()) {
      throw const Failure(
        code: Failure.fileNotFound,
        message: 'PDF 文件不存在，可能已被系统清理',
      );
    }

    PdfDocument? doc;
    try {
      doc = await PdfDocumentFactory().openFile(file.path);
      final int pageCount = doc.pages.length;

      final List<Chapter> chapters = _buildChapters(
        bookId: request.bookId,
        pageCount: pageCount,
      );

      final Book book = Book(
        id: request.bookId,
        title: request.titleHint ?? p.basenameWithoutExtension(file.path),
        author: request.authorHint ?? '佚名',
        format: BookFormat.pdf,
        source: BookSource.local,
        localPath: file.path,
        totalPages: pageCount,
        addedAt: DateTime.now().millisecondsSinceEpoch,
      );

      return ParsedBook(book: book, chapters: chapters);
    } catch (e, st) {
      if (e is Failure) rethrow;
      AppLogger.e(_tag, 'PDF 解析失败', e, st);
      throw Failure(
        code: Failure.parseFailed,
        message: '无法打开该 PDF（文件损坏或受 DRM 保护）',
        cause: e,
      );
    } finally {
      await doc?.dispose();
    }
  }

  /// TODO(phase-3)：接入 `doc.loadOutline()` 读取 PDF 书签，生成真实目录。
  /// 当前按固定页数虚拟分章，保证目录跳转 / 进度记录可用。
  List<Chapter> _buildChapters({
    required String bookId,
    required int pageCount,
  }) {
    final int total = pageCount < 1 ? 1 : pageCount;
    final List<Chapter> out = <Chapter>[];
    for (int start = 1; start <= total; start += pagesPerChapter) {
      final int raw = start + pagesPerChapter - 1;
      final int end = raw > total ? total : raw;
      out.add(
        Chapter(
          id: '$bookId#${out.length}',
          bookId: bookId,
          index: out.length,
          title: total <= pagesPerChapter ? '全文' : '第 $start - $end 页',
          pageStart: start,
          pageEnd: end,
        ),
      );
    }
    if (out.isEmpty) {
      out.add(
        Chapter(
          id: '$bookId#0',
          bookId: bookId,
          index: 0,
          title: '全文',
          pageStart: 1,
          pageEnd: total,
        ),
      );
    }
    return out;
  }
}
