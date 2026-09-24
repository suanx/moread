import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../core/logging/app_logger.dart';
import '../../core/theme/reader_themes.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/reader_settings.dart';

/// WebView 阅读视图。
///
/// 只做三件事：
/// 1. 加载 `ContentHtmlBuilder` 产出的 HTML；
/// 2. 把 Dart 侧的设置/指令翻译成 `window.Reader.*` 调用；
/// 3. 把 WebView 的事件（进度、点击、选区）回调给上层。
///
/// 若将来接入其它渲染内核（如 Web 端 iframe），只需替换本文件。
class ReaderView extends StatefulWidget {
  const ReaderView({
    super.key,
    required this.html,
    required this.settings,
    this.onProgress,
    this.onTapCenter,
    this.onReady,
  });

  final String html;
  final ReaderSettings settings;

  /// 进度回调：page / pages / ratio
  final void Function(int page, int pages, double ratio)? onProgress;

  /// 点击屏幕中间区域（用于唤起工具栏）
  final VoidCallback? onTapCenter;

  /// WebView 就绪
  final void Function(ReaderBridge bridge)? onReady;

  @override
  State<ReaderView> createState() => ReaderViewState();
}

class ReaderViewState extends State<ReaderView> {
  InAppWebViewController? _web;
  ReaderBridge? _bridge;
  bool _ready = false;

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialData: InAppWebViewInitialData(
        data: widget.html,
        mimeType: 'text/html',
        encoding: 'utf-8',
        baseUrl: WebUri('about:blank'),
      ),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        supportZoom: false,
        builtInZoomControls: false,
      ),
      onWebViewCreated: (InAppWebViewController c) {
        _web = c;
        _bridge = ReaderBridge(c);
        c.addJavaScriptHandler(
          handlerName: 'readerEvent',
          callback: (List<dynamic> args) => _onJsEvent(args),
        );
      },
      onLoadStop: (InAppWebViewController c, WebUri? uri) async {
        _ready = true;
        await _bridge?.applySettings(widget.settings);
        await _bridge?.layout();
        widget.onReady?.call(_bridge!);
      },
      onConsoleMessage: (InAppWebViewController c, ConsoleMessage m) {
        if (kDebugMode) {
          AppLogger.d('ReaderView', 'console: ${m.message}');
        }
      },
    );
  }

  void _onJsEvent(List<dynamic> args) {
    if (args.isEmpty) return;
    final dynamic raw = args.first;
    Map<String, dynamic>? payload;
    if (raw is Map<String, dynamic>) {
      payload = raw;
    } else if (raw is String) {
      try {
        final dynamic decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) payload = decoded;
      } catch (_) {
        return;
      }
    }
    if (payload == null) return;

    switch (payload['type'] as String?) {
      case 'progress':
        final int page = (payload['page'] as num?)?.toInt() ?? 0;
        final int pages = (payload['pages'] as num?)?.toInt() ?? 1;
        final double ratio = (payload['ratio'] as num?)?.toDouble() ?? 0;
        widget.onProgress?.call(page, pages, ratio);
        break;
      case 'tapCenter':
        widget.onTapCenter?.call();
        break;
      default:
        break;
    }
  }

  @override
  void didUpdateWidget(covariant ReaderView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_ready) return;
    if (oldWidget.settings != widget.settings) {
      unawaited(_bridge?.applySettings(widget.settings));
    }
    if (oldWidget.html != widget.html) {
      unawaited(_web?.loadData(data: widget.html));
    }
  }

  ReaderBridge? get bridge => _bridge;
}

/// Dart ↔ JS 桥接：把阅读器能力封装成强类型方法。
class ReaderBridge {
  const ReaderBridge(this._web);

  static const String _tag = 'ReaderBridge';

  final InAppWebViewController _web;

  Future<dynamic> _eval(String js) async {
    try {
      return await _web.evaluateJavascript(source: js);
    } catch (e) {
      AppLogger.w(_tag, 'JS 执行失败：$js');
      return null;
    }
  }

  /// 应用排版设置（字号 / 行距 / 字距 / 段距 / 页边距 / 主题 / 翻页模式）
  Future<void> applySettings(ReaderSettings s) async {
    final ReaderTheme t = s.theme;
    await _eval('''
(function(){
  var r = window.Reader; if (!r) return;
  var root = document.documentElement;
  root.style.setProperty('--bg', '${t.cssBackground}');
  root.style.setProperty('--fg', '${t.cssForeground}');
  root.style.setProperty('--sub', '${t.cssSubtitle}');
  root.style.setProperty('--hl', '${t.cssHighlight}');
  root.style.setProperty('--fs', '${s.fontSize}px');
  root.style.setProperty('--lh', '${s.lineHeight}');
  root.style.setProperty('--ls', '${s.letterSpacing}px');
  root.style.setProperty('--ps', '${(0.8 * s.paragraphSpacing)}em');
  root.style.setProperty('--padx', '${20 * s.marginScale}px');
  root.style.setProperty('--font', "${s.cssFontFamily}");
  document.body.style.background = '${t.cssBackground}';
  r.setMode('${s.pageMode == ReaderPageMode.scroll ? 'scroll' : 'paged'}');
  r.layout();
})();
''');
  }

  Future<void> layout() => _eval('window.Reader && window.Reader.layout();');

  Future<int> pageCount() async {
    final dynamic v = await _eval('window.Reader ? window.Reader.pageCount() : 1;');
    return (v as num?)?.toInt() ?? 1;
  }

  Future<void> goToPage(int p) =>
      _eval('window.Reader && window.Reader.goToPage($p);');

  Future<void> goToRatio(double r) =>
      _eval('window.Reader && window.Reader.goToRatio($r);');

  Future<void> goToChar(int offset) =>
      _eval('window.Reader && window.Reader.goToChar($offset);');

  /// 朗读高亮；offset < 0 清除
  Future<void> highlight(int offset) =>
      _eval('window.Reader && window.Reader.highlight($offset);');

  /// 读取当前选区（用于划线做笔记）
  Future<ReaderSelection?> getSelection() async {
    final dynamic v =
        await _eval('JSON.stringify(window.Reader ? window.Reader.getSelection() : null);');
    if (v is! String || v == 'null') return null;
    try {
      final dynamic decoded = jsonDecode(v);
      if (decoded is! Map<String, dynamic>) return null;
      return ReaderSelection(
        text: decoded['text'] as String? ?? '',
        start: (decoded['start'] as num?)?.toInt() ?? 0,
        end: (decoded['end'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSelection() =>
      _eval('window.Reader && window.Reader.clearSelection();');

  /// 回显已有划线
  Future<void> markNotes(List<Note> notes) async {
    if (notes.isEmpty) return;
    final StringBuffer sb = StringBuffer('(function(){');
    for (final Note n in notes) {
      sb.write("window.Reader.markRange(${n.start},${n.end},'mark');");
    }
    sb.write('})();');
    await _eval(sb.toString());
  }

  Future<Map<String, dynamic>?> progress() async {
    final dynamic v =
        await _eval('JSON.stringify(window.Reader ? window.Reader.progress() : null);');
    if (v is! String || v == 'null') return null;
    try {
      final dynamic decoded = jsonDecode(v);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }
}

/// WebView 选区
class ReaderSelection {
  const ReaderSelection({
    required this.text,
    required this.start,
    required this.end,
  });

  final String text;
  final int start;
  final int end;

  bool get isEmpty => text.trim().isEmpty;
}
