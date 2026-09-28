import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/time_utils.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/chapter.dart';
import '../common/empty_view.dart';

/// 书籍详情页：封面、元数据、目录预览、开始/继续阅读。
class BookDetailPage extends ConsumerStatefulWidget {
  const BookDetailPage({super.key, required this.bookId});

  final String bookId;

  @override
  ConsumerState<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends ConsumerState<BookDetailPage> {
  late final Future<_Detail> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_Detail> _load() async {
    final Book? book =
        await ref.read(bookRepositoryProvider).getById(widget.bookId);
    if (book == null) throw Exception('书籍不存在');
    final List<Chapter> chapters =
        await ref.read(bookRepositoryProvider).getChapters(widget.bookId);
    return _Detail(book: book, chapters: chapters);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('书籍详情'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'AI 中心',
            onPressed: () => context.push('/ai/${widget.bookId}'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: FutureBuilder<_Detail>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<_Detail> snap) {
          if (snap.hasError) {
            return ErrorView(
              message: '加载失败：${snap.error}',
              onRetry: () => setState(() => _future = _load()),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final _Detail d = snap.data!;
          return _buildBody(d);
        },
      ),
    );
  }

  Widget _buildBody(_Detail d) {
    final Book book = d.book;
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _cover(book),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          book.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          book.author,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.xs,
                          children: <Widget>[
                            _tag(book.format.name.toUpperCase()),
                            if (book.publisher != null) _tag(book.publisher!),
                            if (book.totalChars > 0)
                              _tag('${(book.totalChars / 10000).toStringAsFixed(1)} 万字'),
                            if (book.totalPages > 0) _tag('${book.totalPages} 页'),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          book.lastReadAt == null
                              ? '加入于 ${TimeUtils.date(book.addedAt)}'
                              : '最近阅读 ${TimeUtils.relative(book.lastReadAt!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (book.description != null && book.description!.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                const Text('简介', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  book.description!,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  const Text('目录', style: TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text(
                    '共 ${d.chapters.length} 章',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Divider(height: AppSpacing.md),
              for (int i = 0; i < d.chapters.length && i < 20; i++)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    d.chapters[i].title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 16),
                  onTap: () => context.push('/reader/${book.id}?chapter=$i'),
                ),
              if (d.chapters.length > 20)
                Center(
                  child: Text(
                    '其余 ${d.chapters.length - 20} 章请在阅读器内查看完整目录',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg + MediaQuery.of(context).padding.bottom,
          ),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _toggleFavorite(book),
                  icon: Icon(
                    book.favorite ? Icons.favorite : Icons.favorite_border,
                    color: book.favorite ? AppColors.danger : null,
                  ),
                  label: Text(book.favorite ? '已收藏' : '收藏'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () => context.push('/reader/${book.id}'),
                  child: Text(book.progress > 0 ? '继续阅读' : '开始阅读'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cover(Book book) {
    final String? path = book.coverPath;
    if (path != null && File(path).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Image.file(
          File(path),
          width: AppSize.bookCoverWidth,
          height: AppSize.bookCoverHeight,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(book),
        ),
      );
    }
    return _placeholder(book);
  }

  Widget _placeholder(Book book) {
    final int hue = (book.title.hashCode % 360).abs();
    return Container(
      width: AppSize.bookCoverWidth,
      height: AppSize.bookCoverHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        color: HSLColor.fromAHSL(1, hue.toDouble(), 0.35, 0.85).toColor(),
      ),
      alignment: Alignment.center,
      child: Text(
        book.title.isEmpty ? '书' : book.title.substring(0, 1),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _tag(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      );

  Future<void> _toggleFavorite(Book book) async {
    await ref
        .read(bookRepositoryProvider)
        .updateBook(book.copyWith(favorite: !book.favorite));
    ref.invalidate(shelfProvider);
    if (mounted) setState(() => _future = _load());
  }

  Future<void> _confirmDelete() async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('移除书籍'),
        content: const Text('确定移除该书？本地文件与阅读记录都会删除。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('移除'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(bookRepositoryProvider).removeBook(widget.bookId);
    ref.invalidate(shelfProvider);
    if (mounted) context.go('/shelf');
  }
}

class _Detail {
  const _Detail({required this.book, required this.chapters});

  final Book book;
  final List<Chapter> chapters;
}
