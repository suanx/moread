import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../services/ai/ai_models.dart';
import 'widgets/ai_chapter_scope.dart';

/// AI 知识卡片：把章节知识点拆成可回顾的卡片墙。
///
/// 交互：点击卡片弹出详情（展开态）；卡片按分类标签着色。
class AiCardsPage extends ConsumerWidget {
  const AiCardsPage({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AiChapterScope(
      bookId: bookId,
      title: '知识卡片',
      builder: (BuildContext context, AiChapterContext ctx) => _CardsView(
        key: ValueKey<String>(ctx.chapter.id),
        ctx: ctx,
      ),
    );
  }
}

class _CardsView extends ConsumerStatefulWidget {
  const _CardsView({super.key, required this.ctx});

  final AiChapterContext ctx;

  @override
  ConsumerState<_CardsView> createState() => _CardsViewState();
}

class _CardsViewState extends ConsumerState<_CardsView> {
  AiKnowledgeCards? _data;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    setState(() => _loading = true);
    try {
      final AiKnowledgeCards cards = await ref.read(aiServiceProvider).extractCards(
            bookTitle: widget.ctx.book.title,
            chapterTitle: widget.ctx.chapter.title,
            text: widget.ctx.text,
          );
      if (!mounted) return;
      setState(() => _data = cards);
    } catch (_) {
      // 失败时保持上一次结果，由按钮重试
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// 分类标签配色
  Color _tagColor(String tag) => switch (tag) {
        '人物' => const Color(0xFF4C86E1),
        '情节' => const Color(0xFFE8A33D),
        '概念' => const Color(0xFF7A5AF8),
        '金句' => const Color(0xFF22A06B),
        _ => AppColors.textSecondary,
      };

  void _openDetail(AiKnowledgeCard card) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _tag(card.tag),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    card.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              card.body,
              style: const TextStyle(fontSize: 14, height: 1.65),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('记住了'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _tagColor(tag).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Text(
          tag,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _tagColor(tag),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final AiKnowledgeCards data = _data!;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            0,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${data.sourceTitle} · ${data.cards.length} 张',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _loading ? null : _generate,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('重新生成'),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.cardGap,
              crossAxisSpacing: AppSpacing.cardGap,
              childAspectRatio: 0.86,
            ),
            itemCount: data.cards.length,
            itemBuilder: (BuildContext context, int i) {
              final AiKnowledgeCard c = data.cards[i];
              return Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: InkWell(
                  onTap: () => _openDetail(c),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _tag(c.tag),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          c.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            c.body,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.55,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Icons.open_in_full,
                            size: 13,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
