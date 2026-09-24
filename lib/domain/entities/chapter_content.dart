import '../../core/utils/text_utils.dart';

/// 章节渲染内容：可直接喂给 WebView 的 HTML + 与之严格对齐的纯文本与句段区间。
///
/// 三者对齐是「朗读高亮」「划线笔记」「按字符定位」能够工作的前提：
/// HTML 中每个句段都被包裹成 `<span data-s="start" data-e="end">`，
/// start/end 即 [plainText] 中的字符偏移。
class ChapterContent {
  const ChapterContent({
    required this.html,
    required this.plainText,
    this.sentences = const <TextRange>[],
  });

  final String html;
  final String plainText;

  /// 句段区间（用于朗读高亮快速定位）
  final List<TextRange> sentences;

  bool get isEmpty => plainText.trim().isEmpty;
}
