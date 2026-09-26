/// 书籍来源：本地导入 / 在线书城下载
enum BookSource { local, online }

/// 受支持的书籍格式
enum BookFormat {
  epub,
  txt,
  pdf;

  static BookFormat fromExtension(String ext) {
    switch (ext.toLowerCase().replaceAll('.', '')) {
      case 'epub':
        return BookFormat.epub;
      case 'txt':
      case 'text':
        return BookFormat.txt;
      case 'pdf':
        return BookFormat.pdf;
      default:
        throw ArgumentError('不支持的文件格式：$ext');
    }
  }

  String get extension => name;
}

/// 书籍实体（书架列表 / 书籍详情的核心模型）。
class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.format,
    required this.source,
    required this.localPath,
    required this.addedAt,
    this.contentDir,
    this.coverPath,
    this.sourceUri,
    this.language,
    this.description,
    this.publisher,
    this.totalChars = 0,
    this.totalPages = 0,
    this.lastReadAt,
    this.progress = 0,
    this.favorite = false,
    this.tags = const <String>[],
  });

  final String id;
  final String title;
  final String author;
  final BookFormat format;

  /// 来源（本地 / 在线）
  final BookSource source;

  /// 本地缓存的原始文件路径
  final String localPath;

  /// 解包后的章节内容目录（EPUB 使用）
  final String? contentDir;

  /// 封面本地路径
  final String? coverPath;

  /// 在线书籍的原始下载地址
  final String? sourceUri;

  final String? language;
  final String? description;
  final String? publisher;

  /// 全书字数（用于阅读统计与进度估算）
  final int totalChars;

  /// PDF 页数
  final int totalPages;

  final int addedAt;
  final int? lastReadAt;

  /// 0.0 ~ 1.0 阅读进度（冗余字段，便于书架展示）
  final double progress;

  final bool favorite;
  final List<String> tags;

  bool get isRead => progress >= 0.99;

  bool get isReading => progress > 0 && progress < 0.99;

  Book copyWith({
    String? title,
    String? author,
    String? sourceUri,
    String? coverPath,
    String? contentDir,
    String? description,
    String? publisher,
    String? language,
    int? totalChars,
    int? totalPages,
    int? lastReadAt,
    double? progress,
    bool? favorite,
    List<String>? tags,
  }) =>
      Book(
        id: id,
        title: title ?? this.title,
        author: author ?? this.author,
        format: format,
        source: source,
        localPath: localPath,
        contentDir: contentDir ?? this.contentDir,
        coverPath: coverPath ?? this.coverPath,
        sourceUri: sourceUri ?? this.sourceUri,
        language: language ?? this.language,
        description: description ?? this.description,
        publisher: publisher ?? this.publisher,
        totalChars: totalChars ?? this.totalChars,
        totalPages: totalPages ?? this.totalPages,
        addedAt: addedAt,
        lastReadAt: lastReadAt ?? this.lastReadAt,
        progress: progress ?? this.progress,
        favorite: favorite ?? this.favorite,
        tags: tags ?? this.tags,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'title': title,
        'author': author,
        'format': format.name,
        'source': source.name,
        'localPath': localPath,
        'contentDir': contentDir,
        'coverPath': coverPath,
        'sourceUri': sourceUri,
        'language': language,
        'description': description,
        'publisher': publisher,
        'totalChars': totalChars,
        'totalPages': totalPages,
        'addedAt': addedAt,
        'lastReadAt': lastReadAt,
        'progress': progress,
        'favorite': favorite,
        'tags': tags,
      };

  factory Book.fromMap(Map<String, dynamic> m) => Book(
        id: m['id'] as String,
        title: m['title'] as String? ?? '未命名',
        author: m['author'] as String? ?? '佚名',
        format: BookFormat.values.firstWhere(
          (BookFormat e) => e.name == m['format'],
          orElse: () => BookFormat.txt,
        ),
        source: BookSource.values.firstWhere(
          (BookSource e) => e.name == m['source'],
          orElse: () => BookSource.local,
        ),
        localPath: m['localPath'] as String? ?? '',
        contentDir: m['contentDir'] as String?,
        coverPath: m['coverPath'] as String?,
        sourceUri: m['sourceUri'] as String?,
        language: m['language'] as String?,
        description: m['description'] as String?,
        publisher: m['publisher'] as String?,
        totalChars: m['totalChars'] as int? ?? 0,
        totalPages: m['totalPages'] as int? ?? 0,
        addedAt: m['addedAt'] as int? ?? 0,
        lastReadAt: m['lastReadAt'] as int?,
        progress: (m['progress'] as num?)?.toDouble() ?? 0,
        favorite: m['favorite'] as bool? ?? false,
        tags: (m['tags'] as List<dynamic>?)
                ?.map((dynamic e) => e.toString())
                .toList() ??
            const <String>[],
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Book && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Book($id, $title, ${format.name}, $progress)';
}
