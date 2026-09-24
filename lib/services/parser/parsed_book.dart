import '../../domain/entities/book.dart';
import '../../domain/entities/chapter.dart';

/// 解析请求：解析器只负责「把文件变成结构化数据」，不负责落库。
class ParseRequest {
  const ParseRequest({
    required this.bookId,
    required this.sourcePath,
    required this.contentDir,
    required this.coverDir,
    this.titleHint,
    this.authorHint,
  });

  /// 预生成的书籍 id（调用方分配，保证文件与数据库一致）
  final String bookId;

  /// 已复制到应用私有目录的源文件路径
  final String sourcePath;

  /// 解包目录（content/<bookId>）
  final String contentDir;

  /// 封面输出目录（covers）
  final String coverDir;

  final String? titleHint;
  final String? authorHint;
}

/// 解析结果。
class ParsedBook {
  const ParsedBook({
    required this.book,
    required this.chapters,
  });

  final Book book;
  final List<Chapter> chapters;

  int get charCount => chapters.fold<int>(
        0,
        (int sum, Chapter c) => sum + (c.endChar - c.startChar),
      );
}
