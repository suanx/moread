import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/entities/book.dart';
import '../../services/ai/ai_models.dart';
import '../common/empty_view.dart';

/// AI 中心：一本书的 AI 能力入口。
///
/// 四类生成能力（问答 / 总结 / 知识卡片 / 思维导图）的调度台，
/// 同时提供「直接提问」快捷入口。所有能力当前由本地 Mock 服务提供。
class AiCenterPage extends ConsumerWidget {
  const AiCenterPage({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Book?> bookAsync = ref.watch(bookByIdProvider(bookId));

    return Scaffold(
      appBar: AppBar(title: const Text('AI 中心')),
      body: bookAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => ErrorView(message: '加载书籍失败：$e'),
        data: (Book? book) => book == null
            ? const EmptyView(icon: Icons.menu_book_outlined, title: '书籍不存在')
            : _Body(book: book),
      ),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.book});

  final Book book;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _ask() {
    final String q = _ctrl.text.trim();
    if (q.isEmpty) return;
    _ctrl.clear();
    context.push('/ai/${widget.book.id}/chat', extra: q);
  }

  @override
  Widget build(BuildContext context) {
    final Book book = widget.book;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: <Widget>[
        _bookHeader(book),
        const SizedBox(height: AppSpacing.xl),
        const Text(
          '能力',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.cardGap,
          crossAxisSpacing: AppSpacing.cardGap,
          childAspectRatio: 1.25,
          children: <Widget>[
            _CapabilityCard(
              capability: AiCapability.qa,
              icon: Icons.forum_outlined,
              onTap: () => context.push('/ai/${book.id}/chat'),
            ),
            _CapabilityCard(
              capability: AiCapability.summary,
              icon: Icons.auto_awesome_motion_outlined,
              onTap: () => context.push('/ai/${book.id}/summary'),
            ),
            _CapabilityCard(
              capability: AiCapability.cards,
              icon: Icons.dashboard_customize_outlined,
              onTap: () => context.push('/ai/${book.id}/cards'),
            ),
            _CapabilityCard(
              capability: AiCapability.mindmap,
              icon: Icons.account_tree_outlined,
              onTap: () => context.push('/ai/${book.id}/mindmap'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const Text(
          '直接提问',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _ctrl,
          minLines: 1,
          maxLines: 3,
          textInputAction: TextInputAction.send,
          decoration: const InputDecoration(
            hintText: '例如：这一章主要讲了什么？',
            prefixIcon: Icon(Icons.auto_awesome, size: 20),
          ),
          onSubmitted: (_) => _ask(),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                '当前为本地模拟模式：结果由章节正文抽取生成，可离线使用',
                style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            FilledButton(onPressed: _ask, child: const Text('提问')),
          ],
        ),
      ],
    );
  }

  /// 顶部书籍信息卡
  Widget _bookHeader(Book book) {
    final String trimmed = book.title.trim();
    final String initial = trimmed.isEmpty ? '书' : trimmed.substring(0, 1);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.brandLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 52,
            height: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF4D84E8), Color(0xFF2B5CC7)],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  book.author,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: <Widget>[
                    _pill('${book.format.name.toUpperCase()}'),
                    const SizedBox(width: AppSpacing.xs),
                    _pill('已读 ${(book.progress * 100).toStringAsFixed(0)}%'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 11, color: AppColors.brand),
        ),
      );
}

/// 单项 AI 能力卡片。
class _CapabilityCard extends StatelessWidget {
  const _CapabilityCard({
    required this.capability,
    required this.icon,
    required this.onTap,
  });

  final AiCapability capability;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 问答/总结/卡片为蓝色系，思维导图用 AI 黄色作区分
    final bool highlight = capability == AiCapability.mindmap;
    final Color accent = highlight ? AppColors.ai : AppColors.brand;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
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
              Row(
                children: <Widget>[
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Icon(icon, size: 19, color: accent),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                capability.label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                capability.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.35,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
