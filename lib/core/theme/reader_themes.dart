import 'package:flutter/material.dart';

/// 阅读器内置主题（护眼 / 夜间 / 纯黑 / 纸张 / 白天）。
///
/// 主题只描述「阅读区」的配色，与 App 外壳主题解耦：
/// 阅读页会用 [ReaderTheme.backgroundColor] 作为整页背景，
/// 并把 fg / bg 注入到 WebView 的 CSS 变量中。
class ReaderTheme {
  const ReaderTheme({
    required this.id,
    required this.name,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.subtitleColor,
    required this.highlightColor,
    required this.isDark,
  });

  final String id;
  final String name;

  /// 正文背景色
  final Color backgroundColor;

  /// 正文文字色
  final Color foregroundColor;

  /// 标题 / 次要文字色（如脚注、引用）
  final Color subtitleColor;

  /// 朗读高亮底色
  final Color highlightColor;

  /// 是否深色主题（决定是否切换系统状态栏）
  final bool isDark;

  /// CSS 颜色字符串（注入 WebView）
  String get cssBackground => _toCss(backgroundColor);

  String get cssForeground => _toCss(foregroundColor);

  String get cssSubtitle => _toCss(subtitleColor);

  String get cssHighlight => _toCss(highlightColor);

  /// 转为 CSS 十六进制颜色（#RRGGBB）
  static String _toCss(Color c) =>
      '#${(c.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  static const ReaderTheme light = ReaderTheme(
    id: 'light',
    name: '白天',
    backgroundColor: Color(0xFFF7F7F5),
    foregroundColor: Color(0xFF1F2328),
    subtitleColor: Color(0xFF6B7280),
    highlightColor: Color(0x33E8A33D),
    isDark: false,
  );

  static const ReaderTheme sepia = ReaderTheme(
    id: 'sepia',
    name: '护眼',
    backgroundColor: Color(0xFFCDE8CF),
    foregroundColor: Color(0xFF243028),
    subtitleColor: Color(0xFF5C6B60),
    highlightColor: Color(0x5522A06B),
    isDark: false,
  );

  static const ReaderTheme paper = ReaderTheme(
    id: 'paper',
    name: '纸张',
    backgroundColor: Color(0xFFF3EADA),
    foregroundColor: Color(0xFF3A3226),
    subtitleColor: Color(0xFF7A6E5C),
    highlightColor: Color(0x33C08A4A),
    isDark: false,
  );

  static const ReaderTheme night = ReaderTheme(
    id: 'night',
    name: '夜间',
    backgroundColor: Color(0xFF121417),
    foregroundColor: Color(0xFF9EA6AE),
    subtitleColor: Color(0xFF6E767E),
    highlightColor: Color(0x3D22A06B),
    isDark: true,
  );

  static const ReaderTheme oled = ReaderTheme(
    id: 'oled',
    name: '纯黑',
    backgroundColor: Color(0xFF000000),
    foregroundColor: Color(0xFF6E767E),
    subtitleColor: Color(0xFF4E565E),
    highlightColor: Color(0x4D22A06B),
    isDark: true,
  );

  static const List<ReaderTheme> all = <ReaderTheme>[
    light,
    sepia,
    paper,
    night,
    oled,
  ];

  static ReaderTheme byId(String id) => all.firstWhere(
        (ReaderTheme t) => t.id == id,
        orElse: () => light,
      );
}
