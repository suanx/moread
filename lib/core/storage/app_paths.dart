import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 应用私有文件目录统一管理。
///
/// 目录结构：
/// ```
/// <supportDir>/
///   books/            # 导入的源文件（epub/txt/pdf 原文件）
///   content/          # 解包后的章节内容（按 bookId 分目录）
///   covers/           # 封面缓存
///   tts/              # Edge-TTS 合成出的音频分片
///   temp/             # 临时文件，启动时清理
/// ```
class AppPaths {
  AppPaths._(this.root);

  final Directory root;

  static AppPaths? _instance;

  static AppPaths get instance => _instance ??
      (throw StateError('AppPaths 尚未初始化，请在 bootstrap 阶段调用 AppPaths.init()'));

  /// 初始化。需在 `WidgetsFlutterBinding.ensureInitialized()` 之后调用。
  static Future<AppPaths> init() async {
    if (_instance != null) return _instance!;
    final Directory base = await getApplicationSupportDirectory();
    final AppPaths paths = AppPaths._(base);
    await paths.ensureAll();
    _instance = paths;
    return paths;
  }

  late final Directory books = Directory(p.join(root.path, 'books'));
  late final Directory content = Directory(p.join(root.path, 'content'));
  late final Directory covers = Directory(p.join(root.path, 'covers'));
  late final Directory tts = Directory(p.join(root.path, 'tts'));
  late final Directory temp = Directory(p.join(root.path, 'temp'));

  Future<void> ensureAll() async {
    for (final Directory d in <Directory>[books, content, covers, tts, temp]) {
      if (!d.existsSync()) {
        await d.create(recursive: true);
      }
    }
  }

  /// 某本书的原文路径：books/<bookId>.<ext>
  String bookFile(String bookId, String ext) =>
      p.join(books.path, '$bookId.$ext');

  /// 某本书解包后的内容目录：content/<bookId>/
  Directory bookContentDir(String bookId) =>
      Directory(p.join(content.path, bookId));

  /// 某本书的 TTS 缓存目录：tts/<bookId>/<chapterId>/
  Directory ttsDir(String bookId, String chapterId) =>
      Directory(p.join(tts.path, bookId, chapterId));

  /// 封面路径：covers/<bookId>.<ext>
  String coverFile(String bookId, String ext) =>
      p.join(covers.path, '$bookId.$ext');

  /// 清理临时目录（不清目录本身）
  Future<void> clearTemp() async {
    if (!await temp.exists()) return;
    await for (final FileSystemEntity e in temp.list()) {
      try {
        await e.delete(recursive: true);
      } catch (_) {
        // 忽略删除失败：临时目录清理失败不影响主流程
      }
    }
  }

  /// 递归计算目录占用大小（字节）
  Future<int> dirSize(Directory d) async {
    if (!await d.exists()) return 0;
    int total = 0;
    await for (final FileSystemEntity e in d.list(recursive: true)) {
      if (e is File) {
        total += await e.length();
      }
    }
    return total;
  }
}
