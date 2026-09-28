import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../core/di/providers.dart';
import '../../services/tts/tts_playback_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/reader_themes.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/entities/reader_settings.dart';
import '../ai/ai_center_page.dart';
import '../tts/tts_player_sheet.dart';
import 'reader_controller.dart';
import 'reader_marks_sheet.dart';
import 'reader_providers.dart';
import 'reader_settings_sheet.dart';
import 'reader_view.dart';
import 'toc_sheet.dart';

/// 阅读器页面。
///
/// 组成：
/// - 内容区：EPUB/TXT → [ReaderView]（WebView 多列分页）；PDF → pdfrx 原生渲染
/// - 顶部栏 / 底部栏：点击屏幕中央切换显隐
/// - 底部工具：目录、排版、朗读、笔记、AI、下一章
/// - 朗读高亮：监听 [ttsControllerProvider] 的字符偏移，驱动 WebView 高亮
class ReaderPage extends ConsumerStatefulWidget {
  const ReaderPage({super.key, required this.bookId});

  final String bookId;

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  final GlobalKey<ReaderViewState> _viewKey = GlobalKey<ReaderViewState>();
  bool _chromeVisible = false;
  int _lastHighlight = -1;

  @override
  void initState() {
    super.initState();
    unawaited(
      ref.read(readerControllerProvider(widget.bookId)).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ReaderController c = ref.watch(readerControllerProvider(widget.bookId));
    final ReaderSettings settings = ref.watch(readerSettingsProvider);
    final ReaderTheme theme = settings.theme;

    // 朗读高亮跟随
    ref.listen<int>(
      ttsControllerProvider.select(
        (TtsPlaybackController p) => p.highlightChar,
      ),
      (int? prev, int next) => _applyHighlight(next),
    );

    if (c.loading) {
      return Scaffold(
        backgroundColor: theme.backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (c.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('阅读')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(c.error!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: _buildContent(c, settings)),
          if (_chromeVisible) ...<Widget>[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopBar(theme, c),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(theme, c),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(ReaderController c, ReaderSettings settings) {
    final Book? book = c.book;
    if (book == null) return const SizedBox.shrink();

    if (book.format == BookFormat.pdf) {
      // PDF 走原生渲染器（pdfrx），不走 WebView
      return PdfViewer.file(book.localPath);
    }

    final String? html = c.content?.html;
    if (html == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ReaderView(
      key: _viewKey,
      html: html,
      settings: settings,
      onProgress: (int page, int pages, double ratio) =>
          c.onPageChanged(page: page, pages: pages, ratio: ratio),
      onTapCenter: () => setState(() => _chromeVisible = !_chromeVisible),
      onReady: (ReaderBridge bridge) {
        unawaited(bridge.markNotes(c.notesInCurrentChapter()));
        final double r = c.progress?.chapterRatio ?? 0;
        if (r > 0) unawaited(bridge.goToRatio(r));
      },
    );
  }

  Widget _buildTopBar(ReaderTheme theme, ReaderController c) {
    return Container(
      height: kToolbarHeight + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      color: theme.backgroundColor,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: theme.foregroundColor),
            onPressed: () async {
              await c.saveProgressNow();
              if (mounted) Navigator.of(context).maybePop();
            },
          ),
          Expanded(
            child: Text(
              c.currentChapter?.title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.foregroundColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              c.isBookmarkedHere() ? Icons.bookmark : Icons.bookmark_border,
              color: c.isBookmarkedHere() ? AppColors.brand : theme.foregroundColor,
            ),
            onPressed: () async {
              final String? currentId = c.currentChapter?.id;
              Bookmark? existing;
              for (final Bookmark b in c.bookmarks) {
                if (b.chapterId == currentId) {
                  existing = b;
                  break;
                }
              }
              if (existing != null) {
                await c.removeBookmark(existing.id);
                if (mounted) _toast('已移除书签');
              } else {
                await c.addBookmark();
                if (mounted) _toast('已添加书签');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ReaderTheme theme, ReaderController c) {
    final Color fg = theme.foregroundColor;
    return Container(
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        border: const Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
        top: AppSpacing.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: <Widget>[
                Text(
                  c.progressText,
                  style: TextStyle(color: fg.withValues(alpha: 0.7), fontSize: 12),
                ),
                const Spacer(),
                Text(
                  c.currentChapter?.title ?? '',
                  style: TextStyle(color: fg.withValues(alpha: 0.7), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _tool(Icons.list, '目录', fg, () => _openToc(c)),
              _tool(Icons.text_fields, '排版', fg, () => _openSettings()),
              _tool(Icons.headphones, '朗读', fg, () => _openTts(c)),
              _tool(Icons.edit_note, '笔记', fg, () => _openMarks(c)),
              _tool(Icons.auto_awesome, 'AI', fg, () => _openAi()),
              _tool(Icons.skip_next, '下一章', fg, () async {
                await c.nextChapter();
                setState(() {});
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tool(IconData icon, String label, Color color, VoidCallback onTap) =>
      InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(color: color, fontSize: 11)),
            ],
          ),
        ),
      );

  // =========================================================================
  // 交互
  // =========================================================================

  Future<void> _applyHighlight(int char) async {
    if (char == _lastHighlight) return;
    _lastHighlight = char;
    final ReaderBridge? bridge = _viewKey.currentState?.bridge;
    if (bridge == null) return;
    await bridge.highlight(char);
  }

  void _openToc(ReaderController c) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TocSheet(
        chapters: c.chapters,
        currentIndex: c.chapterIndex,
        onPick: (int index) async {
          Navigator.of(context).pop();
          await c.goToChapter(index);
          setState(() {});
        },
      ),
    );
  }

  void _openSettings() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => const ReaderSettingsSheet(),
    );
  }

  /// 进入 AI 中心（问答 / 总结 / 知识卡片 / 思维导图）
  void _openAi() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AiCenterPage(bookId: widget.bookId),
      ),
    );
  }

  void _openMarks(ReaderController c) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ReaderMarksSheet(
        bookmarks: c.bookmarks,
        notes: c.notes,
        onJumpBookmark: (b) async {
          Navigator.of(context).pop();
          final int idx =
              c.chapters.indexWhere((ch) => ch.id == b.chapterId);
          if (idx >= 0) {
            await c.goToChapter(idx, ratio: b.chapterRatio);
            setState(() {});
          }
        },
        onJumpNote: (n) async {
          Navigator.of(context).pop();
          final int idx =
              c.chapters.indexWhere((ch) => ch.id == n.chapterId);
          if (idx >= 0) {
            await c.goToChapter(idx);
            setState(() {});
          }
        },
        onDeleteBookmark: c.removeBookmark,
        onDeleteNote: c.removeNote,
      ),
    );
  }

  void _openTts(ReaderController c) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TtsPlayerSheet(
        bookId: widget.bookId,
        chapterId: c.currentChapter?.id ?? '',
        chapterTitle: c.currentChapter?.title ?? '',
        bookTitle: c.book?.title,
        coverPath: c.book?.coverPath,
        onRequestText: () async =>
            ref.read(bookRepositoryProvider).loadChapterText(
                  widget.bookId,
                  c.currentChapter!,
                ),
        onHighlight: _applyHighlight,
        onNextChapter: () async {
          await c.nextChapter();
          setState(() {});
        },
      ),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
