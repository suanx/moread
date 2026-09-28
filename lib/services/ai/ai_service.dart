import 'ai_models.dart';

/// AI 能力服务契约。
///
/// 当前由 [MockAiService] 提供本地实现：不联网、不依赖任何 Key，
/// 但输出结构、异步时序（延迟 + Loading 态）与真实大模型完全一致。
/// 后续接入真实服务时，只需新增一个 `implements AiService` 的实现，
/// 并在 `aiServiceProvider` 中替换，UI 层无需改动。
abstract interface class AiService {
  /// 章节总结：总览 + 要点 + 关键词
  Future<AiSummary> summarize({
    required String bookTitle,
    required String chapterTitle,
    required String text,
  });

  /// 知识卡片抽取
  Future<AiKnowledgeCards> extractCards({
    required String bookTitle,
    required String chapterTitle,
    required String text,
  });

  /// 思维导图（人物 / 事件 / 场景 / 主题）
  Future<MindMapNode> buildMindMap({
    required String bookTitle,
    required String chapterTitle,
    required String text,
  });

  /// 问答：返回回答正文 + 引用的原文片段
  Future<AiAnswer> ask({
    required String bookTitle,
    required String question,
    required String text,
  });
}

/// 问答结果。
class AiAnswer {
  const AiAnswer({required this.text, this.references = const <String>[]});

  final String text;
  final List<String> references;
}

/// 本地 Mock 实现。
///
/// 设计原则：
/// - **确定性**：同一段文本永远得到同样的结果，便于测试与回归；
/// - **有依据**：所有输出都从传入正文里抽取（检索式），不是无脑随机文案，
///   因此换一本书、换一章内容，结果确实会变化；
/// - **可替换**：只用 Dart 标准能力（String/RegExp），不引入额外依赖。
class MockAiService implements AiService {
  const MockAiService();

  /// 模拟网络/推理耗时，让 UI 的 Loading 态真实可感
  static const Duration _latency = Duration(milliseconds: 900);

  /// 中文停顿标点：用于切句
  static final RegExp _sentenceSplit = RegExp(r'[。！？!?…\n]+');

  /// 仅保留中文/字母/数字的 2-gram 词频统计用正则
  static final RegExp _wordChar = RegExp(r'[\u4e00-\u9fa5A-Za-z0-9]');

  static const List<String> _stopWords = <String>[
    '什么', '一个', '自己', '我们', '他们', '你们', '这个', '那个', '就是',
    '可以', '因为', '所以', '但是', '如果', '已经', '没有', '还是', '这样',
    '不是', '时候', '这里', '那里', '知道', '觉得', '一样', '这么多',
  ];

  static const List<String> _cardTags = <String>['人物', '情节', '概念', '金句', '背景'];

  // =========================================================================
  // 总结
  // =========================================================================

  @override
  Future<AiSummary> summarize({
    required String bookTitle,
    required String chapterTitle,
    required String text,
  }) async {
    await Future<void>.delayed(_latency);

    final List<String> sentences = _sentences(text);
    final List<String> keywords = _keywords(sentences);

    final String overview = sentences.isEmpty
        ? '本章内容较少，暂无可提炼的要点。'
        : '${_clip(sentences.first, 60)}。本章围绕'
            '${keywords.take(3).join('、')}展开，'
            '共 ${sentences.length} 个句段、约 ${_charCount(text)} 字。';

    final List<AiSummaryPoint> points = <AiSummaryPoint>[];
    final List<String> picked = _spread(sentences, count: 4);
    for (int i = 0; i < picked.length; i++) {
      final String s = picked[i];
      points.add(
        AiSummaryPoint(
          heading: '要点 ${i + 1} · ${_headline(s)}',
          detail: _clip(s, 90),
          quote: _clip(s, 40),
        ),
      );
    }

    return AiSummary(
      title: '《$bookTitle》· $chapterTitle',
      overview: overview,
      points: points,
      keywords: keywords,
      charCount: _charCount(text),
    );
  }

  // =========================================================================
  // 知识卡片
  // =========================================================================

  @override
  Future<AiKnowledgeCards> extractCards({
    required String bookTitle,
    required String chapterTitle,
    required String text,
  }) async {
    await Future<void>.delayed(_latency);

    final List<String> sentences = _sentences(text);
    final List<String> keywords = _keywords(sentences);
    final List<AiKnowledgeCard> cards = <AiKnowledgeCard>[];

    final List<String> picked = _spread(sentences, count: 6);
    for (int i = 0; i < picked.length; i++) {
      final String s = picked[i];
      final String key = i < keywords.length ? keywords[i] : '要点';
      cards.add(
        AiKnowledgeCard(
          title: '$key · ${_clip(s, 12)}',
          body: _clip(s, 88),
          tag: _cardTags[i % _cardTags.length],
        ),
      );
    }

    return AiKnowledgeCards(
      cards: cards,
      sourceTitle: '《$bookTitle》· $chapterTitle',
    );
  }

  // =========================================================================
  // 思维导图
  // =========================================================================

  @override
  Future<MindMapNode> buildMindMap({
    required String bookTitle,
    required String chapterTitle,
    required String text,
  }) async {
    await Future<void>.delayed(_latency);

    final List<String> sentences = _sentences(text);
    final List<String> keywords = _keywords(sentences);

    /// 依「分组名 + 命中关键词的句子」生成一个分支
    MindMapNode branch(String name, List<String> pool, int take) {
      final List<String> leaves = pool.take(take).map((String s) => _clip(s, 18)).toList();
      return MindMapNode(
        title: name,
        note: leaves.isEmpty ? '本章未提及' : '${leaves.length} 个条目',
        children: leaves
            .map((String leaf) => MindMapNode(title: leaf))
            .toList(growable: false),
      );
    }

    return MindMapNode(
      title: chapterTitle,
      note: '《$bookTitle》· 共 ${sentences.length} 个句段',
      children: <MindMapNode>[
        branch('核心人物', sentences.where((String s) => s.contains('他') || s.contains('她')).toList(), 3),
        branch('关键事件', sentences.where((String s) => s.contains('于是') || s.contains('后来') || s.contains('终于')).toList(), 3),
        branch('重要场景', sentences.where((String s) => s.contains('时候') || s.contains('街上') || s.contains('屋')).toList(), 2),
        branch(
          '主题词',
          keywords.take(4).map((String k) => '$k：本章反复出现').toList(),
          4,
        ),
      ],
    );
  }

  // =========================================================================
  // 问答（检索式）
  // =========================================================================

  @override
  Future<AiAnswer> ask({
    required String bookTitle,
    required String question,
    required String text,
  }) async {
    await Future<void>.delayed(_latency);

    final List<String> sentences = _sentences(text);
    final List<String> grams = _grams(question.replaceAll(RegExp(r'[？?。！!，,、\s]'), ''));

    // 命中打分：句子里包含的提问片段越多，越相关
    final List<({String sentence, int score})> scored =
        <({String sentence, int score})>[
      for (final String s in sentences)
        (
          sentence: s,
          score: grams.where((String g) => s.contains(g)).length,
        ),
    ]..sort((({String sentence, int score}) a, ({String sentence, int score}) b) =>
        b.score.compareTo(a.score));

    final List<String> hits = scored
        .where((({String sentence, int score}) e) => e.score > 0)
        .take(2)
        .map((({String sentence, int score}) e) => _clip(e.sentence, 60))
        .toList();

    final String answer;
    if (hits.isEmpty) {
      answer = '在《$bookTitle》的当前章节里没有直接提到这一点。\n'
          '可以换一种问法，或先读一段正文再问我——我会基于已读内容回答（当前为本地模拟模式）。';
    } else {
      answer = '根据本章内容，${hits.length == 1 ? '' : '可以这样理解：'}\n'
          '${hits.map((String h) => '· $h').join('\n')}\n'
          '——以上引自本章正文（本地模拟模式，接入真实模型后会给出更完整的推理）。';
    }

    return AiAnswer(text: answer, references: hits);
  }

  // =========================================================================
  // 文本工具
  // =========================================================================

  /// 切句：去掉标点残留与过短片段
  List<String> _sentences(String text) => text
      .split(_sentenceSplit)
      .map((String s) => s.trim())
      .where((String s) => _charCount(s) >= 8)
      .toList(growable: false);

  /// 关键词：中文 2-gram 词频 Top-N，过滤停用词
  List<String> _keywords(List<String> sentences) {
    final Map<String, int> freq = <String, int>{};
    for (final String s in sentences) {
      final List<String> grams = _grams(s);
      for (final String g in grams) {
        freq[g] = (freq[g] ?? 0) + 1;
      }
    }
    final List<MapEntry<String, int>> entries = freq.entries
        .where((MapEntry<String, int> e) =>
            e.value >= 2 && !_stopWords.contains(e.key))
        .toList()
      ..sort((MapEntry<String, int> a, MapEntry<String, int> b) =>
          b.value.compareTo(a.value));
    final List<String> top =
        entries.take(6).map((MapEntry<String, int> e) => e.key).toList();
    return top.isEmpty
        ? <String>[for (final String s in sentences.take(3)) _clip(s, 4)]
        : top;
  }

  /// 提取连续 2-gram（仅中文/字母/数字参与）
  List<String> _grams(String source) {
    final List<String> chars = source
        .split('')
        .where((String c) => _wordChar.hasMatch(c))
        .toList(growable: false);
    final List<String> grams = <String>[];
    for (int i = 0; i + 1 < chars.length; i++) {
      grams.add('${chars[i]}${chars[i + 1]}');
    }
    return grams;
  }

  /// 均匀取样，避免所有要点都来自开头
  List<String> _spread(List<String> src, {required int count}) {
    if (src.isEmpty) return const <String>[];
    if (src.length <= count) return src;
    final List<String> out = <String>[];
    final double step = src.length / count;
    for (int i = 0; i < count; i++) {
      out.add(src[(i * step).floor()]);
    }
    return out;
  }

  /// 要点小标题：取句中最长的关键词片段，兜底用句首
  String _headline(String sentence) {
    final List<String> grams = _grams(sentence);
    if (grams.isEmpty) return _clip(sentence, 8);
    final String first = grams.first;
    final String last = grams.last;
    return first == last ? first : '$first…$last';
  }

  int _charCount(String text) =>
      text.runes.where((int r) => r > 32).length;

  String _clip(String text, int max) =>
      text.length <= max ? text : '${text.substring(0, max)}…';
}
