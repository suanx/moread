import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/time_utils.dart';
import '../../domain/entities/reading_session.dart';
import '../common/empty_view.dart';

/// 我的页：阅读统计 + 入口。
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ReadingStats> stats = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: stats.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => ErrorView(message: '统计加载失败：$e'),
        data: (ReadingStats s) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(statsProvider),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              _overallCard(s),
              const SizedBox(height: AppSpacing.lg),
              _weeklyCard(s),
              const SizedBox(height: AppSpacing.lg),
              _entryList(context, s),
            ],
          ),
        ),
      ),
    );
  }

  Widget _overallCard(ReadingStats s) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _metric('连续阅读', '${s.daysInARow} 天'),
                  _metric('读完', '${s.booksFinished} 本'),
                  _metric('在读', '${s.booksReading} 本'),
                ],
              ),
              const Divider(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _metric('阅读时长', TimeUtils.durationShort(s.totalReadSeconds)),
                  _metric('听书时长', TimeUtils.durationShort(s.totalListenSeconds)),
                  _metric('笔记', '${s.noteCount} 条'),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _metric(String label, String value) => Column(
        children: <Widget>[
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      );

  Widget _weeklyCard(ReadingStats s) {
    final List<int> days = <int>[6, 5, 4, 3, 2, 1, 0];
    final int max = days
        .map((int d) => s.dailySeconds[d] ?? 0)
        .fold<int>(0, (int a, int b) => a > b ? a : b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('最近 7 天', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.md),
            if (max == 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(
                  child: Text(
                    '还没有阅读记录，去读一本书吧',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              SizedBox(
                height: 120,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    for (final int d in days)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                TimeUtils.durationShort(s.dailySeconds[d] ?? 0),
                                style: const TextStyle(fontSize: 10),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height:
                                    80 * ((s.dailySeconds[d] ?? 0) / max) + 4,
                                decoration: BoxDecoration(
                                  color: AppColors.brand,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                d == 0 ? '今天' : '${d}天前',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _entryList(BuildContext context, ReadingStats stats) => Card(
        child: Column(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('全部笔记与书签'),
              subtitle: Text(
                '${stats.noteCount} 条笔记 · ${stats.bookmarkCount} 个书签',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right, size: 16),
              onTap: () => context.push('/notes'),
            ),
            const Divider(height: 0.5),
            ListTile(
              leading: const Icon(Icons.headphones_outlined),
              title: const Text('朗读设置与缓存'),
              trailing: const Icon(Icons.chevron_right, size: 16),
              onTap: () => context.push('/settings'),
            ),
            const Divider(height: 0.5),
            ListTile(
              leading: const Icon(Icons.file_download_outlined),
              title: const Text('导入本地书籍'),
              trailing: const Icon(Icons.chevron_right, size: 16),
              onTap: () => context.push('/import'),
            ),
          ],
        ),
      );
}
