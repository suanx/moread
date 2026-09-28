import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/entities/book.dart';
import '../../services/ai/ai_models.dart';
import 'widgets/ai_chapter_scope.dart';

/// AI 总结：章节总览 + 要点 + 关键词。
class AiSummaryPage extends ConsumerWidget {
  const AiSummaryPage({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AiChapterScope(
      bookId: bookId,
      title: 'AI 总结',
      builder: (BuildContext context, AiChapterContext ctx) => _SummaryView(
        key: ValueKey<String>(ctx.chapter.id),
        ctx: ctx,
      ),
    );
  }
}

class _SummaryView extends ConsumerStatefulWidget {
  const _SummaryView({super.key, required this.ctx});

  final AiChapterContext ctx;

  @override
  ConsumerState<_SummaryView> createState() => _SummaryViewState();
}

class _SummaryViewState extends ConsumerState<_SummaryView> {
  AiSummary? _data;
  Object? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final Book book = widget.ctx.book;
      final AiSummary s = await ref.read(aiServiceProvider).summarize(
            bookTitle: book.title,
            chapterTitle: widget.ctx.chapter.title,
            text: widget.ctx.text,
          );
      if (!mounted) return;
      setState(() => _data = s);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _data == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('生成失败：$_error'),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: _generate, child: const Text('重试')),
          ],
        ),
      );
    }

    final AiSummary s = _data!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                s.title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton.icon(
              onPressed: _loading ? null : _generate,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('重新生成'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.brandLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.auto_awesome, size: 16, color: AppColors.brand),
                  const SizedBox(width: AppSpacing.xs),
                  const Text(
                    '总览',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brand,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '约 ${s.charCount} 字',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                s.overview,
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          '要点',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (int i = 0; i < s.points.length; i++)
          _pointCard(i + 1, s.points[i]),
        if (s.keywords.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
          const Text(
            '关键词',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              for (final String k in s.keywords)
                Chip(
                  label: Text(k),
                  backgroundColor: AppColors.surfaceVariant,
                  side: BorderSide.none,
                  labelStyle: const TextStyle(fontSize: 12),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _pointCard(int index, AiSummaryPoint p) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.brandLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brand,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  p.heading,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            p.detail,
            style: const TextStyle(fontSize: 13, height: 1.55),
          ),
          if (p.quote.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.brand, width: 2),
                ),
              ),
              child: Text(
                '「${p.quote}」',
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
