import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/entities/tts_settings.dart';
import '../reader/reader_settings_sheet.dart';

/// 设置页：排版、朗读偏好、缓存管理、关于。
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _version = '-';
  int _cacheBytes = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_loadInfo());
  }

  Future<void> _loadInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    final int size = await ref.read(ttsRepositoryProvider).cacheSize();
    if (!mounted) return;
    setState(() {
      _version = '${info.version} (${info.buildNumber})';
      _cacheBytes = size;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TtsSettings tts = ref.watch(ttsSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.text_format),
                  title: const Text('阅读排版'),
                  subtitle: const Text('字号、行距、主题、翻页方式'),
                  trailing: const Icon(Icons.chevron_right, size: 16),
                  onTap: () => showModalBottomSheet<void>(
                    context: context,
                    builder: (_) => const ReaderSettingsSheet(),
                  ),
                ),
                const Divider(height: 0.5),
                SwitchListTile.adaptive(
                  secondary: const Icon(Icons.remove_red_eye_outlined),
                  title: const Text('朗读时文字高亮跟随'),
                  value: tts.highlightFollow,
                  onChanged: (bool v) => ref
                      .read(ttsSettingsProvider.notifier)
                      .update(tts.copyWith(highlightFollow: v)),
                ),
                SwitchListTile.adaptive(
                  secondary: const Icon(Icons.skip_next_outlined),
                  title: const Text('读完自动播放下一章'),
                  value: tts.autoNextChapter,
                  onChanged: (bool v) => ref
                      .read(ttsSettingsProvider.notifier)
                      .update(tts.copyWith(autoNextChapter: v)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.cleaning_services_outlined),
                  title: const Text('清空朗读缓存'),
                  subtitle: Text('当前占用 ${(_cacheBytes / 1024 / 1024).toStringAsFixed(1)} MB'),
                  trailing: const Icon(Icons.chevron_right, size: 16),
                  onTap: () async {
                    final int freed =
                        await ref.read(ttsRepositoryProvider).clearCache();
                    if (!mounted) return;
                    setState(() => _cacheBytes = 0);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '已释放 ${(freed / 1024 / 1024).toStringAsFixed(1)} MB',
                        ),
                      ),
                    );
                  },
                ),
                const Divider(height: 0.5),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('关于墨读'),
                  subtitle: Text('版本 $_version'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              '朗读能力由 Microsoft Edge 的在线语音合成服务提供，'
              '需要联网使用；已合成的章节会缓存到本地，可离线重复播放。',
              style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}
