import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// 应用主题构造器。
///
/// 设计规范：
/// - 主色 墨绿，强调「安静阅读」；
/// - 圆角统一 12；
/// - AppBar 无阴影、纯色背景，贴近微信阅读的克制风格；
/// - 所有卡片默认 12 圆角 + 极淡阴影。
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color scaffoldBg = isDark ? AppColors.bgDark : AppColors.bg;
    final Color surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final Color textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final Color textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: brightness,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      canvasColor: surface,
      splashFactory: InkSparkle.splashFactory,
      fontFamily: 'PingFang SC',
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: surface,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: textSecondary,
        textColor: textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.dividerDark : AppColors.divider,
        thickness: 0.5,
        space: 0.5,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        hintStyle: TextStyle(color: textSecondary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.brand, width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size.fromHeight(44),
          side: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        selectedItemColor: AppColors.brand,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: const TextStyle(fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusLg),
          ),
        ),
        showDragHandle: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.brand,
        linearTrackColor: AppColors.surfaceVariant,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 15, height: 1.5),
        bodyMedium: TextStyle(color: textPrimary, fontSize: 14, height: 1.45),
        bodySmall: TextStyle(color: textSecondary, fontSize: 12, height: 1.4),
        labelLarge: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}
