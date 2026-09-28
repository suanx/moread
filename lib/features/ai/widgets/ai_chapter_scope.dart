import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/book.dart';
import '../../../domain/entities/chapter.dart';
import '../../../domain/entities/reading_progress.dart';
import '../../common/empty_view.dart';

/// AI 页面上下文：当前书籍、目录、选中章节与章节纯文本。
///
/// 四个 AI 页面（问答 / 总结 / 知识卡片 / 思维导图）都基于「某一章的正文」工作，
/// 因此把「选书 → 取目录 → 选章节 → 读正文 → 加载态处理」抽到这里，
/// 页面只需关心自己的生成结果怎么展示。
class AiChapterContext {
  const AiChapterContext({
    required this.book,
    required this.chapters,
    required this.chapter,
    required this.text,
  });

  final Book book;
  final List<Chapter> chapters;
  final Chapter chapter;

  /// 当前章节纯文本（AI 生成的输入）
  final String text;
}

/// 章节作用域：负责 AppBar、章节选择器与正文加载。
class AiChapterScope extends ConsumerStatefulWidget {
  const AiChapterScope({
    super.key,
    required this.bookId,
    required this.title,
    required this.builder,
  });

  final String bookId;

  /// 页面标题，如「AI 总结」
  final String title;

  /// 正文就绪后的内容构建器
  final Widget Function(BuildContext context, AiChapterContext ctx) builder;

  @override
  ConsumerState<AiChapterScope> createState() => _AiChapterScopeState();
}

class _AiChapterScopeState extends ConsumerState<AiChapterScope> {
  int _chapterIndex = 0;

  /// 阅读进度所在章节（异步载入，作为默认选中项）
  int _preferredIndex = 0;

  /// 用户是否手动切换过章节：切换后不再被默认值覆盖
  bool _userPicked = false;

  @override
  void initState() {
    super.initState();
    _loadPreferredIndex();
  }

  Future<void> _loadPreferredIndex() async {
    try {
      final ReadingProgress? p =
          await ref.read(readingRepositoryProvider).getProgress(widget.bookId);
      if (!mounted || p == null) return;
      setState(() => _preferredIndex = p.chapterIndex);
    } catch (_) {
      // 读进度失败不影响 AI 功能：退化为默认第一章
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Book?> bookAsync = ref.watch(bookByIdProvider(widget.bookId));
    final AsyncValue<List<Chapter>> chaptersAsync =
        ref.watch(chaptersProvider(widget.bookId));

    return bookAsync.when(
      loading: () => _scaffold(const Center(child: CircularProgressIndicator())),
      error: (Object e, _) => _scaffold(ErrorView(message: '加载书籍失败：$e')),
      data: (Book? book) {
        if (book == null) {
          return _scaffold(const EmptyView(icon: Icons.menu_book_outlined, title: '书籍不存在'));
        }
        return chaptersAsync.when(
          loading: () => _scaffold(const Center(child: CircularProgressIndicator())),
          error: (Object e, _) => _scaffold(ErrorView(message: '加载目录失败：$e')),
          data: (List<Chapter> chapters) {
            if (chapters.isEmpty) {
              return _scaffold(
                const EmptyView(
                  icon: Icons.list_alt_outlined,
                  title: '本书暂无可分析的章节',
                  subtitle: 'PDF 或未解析完成的书籍可能没有章节数据',
                ),
              );
            }
            // 默认定位到阅读进度所在章节；用户手动切换后不再覆盖
            if (!_userPicked) {
              _chapterIndex = _preferredIndex.clamp(0, chapters.length - 1);
            } else if (_chapterIndex >= chapters.length) {
              _chapterIndex = chapters.length - 1;
            }

            final Chapter chapter = chapters[_chapterIndex];
            final AsyncValue<String> textAsync = ref.watch(
              chapterTextProvider((bookId: widget.bookId, chapterId: chapter.id)),
            );

            return _scaffold(
              textAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (Object e, _) => ErrorView(message: '读取正文失败：$e'),
                data: (String text) => text.trim().isEmpty
                    ? const EmptyView(
                        icon: Icons.description_outlined,
                        title: '本章没有可分析的正文',
                        subtitle: '试试切换到其它章节',
                      )
                    : widget.builder(
                        context,
                        AiChapterContext(
                          book: book,
                          chapters: chapters,
                          chapter: chapter,
                          text: text,
                        ),
                      ),
              ),
              book: book,
              chapters: chapters,
            );
          },
        );
      },
    );
  }

  /// 统一 Scaffold：标题 + 章节选择器
  Widget _scaffold(Widget body, {Book? book, List<Chapter>? chapters}) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: chapters == null || chapters.isEmpty
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(46),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          book?.title ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _chapterIndex,
                            isDense: true,
                            isExpanded: true,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                            items: <DropdownMenuItem<int>>[
                              for (int i = 0; i < chapters.length; i++)
                                DropdownMenuItem<int>(
                                  value: i,
                                  child: Text(
                                    chapters[i].title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                            onChanged: (int? v) {
                              if (v == null) return;
                              setState(() => _chapterIndex = v);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      body: body,
    );
  }
}
