import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/time_utils.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/note.dart';
import '../common/empty_view.dart';

/// 笔记中心：汇总全书架的划线原文与想法。
///
/// 数据来自 drift 的 notes 表（阅读页划线时写入），
/// 支持按书筛选、跳回阅读页、删除。
class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  /// null 表示「全部」
  String? _bookFilter;

  Future<void> _remove(Note note) async {
    await ref.read(readingRepositoryProvider).removeNote(note.id);
    ref.invalidate(allNotesProvider);
    ref.invalidate(statsProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('已删除这条笔记')));
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Note>> notesAsync = ref.watch(allNotesProvider);
    final List<Book> books = ref.watch(shelfProvider).valueOrNull ?? const <Book>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('笔记'),
        actions: <Widget>[
          if (_bookFilter != null)
            TextButton(
              onPressed: () => setState(() => _bookFilter = null),
              child: const Text('全部'),
            ),
        ],
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => ErrorView(message: '加载失败：$e'),
        data: (List<Note> all) {
          if (all.isEmpty) {
            return const EmptyView(
              icon: Icons.edit_note,
              title: '还没有笔记',
              subtitle: '阅读时长按选中文字即可划线、写想法',
            );
          }

          final List<Note> notes = _bookFilter == null
              ? all
              : all.where((Note n) => n.bookId == _bookFilter).toList();

          return Column(
            children: <Widget>[
              _summaryBar(all.length, books, all),
              const Divider(height: 0.5),
              Expanded(
                child: notes.isEmpty
                    ? const EmptyView(icon: Icons.filter_alt_off, title: '这本书还没有笔记')
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: notes.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.cardGap),
                        itemBuilder: (BuildContext context, int i) =>
                            _card(notes[i], books),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 顶部：总量 + 书籍筛选 chips
  Widget _summaryBar(int total, List<Book> books, List<Note> all) {
    final Set<String> bookIds = all.map((Note n) => n.bookId).toSet();
    final List<Book> withNotes =
        books.where((Book b) => bookIds.contains(b.id)).toList();

    return SizedBox(
      height: 62,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: <Widget>[
          Center(
            child: Text(
              '共 $total 条',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          for (final Book b in withNotes)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Center(
                child: FilterChip(
                  label: Text(
                    b.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  selected: _bookFilter == b.id,
                  onSelected: (_) => setState(
                    () => _bookFilter = _bookFilter == b.id ? null : b.id,
                  ),
                  selectedColor: AppColors.brandLight,
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: _bookFilter == b.id
                        ? AppColors.brand
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _card(Note note, List<Book> books) {
    String bookTitle = '未知书籍';
    for (final Book b in books) {
      if (b.id == note.bookId) {
        bookTitle = b.title;
        break;
      }
    }

    return Dismissible(
      key: ValueKey<String>(note.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _remove(note),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          onTap: () => context.push('/reader/${note.bookId}'),
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
                    Expanded(
                      child: Text(
                        '$bookTitle · ${note.chapterTitle}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      TimeUtils.relative(note.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                // 划线原文：左侧色条 + 引用
                Container(
                  padding: const EdgeInsets.only(left: AppSpacing.sm),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Color(note.color), width: 3),
                    ),
                  ),
                  child: Text(
                    note.quote,
                    style: const TextStyle(fontSize: 14, height: 1.55),
                  ),
                ),
                if (note.content.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(
                        Icons.edit_note,
                        size: 15,
                        color: AppColors.brand,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          note.content,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.menu_book_outlined,
                      size: 13,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '回到原文',
                      style: TextStyle(fontSize: 11, color: AppColors.brand),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _remove(note),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: AppColors.textTertiary,
                      visualDensity: VisualDensity.compact,
                      tooltip: '删除笔记',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
