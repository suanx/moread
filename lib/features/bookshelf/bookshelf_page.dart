import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/entities/book.dart';
import '../common/empty_view.dart';
import 'widgets/book_card.dart';

/// 书架页。
///
/// 布局对齐设计稿：标题行（书架 / 编辑）→ 双列大封面横向书墙（右缘露出下一列，
/// 提示可左右滑动）。支持排序、编辑模式（多选收藏 / 移出）、长按快捷进入编辑。
class BookshelfPage extends ConsumerStatefulWidget {
  const BookshelfPage({super.key});

  @override
  ConsumerState<BookshelfPage> createState() => _BookshelfPageState();
}

class _BookshelfPageState extends ConsumerState<BookshelfPage> {
  /// 卡片宽度与封面高度（与设计稿的双列大封面一致）
  static const double _cardWidth = 108;
  static const double _coverHeight = 148;

  /// 一列高度 = 两张卡片（含书名与状态行）+ 间距
  static double get _stripHeight =>
      (_coverHeight + 64) * 2 + AppSpacing.lg;

  ShelfSort _sort = ShelfSort.recent;
  bool _editing = false;
  final Set<String> _selected = <String>{};

  // =========================================================================
  // 编辑模式
  // =========================================================================

  void _enterEditing([Book? first]) {
    setState(() {
      _editing = true;
      if (first != null) _selected.add(first.id);
    });
  }

  void _exitEditing() {
    setState(() {
      _editing = false;
      _selected.clear();
    });
  }

  void _toggleSelect(Book book) {
    setState(() {
      if (!_selected.remove(book.id)) _selected.add(book.id);
    });
  }

  Future<void> _removeSelected() async {
    final int count = _selected.length;
    if (count == 0) return;

    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('移除 $count 本书'),
        content: const Text('将从书架移除，并删除应用内缓存的书籍文件。'),
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

    final repo = ref.read(bookRepositoryProvider);
    for (final String id in _selected.toList()) {
      await repo.removeBook(id);
    }
    ref.invalidate(shelfProvider);
    ref.invalidate(statsProvider);
    if (!mounted) return;
    _toast('已移除 $count 本');
    _exitEditing();
  }

  Future<void> _toggleFavoriteSelected(List<Book> books) async {
    if (_selected.isEmpty) return;
    final repo = ref.read(bookRepositoryProvider);
    for (final Book b in books.where((Book b) => _selected.contains(b.id))) {
      await repo.updateBook(b.copyWith(favorite: !b.favorite));
    }
    ref.invalidate(shelfProvider);
    if (!mounted) return;
    _toast('已更新收藏');
    _exitEditing();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // =========================================================================
  // 排序
  // =========================================================================

  List<Book> _sorted(List<Book> books) {
    final List<Book> list = List<Book>.of(books);
    switch (_sort) {
      case ShelfSort.recent:
        list.sort((Book a, Book b) =>
            (b.lastReadAt ?? b.addedAt).compareTo(a.lastReadAt ?? a.addedAt));
        break;
      case ShelfSort.title:
        list.sort((Book a, Book b) => a.title.compareTo(b.title));
        break;
      case ShelfSort.progress:
        list.sort((Book a, Book b) => b.progress.compareTo(a.progress));
        break;
      case ShelfSort.favorite:
        list.sort((Book a, Book b) {
          final int f = (b.favorite ? 1 : 0).compareTo(a.favorite ? 1 : 0);
          return f != 0 ? f : b.progress.compareTo(a.progress);
        });
        break;
    }
    return list;
  }

  String _label(ShelfSort s) => switch (s) {
        ShelfSort.recent => '最近阅读',
        ShelfSort.title => '书名',
        ShelfSort.progress => '阅读进度',
        ShelfSort.favorite => '收藏优先',
      };

  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Book>> asyncBooks = ref.watch(shelfProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('书架'),
        actions: <Widget>[
          if (!_editing)
            PopupMenuButton<ShelfSort>(
              icon: const Icon(Icons.sort),
              tooltip: '排序：${_label(_sort)}',
              onSelected: (ShelfSort s) => setState(() => _sort = s),
              itemBuilder: (_) => <PopupMenuEntry<ShelfSort>>[
                for (final ShelfSort s in ShelfSort.values)
                  PopupMenuItem<ShelfSort>(
                    value: s,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          s == _sort
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 16,
                          color: s == _sort
                              ? AppColors.brand
                              : AppColors.textTertiary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(_label(s)),
                      ],
                    ),
                  ),
              ],
            ),
          TextButton(
            onPressed: () => _editing ? _exitEditing() : _enterEditing(),
            child: Text(_editing ? '完成' : '编辑'),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: asyncBooks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => ErrorView(message: '书架加载失败：$e'),
        data: (List<Book> books) {
          if (books.isEmpty) {
            return EmptyView(
              icon: Icons.menu_book_outlined,
              title: '书架还是空的',
              subtitle: '导入 EPUB / TXT / PDF，或在发现页粘贴直链下载',
              actionLabel: '立即导入',
              onAction: () => context.push('/import'),
            );
          }
          final List<Book> sorted = _sorted(books);
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(shelfProvider),
            child: ListView(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              physics: const AlwaysScrollableScrollPhysics(),
              children: <Widget>[
                if (_editing) _editHint(sorted),
                SizedBox(
                  height: _stripHeight,
                  child: _strip(sorted),
                ),
                const SizedBox(height: AppSpacing.md),
                _tip(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar:
          _editing ? _actionBar(asyncBooks.valueOrNull ?? <Book>[]) : null,
    );
  }

  /// 编辑模式顶部提示：已选数量 + 全选 / 取消全选
  Widget _editHint(List<Book> books) {
    final bool allSelected =
        books.isNotEmpty && _selected.length == books.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: <Widget>[
          Text(
            '已选 ${_selected.length} / ${books.length}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => setState(() {
              _selected.clear();
              if (!allSelected) {
                _selected.addAll(books.map((Book b) => b.id));
              }
            }),
            child: Text(allSelected ? '取消全选' : '全选'),
          ),
        ],
      ),
    );
  }

  /// 横向书墙：每列两张卡片，列自左向右排列，右缘自然露出下一列
  Widget _strip(List<Book> books) {
    final int columns = (books.length / 2).ceil();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int c = 0; c < columns; c++)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _card(books[c * 2]),
                  const SizedBox(height: AppSpacing.lg),
                  if (c * 2 + 1 < books.length)
                    _card(books[c * 2 + 1])
                  else
                    const SizedBox(width: _cardWidth),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _card(Book book) => BookCard(
        book: book,
        width: _cardWidth,
        coverHeight: _coverHeight,
        editing: _editing,
        selected: _selected.contains(book.id),
        onToggleSelect: () => _toggleSelect(book),
        onTap: () => context.push('/book/${book.id}'),
        onLongPress: () => _enterEditing(book),
      );

  /// 底部操作栏（仅编辑模式）
  Widget _actionBar(List<Book> books) {
    final bool anySelected = _selected.isNotEmpty;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextButton.icon(
                onPressed:
                    anySelected ? () => _toggleFavoriteSelected(books) : null,
                icon: const Icon(Icons.favorite_border, size: 18),
                label: const Text('收藏'),
              ),
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: anySelected ? _removeSelected : null,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('移出书架'),
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tip() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Text(
          '左右滑动查看更多 · 长按书籍可批量管理',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
        ),
      );
}

/// 书架排序方式
enum ShelfSort { recent, title, progress, favorite }
