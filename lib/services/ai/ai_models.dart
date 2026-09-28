/// AI 能力的领域模型。
///
/// 说明：当前实现为本地 Mock（见 `ai_service.dart`），
/// 这些模型即为「真实大模型接入」后的返回值契约，替换服务实现即可无缝升级。
library;

/// AI 四类生成能力。
///
/// 顺序与 UI（AI 中心宫格）保持一致。
enum AiCapability {
  qa('问答', '就书中内容提问，逐句给出出处', '问'),
  summary('总结', '抽取章节要点与关键情节', '总'),
  cards('知识卡片', '把知识点拆成可回顾的卡片', '卡'),
  mindmap('思维导图', '梳理人物、事件与结构脉络', '图');

  const AiCapability(this.label, this.description, this.badge);

  /// 能力名称（问答 / 总结 / 知识卡片 / 思维导图）
  final String label;

  /// 一句话说明，用于能力卡片副标题
  final String description;

  /// 卡片右上角的单字标记
  final String badge;
}

/// 对话消息（问答页使用）。
class AiMessage {
  const AiMessage({
    required this.role,
    required this.text,
    this.references = const <String>[],
    this.pending = false,
  });

  /// 提问方
  static const String roleUser = 'user';

  /// 回答方
  static const String roleAssistant = 'assistant';

  final String role;

  final String text;

  /// 回答引用的原文片段（可空）
  final List<String> references;

  /// 是否正在生成（用于展示打字/骨架态）
  final bool pending;

  bool get isUser => role == roleUser;

  AiMessage copyWith({String? text, List<String>? references, bool? pending}) =>
      AiMessage(
        role: role,
        text: text ?? this.text,
        references: references ?? this.references,
        pending: pending ?? this.pending,
      );
}

/// 总结结果：一段总览 + 若干要点。
class AiSummary {
  const AiSummary({
    required this.title,
    required this.overview,
    required this.points,
    required this.keywords,
    required this.charCount,
  });

  /// 结果标题（通常为「《书名》· 章节名」）
  final String title;

  /// 整体概述
  final String overview;

  /// 要点列表
  final List<AiSummaryPoint> points;

  /// 关键词
  final List<String> keywords;

  /// 参与生成的正文字数
  final int charCount;
}

/// 总结要点。
class AiSummaryPoint {
  const AiSummaryPoint({
    required this.heading,
    required this.detail,
    this.quote = '',
  });

  final String heading;
  final String detail;

  /// 对应的原文摘录
  final String quote;
}

/// 知识卡片集合。
class AiKnowledgeCards {
  const AiKnowledgeCards({required this.cards, required this.sourceTitle});

  final List<AiKnowledgeCard> cards;

  /// 来源（书名 · 章节）
  final String sourceTitle;
}

/// 单张知识卡片。
class AiKnowledgeCard {
  const AiKnowledgeCard({
    required this.title,
    required this.body,
    required this.tag,
  });

  final String title;
  final String body;

  /// 分类标签，例如「人物」「情节」「概念」
  final String tag;
}

/// 思维导图节点（树形）。
class MindMapNode {
  const MindMapNode({
    required this.title,
    this.note = '',
    this.children = const <MindMapNode>[],
  });

  final String title;

  /// 节点的补充说明（可空）
  final String note;

  final List<MindMapNode> children;

  /// 树的节点总数（绘制时用于估算画布尺寸）
  int get size =>
      1 + children.fold<int>(0, (int sum, MindMapNode c) => sum + c.size);

  /// 叶子节点数（绘制时用于分配垂直空间）
  int get leafCount {
    if (children.isEmpty) return 1;
    return children.fold<int>(0, (int sum, MindMapNode c) => sum + c.leafCount);
  }
}
