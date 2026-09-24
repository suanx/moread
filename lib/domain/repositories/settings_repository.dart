import '../entities/reader_settings.dart';

/// 阅读排版偏好仓储（SharedPreferences 实现）。
abstract interface class SettingsRepository {
  Future<ReaderSettings> getReaderSettings();

  Future<void> saveReaderSettings(ReaderSettings settings);

  Future<bool> isFirstLaunch();

  Future<void> setThemeMode(String mode);
}
