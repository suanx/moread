import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/book.dart';

/// 书架书籍卡片：大封面 + 书名 + 状态行。
///
/// 两种形态：
/// - 常规：点击进入详情，长按（由外层决定）进入编辑模式；
/// - 编辑：右上角出现选择圈，点击切换选中态。
class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    this.onLongPress,
    this.width = 108,
    this.coverHeight = 148,
    this.showProgress = true,
    this.editing = false,
    this.selected = false,
    this.onToggleSelect,
  });

  final Book book;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  /// 卡片宽度（封面宽度随之一致）
  final double width;

  /// 封面高度
  final double coverHeight;

  /// false 时状态行展示作者而非进度
  final bool showProgress;

  /// 是否处于编辑模式
  final bool editing;

  /// 编辑模式下是否被选中
  final bool selected;

  final VoidCallback? onToggleSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: editing ? (onToggleSelect ?? onTap) : onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: coverHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    _cover(),
                    // 半透明遮罩：提示已选中
                    if (editing && selected)
                      Container(color: AppColors.mask.withValues(alpha: 0.35)),
                    if (book.favorite && !editing)
                      const Positioned(
                        top: 6,
                        right: 6,
                        child: Icon(
                          Icons.favorite,
                          size: 15,
                          color: AppColors.danger,
                        ),
                      ),
                    if (editing)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: _selectionDot(selected),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              book.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            if (showProgress)
              Text(
                _statusText(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              )
            else
              Text(
                book.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _statusText() {
    if (book.isRead) return '已读完';
    if (book.isReading) return '在读 · ${(book.progress * 100).toStringAsFixed(0)}%';
    return '未读 · ${book.format.name.toUpperCase()}';
  }

  Widget _selectionDot(bool selected) => Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: selected ? AppColors.brand : Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.brand : AppColors.textTertiary,
            width: 1.5,
          ),
        ),
        child: selected
            ? const Icon(Icons.check, size: 13, color: Colors.white)
            : null,
      );

  Widget _cover() {
    final String? path = book.coverPath;
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  /// 无封面时用书名首字生成占位封面，避免书架出现大片空白
  Widget _placeholder() {
    final String trimmed = book.title.trim();
    final String initial = trimmed.isEmpty ? '书' : trimmed.substring(0, 1);
    final int hue = (book.title.hashCode % 360).abs();
    final Color base = HSLColor.fromAHSL(1, hue.toDouble(), 0.35, 0.55).toColor();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[base, base.withValues(alpha: 0.75)],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 34,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
