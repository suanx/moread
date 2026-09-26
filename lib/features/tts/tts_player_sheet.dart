import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/time_utils.dart';
import '../../domain/entities/tts_settings.dart';
import '../../services/tts/tts_playback_controller.dart';

/// 听书面板：音色 / 语速 / 音量 / 定时关闭 / 播放控制。
///
/// 与阅读页通过 [onHighlight] 联动，实现「文字高亮跟随」。
class TtsPlayerSheet extends ConsumerStatefulWidget {
  const TtsPlayerSheet({
    super.key,
    required this.bookId,
    required this.chapterId,
    required this.chapterTitle,
    required this.onRequestText,
    required this.onHighlight,
    required this.onNextChapter,
    this.bookTitle,
    this.coverPath,
  });

  final String bookId;
  final String chapterId;
  final String chapterTitle;
  final String? bookTitle;
  final String? coverPath;

  /// 获取本章纯文本（由阅读页提供，避免重复 IO）
  final Future<String> Function() onRequestText;

  /// 高亮回调：传入字符偏移（-1 表示清除）
  final ValueChanged<int> onHighlight;

  /// 播放下一章
  final Future<void> Function() onNextChapter;

  @override
  ConsumerState<TtsPlayerSheet> createState() => _TtsPlayerSheetState();
}

class _TtsPlayerSheetState extends ConsumerState<TtsPlayerSheet> {
  bool _prepared = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_prepare());
  }

  Future<void> _prepare() async {
    await ref.read(permissionServiceProvider).ensureNotificationPermission();
    final TtsSettings settings = ref.read(ttsSettingsProvider);
    final TtsPlaybackController c = ref.read(ttsControllerProvider);
    await c.initSession();
    try {
      final String text = await widget.onRequestText();
      await c.prepare(
        bookId: widget.bookId,
        chapterId: widget.chapterId,
        chapterTitle: widget.chapterTitle,
        text: text,
        settings: settings,
        bookTitle: widget.bookTitle,
        coverPath: widget.coverPath,
      );
      c.setSleepTimer(settings.sleepTimerMinutes);
      if (mounted) setState(() => _prepared = true);
      await c.play();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final TtsPlaybackController c = ref.watch(ttsControllerProvider);
    final TtsSettings settings = ref.watch(ttsSettingsProvider);
    final TtsSettingsNotifier notifier =
        ref.read(ttsSettingsProvider.notifier);

    // 高亮跟随
    ref.listen<int>(
      ttsControllerProvider.select((TtsPlaybackController p) => p.highlightChar),
      (int? prev, int next) => widget.onHighlight(next),
    );

    // 本章播完 → 自动下一章
    ref.listen<TtsStatus>(
      ttsControllerProvider.select((TtsPlaybackController p) => p.status),
      (TtsStatus? prev, TtsStatus next) async {
        if (next == TtsStatus.completed && settings.autoNextChapter) {
          await widget.onNextChapter();
          await _prepare();
        }
      },
    );

    if (!_prepared && _error == null) {
      return const SafeArea(
        child: SizedBox(
          height: 240,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: AppSpacing.md),
                Text('正在合成语音…', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ),
      );
    }

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
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    widget.chapterTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  '朗读失败：$_error',
                  style: const TextStyle(color: AppColors.danger, fontSize: 12),
                ),
              ),
            if (c.status == TtsStatus.preparing)
              LinearProgressIndicator(value: c.prepareProgress),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                Text(TimeUtils.durationClock(c.position.inSeconds),
                    style: const TextStyle(fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: _ratio(c),
                    activeColor: AppColors.brand,
                    onChanged: (double v) async {
                      final int total = c.duration.inMilliseconds;
                      if (total <= 0) return;
                      await c.seekForward(((v - _ratio(c)) * total / 1000).round());
                    },
                  ),
                ),
                Text(TimeUtils.durationClock(c.duration.inSeconds),
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  iconSize: 32,
                  icon: const Icon(Icons.fast_rewind),
                  onPressed: () => c.seekBackward(15),
                ),
                const SizedBox(width: AppSpacing.lg),
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.brand,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    iconSize: 30,
                    color: Colors.white,
                    icon: Icon(c.isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () => c.isPlaying ? c.pause() : c.play(),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                IconButton(
                  iconSize: 32,
                  icon: const Icon(Icons.fast_forward),
                  onPressed: () => c.seekForward(15),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                const SizedBox(width: 56, child: Text('音色', style: TextStyle(fontSize: 13))),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: settings.voice,
                    items: <DropdownMenuItem<String>>[
                      for (final TtsVoice v in TtsVoice.builtIn)
                        DropdownMenuItem<String>(
                          value: v.shortName,
                          child: Text(
                            v.displayName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                    ],
                    onChanged: (String? v) async {
                      if (v == null) return;
                      await notifier.update(settings.copyWith(voice: v));
                      await _prepare();
                    },
                  ),
                ),
              ],
            ),
            _slider(
              '语速',
              settings.ratePercent.toDouble(),
              -50,
              100,
              '${settings.ratePercent > 0 ? '+' : ''}${settings.ratePercent}%',
              (double v) => notifier.update(
                settings.copyWith(ratePercent: v.round()),
              ),
            ),
            _slider(
              '音量',
              settings.volumePercent.toDouble(),
              -50,
              50,
              '${settings.volumePercent > 0 ? '+' : ''}${settings.volumePercent}%',
              (double v) async {
                final int p = v.round();
                await notifier.update(settings.copyWith(volumePercent: p));
                await c.applyVolume(p);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                const Text('定时关闭', style: TextStyle(fontSize: 13)),
                const Spacer(),
                for (final int m in const <int>[0, 15, 30, 60])
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.xs),
                    child: ChoiceChip(
                      label: Text(m == 0 ? '关闭' : '$m 分钟'),
                      selected: settings.sleepTimerMinutes == m,
                      selectedColor: AppColors.brandLight,
                      onSelected: (_) async {
                        await notifier.update(
                          settings.copyWith(sleepTimerMinutes: m),
                        );
                        c.setSleepTimer(m);
                      },
                    ),
                  ),
              ],
            ),
            if (c.sleepRemainSeconds > 0)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  '将在 ${TimeUtils.durationClock(c.sleepRemainSeconds)} 后停止',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('读完自动播放下一章', style: TextStyle(fontSize: 13)),
              value: settings.autoNextChapter,
              onChanged: (bool v) =>
                  notifier.update(settings.copyWith(autoNextChapter: v)),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('朗读时文字高亮跟随', style: TextStyle(fontSize: 13)),
              value: settings.highlightFollow,
              onChanged: (bool v) =>
                  notifier.update(settings.copyWith(highlightFollow: v)),
            ),
          ],
        ),
      ),
    );
  }

  double _ratio(TtsPlaybackController c) {
    final int total = c.duration.inMilliseconds;
    if (total <= 0) return 0;
    final double r = c.position.inMilliseconds / total;
    return r < 0 ? 0 : (r > 1 ? 1 : r);
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    String display,
    ValueChanged<double> onChanged,
  ) =>
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
          SizedBox(width: 56, child: Text(display, style: const TextStyle(fontSize: 12))),
        ],
      );
}
