import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/time_utils.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/entities/note.dart';

/// 书签 / 笔记面板。
class ReaderMarksSheet extends StatelessWidget {
  const ReaderMarksSheet({
    super.key,
    required this.bookmarks,
    required this.notes,
    required this.onJumpBookmark,
    required this.onJumpNote,
    required this.onDeleteBookmark,
    required this.onDeleteNote,
  });

  final List<Bookmark> bookmarks;
  final List<Note> notes;
  final ValueChanged<Bookmark> onJumpBookmark;
  final ValueChanged<Note> onJumpNote;
  final ValueChanged<String> onDeleteBookmark;
  final ValueChanged<String> onDeleteNote;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (BuildContext context, ScrollController controller) =>
          DefaultTabController(
        length: 2,
        child: Column(
          children: <Widget>[
            const TabBar(
              tabs: <Widget>[
                Tab(text: '书签'),
                Tab(text: '笔记'),
              ],
              labelColor: AppColors.brand,
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  _buildList(
                    controller,
                    count: bookmarks.length,
                    empty: '还没有书签，阅读时点击右上角书签图标添加',
                    item: (int i) {
                      final Bookmark b = bookmarks[i];
                      return ListTile(
                        title: Text(
                          b.chapterTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${b.excerpt} · ${TimeUtils.relative(b.createdAt)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          onPressed: () => onDeleteBookmark(b.id),
                        ),
                        onTap: () => onJumpBookmark(b),
                      );
                    },
                  ),
                  _buildList(
                    controller,
                    count: notes.length,
                    empty: '还没有笔记，长按正文选中文字即可划线记录',
                    item: (int i) {
                      final Note n = notes[i];
                      return ListTile(
                        title: Text(
                          n.quote,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          n.content.isEmpty
                              ? n.chapterTitle
                              : '想法：${n.content}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          onPressed: () => onDeleteNote(n.id),
                        ),
                        onTap: () => onJumpNote(n),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    ScrollController controller, {
    required int count,
    required String empty,
    required Widget Function(int) item,
  }) {
    if (count == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            empty,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
      );
    }
    return ListView.separated(
      controller: controller,
      itemCount: count,
      separatorBuilder: (_, __) => const Divider(height: 0.5),
      itemBuilder: (BuildContext context, int i) => item(i),
    );
  }
}
