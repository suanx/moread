/// 笔记 / 划线。
///
/// 与 [Bookmark] 的区别：笔记必须有选中的原文 [quote]，
/// 可选附用户自己的感想 [content]。
class Note {
  const Note({
    required this.id,
    required this.bookId,
    required this.chapterId,
    required this.chapterTitle,
    required this.quote,
    required this.createdAt,
    this.content = '',
    this.start = 0,
    this.end = 0,
    this.color = 0xFFE8A33D,
    this.updatedAt = 0,
  });

  final String id;
  final String bookId;
  final String chapterId;
  final String chapterTitle;

  /// 划线的原文
  final String quote;

  /// 用户感想
  final String content;

  /// 划线在章节纯文本中的起止偏移
  final int start;
  final int end;

  /// 划线颜色 ARGB
  final int color;

  final int createdAt;
  final int updatedAt;

  Note copyWith({String? content, int? color, int? updatedAt}) => Note(
        id: id,
        bookId: bookId,
        chapterId: chapterId,
        chapterTitle: chapterTitle,
        quote: quote,
        content: content ?? this.content,
        start: start,
        end: end,
        color: color ?? this.color,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now().millisecondsSinceEpoch,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'bookId': bookId,
        'chapterId': chapterId,
        'chapterTitle': chapterTitle,
        'quote': quote,
        'content': content,
        'start': start,
        'end': end,
        'color': color,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory Note.fromMap(Map<String, dynamic> m) => Note(
        id: m['id'] as String,
        bookId: m['bookId'] as String,
        chapterId: m['chapterId'] as String? ?? '',
        chapterTitle: m['chapterTitle'] as String? ?? '',
        quote: m['quote'] as String? ?? '',
        content: m['content'] as String? ?? '',
        start: m['start'] as int? ?? 0,
        end: m['end'] as int? ?? 0,
        color: m['color'] as int? ?? 0xFFE8A33D,
        createdAt: m['createdAt'] as int? ?? 0,
        updatedAt: m['updatedAt'] as int? ?? 0,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Note && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
