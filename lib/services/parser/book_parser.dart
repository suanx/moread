import '../../domain/entities/book.dart';
import 'parsed_book.dart';

/// 书籍解析器统一接口。
///
/// 新增格式（mobi / azw3 / docx）时，实现本接口并注册到 [ParserRegistry] 即可，
/// 上层（导入流程、阅读器）无需改动。
abstract interface class BookParser {
  /// 支持的格式集合
  Set<BookFormat> get supportedFormats;

  /// 解析入口。失败时抛 [Failure]。
  Future<ParsedBook> parse(ParseRequest request);
}
