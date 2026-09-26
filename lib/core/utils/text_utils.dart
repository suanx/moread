import 'dart:convert';
import 'dart:typed_data';

/// 文本处理工具：章节切分、字数统计、HTML 转义、TTS 文本清洗。
abstract final class TextUtils {
  /// 常见中文书籍章节标题正则（第X章/第X节/卷/回/篇 + 可选标题）
  static final RegExp chapterPattern = RegExp(
    r'^\s{0,8}(?:序|序言|前言|引子|楔子|后记|尾声|番外|'
    r'第\s*[0-9零一二三四五六七八九十百千万]+\s*[章节回卷篇集部]\s*[:：·、.\s]?.*)$',
    multiLine: true,
  );

  /// 英文章节：Chapter 1 / CHAPTER I
  static final RegExp enChapterPattern = RegExp(
    r'^\s{0,8}(?:Chapter|CHAPTER|Part|PART)\s+[0-9IVXLC]+.*$',
    multiLine: true,
  );

  /// 移除 HTML 标签，得到纯文本（用于 TTS、全文搜索、字数统计）
  static String stripHtml(String html) {
    final String noScript =
        html.replaceAll(RegExp(r'<script[\s\S]*?</script>', caseSensitive: false), '');
    final String noStyle =
        noScript.replaceAll(RegExp(r'<style[\s\S]*?</style>', caseSensitive: false), '');
    final String withBreaks = noStyle
        .replaceAll(RegExp(r'<(br|p|div|h[1-6]|li|tr)\b[^>]*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</(p|div|h[1-6]|li|tr)>', caseSensitive: false), '\n');
    final String plain = withBreaks.replaceAll(RegExp(r'<[^>]+>'), '');
    return decodeHtmlEntities(plain)
        .replaceAll('\r\n', '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  /// HTML 实体解码（仅处理常见实体，避免引入额外依赖）
  static String decodeHtmlEntities(String input) => input
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&#39;', "'")
      .replaceAll('&ldquo;', '“')
      .replaceAll('&rdquo;', '”')
      .replaceAll('&mdash;', '—')
      .replaceAll('&hellip;', '…');

  /// XML / SSML 转义
  static String escapeXml(String input) => input
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');

  /// 统计「有效字数」：中日韩字符 + 英文单词
  static int countWords(String text) {
    if (text.isEmpty) return 0;
    final int cjk = RegExp(r'[\u4e00-\u9fff\u3400-\u4dbf\u3040-\u30ff]')
        .allMatches(text)
        .length;
    final String withoutCjk = text.replaceAll(
        RegExp(r'[\u4e00-\u9fff\u3400-\u4dbf\u3040-\u30ff]'), ' ');
    final int words = RegExp(r'[A-Za-z0-9]+').allMatches(withoutCjk).length;
    return cjk + words;
  }

  /// 生成书签/笔记的摘要文本
  static String excerpt(String source, int start, {int length = 40}) {
    if (source.isEmpty) return '';
    final int s = start < 0 ? 0 : (start > source.length ? source.length : start);
    final int raw = s + length;
    final int e = raw > source.length ? source.length : raw;
    return source.substring(s, e).replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// 把长文本切分为「朗读分片」：按句子边界累积，单片不超过 [maxChars]。
  ///
  /// 返回值为每个分片在原文本中的 [start, end) 区间（左闭右开）。
  static List<TextRange> splitForSpeech(
    String text, {
    int maxChars = 1500,
  }) {
    if (text.trim().isEmpty) return const <TextRange>[];
    final List<TextRange> ranges = <TextRange>[];
    final RegExp sentenceEnd = RegExp(r'[。！？!?；;\n]');
    int start = 0;
    while (start < text.length) {
      final int rawEnd = start + maxChars;
      final int hardEnd = rawEnd > text.length ? text.length : rawEnd;
      if (hardEnd >= text.length) {
        ranges.add(TextRange(start: start, end: text.length));
        break;
      }
      // 在 [start + maxChars*0.6, hardEnd] 内寻找最后一个句末标点
      final int rawFrom = start + (maxChars * 0.6).floor();
      final int searchFrom = rawFrom > text.length ? text.length : rawFrom;
      final String window = text.substring(searchFrom, hardEnd);
      int offset = -1;
      for (final Match m in sentenceEnd.allMatches(window)) {
        offset = m.end;
      }
      final int end = offset > 0 ? searchFrom + offset : hardEnd;
      ranges.add(TextRange(start: start, end: end));
      start = end;
    }
    return ranges;
  }

  /// 按句子（中英文标点）切分，返回每句在原文中的区间 —— 用于朗读高亮。
  static List<TextRange> splitSentences(String text) {
    final List<TextRange> out = <TextRange>[];
    if (text.isEmpty) return out;
    final RegExp endMark = RegExp(r'[。！？!?；;…\n]');
    int start = 0;
    for (final Match m in endMark.allMatches(text)) {
      final int end = m.end;
      if (end - start > 0) {
        out.add(TextRange(start: start, end: end));
      }
      start = end;
    }
    if (start < text.length) {
      out.add(TextRange(start: start, end: text.length));
    }
    return out;
  }

  /// 字节数组解码：优先 UTF-8，失败则按 BOM 判断 UTF-16，最后回退 latin1。
  ///
  /// 说明：GBK/GB18030 解码器通过 [charsetDecoder] 注入，MVP 阶段默认不提供，
  /// 后续接入 `charset_converter` 等插件时实现同一接口即可（见 docs/ARCHITECTURE.md）。
  static String decodeBytes(List<int> bytes, {String? charset}) {
    // UTF-8 BOM: EF BB BF
    if (bytes.length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF) {
      bytes = bytes.sublist(3);
    }
    const Utf8Decoder strict = Utf8Decoder();
    try {
      return strict.convert(Uint8List.fromList(bytes));
    } catch (_) {
      // UTF-8 解析失败：交由外部注入的 GBK 解码器，或使用 latin1 兜底（不丢字符）
      return const Latin1Decoder().convert(Uint8List.fromList(bytes));
    }
  }
}

/// 文本区间（左闭右开），与 Flutter 的 TextRange 同名类型保持一致语义。
class TextRange {
  const TextRange({required this.start, required this.end});

  final int start;
  final int end;

  int get length => end - start;

  bool contains(int index) => index >= start && index < end;

  @override
  String toString() => 'TextRange($start, $end)';
}
