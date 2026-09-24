import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/reading_repository.dart';
import '../common/empty_view.dart';

/// 发现页。
///
/// MVP 提供两类能力：
/// 1. 本地检索：按书名 / 作者过滤书架，并对选中书籍做全文检索；
/// 2. 在线下载：粘贴书籍直链（EPUB/TXT/PDF）下载到本地，之后完全离线可读。
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _ctrl = TextEditingController();
  String _keyword = '';
  Book? _selected;
  Future<List<SearchHit>>? _hits;
  bool _downloading = false;
  double _downloadProgress = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<Book> _filter(List<Book> books) {
    if (_keyword.trim().isEmpty) return books;
    final String k = _keyword.trim().toLowerCase();
    return books
        .where((Book b) =>
            b.title.toLowerCase().contains(k) ||
            b.author.toLowerCase().contains(k))
        .toList();
  }

  Future<void> _searchInBook(Book book) async {
    setState(() {
      _selected = book;
      _hits = ref
          .read(readingRepositoryProvider)
          .searchInBook(book.id, _keyword.trim());
    });
  }

  Future<void> _download() async {
    final String url = _ctrl.text.trim();
    if (url.isEmpty || !url.startsWith('http')) {
      _toast('请输入以 http(s) 开头的书籍直链');
      return;
    }
    setState(() {
      _downloading = true;
      _downloadProgress = 0;
    });
    try {
      final Book book = await ref.read(bookRepositoryProvider).downloadOnline(
        url: url,
        title: Uri.parse(url).pathSegments.isEmpty
            ? '在线书籍'
            : Uri.parse(url).pathSegments.last,
        onProgress: (double p) => setState(() => _downloadProgress = p),
      );
      ref.invalidate(shelfProvider);
      if (mounted) {
        _toast('《${book.title}》已加入书架');
        context.push('/book/${book.id}');
      }
    } catch (e) {
      _toast('下载失败：${e.toString()}');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  void _toast(String m) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Book>> shelf = ref.watch(shelfProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('发现'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: TextField(
              controller: _ctrl,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: '搜索书名 / 作者，或粘贴书籍下载链接',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
              onChanged: (String v) => setState(() => _keyword = v),
              onSubmitted: (_) => _download(),
            ),
          ),
        ),
      ),
      body: shelf.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => ErrorView(message: '加载失败：$e'),
        data: (List<Book> books) {
          final List<Book> matched = _filter(books);
          if (matched.isEmpty) {
            return EmptyView(
              icon: Icons.search_off,
              title: _keyword.isEmpty ? '书架还没有书' : '没有匹配的书籍',
              subtitle: '也可以在上方粘贴书籍直链直接下载',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              if (_downloading) ...<Widget>[
                LinearProgressIndicator(value: _downloadProgress),
                const SizedBox(height: AppSpacing.sm),
              ],
              if (_selected != null && _hits != null) ...<Widget>[
                _buildHits(_selected!, _hits!),
                const Divider(height: AppSpacing.lg),
              ],
              const Text('书架', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.sm),
              for (final Book b in matched)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.menu_book_outlined),
                  title: Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(b.author),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.search, size: 18),
                        tooltip: '全文检索',
                        onPressed: _keyword.trim().isEmpty
                            ? null
                            : () => _searchInBook(b),
                      ),
                      const Icon(Icons.chevron_right, size: 16),
                    ],
                  ),
                  onTap: () => context.push('/book/${b.id}'),
                ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                '提示：在输入框粘贴 EPUB / TXT / PDF 直链并回车即可下载到本地。',
                style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHits(Book book, Future<List<SearchHit>> hits) {
    return FutureBuilder<List<SearchHit>>(
      future: hits,
      builder: (BuildContext context, AsyncSnapshot<List<SearchHit>> snap) {
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final List<SearchHit> list = snap.data!;
        if (list.isEmpty) {
          return Text('《${book.title}》中没有找到「$_keyword」');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('《${book.title}》命中 ${list.length} 处',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.sm),
            for (final SearchHit h in list)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(h.snippet, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(h.chapterTitle),
                onTap: () => context.push('/reader/${book.id}'),
              ),
          ],
        );
      },
    );
  }
}
