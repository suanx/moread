import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/error/failure.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/chapter.dart';
import 'book_parser.dart';
import 'parsed_book.dart';

/// PDF 解析器。
///
/// 与流式文本不同，PDF 天然以「页」为单位，因此：
/// - 渲染由原生 `pdfrx` 的 `PdfViewer.file()` 承担（不走 WebView）；
/// - **导入阶段不打开文档**：无需 PDFium 初始化，导入更快，也不会因为
///   加密 / 损坏文档导致入架失败；真实页数在阅读器首帧回调后回填（TODO phase-3）；
/// - MVP 不做文本层抽取，听书采用「按章节顺序播报」的降级方案。
class PdfParser implements BookParser {
  const PdfParser({this.pagesPerChapter = 20});

  static const String _tag = 'PdfParser';

  /// 每多少页虚拟划分为一章
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

    try {
      // 仅校验文件头，不解码正文
      final RandomAccessFile raf = await file.open(mode: FileMode.read);
      final List<int> head = await raf.read(5);
      await raf.close();
      if (!String.fromCharCodes(head).startsWith('%PDF')) {
        AppLogger.w(_tag, '文件不是 PDF：${file.path}');
        throw const Failure(
          code: Failure.parseFailed,
          message: '该文件不是有效的 PDF（缺少 %PDF 文件头）',
        );
      }

      final Book book = Book(
        id: request.bookId,
        title: request.titleHint ?? p.basenameWithoutExtension(file.path),
        author: request.authorHint ?? '佚名',
        format: BookFormat.pdf,
        source: BookSource.local,
        localPath: file.path,
        totalPages: 0, // 阅读器首帧回调后回填
        addedAt: DateTime.now().millisecondsSinceEpoch,
      );

      return ParsedBook(book: book, chapters: _buildChapters(request.bookId));
    } on Failure {
      rethrow;
    } catch (e, st) {
      AppLogger.e(_tag, 'PDF 导入失败', e, st);
      throw Failure(
        code: Failure.parseFailed,
        message: 'PDF 导入失败：${e.toString()}',
        cause: e,
      );
    }
  }

  /// 未拿到总页数时先预生成若干「待定」章节，保证目录跳转与进度记录可用；
  /// 真实页数回填后可重建目录。
  List<Chapter> _buildChapters(String bookId) {
    final List<Chapter> out = <Chapter>[];
    for (int i = 0; i < 5; i++) {
      final int start = i * pagesPerChapter + 1;
      out.add(
        Chapter(
          id: '$bookId#$i',
          bookId: bookId,
          index: i,
          title: '第 $start 页起',
          pageStart: start,
          pageEnd: start + pagesPerChapter - 1,
        ),
      );
    }
    return out;
  }
}
