import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../services/ai/ai_models.dart';
import 'widgets/ai_chapter_scope.dart';

/// AI 思维导图：把章节脉络绘成树状导图。
///
/// 交互：画布支持拖动平移与双指缩放；点击节点高亮并显示节点说明。
class AiMindMapPage extends ConsumerWidget {
  const AiMindMapPage({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AiChapterScope(
      bookId: bookId,
      title: '思维导图',
      builder: (BuildContext context, AiChapterContext ctx) => _MindMapView(
        key: ValueKey<String>(ctx.chapter.id),
        ctx: ctx,
      ),
    );
  }
}

class _MindMapView extends ConsumerStatefulWidget {
  const _MindMapView({super.key, required this.ctx});

  final AiChapterContext ctx;

  @override
  ConsumerState<_MindMapView> createState() => _MindMapViewState();
}

class _MindMapViewState extends ConsumerState<_MindMapView> {
  MindMapNode? _root;
  bool _loading = false;
  int _selectedIndex = -1;
  List<_NodeBox> _boxes = const <_NodeBox>[];
  Size _canvas = Size.zero;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    setState(() => _loading = true);
    try {
      final MindMapNode root = await ref.read(aiServiceProvider).buildMindMap(
            bookTitle: widget.ctx.book.title,
            chapterTitle: widget.ctx.chapter.title,
            text: widget.ctx.text,
          );
      if (!mounted) return;
      final _LayoutResult layout = _layout(root);
      setState(() {
        _root = root;
        _boxes = layout.boxes;
        _canvas = layout.size;
        _selectedIndex = -1;
      });
    } catch (_) {
      // 保留旧结果
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// 树布局：叶子按顺序分配纵向槽位，父节点纵向居中于子节点之间
  _LayoutResult _layout(MindMapNode root) {
    const double colGap = 56;
    const double rowGap = 14;
    const double pad = 24;

    final List<_NodeBox> boxes = <_NodeBox>[];
    double maxRight = 0;
    int leafSeq = 0;

    /// 返回节点矩形（先占位，父节点稍后由子节点位置回填）
    double place(MindMapNode node, int depth, {required double width}) {
      final double x = pad + depth * (width + colGap);
      final double height = depth == 0 ? 46 : (depth == 1 ? 40 : 34);

      if (node.children.isEmpty) {
        final double y = pad + leafSeq * (34 + rowGap);
        leafSeq++;
        boxes.add(_NodeBox(
          rect: Rect.fromLTWH(x, y, width, height),
          node: node,
          depth: depth,
        ));
        maxRight = math.max(maxRight, x + width);
        return y + height / 2;
      }

      final List<double> centers = <double>[];
      for (final MindMapNode child in node.children) {
        centers.add(place(child, depth + 1, width: depth == 0 ? 132 : 124));
      }
      // 父节点纵向居中于首尾子节点之间
      final double mid = (centers.first + centers.last) / 2;
      final double y = mid - height / 2;
      boxes.add(_NodeBox(
        rect: Rect.fromLTWH(x, y, width, height),
        node: node,
        depth: depth,
      ));
      maxRight = math.max(maxRight, x + width);
      return y + height / 2;
    }

    place(root, 0, width: depthRootWidth);
    return _LayoutResult(
      boxes: boxes,
      size: Size(maxRight + pad, pad + leafSeq * (34 + rowGap) + pad),
    );
  }

  static const double depthRootWidth = 150;

  void _onTapCanvas(Offset local) {
    for (int i = 0; i < _boxes.length; i++) {
      if (_boxes[i].rect.contains(local)) {
        setState(() => _selectedIndex = i);
        return;
      }
    }
    setState(() => _selectedIndex = -1);
  }

  @override
  Widget build(BuildContext context) {
    if (_root == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final _NodeBox? selected =
        _selectedIndex >= 0 && _selectedIndex < _boxes.length
            ? _boxes[_selectedIndex]
            : null;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            0,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${_boxes.length} 个节点 · 双指缩放 / 拖动平移',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _loading ? null : _generate,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('重新生成'),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.lg),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.divider),
            ),
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 2.4,
              boundaryMargin: const EdgeInsets.all(80),
              constrained: false,
              child: GestureDetector(
                onTapUp: (TapUpDetails d) => _onTapCanvas(d.localPosition),
                child: CustomPaint(
                  size: _canvas,
                  painter: _MindMapPainter(
                    boxes: _boxes,
                    selectedIndex: _selectedIndex,
                    lineColor: AppColors.divider,
                    brandColor: AppColors.brand,
                    textColor: AppColors.textPrimary,
                    subTextColor: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (selected != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  selected.node.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (selected.node.note.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    selected.node.note,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// 一个已布局的节点盒子
class _NodeBox {
  const _NodeBox({required this.rect, required this.node, required this.depth});

  final Rect rect;
  final MindMapNode node;
  final int depth;
}

class _LayoutResult {
  const _LayoutResult({required this.boxes, required this.size});

  final List<_NodeBox> boxes;
  final Size size;
}

/// 导图绘制：圆角节点 + 贝塞尔连线
class _MindMapPainter extends CustomPainter {
  const _MindMapPainter({
    required this.boxes,
    required this.selectedIndex,
    required this.lineColor,
    required this.brandColor,
    required this.textColor,
    required this.subTextColor,
  });

  final List<_NodeBox> boxes;
  final int selectedIndex;
  final Color lineColor;
  final Color brandColor;
  final Color textColor;
  final Color subTextColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint line = Paint()
      ..color = lineColor
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    // 1) 先画连线（父子关系）
    for (final _NodeBox parent in boxes) {
      if (parent.node.children.isEmpty) continue;
      for (final MindMapNode child in parent.node.children) {
        final int idx = boxes.indexWhere((_NodeBox b) => b.node == child);
        if (idx < 0) continue;
        final Rect a = parent.rect;
        final Rect b = boxes[idx].rect;
        final Offset start = Offset(a.right, a.center.dy);
        final Offset end = Offset(b.left, b.center.dy);
        final double mid = (start.dx + end.dx) / 2;
        final Path path = Path()
          ..moveTo(start.dx, start.dy)
          ..cubicTo(mid, start.dy, mid, end.dy, end.dx, end.dy);
        canvas.drawPath(path, line);
      }
    }

    // 2) 再画节点
    for (int i = 0; i < boxes.length; i++) {
      final _NodeBox box = boxes[i];
      final bool isSelected = i == selectedIndex;
      final bool isRoot = box.depth == 0;
      final RRect rr =
          RRect.fromRectAndRadius(box.rect, const Radius.circular(10));

      canvas.drawRRect(
        rr,
        Paint()..color = isRoot
            ? brandColor
            : (isSelected ? AppColors.brandLight : const Color(0xFFF7F9FC)),
      );
      canvas.drawRRect(
        rr,
        Paint()
          ..color = isSelected ? brandColor : lineColor
          ..strokeWidth = isSelected ? 2 : 1.2
          ..style = PaintingStyle.stroke,
      );

      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: box.node.title,
          style: TextStyle(
            fontSize: isRoot ? 13 : 12,
            fontWeight: isRoot ? FontWeight.w700 : FontWeight.w500,
            color: isRoot ? Colors.white : textColor,
          ),
        ),
        maxLines: box.depth >= 2 ? 2 : 1,
        ellipsis: '…',
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: box.rect.width - 14);

      tp.paint(
        canvas,
        Offset(
          box.rect.left + (box.rect.width - tp.width) / 2,
          box.rect.top + (box.rect.height - tp.height) / 2,
        ),
      );

      // 根节点下的分支标签（note）贴在节点右上角
      if (box.depth == 1 && box.node.note.isNotEmpty) {
        final TextPainter note = TextPainter(
          text: TextSpan(
            text: box.node.note,
            style: TextStyle(fontSize: 10, color: subTextColor),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: 120);
        note.paint(canvas, Offset(box.rect.left + 8, box.rect.bottom + 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MindMapPainter old) =>
      old.boxes != boxes || old.selectedIndex != selectedIndex;
}
