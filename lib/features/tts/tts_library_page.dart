import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/entities/book.dart';
import '../bookshelf/widgets/book_card.dart';
import '../common/empty_view.dart';

/// 听书页：以「继续听」为中心的朗读入口。
///
/// 说明：朗读本身由阅读页内的 [TtsPlayerSheet] 承载（需要正文与高亮联动），
/// 本页负责选书与拉起——点击书籍即以 `?tts=1` 打开阅读页并自动唤起朗读面板。
class TtsLibraryPage extends ConsumerWidget {
  const TtsLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Book>> shelf = ref.watch(shelfProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('听书')),
      body: shelf.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => ErrorView(message: '加载失败：$e'),
        data: (List<Book> books) {
          // PDF 无法朗读（无稳定文本层），这里过滤掉
          final List<Book> listenable = books
              .where((Book b) => b.format != BookFormat.pdf)
              .toList();

          if (listenable.isEmpty) {
            return EmptyView(
              icon: Icons.headphones_outlined,
              title: '暂无可朗读的书',
              subtitle: '导入 EPUB / TXT 后即可一键听书',
              actionLabel: '去导入',
              onAction: () => context.push('/import'),
            );
          }

          // 最近在听的排在前面（有阅读进度的优先）
          listenable.sort((Book a, Book b) =>
              (b.lastReadAt ?? 0).compareTo(a.lastReadAt ?? 0));

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              _heroCard(context),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  const Text(
                    '继续听',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Text(
                    '共 ${listenable.length} 本',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              for (final Book b in listenable) _listenTile(context, b),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                '提示：朗读使用 Edge-TTS 在线合成，需联网；生成的音频会缓存在本地。',
                style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 顶部说明卡：介绍听书能力
  Widget _heroCard(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF3F74D9), Color(0xFF2B52C4)],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.headphones, color: Colors.white, size: 30),
            const SizedBox(width: AppSpacing.md),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '边听边看，字随声动',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '朗读时正文会同步高亮，支持音色 / 语速 / 定时关闭',
                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _listenTile(BuildContext context, Book b) {
    final double width = 96;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BookCard(
            book: b,
            width: 56,
            coverHeight: 76,
            showProgress: false,
            onTap: () => context.push('/reader/${b.id}?tts=1'),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  b.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${b.author} · ${b.format.name.toUpperCase()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                        child: LinearProgressIndicator(
                          value: b.progress,
                          minHeight: 4,
                          backgroundColor: AppColors.surfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      b.progress <= 0
                          ? '未开始'
                          : '${(b.progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: width + 28,
                  child: FilledButton.icon(
                    onPressed: () => context.push('/reader/${b.id}?tts=1'),
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: Text(b.isReading ? '继续听' : '开始听'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(36),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
