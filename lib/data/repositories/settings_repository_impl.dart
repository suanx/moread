import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/reader_settings.dart';
import '../../domain/repositories/settings_repository.dart';

/// 阅读排版偏好实现（SharedPreferences，避免为少量配置项开表）。
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._prefs);

  static const String _readerKey = 'reader_settings_v1';
  static const String _firstLaunchKey = 'first_launch_v1';
  static const String _themeModeKey = 'app_theme_mode_v1';

  final Future<SharedPreferences> _prefs;

  @override
  Future<ReaderSettings> getReaderSettings() async {
    final SharedPreferences prefs = await _prefs;
    final String? raw = prefs.getString(_readerKey);
    if (raw == null || raw.isEmpty) return const ReaderSettings();
    try {
      final List<String> p = raw.split('|');
      return ReaderSettings(
        fontSize: double.tryParse(p[0]) ?? 17,
        lineHeight: double.tryParse(p[1]) ?? 1.75,
        letterSpacing: double.tryParse(p[2]) ?? 0,
        paragraphSpacing: double.tryParse(p[3]) ?? 1,
        marginScale: double.tryParse(p[4]) ?? 1,
        fontFamily: p[5],
        themeId: p[6],
        followSystemTheme: p[7] == '1',
        pageMode: p[8] == 'scroll' ? ReaderPageMode.scroll : ReaderPageMode.paged,
        keepScreenOn: p[9] == '1',
        brightnessFollowSystem: p[10] == '1',
        screenBrightness: double.tryParse(p[11]) ?? 0.6,
        enableVolumeKeyTurnPage: p[12] == '1',
      );
    } catch (_) {
      return const ReaderSettings();
    }
  }

  @override
  Future<void> saveReaderSettings(ReaderSettings s) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(
      _readerKey,
      <Object>[
        s.fontSize,
        s.lineHeight,
        s.letterSpacing,
        s.paragraphSpacing,
        s.marginScale,
        s.fontFamily,
        s.themeId,
        s.followSystemTheme ? 1 : 0,
        s.pageMode == ReaderPageMode.scroll ? 'scroll' : 'paged',
        s.keepScreenOn ? 1 : 0,
        s.brightnessFollowSystem ? 1 : 0,
        s.screenBrightness,
        s.enableVolumeKeyTurnPage ? 1 : 0,
      ].join('|'),
    );
  }

  @override
  Future<bool> isFirstLaunch() async {
    final SharedPreferences prefs = await _prefs;
    final bool first = prefs.getBool(_firstLaunchKey) ?? true;
    if (first) {
      await prefs.setBool(_firstLaunchKey, false);
    }
    return first;
  }

  @override
  Future<void> setThemeMode(String mode) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(_themeModeKey, mode);
  }
}
