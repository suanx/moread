import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/entities/chapter.dart';

/// 目录抽屉：点击跳转章节，当前章节高亮。
class TocSheet extends StatefulWidget {
  const TocSheet({
    super.key,
    required this.chapters,
    required this.currentIndex,
    required this.onPick,
  });

  final List<Chapter> chapters;
  final int currentIndex;
  final ValueChanged<int> onPick;

  @override
  State<TocSheet> createState() => _TocSheetState();
}

class _TocSheetState extends State<TocSheet> {
  final TextEditingController _search = TextEditingController();
  String _keyword = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Chapter> get _filtered {
    if (_keyword.trim().isEmpty) return widget.chapters;
    return widget.chapters
        .where((Chapter c) => c.title.contains(_keyword.trim()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Chapter> list = _filtered;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (BuildContext context, ScrollController controller) => Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Row(
              children: <Widget>[
                const Text(
                  '目录',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '共 ${widget.chapters.length} 章',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(
                hintText: '搜索章节标题',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
              onChanged: (String v) => setState(() => _keyword = v),
            ),
          ),
          const Divider(height: AppSpacing.md),
          Expanded(
            child: ListView.separated(
              controller: controller,
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 0.5),
              itemBuilder: (BuildContext context, int i) {
                final Chapter c = list[i];
                final bool active = c.index == widget.currentIndex;
                return ListTile(
                  dense: true,
                  title: Text(
                    c.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: active ? AppColors.brand : null,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  trailing: active
                      ? const Icon(Icons.check, size: 16, color: AppColors.brand)
                      : null,
                  onTap: () => widget.onPick(c.index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
