import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import '../../core/theme/reader_themes.dart';
import '../../core/utils/text_utils.dart';
import '../../domain/entities/reader_settings.dart';

/// 阅读页文档模型：可直接喂给 WebView 的 HTML + 与之对齐的纯文本与句段区间。
///
/// [plainText] 与 [sentences] 是「朗读高亮」「划线笔记」「全文搜索」的基础：
/// HTML 中每个句段都被包裹成 `<span data-s="start" data-e="end">`，
/// start/end 即 [plainText] 中的字符偏移，因此两端永远对齐。
class ReaderDocument {
  const ReaderDocument({
    required this.html,
    required this.plainText,
    required this.sentences,
  });

  final String html;
  final String plainText;
  final List<TextRange> sentences;
}

/// 把「清洗后的正文 HTML」渲染成统一排版的阅读页文档。
///
/// 设计要点：
/// 1. **统一排版**：EPUB 自带 CSS 一律不加载，改用 App 主题变量，保证跨书体验一致；
/// 2. **CSS 多列分页**：`#content` 使用 `column-width + column-gap` 实现横向分页，
///    页边距由 `padding` + `column-gap` 共同实现（详见 [_jsBridge] 注释）；
/// 3. **句段包裹**：遍历文本节点，按句末标点切分并包裹 `<span data-s data-e>`。
abstract final class ContentHtmlBuilder {
  static ReaderDocument build({
    required String bodyHtml,
    required ReaderSettings settings,
    required ReaderTheme theme,
    String chapterTitle = '',
    List<String> anchors = const <String>[],
  }) {
    final dom.Document doc = html_parser.parse(bodyHtml);
    final dom.Element body = doc.body ?? (doc.createElement('body') as dom.Element);

    final StringBuffer plain = StringBuffer();
    final List<TextRange> sentences = <TextRange>[];
    int cursor = 0;

    void walk(dom.Node node) {
      if (node is dom.Text) {
        _wrapTextNode(
          doc,
          node,
          plain,
          sentences,
          cursor,
          (int n) => cursor += n,
        );
        return;
      }
      if (node is dom.Element) {
        for (final dom.Node child in node.nodes.toList()) {
          walk(child);
        }
        if (_isBlock(node.localName)) {
          plain.write('\n');
          cursor += 1;
        }
      }
    }

    for (final dom.Node child in body.nodes.toList()) {
      walk(child);
    }

    final String innerHtml = body.innerHtml;
    return ReaderDocument(
      html: _pageHtml(
        innerHtml: innerHtml,
        settings: settings,
        theme: theme,
        chapterTitle: chapterTitle,
      ),
      plainText: plain.toString(),
      sentences: sentences,
    );
  }

  static void _wrapTextNode(
    dom.Document document,
    dom.Text textNode,
    StringBuffer plain,
    List<TextRange> sentences,
    int cursor,
    void Function(int delta) advance,
  ) {
    final String raw = textNode.text;
    if (raw.trim().isEmpty) {
      plain.write(raw);
      advance(raw.length);
      return;
    }

    final dom.Node? parent = textNode.parentNode;
    final List<dom.Node> replacement = <dom.Node>[];
    final RegExp endMark = RegExp(r'[。！？!?；;…]');
    int last = 0;

    void push(int start, int end) {
      final String piece = raw.substring(start, end);
      if (piece.isEmpty) return;
      final int absStart = cursor + start;
      final int absEnd = absStart + piece.length;
      plain.write(piece);
      sentences.add(TextRange(start: absStart, end: absEnd));
      if (parent != null) {
        final dom.Element span = document.createElement('span');
        span.attributes['data-s'] = '$absStart';
        span.attributes['data-e'] = '$absEnd';
        span.text = piece;
        replacement.add(span);
      }
    }

    for (final Match m in endMark.allMatches(raw)) {
      push(last, m.end);
      last = m.end;
    }
    if (last < raw.length) {
      push(last, raw.length);
    }

    advance(raw.length);

    if (parent != null) {
      for (final dom.Node n in replacement) {
        parent.insertBefore(n, textNode);
      }
      textNode.remove();
    }
  }

  static bool _isBlock(String? tag) => switch (tag) {
        'p' || 'div' || 'h1' || 'h2' || 'h3' || 'h4' || 'h5' || 'h6' ||
        'li' || 'tr' || 'blockquote' || 'pre' || 'section' || 'article' ||
        'br' =>
          true,
        _ => false,
      };

  static String _pageHtml({
    required String innerHtml,
    required ReaderSettings settings,
    required ReaderTheme theme,
    required String chapterTitle,
  }) {
    final double padX = 20 * settings.marginScale;
    final double padY = 16.0;
    final String titleBlock = chapterTitle.isEmpty
        ? ''
        : '<h1 class="chapter-title">${TextUtils.escapeXml(chapterTitle)}</h1>';

    return '''<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">
<style>
:root{
  --bg:${theme.cssBackground};
  --fg:${theme.cssForeground};
  --sub:${theme.cssSubtitle};
  --hl:${theme.cssHighlight};
  --fs:${settings.fontSize}px;
  --lh:${settings.lineHeight};
  --ls:${settings.letterSpacing}px;
  --ps:${(0.8 * settings.paragraphSpacing)}em;
  --padx:${padX}px;
  --pady:${padY}px;
  --font:${settings.cssFontFamily};
}
*{box-sizing:border-box;margin:0;padding:0;-webkit-tap-highlight-color:transparent}
html,body{height:100%;background:var(--bg);color:var(--fg);overflow:hidden}
#viewport{position:fixed;inset:0;overflow:hidden;background:var(--bg)}
#content{
  position:absolute;top:0;left:0;
  box-sizing:border-box;width:100vw;height:100%;
  padding:var(--pady) var(--padx);
  font-family:var(--font);font-size:var(--fs);line-height:var(--lh);
  letter-spacing:var(--ls);text-align:justify;
  will-change:transform;
}
#content.paged{
  column-width:calc(100vw - 2 * var(--padx));
  column-gap:calc(2 * var(--padx));
  column-fill:auto;
  height:100%;
}
#content.scroll{margin:0;height:auto;column-width:auto;column-gap:normal}
#viewport.scrollable{overflow-y:auto;overflow-x:hidden;-webkit-overflow-scrolling:touch}
#content p{margin-bottom:var(--ps);text-indent:2em}
#content p:first-of-type,#content p.no-indent{text-indent:0}
.chapter-title{font-size:1.25em;font-weight:600;margin:0 0 1.2em;color:var(--fg);text-indent:0}
#content h1,#content h2,#content h3{font-size:1.15em;margin:1.2em 0 .6em;text-indent:0}
#content img{max-width:100%;height:auto;display:block;margin:.6em auto;break-inside:avoid}
#content blockquote{margin:.6em 0;padding-left:1em;border-left:2px solid var(--sub);color:var(--sub)}
#content pre{white-space:pre-wrap;word-break:break-word;font-size:.9em;color:var(--sub)}
#content a{color:inherit;text-decoration:none}
#content span.hl{background:var(--hl);border-radius:3px}
#content span.mark{background:var(--hl);border-radius:2px}
</style>
</head>
<body>
<div id="viewport">
  <div id="content" class="paged">
    <div id="reader-body">$titleBlock$innerHtml</div>
  </div>
</div>
<script>
${_jsBridge()}
</script>
</body>
</html>''';
  }

  /// 阅读页 JS 桥接层。
  ///
  /// 对外暴露 `window.Reader.*`，Flutter 通过 `evaluateJavascript` 调用；
  /// 事件通过 `window.flutter_inappwebview.callHandler('readerEvent', ...)` 回传。
  ///
  /// 分页原理：
  /// - `#content` 为多列容器，`column-width = 100vw - 2*padX`，`column-gap = 2*padX`；
  /// - 每列实际宽度 = 100vw - 2*padX，列间距 2*padX ⇒ 第 k 列左边缘 = padX + k*100vw；
  /// - 因此「翻页」只需 `translateX(-k * 100vw)`，且每页左右都保留 padX 边距；
  /// - 总页数：`scrollWidth = padX + (pages-1)*100vw + (100vw - 2*padX)`，故
  ///   `pages = round((scrollWidth + padX) / 100vw)`。
  static String _jsBridge() => r'''
(function () {
  var viewport = document.getElementById('viewport');
  var content = document.getElementById('content');
  var state = { mode: 'paged', page: 0, pages: 1, lastSpan: null };

  function vw() { return viewport.clientWidth || window.innerWidth; }
  function padX() { return parseFloat(window.getComputedStyle(content).paddingLeft) || 0; }
  function notify(type, payload) {
    try {
      if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
        window.flutter_inappwebview.callHandler('readerEvent',
          JSON.stringify(Object.assign({ type: type }, payload || {})));
      }
    } catch (e) { /* 宿主未注册时静默 */ }
  }

  function measure() {
    if (state.mode !== 'paged') { state.pages = 1; return; }
    var w = content.scrollWidth || 0;
    var p = Math.max(1, Math.round((w + padX()) / vw()));
    if (p !== state.pages) { state.pages = p; }
  }

  function apply() {
    if (state.mode === 'paged') {
      content.style.transform = 'translateX(' + (-state.page * vw()) + 'px)';
    } else {
      content.style.transform = 'none';
    }
  }

  function emitProgress() {
    if (state.mode === 'paged') {
      notify('progress', {
        page: state.page, pages: state.pages,
        ratio: state.pages <= 1 ? 1 : (state.page + 1) / state.pages
      });
    } else {
      var max = Math.max(1, viewport.scrollHeight - viewport.clientHeight);
      notify('progress', {
        page: 0, pages: 1,
        ratio: Math.min(1, Math.max(0, viewport.scrollTop / max))
      });
    }
  }

  var Reader = {
    /** 切换分页 / 滚动模式 */
    setMode: function (mode) {
      state.mode = mode;
      if (mode === 'paged') {
        content.classList.add('paged');
        content.classList.remove('scroll');
        viewport.classList.remove('scrollable');
      } else {
        content.classList.remove('paged');
        content.classList.add('scroll');
        viewport.classList.add('scrollable');
      }
      measure();
      apply();
      emitProgress();
    },
    setFontSize: function (px) { content.style.fontSize = px + 'px'; },
    setLineHeight: function (v) { content.style.lineHeight = String(v); },
    setLetterSpacing: function (px) { content.style.letterSpacing = px + 'px'; },
    setVar: function (name, value) { document.documentElement.style.setProperty(name, value); },

    layout: function () {
      var keep = state.page;
      measure();
      if (state.mode === 'paged') {
        state.page = Math.min(keep, state.pages - 1);
        if (state.page < 0) state.page = 0;
      }
      apply();
      emitProgress();
      return { pages: state.pages, page: state.page };
    },

    pageCount: function () { measure(); return state.pages; },
    currentPage: function () { return state.page; },

    goToPage: function (p) {
      measure();
      state.page = Math.max(0, Math.min(state.pages - 1, Math.round(p)));
      apply();
      emitProgress();
      return state.page;
    },
    nextPage: function () { return Reader.goToPage(state.page + 1); },
    prevPage: function () { return Reader.goToPage(state.page - 1); },

    goToRatio: function (r) {
      measure();
      var p = Math.round(r * (state.pages - 1));
      return Reader.goToPage(p);
    },

    /** 跳转到章节内锚点（目录子项、笔记、书签） */
    goToAnchor: function (id) {
      var el = document.getElementById(id);
      if (!el) return -1;
      if (state.mode !== 'paged') {
        var top = el.getBoundingClientRect().top + viewport.scrollTop - 24;
        viewport.scrollTop = top;
        emitProgress();
        return 0;
      }
      var prev = content.style.transform;
      content.style.transform = 'none';
      var left = el.getBoundingClientRect().left - padX();
      content.style.transform = prev;
      var p = Math.max(0, Math.floor(left / vw()));
      return Reader.goToPage(p);
    },

    /** 按纯文本字符偏移定位（书签 / 搜索命中 / 朗读跟随） */
    goToChar: function (offset) {
      var span = Reader.spanAt(offset);
      if (!span) return -1;
      if (state.mode !== 'paged') {
        var top = span.getBoundingClientRect().top + viewport.scrollTop - 24;
        viewport.scrollTop = top;
        emitProgress();
        return 0;
      }
      var prev = content.style.transform;
      content.style.transform = 'none';
      var left = span.getBoundingClientRect().left - padX();
      content.style.transform = prev;
      var p = Math.max(0, Math.floor(left / vw()));
      return Reader.goToPage(p);
    },

    spanAt: function (offset) {
      var spans = content.querySelectorAll('span[data-s]');
      var lo = 0, hi = spans.length - 1, best = null;
      while (lo <= hi) {
        var mid = (lo + hi) >> 1;
        var s = parseInt(spans[mid].getAttribute('data-s'), 10);
        var e = parseInt(spans[mid].getAttribute('data-e'), 10);
        if (offset < s) { hi = mid - 1; }
        else if (offset >= e) { lo = mid + 1; }
        else { best = spans[mid]; break; }
      }
      if (!best && spans.length) {
        best = offset <= 0 ? spans[0] : spans[spans.length - 1];
      }
      return best;
    },

    /** 朗读高亮：传入纯文本偏移；传 -1 清除 */
    highlight: function (offset) {
      if (state.lastSpan) { state.lastSpan.classList.remove('hl'); }
      if (offset < 0) { state.lastSpan = null; return false; }
      var span = Reader.spanAt(offset);
      if (!span) { state.lastSpan = null; return false; }
      span.classList.add('hl');
      state.lastSpan = span;
      if (state.mode === 'paged') {
        var prev = content.style.transform;
        content.style.transform = 'none';
        var left = span.getBoundingClientRect().left - padX();
        content.style.transform = prev;
        var p = Math.max(0, Math.floor(left / vw()));
        if (p !== state.page) { Reader.goToPage(p); }
      } else {
        var top = span.getBoundingClientRect().top + viewport.scrollTop - viewport.clientHeight / 2;
        if (Math.abs(viewport.scrollTop - top) > viewport.clientHeight * 0.6) {
          viewport.scrollTop = top;
        }
      }
      return true;
    },

    /** 获取当前选区，返回 {text,start,end} */
    getSelection: function () {
      var sel = window.getSelection();
      if (!sel || sel.rangeCount === 0 || sel.isCollapsed) return null;
      var range = sel.getRangeAt(0);
      var spans = content.querySelectorAll('span[data-s]');
      var start = -1, end = -1;
      for (var i = 0; i < spans.length; i++) {
        try {
          if (!range.intersectsNode(spans[i])) continue;
        } catch (e) { continue; }
        var s = parseInt(spans[i].getAttribute('data-s'), 10);
        var e = parseInt(spans[i].getAttribute('data-e'), 10);
        if (start < 0 || s < start) start = s;
        if (end < 0 || e > end) end = e;
      }
      var text = sel.toString();
      if (start < 0) { start = 0; end = text.length; }
      return { text: text, start: start, end: end };
    },

    clearSelection: function () {
      try { window.getSelection().removeAllRanges(); } catch (e) {}
    },

    /** 渲染已有划线（笔记回显） */
    markRange: function (start, end, cls) {
      var spans = content.querySelectorAll('span[data-s]');
      for (var i = 0; i < spans.length; i++) {
        var s = parseInt(spans[i].getAttribute('data-s'), 10);
        var e = parseInt(spans[i].getAttribute('data-e'), 10);
        if (e > start && s < end) { spans[i].classList.add(cls || 'mark'); }
      }
    },

    progress: function () {
      measure();
      if (state.mode === 'paged') {
        return { page: state.page, pages: state.pages,
                 ratio: state.pages <= 1 ? 1 : (state.page + 1) / state.pages };
      }
      var max = Math.max(1, viewport.scrollHeight - viewport.clientHeight);
      return { page: 0, pages: 1, ratio: viewport.scrollTop / max };
    }
  };

  window.Reader = Reader;

  // 点击翻页：左 1/3 上一页，右 2/3 下一页
  viewport.addEventListener('click', function (ev) {
    if (state.mode !== 'paged') return;
    var sel = window.getSelection();
    if (sel && !sel.isCollapsed) return;
    var x = ev.clientX, w = vw();
    if (x < w / 3) { Reader.prevPage(); }
    else if (x > w * 2 / 3) { Reader.nextPage(); }
    else { notify('tapCenter', {}); }
  });

  if (viewport.addEventListener) {
    viewport.addEventListener('scroll', function () { emitProgress(); });
  }

  window.addEventListener('resize', function () { Reader.layout(); });
  window.addEventListener('load', function () { Reader.layout(); });
  document.addEventListener('DOMContentLoaded', function () { Reader.layout(); });
  setTimeout(function () { Reader.layout(); }, 60);
  setTimeout(function () { Reader.layout(); }, 300);
})();
''';
}
