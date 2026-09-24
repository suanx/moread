import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/book.dart';

/// 书架书籍卡片：封面 + 书名 + 进度条。
class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    this.onLongPress,
    this.showProgress = true,
  });

  final Book book;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  _cover(),
                  if (book.favorite)
                    const Positioned(
                      top: 4,
                      right: 4,
                      child: Icon(Icons.favorite, size: 14, color: AppColors.danger),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          if (showProgress)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: SizedBox(
                height: 3,
                child: LinearProgressIndicator(
                  value: book.progress <= 0 ? 0 : book.progress,
                  backgroundColor: AppColors.surfaceVariant,
                  color: book.isRead ? AppColors.textTertiary : AppColors.brand,
                ),
              ),
            )
          else
            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }

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
    return Container(
      color: HSLColor.fromAHSL(1, hue.toDouble(), 0.35, 0.85).toColor(),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
