import '../entities/tts_settings.dart';

/// 朗读仓储：音色列表、朗读偏好、合成音频缓存管理。
abstract interface class TtsRepository {
  Future<List<TtsVoice>> getVoices();

  Future<TtsSettings> getSettings();

  Future<void> saveSettings(TtsSettings settings);

  /// 清理某本书（或全部）的合成音频缓存，返回释放的字节数
  Future<int> clearCache({String? bookId});

  /// 缓存占用（字节）
  Future<int> cacheSize({String? bookId});
}
