import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../core/error/failure.dart';
import '../../core/logging/app_logger.dart';
import '../../core/storage/app_paths.dart';
import '../parser/parsed_book.dart';
import '../parser/parser_registry.dart';

/// 本地导入流程编排：复制文件 → 选择解析器 → 解析 → 返回结构化结果。
///
/// 复制而非直接引用原路径的原因：
/// iOS / Android 的第三方目录（下载、微信、QQ）随时可能被清理，
/// 复制到应用私有目录才能保证「导入即可离线阅读」。
class BookImporter {
  BookImporter({
    required ParserRegistry registry,
    required AppPaths paths,
    Uuid? uuid,
  })  : _registry = registry,
        _paths = paths,
        _uuid = uuid ?? const Uuid();

  static const String _tag = 'BookImporter';

  final ParserRegistry _registry;
  final AppPaths _paths;
  final Uuid _uuid;

  /// 支持的文件后缀（供文件选择器过滤）
  static const List<String> supportedExtensions = <String>['epub', 'txt', 'pdf'];

  Future<ParsedBook> import(
    String sourcePath, {
    String? title,
    String? author,
  }) async {
    final File src = File(sourcePath);
    if (!src.existsSync()) {
      throw const Failure(
        code: Failure.fileNotFound,
        message: '所选文件不存在或已被系统清理',
      );
    }

    final String ext = p.extension(sourcePath).replaceAll('.', '');
    if (!_registry.supports(ext)) {
      throw Failure(
        code: Failure.unsupportedFormat,
        message: '暂不支持 .$ext 格式，目前支持 EPUB / TXT / PDF',
      );
    }

    final String bookId = _uuid.v4();
    final String dest = _paths.bookFile(bookId, ext.toLowerCase());
    try {
      await src.copy(dest);
    } catch (e, st) {
      AppLogger.e(_tag, '复制文件失败', e, st);
      throw Failure(
        code: Failure.fileNotFound,
        message: '文件复制失败，可能是权限不足或存储空间不足',
        cause: e,
      );
    }

    final ParseRequest request = ParseRequest(
      bookId: bookId,
      sourcePath: dest,
      contentDir: _paths.bookContentDir(bookId).path,
      coverDir: _paths.covers.path,
      titleHint: title,
      authorHint: author,
    );

    return _registry.parserFor(ext).parse(request);
  }
}
