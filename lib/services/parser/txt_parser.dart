import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/error/failure.dart';
import '../../core/logging/app_logger.dart';
import '../../core/utils/text_utils.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/chapter.dart';
import 'book_parser.dart';
import 'parsed_book.dart';

/// TXT 解析器。
///
/// 关键点：
/// 1. 编码探测：UTF-8(BOM) → UTF-8 → latin1 兜底；GBK 可通过注入自定义解码器扩展；
/// 2. 章节切分：识别「第X章 / Chapter N / 序 / 后记」等常见标题；
/// 3. 超长章节二次切分：单章超过 [maxChapterChars] 时按段落再切，避免 WebView 卡顿；
/// 4. 全文只落一份 `book.txt`，章节用字符区间描述，节省磁盘与内存。
class TxtParser implements BookParser {
  const TxtParser({this.maxChapterChars = 60000});

  final int maxChapterChars;

  static const String _tag = 'TxtParser';

  @override
  Set<BookFormat> get supportedFormats => <BookFormat>{BookFormat.txt};

  @override
  Future<ParsedBook> parse(ParseRequest request) async {
    final File file = File(request.sourcePath);
    if (!file.existsSync()) {
      throw const Failure(
        code: Failure.fileNotFound,
        message: 'TXT 文件不存在，可能已被系统清理',
      );
    }

    final String text;
    try {
      text = TextUtils.decodeBytes(await file.readAsBytes());
    } catch (e, st) {
      AppLogger.e(_tag, '文本解码失败', e, st);
      throw Failure(
        code: Failure.parseFailed,
        message: '无法解码该文本文件（暂不支持的编码）',
        cause: e,
      );
    }
    if (text.trim().isEmpty) {
      throw const Failure(code: Failure.parseFailed, message: '文件内容为空');
    }

    final Directory outDir = Directory(request.contentDir);
    if (!outDir.existsSync()) {
      await outDir.create(recursive: true);
    }
    final File target = File(p.join(outDir.path, 'book.txt'));
    await target.writeAsString(text, flush: true);

    final List<Chapter> chapters = _splitChapters(request.bookId, text, target.path);

    if (chapters.isEmpty) {
      throw const Failure(code: Failure.parseFailed, message: '未能解析出章节结构');
    }

    // 首行往往是书名，尝试用作标题；否则用文件名
    final String firstLine = text
        .split('\n')
        .firstWhere((String l) => l.trim().isNotEmpty, orElse: () => '')
        .trim();
    final String title = request.titleHint ??
        (firstLine.length <= 40 && firstLine.isNotEmpty
            ? firstLine
            : p.basenameWithoutExtension(request.sourcePath));

    final Book book = Book(
      id: request.bookId,
      title: title,
      author: request.authorHint ?? '佚名',
      format: BookFormat.txt,
      source: BookSource.local,
      localPath: request.sourcePath,
      contentDir: outDir.path,
      totalChars: TextUtils.countWords(text),
      addedAt: DateTime.now().millisecondsSinceEpoch,
    );

    return ParsedBook(book: book, chapters: chapters);
  }

  /// 章节切分：标题识别 + 超长章节二次切分。
  List<Chapter> _splitChapters(String bookId, String text, String contentPath) {
    final List<_Mark> marks = <_Mark>[];
    for (final Match m in TextUtils.chapterPattern.allMatches(text)) {
      marks.add(_Mark(m.start, _titleOf(m.group(0))));
    }
    for (final Match m in TextUtils.enChapterPattern.allMatches(text)) {
      marks.add(_Mark(m.start, _titleOf(m.group(0))));
    }
    marks.sort((_Mark a, _Mark b) => a.offset.compareTo(b.offset));

    // 去重：相邻过近的标题（< 200 字）只保留第一个，过滤目录页常见的密集标题
    final List<_Mark> kept = <_Mark>[];
    for (final _Mark m in marks) {
      if (kept.isEmpty || m.offset - kept.last.offset >= 200) {
        kept.add(m);
      }
    }

    if (kept.isEmpty || kept.first.offset > 0) {
      kept.insert(0, _Mark(0, '开头'));
    }

    final List<Chapter> out = <Chapter>[];
    for (int i = 0; i < kept.length; i++) {
      final int start = kept[i].offset;
      final int end = i + 1 < kept.length ? kept[i + 1].offset : text.length;
      out.addAll(_emit(bookId, contentPath, text, start, end, kept[i].title, out.length));
    }
    return out;
  }

  /// 单章过长时按段落（空行）继续切分
  List<Chapter> _emit(
    String bookId,
    String contentPath,
    String text,
    int start,
    int end,
    String baseTitle,
    int startIndex,
  ) {
    if (end - start <= maxChapterChars) {
      return <Chapter>[
        _chapter(bookId, contentPath, startIndex, baseTitle, start, end),
      ];
    }
    final List<Chapter> out = <Chapter>[];
    int cursor = start;
    int part = 1;
    while (cursor < end) {
      final int raw = cursor + maxChapterChars;
      int sliceEnd = raw > end ? end : raw;
      if (sliceEnd < end) {
        final int nl = text.lastIndexOf('\n', sliceEnd);
        if (nl > cursor) sliceEnd = nl;
      }
      out.add(
        _chapter(
          bookId,
          contentPath,
          startIndex + out.length,
          '$baseTitle（$part）',
          cursor,
          sliceEnd,
        ),
      );
      cursor = sliceEnd;
      part++;
    }
    return out;
  }

  Chapter _chapter(String bookId, String contentPath, int index, String title,
          int start, int end) =>
      Chapter(
        id: '$bookId#$index',
        bookId: bookId,
        index: index,
        title: title,
        contentPath: contentPath,
        startChar: start,
        endChar: end,
      );

  static String _titleOf(String? raw) {
    final String t = (raw ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (t.length > 40) return '${t.substring(0, 40)}…';
    return t.isEmpty ? '正文' : t;
  }
}

class _Mark {
  const _Mark(this.offset, this.title);

  final int offset;
  final String title;
}

/// TXT 正文 → 阅读页 HTML（供 `BookRepository.loadChapterHtml` 复用）
abstract final class TxtHtml {
  /// 把纯文本按空行切段，生成 `<p>` 结构
  static String toBodyHtml(String plain) {
    final List<String> blocks = plain
        .split(RegExp(r'\n\s*\n'))
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList();
    final StringBuffer sb = StringBuffer();
    for (final String block in blocks) {
      final String escaped = TextUtils.escapeXml(block).replaceAll('\n', '<br/>');
      sb.writeln('<p>$escaped</p>');
    }
    return sb.toString();
  }
}
