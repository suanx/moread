import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/providers.dart';
import '../../core/error/failure.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/entities/book.dart';
import '../common/empty_view.dart';
import 'widgets/book_card.dart';

/// 书架页：网格展示 + 排序 + 导入入口 + 长按删除。
class BookshelfPage extends ConsumerStatefulWidget {
  const BookshelfPage({super.key});

  @override
  ConsumerState<BookshelfPage> createState() => _BookshelfPageState();
}

class _BookshelfPageState extends ConsumerState<BookshelfPage> {
  ShelfSort _sort = ShelfSort.recent;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Book>> asyncBooks = ref.watch(shelfProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('书架'),
        actions: <Widget>[
          PopupMenuButton<ShelfSort>(
            icon: const Icon(Icons.sort),
            onSelected: (ShelfSort s) => setState(() => _sort = s),
            itemBuilder: (_) => <PopupMenuEntry<ShelfSort>>[
              const PopupMenuItem<ShelfSort>(
                value: ShelfSort.recent,
                child: Text('最近阅读'),
              ),
              const PopupMenuItem<ShelfSort>(
                value: ShelfSort.title,
                child: Text('书名'),
              ),
              const PopupMenuItem<ShelfSort>(
                value: ShelfSort.progress,
                child: Text('阅读进度'),
              ),
              const PopupMenuItem<ShelfSort>(
                value: ShelfSort.favorite,
                child: Text('收藏优先'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: '导入本地书籍',
            onPressed: () => context.push('/import'),
          ),
        ],
      ),
      body: asyncBooks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              e is Failure ? e.message : '书架加载失败：$e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (List<Book> books) {
          if (books.isEmpty) {
            return EmptyView(
              icon: Icons.menu_book_outlined,
              title: '书架还是空的',
              subtitle: '点击右上角 + 导入 EPUB / TXT / PDF',
              actionLabel: '立即导入',
              onAction: () => context.push('/import'),
            );
          }
          final List<Book> sorted = _sorted(books);
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(shelfProvider),
            child: GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: AppSpacing.lg,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio:
                    AppSize.bookCoverWidth / (AppSize.bookCoverHeight + 34),
              ),
              itemCount: sorted.length,
              itemBuilder: (BuildContext context, int i) => BookCard(
                book: sorted[i],
                onTap: () => context.push('/book/${sorted[i].id}'),
                onLongPress: () => _confirmDelete(sorted[i]),
              ),
            ),
          );
        },
      ),
    );
  }

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

  Future<void> _confirmDelete(Book book) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('移除书籍'),
        content: Text('确定从书架移除《${book.title}》？本地文件也会一并删除。'),
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
    await ref.read(bookRepositoryProvider).removeBook(book.id);
    ref.invalidate(shelfProvider);
  }
}

/// 书架排序方式
enum ShelfSort { recent, title, progress, favorite }
