/// 阅读进度快照（一本书一条，主键为 bookId）。
class ReadingProgress {
  const ReadingProgress({
    required this.bookId,
    required this.chapterId,
    required this.chapterIndex,
    this.chapterRatio = 0,
    this.bookRatio = 0,
    this.position = 0,
    this.page = 0,
    this.updatedAt = 0,
  });

  final String bookId;

  /// 当前章节 id
  final String chapterId;
  final int chapterIndex;

  /// 章节内进度 0~1（翻页模式 = 当前页 / 总页数；滚动模式 = 滚动比例）
  final double chapterRatio;

  /// 全书进度 0~1
  final double bookRatio;

  /// 章节内字符偏移（TXT/EPUB）或 PDF 页码
  final int position;

  /// PDF 页码（从 1 开始）
  final int page;

  final int updatedAt;

  ReadingProgress copyWith({
    String? chapterId,
    int? chapterIndex,
    double? chapterRatio,
    double? bookRatio,
    int? position,
    int? page,
    int? updatedAt,
  }) =>
      ReadingProgress(
        bookId: bookId,
        chapterId: chapterId ?? this.chapterId,
        chapterIndex: chapterIndex ?? this.chapterIndex,
        chapterRatio: chapterRatio ?? this.chapterRatio,
        bookRatio: bookRatio ?? this.bookRatio,
        position: position ?? this.position,
        page: page ?? this.page,
        updatedAt: updatedAt ?? DateTime.now().millisecondsSinceEpoch,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'bookId': bookId,
        'chapterId': chapterId,
        'chapterIndex': chapterIndex,
        'chapterRatio': chapterRatio,
        'bookRatio': bookRatio,
        'position': position,
        'page': page,
        'updatedAt': updatedAt,
      };

  factory ReadingProgress.fromMap(Map<String, dynamic> m) => ReadingProgress(
        bookId: m['bookId'] as String,
        chapterId: m['chapterId'] as String? ?? '',
        chapterIndex: m['chapterIndex'] as int? ?? 0,
        chapterRatio: (m['chapterRatio'] as num?)?.toDouble() ?? 0,
        bookRatio: (m['bookRatio'] as num?)?.toDouble() ?? 0,
        position: m['position'] as int? ?? 0,
        page: m['page'] as int? ?? 0,
        updatedAt: m['updatedAt'] as int? ?? 0,
      );

  @override
  String toString() =>
      'ReadingProgress($bookId, ch=$chapterIndex, ${(bookRatio * 100).toStringAsFixed(1)}%)';
}
