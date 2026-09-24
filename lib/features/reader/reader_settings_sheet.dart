import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/reader_themes.dart';
import '../../domain/entities/reader_settings.dart';

/// 阅读排版设置面板：字号 / 行距 / 字距 / 段距 / 页边距 / 字体 / 主题 / 翻页方式。
class ReaderSettingsSheet extends ConsumerWidget {
  const ReaderSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ReaderSettings s = ref.watch(readerSettingsProvider);
    final ReaderSettingsNotifier notifier =
        ref.read(readerSettingsProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('排版', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.md),
            _slider(
              label: '字号',
              value: s.fontSize,
              min: 12,
              max: 30,
              display: '${s.fontSize.toStringAsFixed(0)}',
              onChanged: (double v) => notifier.update(s.copyWith(fontSize: v)),
            ),
            _slider(
              label: '行距',
              value: s.lineHeight,
              min: 1.2,
              max: 2.6,
              display: s.lineHeight.toStringAsFixed(2),
              onChanged: (double v) => notifier.update(s.copyWith(lineHeight: v)),
            ),
            _slider(
              label: '字距',
              value: s.letterSpacing,
              min: 0,
              max: 4,
              display: s.letterSpacing.toStringAsFixed(1),
              onChanged: (double v) =>
                  notifier.update(s.copyWith(letterSpacing: v)),
            ),
            _slider(
              label: '段距',
              value: s.paragraphSpacing,
              min: 0.4,
              max: 2.5,
              display: s.paragraphSpacing.toStringAsFixed(2),
              onChanged: (double v) =>
                  notifier.update(s.copyWith(paragraphSpacing: v)),
            ),
            _slider(
              label: '页边距',
              value: s.marginScale,
              min: 0.5,
              max: 2.0,
              display: s.marginScale.toStringAsFixed(2),
              onChanged: (double v) => notifier.update(s.copyWith(marginScale: v)),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('字体', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: <Widget>[
                _chip(context, '系统', s.fontFamily == 'system',
                    () => notifier.update(s.copyWith(fontFamily: 'system'))),
                _chip(context, '宋体', s.fontFamily == 'serif',
                    () => notifier.update(s.copyWith(fontFamily: 'serif'))),
                _chip(context, '黑体', s.fontFamily == 'sans',
                    () => notifier.update(s.copyWith(fontFamily: 'sans'))),
                _chip(context, '楷体', s.fontFamily == 'kai',
                    () => notifier.update(s.copyWith(fontFamily: 'kai'))),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('主题', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: <Widget>[
                for (final ReaderTheme t in ReaderTheme.all)
                  _themeChip(context, t, s.themeId == t.id,
                      () => notifier.update(s.copyWith(themeId: t.id))),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                const Text('翻页方式', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const Spacer(),
                SegmentedButton<ReaderPageMode>(
                  segments: const <ButtonSegment<ReaderPageMode>>[
                    ButtonSegment<ReaderPageMode>(
                      value: ReaderPageMode.paged,
                      label: Text('翻页'),
                      icon: Icon(Icons.menu_book),
                    ),
                    ButtonSegment<ReaderPageMode>(
                      value: ReaderPageMode.scroll,
                      label: Text('滚动'),
                      icon: Icon(Icons.swap_vert),
                    ),
                  ],
                  selected: <ReaderPageMode>{s.pageMode},
                  onSelectionChanged: (Set<ReaderPageMode> v) =>
                      notifier.update(s.copyWith(pageMode: v.first)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('跟随系统深色模式'),
              value: s.followSystemTheme,
              onChanged: (bool v) =>
                  notifier.update(s.copyWith(followSystemTheme: v)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String display,
    required ValueChanged<double> onChanged,
  }) =>
      Row(
        children: <Widget>[
          SizedBox(width: 56, child: Text(label, style: const TextStyle(fontSize: 13))),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              activeColor: AppColors.brand,
              onChanged: onChanged,
            ),
          ),
          SizedBox(width: 44, child: Text(display, style: const TextStyle(fontSize: 12))),
        ],
      );

  Widget _chip(BuildContext context, String text, bool selected, VoidCallback onTap) =>
      ChoiceChip(
        label: Text(text),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.brandLight,
        labelStyle: TextStyle(
          color: selected ? AppColors.brand : AppColors.textPrimary,
        ),
      );

  Widget _themeChip(
    BuildContext context,
    ReaderTheme theme,
    bool selected,
    VoidCallback onTap,
  ) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: theme.backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: selected ? AppColors.brand : AppColors.divider,
              width: selected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              theme.name,
              style: TextStyle(color: theme.foregroundColor, fontSize: 12),
            ),
          ),
        ),
      );
}
