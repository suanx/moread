import '../../core/error/failure.dart';
import '../../domain/entities/book.dart';
import 'book_parser.dart';

/// 解析器注册表：按文件扩展名分发到具体解析器。
class ParserRegistry {
  ParserRegistry(this._parsers);

  final List<BookParser> _parsers;

  bool supports(String ext) {
    try {
      final BookFormat f = BookFormat.fromExtension(ext);
      return _parsers.any((BookParser p) => p.supportedFormats.contains(f));
    } catch (_) {
      return false;
    }
  }

  BookParser parserFor(String ext) {
    final BookFormat format;
    try {
      format = BookFormat.fromExtension(ext);
    } catch (_) {
      throw Failure(
        code: Failure.unsupportedFormat,
        message: '暂不支持 .$ext 格式，目前支持 EPUB / TXT / PDF',
      );
    }
    for (final BookParser p in _parsers) {
      if (p.supportedFormats.contains(format)) return p;
    }
    throw Failure(
      code: Failure.unsupportedFormat,
      message: '未注册 ${format.name.toUpperCase()} 解析器',
    );
  }
}
