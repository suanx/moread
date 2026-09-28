import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/providers.dart';
import '../../core/error/failure.dart';
import '../../core/logging/app_logger.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../services/import/book_importer.dart';

/// 本地导入页：选择文件 → 解析 → 入架。
///
/// 错误处理：
/// - 未授权 → 提示并引导系统设置
/// - 格式不支持 → 明确列出支持的格式
/// - 解析失败 → 汇总失败文件清单，成功的照常入架
class ImportPage extends ConsumerStatefulWidget {
  const ImportPage({super.key});

  @override
  ConsumerState<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends ConsumerState<ImportPage> {
  bool _importing = false;
  double _progress = 0;
  int _total = 0;
  int _done = 0;

  /// 当前正在解析的文件名（给用户可见的进度反馈）
  String _current = '';

  /// 失败清单：保留路径以便「重试失败项」
  final List<({String name, String path, String reason})> _failures =
      <({String name, String path, String reason})>[];

  Future<void> _pickFiles() async {
    final bool granted =
        await ref.read(permissionServiceProvider).ensureImportPermission();
    if (!granted) {
      if (!mounted) return;
      await _showPermissionDialog();
      return;
    }

    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: BookImporter.supportedExtensions,
      allowMultiple: true,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;

    final List<String> paths = result.files
        .map((PlatformFile f) => f.path)
        .whereType<String>()
        .toList();
    if (paths.isEmpty) {
      _toast('未能读取所选文件，请换一个来源再试');
      return;
    }
    await _import(paths);
  }

  Future<void> _import(List<String> paths) async {
    setState(() {
      _importing = true;
      _progress = 0;
      _total = paths.length;
      _done = 0;
      _current = '';
      _failures.clear();
    });

    final repo = ref.read(bookRepositoryProvider);
    for (final String path in paths) {
      setState(() => _current = _name(path));
      try {
        await repo.importLocalFile(path);
      } on Failure catch (e) {
        _failures.add((name: _name(path), path: path, reason: e.message));
      } catch (e, st) {
        AppLogger.e('ImportPage', '导入失败：$path', e, st);
        _failures.add((name: _name(path), path: path, reason: '未知错误：$e'));
      } finally {
        _done++;
        if (mounted) {
          setState(() => _progress = _done / _total);
        }
      }
    }

    if (!mounted) return;
    ref.invalidate(shelfProvider);
    ref.invalidate(statsProvider);
    final int ok = _total - _failures.length;
    setState(() {
      _importing = false;
      _current = '';
    });

    if (_failures.isEmpty) {
      _toast('已导入 $ok 本');
      context.pop();
      return;
    }

    final List<({String name, String path, String reason})> failed =
        List<({String name, String path, String reason})>.of(_failures);
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('导入完成（$ok/$_total）'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final ({String name, String path, String reason}) f in failed)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    '• ${f.name}\n   ${f.reason}',
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('稍后再说'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 仅重试失败的文件
              unawaited(_import(<String>[
                for (final ({String name, String path, String reason}) f in failed)
                  f.path,
              ]));
            },
            child: const Text('重试失败项'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPermissionDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('需要文件访问权限'),
        content: const Text('导入本地书籍需要访问设备上的文件，请在系统设置中允许。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(permissionServiceProvider).openSettings();
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  String _name(String path) =>
      path.split(Platform.pathSeparator).last;

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('导入书籍')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _formatCard(
              icon: Icons.auto_stories_outlined,
              title: 'EPUB',
              desc: '保留目录、封面与图片，推荐格式',
            ),
            _formatCard(
              icon: Icons.text_snippet_outlined,
              title: 'TXT',
              desc: '自动识别章节标题（第X章 / Chapter N）',
            ),
            _formatCard(
              icon: Icons.picture_as_pdf_outlined,
              title: 'PDF',
              desc: '原生渲染，支持页码跳转与目录分章',
            ),
            const Spacer(),
            if (_importing) ...<Widget>[
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '正在导入 $_done/$_total${_current.isEmpty ? '' : ' · $_current'}',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            FilledButton.icon(
              onPressed: _importing ? null : _pickFiles,
              icon: const Icon(Icons.folder_open_outlined),
              label: const Text('选择文件'),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              '提示：文件会被复制到应用私有目录，原文件删除后仍可继续阅读。',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formatCard({
    required IconData icon,
    required String title,
    required String desc,
  }) =>
      Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: <Widget>[
              Icon(icon, color: AppColors.brand),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(desc,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
