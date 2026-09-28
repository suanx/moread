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
/// 布局对齐设计稿：搜索框 → 推荐区块（横向卡片）→ 数据小卡行 → 书籍列表。
/// 三类能力：
/// 1. 本地检索：按书名 / 作者过滤书架，并可对选中书籍做全文检索；
/// 2. 在线下载：粘贴 EPUB/TXT/PDF 直链下载到本地；
/// 3. 继续阅读：直接回到上次进度。
class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> {
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

  bool get _isSearching => _keyword.trim().isNotEmpty;

  List<Book> _filter(List<Book> books) {
    final String k = _keyword.trim().toLowerCase();
    if (k.isEmpty) return books;
    return books
        .where((Book b) =>
            b.title.toLowerCase().contains(k) ||
            b.author.toLowerCase().contains(k))
        .toList();
  }

  void _searchInBook(Book book) {
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
      if (!mounted) return;
      _toast('《${book.title}》已加入书架');
      context.push('/book/${book.id}');
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
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            _searchBar(),
            if (_downloading)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xs,
                ),
                child: LinearProgressIndicator(value: _downloadProgress),
              ),
            Expanded(
              child: shelf.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (Object e, _) => ErrorView(message: '加载失败：$e'),
                data: (List<Book> books) => _isSearching
                    ? _searchResult(books)
                    : _home(books),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 搜索框
  // =========================================================================

  Widget _searchBar() {
    final bool isUrl = _ctrl.text.trim().startsWith('http');
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: TextField(
        controller: _ctrl,
        textInputAction: isUrl ? TextInputAction.go : TextInputAction.search,
        decoration: InputDecoration(
          hintText: '搜索书籍',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _keyword.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: '清空',
                  onPressed: () => setState(() {
                    _ctrl.clear();
                    _keyword = '';
                    _selected = null;
                    _hits = null;
                  }),
                ),
        ),
        onChanged: (String v) => setState(() {
          _keyword = v;
          _selected = null;
          _hits = null;
        }),
        onSubmitted: (_) => isUrl ? _download() : null,
      ),
    );
  }

  // =========================================================================
  // 首页（推荐 + 小卡 + 继续阅读）
  // =========================================================================

  Widget _home(List<Book> books) {
    final List<Book> reading =
        books.where((Book b) => b.isReading).take(5).toList();
    final List<Book> recent = List<Book>.of(books)
      ..sort((Book a, Book b) => b.addedAt.compareTo(a.addedAt));

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      children: <Widget>[
        _sectionHeader(
          '推荐',
          onEnter: () => _toast('推荐频道开发中，先把书架里的书读起来'),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 168,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            children: <Widget>[
              _recoCard(
                title: '每日推荐',
                subtitle: '4286 人在读',
                badge: '荐',
                metric: '64.2万字',
                colors: const <Color>[Color(0xFF2F7D5B), Color(0xFF1C5A40)],
                secondColors: const <Color>[
                  Color(0xFF79B79A),
                  Color(0xFF5C9C7F),
                ],
                bookLabel: '人间草木',
                onTap: () => _toast('已为你准备每日推荐（演示数据）'),
              ),
              _recoCard(
                title: '新书速递',
                subtitle: '上周上新',
                badge: '新',
                metric: '231本',
                colors: const <Color>[Color(0xFF5A8DE8), Color(0xFF3A63C4)],
                secondColors: const <Color>[
                  Color(0xFF9DBDF2),
                  Color(0xFF7BA0E5),
                ],
                bookLabel: '山海',
                onTap: () => _toast('新书速递每周更新（演示数据）'),
              ),
              _recoCard(
                title: '本周榜单',
                subtitle: '热度飙升',
                badge: '榜',
                metric: 'Top 20',
                colors: const <Color>[Color(0xFFF2A35A), Color(0xFFD9482B)],
                secondColors: const <Color>[
                  Color(0xFFF0A8B8),
                  Color(0xFFE77F97),
                ],
                bookLabel: '长风渡',
                onTap: () => _toast('查看本周热读榜（演示数据）'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _miniRow(books),
        if (reading.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
          _sectionHeader('继续阅读'),
          const SizedBox(height: AppSpacing.xs),
          for (final Book b in reading) _continueTile(b),
        ],
        if (recent.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
          _sectionHeader(
            '书架',
            onEnter: () => context.go('/shelf'),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final Book b in recent.take(6))
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 2,
              ),
              leading: _coverThumb(b),
              title: Text(
                b.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              subtitle: Text(
                '${b.author} · ${b.format.name.toUpperCase()}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right, size: 18),
              onTap: () => context.push('/book/${b.id}'),
            ),
        ],
      ],
    );
  }

  /// 区块标题行：标题 + 右侧进入图标
  Widget _sectionHeader(String title, {VoidCallback? onEnter}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          if (onEnter != null)
            IconButton(
              onPressed: onEnter,
              icon: const Icon(Icons.keyboard_return, size: 18),
              color: AppColors.brand,
              visualDensity: VisualDensity.compact,
              tooltip: '进入$title',
            ),
        ],
      ),
    );
  }

  /// 推荐大卡：双封面 + 标题 + 底部 meta
  Widget _recoCard({
    required String title,
    required String subtitle,
    required String badge,
    required String metric,
    required List<Color> colors,
    required List<Color> secondColors,
    required String bookLabel,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.cardGap),
      child: SizedBox(
        width: 152,
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 96,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: _coverBlock(
                            colors: colors,
                            label: bookLabel,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          flex: 2,
                          child: _coverBlock(
                            colors: secondColors,
                            label: '卷一',
                            small: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 12,
                        height: 12,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        metric,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 纯色块书封占位
  Widget _coverBlock({
    required List<Color> colors,
    required String label,
    bool small = false,
  }) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: small ? 10 : 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 小卡行：蓝色数据卡 + 新书双封面卡
  Widget _miniRow(List<Book> books) {
    final int readingCount = books.where((Book b) => b.isReading).length;
    final int finished = books.where((Book b) => b.isRead).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Material(
              color: AppColors.brandLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: InkWell(
                onTap: () => context.go('/me'),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.brand,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bar_chart,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '在读 $readingCount 本',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '已读完 $finished 本',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.cardGap),
          Expanded(
            child: Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: InkWell(
                onTap: () => context.push('/import'),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              '导入本地书',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'EPUB / TXT / PDF',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2543F),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _continueTile(Book b) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 2,
      ),
      leading: _coverThumb(b),
      title: Text(
        b.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: LinearProgressIndicator(
            value: b.progress,
            minHeight: 4,
            backgroundColor: AppColors.surfaceVariant,
          ),
        ),
      ),
      trailing: Text(
        '${(b.progress * 100).toStringAsFixed(0)}%',
        style: const TextStyle(fontSize: 11, color: AppColors.brand),
      ),
      onTap: () => context.push('/reader/${b.id}'),
    );
  }

  Widget _coverThumb(Book b) {
    final String trimmed = b.title.trim();
    return Container(
      width: 34,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF4D84E8), Color(0xFF2B5CC7)],
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        trimmed.isEmpty ? '书' : trimmed.substring(0, 1),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // =========================================================================
  // 搜索结果
  // =========================================================================

  Widget _searchResult(List<Book> books) {
    final List<Book> matched = _filter(books);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: <Widget>[
        if (_selected != null && _hits != null) ...<Widget>[
          _buildHits(_selected!, _hits!),
          const Divider(height: AppSpacing.xl),
        ],
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                '书架命中 ${matched.length} 本',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (_keyword.trim().startsWith('http'))
              TextButton(
                onPressed: _download,
                child: const Text('作为直链下载'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        if (matched.isEmpty)
          const EmptyView(
            icon: Icons.search_off,
            title: '没有匹配的书籍',
            subtitle: '也可以在上方粘贴 EPUB / TXT / PDF 直链，回车下载',
          )
        else
          for (final Book b in matched)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: _coverThumb(b),
              title: Text(
                b.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${b.author} · ${b.format.name.toUpperCase()}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.manage_search, size: 20),
                tooltip: '全书检索',
                onPressed: () => _searchInBook(b),
              ),
              onTap: () => context.push('/book/${b.id}'),
            ),
      ],
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
            Text(
              '《${book.title}》命中 ${list.length} 处',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final SearchHit h in list)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  h.snippet,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(h.chapterTitle),
                onTap: () => context.push('/reader/${book.id}'),
              ),
          ],
        );
      },
    );
  }
}
