import '../../core/theme/reader_themes.dart';

/// 阅读器排版与交互偏好（全局，非单本）。
class ReaderSettings {
  const ReaderSettings({
    this.fontSize = 17,
    this.lineHeight = 1.75,
    this.letterSpacing = 0.0,
    this.paragraphSpacing = 1.0,
    this.marginScale = 1.0,
    this.fontFamily = 'system',
    this.themeId = 'light',
    this.followSystemTheme = false,
    this.pageMode = ReaderPageMode.paged,
    this.keepScreenOn = true,
    this.brightnessFollowSystem = true,
    this.screenBrightness = 0.6,
    this.enableVolumeKeyTurnPage = false,
  });

  /// 正文字号（sp）
  final double fontSize;

  /// 行高倍数
  final double lineHeight;

  /// 字间距（px）
  final double letterSpacing;

  /// 段间距倍数
  final double paragraphSpacing;

  /// 页边距缩放（1.0 = 标准 20px）
  final double marginScale;

  /// 字体：system / serif / sans / kai
  final String fontFamily;

  final String themeId;

  /// 是否跟随系统深色模式自动切夜间
  final bool followSystemTheme;

  final ReaderPageMode pageMode;

  final bool keepScreenOn;

  /// 亮度是否跟随系统
  final bool brightnessFollowSystem;

  /// 阅读页独立亮度（0~1）
  final double screenBrightness;

  final bool enableVolumeKeyTurnPage;

  ReaderTheme get theme => ReaderTheme.byId(themeId);

  /// CSS font-family
  String get cssFontFamily => switch (fontFamily) {
        'serif' => "'Songti SC', 'Noto Serif CJK SC', Georgia, serif",
        'sans' => "'PingFang SC', 'Noto Sans CJK SC', Helvetica, sans-serif",
        'kai' => "'Kaiti SC', 'STKaiti', 'Noto Serif CJK SC', serif",
        _ => "-apple-system, 'PingFang SC', 'Microsoft YaHei', sans-serif",
      };

  ReaderSettings copyWith({
    double? fontSize,
    double? lineHeight,
    double? letterSpacing,
    double? paragraphSpacing,
    double? marginScale,
    String? fontFamily,
    String? themeId,
    bool? followSystemTheme,
    ReaderPageMode? pageMode,
    bool? keepScreenOn,
    bool? brightnessFollowSystem,
    double? screenBrightness,
    bool? enableVolumeKeyTurnPage,
  }) =>
      ReaderSettings(
        fontSize: fontSize ?? this.fontSize,
        lineHeight: lineHeight ?? this.lineHeight,
        letterSpacing: letterSpacing ?? this.letterSpacing,
        paragraphSpacing: paragraphSpacing ?? this.paragraphSpacing,
        marginScale: marginScale ?? this.marginScale,
        fontFamily: fontFamily ?? this.fontFamily,
        themeId: themeId ?? this.themeId,
        followSystemTheme: followSystemTheme ?? this.followSystemTheme,
        pageMode: pageMode ?? this.pageMode,
        keepScreenOn: keepScreenOn ?? this.keepScreenOn,
        brightnessFollowSystem: brightnessFollowSystem ?? this.brightnessFollowSystem,
        screenBrightness: screenBrightness ?? this.screenBrightness,
        enableVolumeKeyTurnPage:
            enableVolumeKeyTurnPage ?? this.enableVolumeKeyTurnPage,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'fontSize': fontSize,
        'lineHeight': lineHeight,
        'letterSpacing': letterSpacing,
        'paragraphSpacing': paragraphSpacing,
        'marginScale': marginScale,
        'fontFamily': fontFamily,
        'themeId': themeId,
        'followSystemTheme': followSystemTheme,
        'pageMode': pageMode.name,
        'keepScreenOn': keepScreenOn,
        'brightnessFollowSystem': brightnessFollowSystem,
        'screenBrightness': screenBrightness,
        'enableVolumeKeyTurnPage': enableVolumeKeyTurnPage,
      };

  factory ReaderSettings.fromMap(Map<String, dynamic> m) => ReaderSettings(
        fontSize: (m['fontSize'] as num?)?.toDouble() ?? 17,
        lineHeight: (m['lineHeight'] as num?)?.toDouble() ?? 1.75,
        letterSpacing: (m['letterSpacing'] as num?)?.toDouble() ?? 0,
        paragraphSpacing: (m['paragraphSpacing'] as num?)?.toDouble() ?? 1,
        marginScale: (m['marginScale'] as num?)?.toDouble() ?? 1,
        fontFamily: m['fontFamily'] as String? ?? 'system',
        themeId: m['themeId'] as String? ?? 'light',
        followSystemTheme: m['followSystemTheme'] as bool? ?? false,
        pageMode: ReaderPageMode.values.firstWhere(
          (ReaderPageMode e) => e.name == m['pageMode'],
          orElse: () => ReaderPageMode.paged,
        ),
        keepScreenOn: m['keepScreenOn'] as bool? ?? true,
        brightnessFollowSystem: m['brightnessFollowSystem'] as bool? ?? true,
        screenBrightness: (m['screenBrightness'] as num?)?.toDouble() ?? 0.6,
        enableVolumeKeyTurnPage: m['enableVolumeKeyTurnPage'] as bool? ?? false,
      );
}

/// 阅读翻页方式：仿真翻页/滑动分页/滚动
enum ReaderPageMode { paged, scroll }
