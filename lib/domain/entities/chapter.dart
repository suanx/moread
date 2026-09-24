/// 章节实体。
///
/// 统一抽象三种格式：
/// - EPUB：对应 spine 中的一个文档；
/// - TXT：按「第X章」正则切分出来的一段；
/// - PDF：对应书签/大纲条目；无大纲时全书视为单章，[pageStart]/[pageEnd] 生效。
class Chapter {
  const Chapter({
    required this.id,
    required this.bookId,
    required this.index,
    required this.title,
    this.href,
    this.contentPath,
    this.startChar = 0,
    this.endChar = 0,
    this.pageStart,
    this.pageEnd,
    this.level = 0,
  });

  final String id;
  final String bookId;
  final int index;
  final String title;

  /// EPUB 内部相对路径（含可选 #fragment）
  final String? href;

  /// 解包后的本地文件绝对路径（EPUB 章节 HTML；TXT 分片文本文件）
  final String? contentPath;

  /// 在全书纯文本中的起止字符偏移（TXT / EPUB 有效）
  final int startChar;
  final int endChar;

  /// PDF 页码区间（从 1 开始）
  final int? pageStart;
  final int? pageEnd;

  /// 目录层级（0 为顶级）
  final int level;

  int get charCount {
    final int n = endChar - startChar;
    return n < 0 ? 0 : n;
  }

  Chapter copyWith({
    String? title,
    int? index,
    String? href,
    String? contentPath,
    int? startChar,
    int? endChar,
    int? pageStart,
    int? pageEnd,
    int? level,
  }) =>
      Chapter(
        id: id,
        bookId: bookId,
        index: index ?? this.index,
        title: title ?? this.title,
        href: href ?? this.href,
        contentPath: contentPath ?? this.contentPath,
        startChar: startChar ?? this.startChar,
        endChar: endChar ?? this.endChar,
        pageStart: pageStart ?? this.pageStart,
        pageEnd: pageEnd ?? this.pageEnd,
        level: level ?? this.level,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'bookId': bookId,
        'index': index,
        'title': title,
        'href': href,
        'contentPath': contentPath,
        'startChar': startChar,
        'endChar': endChar,
        'pageStart': pageStart,
        'pageEnd': pageEnd,
        'level': level,
      };

  factory Chapter.fromMap(Map<String, dynamic> m) => Chapter(
        id: m['id'] as String,
        bookId: m['bookId'] as String,
        index: m['index'] as int? ?? 0,
        title: m['title'] as String? ?? '',
        href: m['href'] as String?,
        contentPath: m['contentPath'] as String?,
        startChar: m['startChar'] as int? ?? 0,
        endChar: m['endChar'] as int? ?? 0,
        pageStart: m['pageStart'] as int?,
        pageEnd: m['pageEnd'] as int?,
        level: m['level'] as int? ?? 0,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Chapter && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Chapter($index, $title)';
}
