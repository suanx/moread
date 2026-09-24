import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/tts_settings.dart';
import '../../domain/repositories/tts_repository.dart';
import '../../services/tts/tts_playback_controller.dart';

/// 朗读仓储实现：偏好持久化 + 音频缓存管理。
class TtsRepositoryImpl implements TtsRepository {
  TtsRepositoryImpl({
    required Future<SharedPreferences> prefs,
    required TtsPlaybackController controller,
  })  : _prefs = prefs,
        _controller = controller;

  static const String _settingsKey = 'tts_settings_v1';

  final Future<SharedPreferences> _prefs;
  final TtsPlaybackController _controller;

  @override
  Future<List<TtsVoice>> getVoices() async => TtsVoice.builtIn;

  @override
  Future<TtsSettings> getSettings() async {
    final SharedPreferences prefs = await _prefs;
    final String? raw = prefs.getString(_settingsKey);
    if (raw == null || raw.isEmpty) return const TtsSettings();
    try {
      final List<String> parts = raw.split('|');
      return TtsSettings(
        voice: parts.isNotEmpty && parts[0].isNotEmpty
            ? parts[0]
            : 'zh-CN-XiaoxiaoNeural',
        ratePercent: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
        pitchHz: parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0,
        volumePercent: parts.length > 3 ? int.tryParse(parts[3]) ?? 0 : 0,
        autoNextChapter: parts.length > 4 ? parts[4] == '1' : true,
        sleepTimerMinutes: parts.length > 5 ? int.tryParse(parts[5]) ?? 0 : 0,
        highlightFollow: parts.length > 6 ? parts[6] == '1' : true,
        playInBackground: parts.length > 7 ? parts[7] == '1' : true,
      );
    } catch (_) {
      return const TtsSettings();
    }
  }

  @override
  Future<void> saveSettings(TtsSettings settings) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(
      _settingsKey,
      <Object>[
        settings.voice,
        settings.ratePercent,
        settings.pitchHz,
        settings.volumePercent,
        settings.autoNextChapter ? 1 : 0,
        settings.sleepTimerMinutes,
        settings.highlightFollow ? 1 : 0,
        settings.playInBackground ? 1 : 0,
      ].join('|'),
    );
  }

  @override
  Future<int> clearCache({String? bookId}) => _controller.clearCache(bookId: bookId);

  @override
  Future<int> cacheSize({String? bookId}) => _controller.cacheSize(bookId: bookId);
}
