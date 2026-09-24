/// 书签：记录「读到哪里」。
class Bookmark {
  const Bookmark({
    required this.id,
    required this.bookId,
    required this.chapterId,
    required this.chapterTitle,
    required this.position,
    required this.excerpt,
    required this.createdAt,
    this.chapterRatio = 0,
  });

  final String id;
  final String bookId;
  final String chapterId;
  final String chapterTitle;

  /// 章节内字符偏移（PDF 为页码）
  final int position;

  /// 进度比例（用于从书签跳转）
  final double chapterRatio;

  /// 位置附近的正文摘要
  final String excerpt;

  final int createdAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'bookId': bookId,
        'chapterId': chapterId,
        'chapterTitle': chapterTitle,
        'position': position,
        'chapterRatio': chapterRatio,
        'excerpt': excerpt,
        'createdAt': createdAt,
      };

  factory Bookmark.fromMap(Map<String, dynamic> m) => Bookmark(
        id: m['id'] as String,
        bookId: m['bookId'] as String,
        chapterId: m['chapterId'] as String? ?? '',
        chapterTitle: m['chapterTitle'] as String? ?? '',
        position: m['position'] as int? ?? 0,
        chapterRatio: (m['chapterRatio'] as num?)?.toDouble() ?? 0,
        excerpt: m['excerpt'] as String? ?? '',
        createdAt: m['createdAt'] as int? ?? 0,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Bookmark && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
