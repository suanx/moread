import 'package:flutter/material.dart';

/// 全应用统一色彩令牌（Design Token）。
///
/// 约定：业务代码只允许引用本文件的常量，禁止硬编码颜色值，
/// 以保证主题切换（浅色 / 深色 / 阅读主题）时的一致性。
abstract final class AppColors {
  // ---------- 品牌色 ----------
  static const Color brand = Color(0xFF22A06B);
  static const Color brandDark = Color(0xFF1B8156);
  static const Color brandLight = Color(0xFFE8F5EF);

  // ---------- 语义色 ----------
  static const Color success = Color(0xFF2FA36B);
  static const Color warning = Color(0xFFE8A33D);
  static const Color danger = Color(0xFFE15B4C);
  static const Color info = Color(0xFF4C86E1);

  // ---------- 浅色主题 ----------
  static const Color bg = Color(0xFFF6F7F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F5);
  static const Color divider = Color(0xFFE7EAED);
  static const Color textPrimary = Color(0xFF1A1C1E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFFA6ADB4);

  // ---------- 深色主题 ----------
  static const Color bgDark = Color(0xFF0F1113);
  static const Color surfaceDark = Color(0xFF171A1D);
  static const Color surfaceVariantDark = Color(0xFF212529);
  static const Color dividerDark = Color(0xFF2A2F34);
  static const Color textPrimaryDark = Color(0xFFE9ECEF);
  static const Color textSecondaryDark = Color(0xFF9AA4AE);

  // ---------- 其它 ----------
  static const Color skeleton = Color(0xFFE9ECEF);
  static const Color mask = Color(0x99000000);
}
