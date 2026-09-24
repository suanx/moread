import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/error/failure.dart';
import '../../core/logging/app_logger.dart';
import '../../core/storage/app_paths.dart';
import '../../core/utils/text_utils.dart';
import '../../domain/entities/tts_settings.dart';
import 'edge_tts_engine.dart';
import 'models/tts_models.dart';

/// 朗读播放状态
enum TtsStatus { idle, preparing, playing, paused, completed, error }

/// 朗读播放控制器 —— 「听书」功能的中枢。
///
/// 能力：
/// - 章节文本 → 分片 → 逐片调用 Edge-TTS 合成 → 落盘缓存（离线可重复播放）
/// - 使用 `just_audio` 的 [ConcatenatingAudioSource] 串联播放，天然支持跨分片续播
/// - 依据词边界把播放进度换算成「字符偏移」，驱动 WebView 高亮跟随
/// - 定时关闭（倒计时到点自动暂停，最后 10 秒渐隐）
/// - 断点续播（SharedPreferences 记录每个章节的播放位置）
/// - 后台播放与锁屏控制（just_audio_background + audio_session）
class TtsPlaybackController extends ChangeNotifier {
  TtsPlaybackController({
    required EdgeTtsEngine engine,
    required Future<SharedPreferences> prefs,
  })  : _engine = engine,
        _prefs = prefs;

  static const String _tag = 'TtsPlaybackController';

  final EdgeTtsEngine _engine;
  final Future<SharedPreferences> _prefs;

  final AudioPlayer _player = AudioPlayer();

  TtsStatus _status = TtsStatus.idle;
  TtsChapterTask? _task;
  TtsSettings _settings = const TtsSettings();

  /// 当前高亮字符偏移（-1 表示无）
  int _highlightChar = -1;

  /// 合成进度 0~1
  double _prepareProgress = 0;

  /// 定时关闭剩余秒数（0 表示未开启）
  int _sleepRemain = 0;

  String? _errorMessage;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _stateSub;
  Timer? _sleepTimer;

  // =========================================================================
  // 对外状态
  // =========================================================================

  TtsStatus get status => _status;
  TtsChapterTask? get task => _task;
  int get highlightChar => _highlightChar;
  double get prepareProgress => _prepareProgress;
  int get sleepRemainSeconds => _sleepRemain;
  String? get errorMessage => _errorMessage;
  bool get isPlaying => _status == TtsStatus.playing;
  Duration get position => _player.position;
  Duration get duration => _player.duration ?? _task?.estimatedDuration ?? Duration.zero;

  /// 初始化音频会话（应用启动时调用一次）
  Future<void> initSession() async {
    final AudioSession session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
  }

  // =========================================================================
  // 准备（合成 / 复用缓存）
  // =========================================================================

  /// 准备一个章节：返回后即可 [play]。
  ///
  /// - [text] 章节纯文本
  /// - [settings] 朗读参数；参数变化会触发重新合成（签名校验）
  Future<void> prepare({
    required String bookId,
    required String chapterId,
    required String chapterTitle,
    required String text,
    required TtsSettings settings,
    String? bookTitle,
    String? coverPath,
  }) async {
    _setStatus(TtsStatus.preparing);
    _settings = settings;
    _prepareProgress = 0;
    _highlightChar = -1;
    _errorMessage = null;
    notifyListeners();

    try {
      final Directory dir = AppPaths.instance.ttsDir(bookId, chapterId);
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }

      final List<TextRange> ranges = TextUtils.splitForSpeech(text);
      final List<TtsChunk> chunks = <TtsChunk>[];
      for (int i = 0; i < ranges.length; i++) {
        chunks.add(
          TtsChunk(
            index: i,
            startChar: ranges[i].start,
            endChar: ranges[i].end,
            text: text.substring(ranges[i].start, ranges[i].end),
          ),
        );
      }

      final String signature = _signature(settings);
      final File metaFile = File(p.join(dir.path, 'meta.json'));
      if (metaFile.existsSync()) {
        final Map<String, dynamic>? cached = _readMeta(metaFile);
        if (cached != null &&
            cached['sig'] == signature &&
            (cached['chunks'] as List<dynamic>?)?.length == chunks.length) {
          _restoreChunks(chunks, cached, dir.path);
          _prepareProgress = 1;
          notifyListeners();
          await _loadPlayer(bookId, chapterId, chapterTitle, chunks, bookTitle, coverPath);
          return;
        }
      }

      // 逐片合成（串行，避免被服务端限流）
      for (int i = 0; i < chunks.length; i++) {
        final TtsChunk c = chunks[i];
        final TtsSynthesisResult result = await _engine.synthesize(
          text: c.text,
          settings: settings,
          baseChar: c.startChar,
        );
        final File audioFile = File(p.join(dir.path, '${c.index}.mp3'));
        await audioFile.writeAsBytes(result.audio, flush: true);
        c.filePath = audioFile.path;
        c.bytes = result.audio.lengthInBytes;
        c.words
          ..clear()
          ..addAll(result.words);
        _prepareProgress = (i + 1) / chunks.length;
        notifyListeners();
      }

      await metaFile.writeAsString(
        jsonEncode(<String, dynamic>{
          'sig': signature,
          'chunks': chunks.map((TtsChunk c) => c.toJson()).toList(),
        }),
        flush: true,
      );

      _prepareProgress = 1;
      notifyListeners();
      await _loadPlayer(bookId, chapterId, chapterTitle, chunks, bookTitle, coverPath);
    } on Failure catch (e) {
      _errorMessage = e.message;
      _setStatus(TtsStatus.error);
    } catch (e, st) {
      AppLogger.e(_tag, '朗读准备失败', e, st);
      _errorMessage = '朗读准备失败：${e.toString()}';
      _setStatus(TtsStatus.error);
    }
  }

  Future<void> _loadPlayer(
    String bookId,
    String chapterId,
    String chapterTitle,
    List<TtsChunk> chunks,
    String? bookTitle,
    String? coverPath,
  ) async {
    _task = TtsChapterTask(
      bookId: bookId,
      chapterId: chapterId,
      chapterTitle: chapterTitle,
      plainText: '',
      chunks: chunks,
      settingsSignature: _signature(_settings),
    );

    final MediaItem item = MediaItem(
      id: '$bookId/$chapterId',
      title: chapterTitle,
      album: bookTitle ?? '墨读',
      artist: 'Edge 朗读',
      artUri: coverPath != null ? Uri.file(coverPath) : null,
    );

    await _player.setAudioSource(
      ConcatenatingAudioSource(
        children: <AudioSource>[
          for (final TtsChunk c in chunks)
            if (c.filePath != null)
              AudioSource.file(c.filePath!, tag: item),
        ],
      ),
      preload: true,
    );

    await _player.setSpeed(1.0);
    await _player.setVolume(1.0 + (_settings.volumePercent / 200));

    // 断点续播
    final SharedPreferences prefs = await _prefs;
    final int saved = prefs.getInt(_posKey(bookId, chapterId)) ?? 0;
    if (saved > 0 && saved < duration.inMilliseconds - 3000) {
      await _player.seek(Duration(milliseconds: saved));
    }

    _bindStreams(bookId, chapterId);
    _setStatus(TtsStatus.paused);
  }

  // =========================================================================
  // 播放控制
  // =========================================================================

  Future<void> play() async {
    if (_task == null) return;
    final AudioSession session = await AudioSession.instance;
    await session.setActive(true);
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
    await _savePosition();
  }

  Future<void> stop() async {
    await _savePosition();
    await _player.pause();
    await _player.seek(Duration.zero);
    _highlightChar = -1;
    _setStatus(TtsStatus.idle);
  }

  Future<void> seekForward(int seconds) => _seekBy(Duration(seconds: seconds));

  Future<void> seekBackward(int seconds) =>
      _seekBy(Duration(seconds: -seconds));

  Future<void> _seekBy(Duration delta) async {
    final Duration target = _player.position + delta;
    await _player.seek(
      target < Duration.zero
          ? Duration.zero
          : (target > duration ? duration : target),
    );
  }

  /// 跳到某个字符偏移处开始朗读
  Future<void> seekToChar(int charOffset) async {
    final TtsChapterTask? t = _task;
    if (t == null) return;
    int acc = 0;
    for (final TtsChunk c in t.chunks) {
      final int dur = c.estimatedDuration.inMilliseconds;
      if (charOffset < c.endChar) {
        // 在该分片内找到最接近的词
        int bestMs = 0;
        for (final TtsWord w in c.words) {
          if (w.charStart <= charOffset) {
            bestMs = w.offsetMs;
          } else {
            break;
          }
        }
        await _player.seek(Duration(milliseconds: acc + bestMs));
        return;
      }
      acc += dur;
    }
    await _player.seek(Duration(milliseconds: acc));
  }

  /// 定时器（分钟），0 表示取消
  void setSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepRemain = minutes <= 0 ? 0 : minutes * 60;
    notifyListeners();
    if (minutes <= 0) return;

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      _sleepRemain -= 1;
      if (_sleepRemain <= 10 && _sleepRemain > 0) {
        // 最后 10 秒渐隐，避免突然静音
        final double v = _sleepRemain / 10;
        await _player.setVolume(v < 0 ? 0 : (v > 1 ? 1 : v));
      }
      if (_sleepRemain <= 0) {
        t.cancel();
        _sleepTimer = null;
        await pause();
        await _player.setVolume(1.0 + (_settings.volumePercent / 200));
      }
      notifyListeners();
    });
  }

  /// 实时调节音量（-100 ~ 100）
  Future<void> applyVolume(int volumePercent) async {
    _settings = _settings.copyWith(volumePercent: volumePercent);
    await _player.setVolume(1.0 + (volumePercent / 200));
    notifyListeners();
  }

  // =========================================================================
  // 进度 → 高亮
  // =========================================================================

  void _bindStreams(String bookId, String chapterId) {
    _positionSub?.cancel();
    _stateSub?.cancel();

    _positionSub = _player.positionStream.listen((Duration pos) {
      _updateHighlight(pos);
      _maybeAutoSave(bookId, chapterId, pos);
    });

    _stateSub = _player.playerStateStream.listen((PlayerState s) {
      if (s.playing) {
        if (_status != TtsStatus.playing) _setStatus(TtsStatus.playing);
      } else if (s.processingState == ProcessingState.completed) {
        _savePositionSync(bookId, chapterId);
        _setStatus(TtsStatus.completed);
      } else if (_status == TtsStatus.playing) {
        _setStatus(TtsStatus.paused);
      }
    });
  }

  void _updateHighlight(Duration pos) {
    final TtsChapterTask? t = _task;
    if (t == null) return;
    if (!_settings.highlightFollow) {
      if (_highlightChar != -1) {
        _highlightChar = -1;
        notifyListeners();
      }
      return;
    }

    final int ms = pos.inMilliseconds;
    int acc = 0;
    int found = -1;
    for (final TtsChunk c in t.chunks) {
      final int dur = c.estimatedDuration.inMilliseconds;
      if (ms < acc + dur || c == t.chunks.last) {
        final int local = ms - acc;
        for (final TtsWord w in c.words) {
          if (w.offsetMs <= local) {
            found = w.charStart;
          } else {
            break;
          }
        }
        break;
      }
      acc += dur;
    }
    if (found != _highlightChar) {
      _highlightChar = found;
      notifyListeners();
    }
  }

  DateTime _lastSave = DateTime.now();

  void _maybeAutoSave(String bookId, String chapterId, Duration pos) {
    final DateTime now = DateTime.now();
    if (now.difference(_lastSave).inSeconds < 5) return;
    _lastSave = now;
    _savePositionSync(bookId, chapterId);
  }

  Future<void> _savePosition() async {
    final TtsChapterTask? t = _task;
    if (t == null) return;
    await _savePositionSync(t.bookId, t.chapterId);
  }

  Future<void> _savePositionSync(String bookId, String chapterId) async {
    try {
      final SharedPreferences prefs = await _prefs;
      await prefs.setInt(
        _posKey(bookId, chapterId),
        _player.position.inMilliseconds,
      );
    } catch (_) {
      // 位置保存失败不影响播放
    }
  }

  static String _posKey(String bookId, String chapterId) =>
      'tts_pos_${bookId}_$chapterId';

  // =========================================================================
  // 缓存 / 工具
  // =========================================================================

  static String _signature(TtsSettings s) =>
      '${s.voice}|${s.ratePercent}|${s.pitchHz}';

  Map<String, dynamic>? _readMeta(File f) {
    try {
      final dynamic decoded = jsonDecode(f.readAsStringSync());
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  void _restoreChunks(List<TtsChunk> chunks, Map<String, dynamic> meta, String dir) {
    final List<dynamic> list = meta['chunks'] as List<dynamic>? ?? <dynamic>[];
    for (int i = 0; i < chunks.length && i < list.length; i++) {
      final TtsChunk parsed = TtsChunk.fromJson(list[i] as Map<String, dynamic>);
      if (parsed.filePath != null && File(parsed.filePath!).existsSync()) {
        chunks[i]
          ..filePath = parsed.filePath
          ..bytes = parsed.bytes
          ..words.addAll(parsed.words);
      } else {
        final File guess = File(p.join(dir, '${chunks[i].index}.mp3'));
        if (guess.existsSync()) {
          chunks[i]
            ..filePath = guess.path
            ..bytes = guess.lengthSync()
            ..words.addAll(parsed.words);
        }
      }
    }
  }

  /// 清理某本书的朗读缓存
  Future<int> clearCache({String? bookId}) async {
    final Directory base = AppPaths.instance.tts;
    final Directory target = bookId == null ? base : Directory(p.join(base.path, bookId));
    final int size = await AppPaths.instance.dirSize(target);
    if (target.existsSync()) {
      await target.delete(recursive: true);
    }
    return size;
  }

  Future<int> cacheSize({String? bookId}) async {
    final Directory base = AppPaths.instance.tts;
    final Directory target = bookId == null ? base : Directory(p.join(base.path, bookId));
    return AppPaths.instance.dirSize(target);
  }

  void _setStatus(TtsStatus s) {
    _status = s;
    notifyListeners();
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    unawaited(_positionSub?.cancel());
    unawaited(_stateSub?.cancel());
    unawaited(_player.dispose());
    super.dispose();
  }
}
