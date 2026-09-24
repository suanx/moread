import 'dart:async';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../../core/error/failure.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/entities/tts_settings.dart';
import 'core/tts_socket.dart';
import 'edge_tts_protocol.dart';
import 'models/tts_models.dart';

/// Edge-TTS 合成引擎。
///
/// 职责：把一段文本 + 朗读参数 → MP3 字节流 + 词边界列表。
/// 不负责播放（播放由 `TtsPlaybackController` 管理）。
class EdgeTtsEngine {
  EdgeTtsEngine({
    this.maxRetry = 2,
    this.connectTimeout = const Duration(seconds: 15),
    this.idleTimeout = const Duration(seconds: 20),
  });

  static const String _tag = 'EdgeTtsEngine';

  final int maxRetry;
  final Duration connectTimeout;
  final Duration idleTimeout;

  final Uuid _uuid = const Uuid();

  /// 合成一段文本。
  ///
  /// - [text] 原始文本（不做空白折叠，保证偏移可映射）
  /// - [baseChar] 该段在章节纯文本中的起始偏移，用于把词边界换算成全局偏移
  /// - 返回的 [TtsSynthesisResult.words] 偏移均为「全局」偏移
  Future<TtsSynthesisResult> synthesize({
    required String text,
    required TtsSettings settings,
    int baseChar = 0,
  }) async {
    if (text.trim().isEmpty) {
      return TtsSynthesisResult(audio: Uint8List(0), words: const <TtsWord>[]);
    }

    Failure? lastError;
    for (int attempt = 0; attempt <= maxRetry; attempt++) {
      try {
        return await _once(
          text: text,
          settings: settings,
          baseChar: baseChar,
        );
      } on Failure catch (e) {
        lastError = e;
        AppLogger.w(_tag, '第 ${attempt + 1} 次合成失败：${e.message}');
        // 鉴权在 5 分钟边界上偶发失败，退避后重试
        await Future<void>.delayed(Duration(milliseconds: 400 * (attempt + 1)));
      }
    }
    throw lastError ??
        const Failure(code: Failure.ttsError, message: '朗读合成失败，请检查网络');
  }

  Future<TtsSynthesisResult> _once({
    required String text,
    required TtsSettings settings,
    required int baseChar,
  }) async {
    final String connectionId = _uuid.v4().replaceAll('-', '');
    final Uri uri = EdgeTtsProtocol.buildUri(connectionId);
    final TtsSocket socket = await connectTtsSocket(
      uri,
      headers: EdgeTtsProtocol.buildHeaders(),
    ).timeout(connectTimeout, onTimeout: () {
      throw const Failure(
        code: Failure.networkError,
        message: '连接朗读服务超时，请检查网络',
      );
    });

    final BytesBuilder audio = BytesBuilder(copy: false);
    final List<TtsWord> words = <TtsWord>[];
    int cursor = 0; // 已匹配到的原文位置
    bool done = false;

    final Completer<void> finished = Completer<void>();

    final StreamSubscription<Object> sub = socket.messages.listen(
      (Object msg) {
        if (msg is! Uint8List) return;
        final TtsFrame? frame = EdgeTtsProtocol.parseFrame(msg);
        if (frame == null) return;

        if (frame.isAudio) {
          audio.add(frame.payload);
        } else if (frame.isMetadata) {
          for (final EdgeWordBoundary b
              in EdgeTtsProtocol.parseWordBoundaries(frame.payload)) {
            final int start = _locate(text, b.text, cursor);
            cursor = start + b.text.length;
            words.add(
              TtsWord(
                charStart: baseChar + start,
                charEnd: baseChar + cursor,
                offsetMs: EdgeTtsProtocol.ticksToMs(b.offsetTicks),
                text: b.text,
              ),
            );
          }
        } else if (frame.isTurnEnd) {
          done = true;
          if (!finished.isCompleted) finished.complete();
        }
      },
      onError: (Object e, StackTrace st) {
        if (!finished.isCompleted) {
          finished.completeError(
            Failure(code: Failure.ttsError, message: '朗读连接异常：${e.toString()}'),
          );
        }
      },
      onDone: () {
        if (!finished.isCompleted) finished.complete();
      },
      cancelOnError: false,
    );

    // 发送 speech.config + ssml
    socket.sendText(EdgeTtsProtocol.speechConfigMessage());
    socket.sendText(
      EdgeTtsProtocol.ssmlMessage(
        EdgeTtsProtocol.buildSsml(
          text: text,
          voice: settings.voice,
          ratePercent: settings.ratePercent,
          pitchHz: settings.pitchHz,
          volumePercent: settings.volumePercent,
        ),
      ),
    );

    try {
      await finished.future.timeout(idleTimeout, onTimeout: () {
        throw const Failure(
          code: Failure.ttsError,
          message: '朗读服务响应超时，请稍后重试',
        );
      });
    } finally {
      await sub.cancel();
      await socket.close();
    }

    final Uint8List bytes = audio.takeBytes();
    if (!done && bytes.isEmpty) {
      throw const Failure(
        code: Failure.ttsError,
        message: '朗读服务未返回音频，可能是音色不受支持',
      );
    }
    if (bytes.isEmpty) {
      throw const Failure(
        code: Failure.ttsError,
        message: '合成结果为空，请更换音色后重试',
      );
    }

    return TtsSynthesisResult(audio: bytes, words: words);
  }

  /// 在 [source] 中从 [from] 开始定位 [needle]，用于把词边界映射回原文偏移。
  ///
  /// Edge 返回的词可能与原文存在空白差异，因此先顺序匹配、失败再全局兜底。
  static int _locate(String source, String needle, int from) {
    final int f = from < 0
        ? 0
        : (from > source.length ? source.length : from);
    if (needle.isEmpty) return f;
    final int idx = source.indexOf(needle, f);
    if (idx >= 0) return idx;
    final int global = source.indexOf(needle);
    return global >= 0 ? global : f;
  }
}

/// 单次合成结果。
class TtsSynthesisResult {
  const TtsSynthesisResult({required this.audio, required this.words});

  final Uint8List audio;
  final List<TtsWord> words;

  int get bytes => audio.lengthInBytes;

  /// 估算时长（48kbps CBR）
  Duration get duration =>
      Duration(milliseconds: (bytes * 8 / 48000 * 1000).round());
}
