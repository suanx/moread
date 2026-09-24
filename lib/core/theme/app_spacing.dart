import 'package:flutter/widgets.dart';

/// 间距 / 圆角 / 字号 / 阴影 等设计令牌。
///
/// 所有布局统一使用 4dp 栅格，避免随手写的 magic number。
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// 页面左右安全边距
  static const double pagePadding = 16;

  /// 卡片间距
  static const double cardGap = 12;

  // ---------- 圆角 ----------
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusFull = 999;

  // ---------- 阴影 ----------
  static const List<BoxShadow> cardShadow = <BoxShadow>[
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}

/// 通用尺寸常量（书架网格等）
abstract final class AppSize {
  static const double bookCoverWidth = 96;
  static const double bookCoverHeight = 136;
  static const double toolbarHeight = 48;
  static const double bottomBarHeight = 56;
}
