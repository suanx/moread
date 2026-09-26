import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

import '../../core/error/failure.dart';
import '../../core/logging/app_logger.dart';
import '../../core/utils/text_utils.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/chapter.dart';
import 'book_parser.dart';
import 'parsed_book.dart';

/// EPUB（2.0 / 3.0）解析器。
///
/// 流程：
/// 1. 读取 `META-INF/container.xml` 定位 OPF；
/// 2. 解析 OPF：metadata / manifest / spine；
/// 3. 解析目录：优先 EPUB3 `nav.xhtml`，回退 EPUB2 `toc.ncx`；
/// 4. 把整包解到 `content/<bookId>/`，章节记录的 `contentPath` 指向本地 XHTML；
/// 5. 抽出封面写入 `covers/`。
///
/// 正文渲染所需的 HTML 在「打开章节时」才生成（见 `BookRepository.loadChapterHtml`），
/// 这样导入大部头书籍也不会一次性占用太多内存。
class EpubParser implements BookParser {
  const EpubParser();

  static const String _tag = 'EpubParser';

  @override
  Set<BookFormat> get supportedFormats => <BookFormat>{BookFormat.epub};

  @override
  Future<ParsedBook> parse(ParseRequest request) async {
    final File file = File(request.sourcePath);
    if (!file.existsSync()) {
      throw const Failure(
        code: Failure.fileNotFound,
        message: 'EPUB 文件不存在，可能已被系统清理',
      );
    }

    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(await file.readAsBytes());
    } catch (e, st) {
      AppLogger.e(_tag, 'zip 解包失败', e, st);
      throw Failure(
        code: Failure.parseFailed,
        message: 'EPUB 文件损坏或不是有效的压缩包',
        cause: e,
      );
    }

    // ---------- 1. container.xml → OPF ----------
    final ArchiveFile? container =
        _findFile(archive, 'META-INF/container.xml');
    if (container == null) {
      throw const Failure(
        code: Failure.parseFailed,
        message: 'EPUB 缺少 META-INF/container.xml',
      );
    }
    final String opfPath = _parseOpfPath(utf8.decode(_bytes(container)));
    final String opfDir = p.dirname(opfPath).replaceAll(r'\', '/');

    final ArchiveFile? opfFile = _findFile(archive, opfPath);
    if (opfFile == null) {
      throw const Failure(
        code: Failure.parseFailed,
        message: 'EPUB 缺少 OPF 描述文件',
      );
    }
    final XmlDocument opf = _safeXml(utf8.decode(_bytes(opfFile)));

    // ---------- 2. metadata ----------
    final XmlElement? metadata = _firstLocal(opf, 'metadata');
    final String title = request.titleHint ??
        _metaText(metadata, 'title') ??
        p.basenameWithoutExtension(request.sourcePath);
    final String author = request.authorHint ?? _metaText(metadata, 'creator') ?? '佚名';
    final String language = _metaText(metadata, 'language') ?? 'zh';
    final String? publisher = _metaText(metadata, 'publisher');
    final String? description = _metaText(metadata, 'description');

    // ---------- 3. manifest ----------
    final Map<String, _ManifestItem> manifest = <String, _ManifestItem>{};
    for (final XmlElement item in _allLocal(opf, 'item')) {
      final String? id = item.getAttribute('id');
      final String? href = item.getAttribute('href');
      if (id == null || href == null) continue;
      manifest[id] = _ManifestItem(
        id: id,
        href: _normalize(p.join(opfDir, href)),
        mediaType: item.getAttribute('media-type') ?? '',
        properties: item.getAttribute('properties') ?? '',
      );
    }

    // ---------- 4. spine ----------
    final XmlElement? spine = _firstLocal(opf, 'spine');
    final String? tocId = spine?.getAttribute('toc');
    final List<String> spineOrder = <String>[];
    if (spine != null) {
      for (final XmlElement ref in _allLocal(spine, 'itemref')) {
        final String? idref = ref.getAttribute('idref');
        if (idref != null && manifest.containsKey(idref)) {
          spineOrder.add(idref);
        }
      }
    }
    if (spineOrder.isEmpty) {
      // 兜底：按 manifest 顺序取所有 XHTML
      spineOrder.addAll(
        manifest.values
            .where((_ManifestItem m) => m.mediaType.contains('html'))
            .map((_ManifestItem m) => m.id),
      );
    }

    // ---------- 5. 解包到本地 ----------
    final Directory outDir = Directory(request.contentDir);
    await _extract(archive, outDir);

    // ---------- 6. 目录（nav.xhtml → ncx） ----------
    final Map<String, String> tocTitle = <String, String>{};
    final _ManifestItem? navItem = manifest.values.firstWhereOrNull(
      (_ManifestItem m) => m.properties.contains('nav'),
    );
    final _ManifestItem? ncxItem = tocId != null ? manifest[tocId] : null;
    if (navItem != null) {
      final File navFile = File(p.join(outDir.path, navItem.href));
      if (navFile.existsSync()) {
        tocTitle.addAll(_parseNavXhtml(await navFile.readAsString()));
      }
    }
    if (tocTitle.isEmpty && ncxItem != null) {
      final File ncxFile = File(p.join(outDir.path, ncxItem.href));
      if (ncxFile.existsSync()) {
        tocTitle.addAll(_parseNcx(await ncxFile.readAsString()));
      }
    }

    // ---------- 7. 生成章节 ----------
    final List<Chapter> chapters = <Chapter>[];
    int index = 0;
    int cursor = 0;
    for (final String idref in spineOrder) {
      final _ManifestItem item = manifest[idref]!;
      final File chapterFile = File(p.join(outDir.path, item.href));
      if (!chapterFile.existsSync()) continue;

      final String raw = await chapterFile.readAsString();
      final String bodyHtml = extractBodyHtml(raw, baseDir: chapterFile.parent);
      final String plain = TextUtils.stripHtml(bodyHtml);
      final int len = plain.length;

      final String? tocKey = _tocKeyFor(item.href);
      final String chapterTitle = tocTitle[tocKey] ??
          tocTitle[item.href] ??
          _firstHeading(raw) ??
          '第 ${index + 1} 章';

      chapters.add(
        Chapter(
          id: '${request.bookId}#$index',
          bookId: request.bookId,
          index: index,
          title: chapterTitle,
          href: item.href,
          contentPath: chapterFile.path,
          startChar: cursor,
          endChar: cursor + len,
        ),
      );
      cursor += len + 1; // +1：章节之间用换行分隔，与 plainText 拼接规则一致
      index++;
    }

    if (chapters.isEmpty) {
      throw const Failure(
        code: Failure.parseFailed,
        message: '未能从该 EPUB 中解析出任何章节',
      );
    }

    // ---------- 8. 封面 ----------
    final String? coverPath = await _extractCover(
      archive: archive,
      opf: opf,
      manifest: manifest,
      coverDir: request.coverDir,
      bookId: request.bookId,
    );

    final Book book = Book(
      id: request.bookId,
      title: title,
      author: author,
      format: BookFormat.epub,
      source: BookSource.local,
      localPath: request.sourcePath,
      contentDir: outDir.path,
      coverPath: coverPath,
      language: language,
      description: description,
      publisher: publisher,
      totalChars: cursor,
      addedAt: DateTime.now().millisecondsSinceEpoch,
    );

    return ParsedBook(book: book, chapters: chapters);
  }

  // =========================================================================
  // 内部方法
  // =========================================================================

  static ArchiveFile? _findFile(Archive archive, String name) {
    for (final ArchiveFile f in archive.files) {
      if (f.name.toLowerCase() == name.toLowerCase()) return f;
    }
    // 部分 EPUB 打包时带 ./ 前缀或大小写差异
    for (final ArchiveFile f in archive.files) {
      if (_normalize(f.name) == _normalize(name)) return f;
    }
    return null;
  }

  static Uint8List _bytes(ArchiveFile f) => Uint8List.fromList(f.content);

  static String _normalize(String path) =>
      p.normalize(path).replaceAll(r'\', '/').replaceAll(RegExp(r'^\./'), '');

  static String _parseOpfPath(String containerXml) {
    try {
      final XmlDocument doc = XmlDocument.parse(containerXml);
      for (final XmlElement e in _allLocal(doc, 'rootfile')) {
        final String? fullPath = e.getAttribute('full-path');
        if (fullPath != null && fullPath.isNotEmpty) {
          return _normalize(fullPath);
        }
      }
    } catch (_) {
      // 部分老书直接把 OPF 放在根目录
    }
    return 'content.opf';
  }

  static XmlDocument _safeXml(String source) {
    try {
      return XmlDocument.parse(source);
    } catch (e) {
      throw Failure(
        code: Failure.parseFailed,
        message: 'EPUB 描述文件 XML 格式非法',
        cause: e,
      );
    }
  }

  static Iterable<XmlElement> _allLocal(XmlNode root, String local) sync* {
    for (final XmlElement node in root.descendants.whereType<XmlElement>()) {
      if (node.name.local == local) yield node;
    }
  }

  static XmlElement? _firstLocal(XmlNode root, String local) {
    for (final XmlElement e in _allLocal(root, local)) {
      return e;
    }
    return null;
  }

  static String? _metaText(XmlElement? metadata, String local) {
    if (metadata == null) return null;
    for (final XmlElement e in _allLocal(metadata, local)) {
      final String t = e.innerText.trim();
      if (t.isNotEmpty) return t;
    }
    return null;
  }

  static Future<void> _extract(Archive archive, Directory outDir) async {
    if (!outDir.existsSync()) {
      await outDir.create(recursive: true);
    }
    for (final ArchiveFile f in archive.files) {
      if (!f.isFile) continue;
      final String safe = _safeJoin(outDir.path, f.name);
      if (safe.isEmpty) continue; // 防御 zip slip 路径穿越
      final File out = File(safe);
      await out.parent.create(recursive: true);
      await out.writeAsBytes(_bytes(f), flush: true);
    }
  }

  /// 拼接路径并校验不会逃逸出 [base]（防止恶意 EPUB 写入任意目录）
  static String _safeJoin(String base, String name) {
    final String normalized = _normalize(name);
    if (normalized.contains('..')) return '';
    final String full = p.normalize(p.join(base, normalized));
    final String baseFull = p.normalize(base);
    if (!p.isWithin(baseFull, full)) return '';
    return full;
  }

  /// 抽取 XHTML 正文的 body 内容，并把图片转成 data URI。
  ///
  /// 转成 data URI 的原因：iOS / Android 的 WebView 对 `file://` 跨目录访问有
  /// 严格限制，直接引用解包后的相对路径容易加载失败；内联可保证离线可用。
  static String extractBodyHtml(
    String xhtml, {
    Directory? baseDir,
    int maxImageBytes = 2 * 1024 * 1024,
  }) {
    try {
      final dom.Document doc = html_parser.parse(xhtml);
      if (baseDir != null) {
        for (final dom.Element img
            in doc.getElementsByTagName('img')) {
          final String? src = img.attributes['src'];
          if (src == null || src.isEmpty || src.startsWith('data:')) continue;
          final File f = File(p.join(baseDir.path, Uri.decodeComponent(src)));
          if (!f.existsSync()) continue;
          final int len = f.lengthSync();
          if (len > maxImageBytes) continue;
          final String? mime = lookupMimeType(f.path) ?? 'image/jpeg';
          img.attributes['src'] =
              'data:$mime;base64,${base64Encode(f.readAsBytesSync())}';
        }
      }
      // 移除脚本与外部样式，统一由 App 主题接管排版
      doc.getElementsByTagName('script').forEach((dom.Node n) => n.remove());
      doc.getElementsByTagName('style').forEach((dom.Node n) => n.remove());
      doc.getElementsByTagName('link').forEach((dom.Node n) => n.remove());
      return doc.body?.innerHtml ?? '';
    } catch (e) {
      AppLogger.w(_tag, '正文抽取失败，回退为纯文本：${e.toString()}');
      return '<p>${TextUtils.escapeXml(TextUtils.stripHtml(xhtml)).replaceAll('\n', '</p><p>')}</p>';
    }
  }

  static String? _firstHeading(String xhtml) {
    final RegExpMatch? m =
        RegExp(r'<h[1-6][^>]*>([\s\S]{0,80}?)</h[1-6]>', caseSensitive: false)
            .firstMatch(xhtml);
    if (m == null) return null;
    final String t = TextUtils.stripHtml(m.group(1) ?? '').trim();
    return t.isEmpty ? null : (t.length > 40 ? '${t.substring(0, 40)}…' : t);
  }

  static String _tocKeyFor(String href) => href.split('#').first;

  static Map<String, String> _parseNavXhtml(String nav) {
    final Map<String, String> out = <String, String>{};
    try {
      final dom.Document doc = html_parser.parse(nav);
      for (final dom.Element navEl in doc.getElementsByTagName('nav')) {
        final String type = navEl.attributes['epub:type'] ??
            navEl.attributes['type'] ??
            '';
        if (!type.contains('toc')) continue;
        for (final dom.Element a in navEl.getElementsByTagName('a')) {
          final String? href = a.attributes['href'];
          final String label = a.text.trim();
          if (href == null || label.isEmpty) continue;
          out[_tocKeyFor(_normalize(href))] = label;
        }
      }
    } catch (_) {
      // 目录解析失败不影响正文阅读
    }
    return out;
  }

  static Map<String, String> _parseNcx(String ncx) {
    final Map<String, String> out = <String, String>{};
    try {
      final XmlDocument doc = XmlDocument.parse(ncx);
      for (final XmlElement point in _allLocal(doc, 'navPoint')) {
        final XmlElement? label = _firstLocal(point, 'navLabel');
        final XmlElement? content = _firstLocal(point, 'content');
        final String? src = content?.getAttribute('src');
        final String text = label?.innerText.trim() ?? '';
        if (src == null || text.isEmpty) continue;
        out[_tocKeyFor(_normalize(src))] = text;
      }
    } catch (_) {
      // 同上
    }
    return out;
  }

  static Future<String?> _extractCover({
    required Archive archive,
    required XmlDocument opf,
    required Map<String, _ManifestItem> manifest,
    required String coverDir,
    required String bookId,
  }) async {
    String? coverId;
    for (final XmlElement meta in _allLocal(opf, 'meta')) {
      if (meta.getAttribute('name') == 'cover') {
        coverId = meta.getAttribute('content');
      }
    }
    _ManifestItem? item = coverId != null ? manifest[coverId] : null;
    item ??= manifest.values.firstWhereOrNull(
      (_ManifestItem m) =>
          m.properties.contains('cover-image') || m.mediaType.startsWith('image/'),
    );
    if (item == null) return null;

    final ArchiveFile? f = _findFile(archive, item.href);
    if (f == null) return null;

    try {
      final Directory dir = Directory(coverDir);
      if (!dir.existsSync()) await dir.create(recursive: true);
      final String ext = p.extension(item.href).replaceAll('.', '');
      final File out = File(p.join(coverDir, '$bookId.${ext.isEmpty ? 'jpg' : ext}'));
      await out.writeAsBytes(_bytes(f), flush: true);
      return out.path;
    } catch (e) {
      AppLogger.w(_tag, '封面提取失败：${e.toString()}');
      return null;
    }
  }
}

/// manifest 中的一条记录
class _ManifestItem {
  const _ManifestItem({
    required this.id,
    required this.href,
    required this.mediaType,
    required this.properties,
  });

  final String id;
  final String href;
  final String mediaType;
  final String properties;
}

/// 为 Iterable 提供 firstWhereOrNull（避免引入额外依赖）
extension _IterableX<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final T e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
