import 'dart:typed_data';

/// 一个「朗读分片」：受 Edge-TTS 单次请求长度限制，长章节需切成多片。
///
/// [startChar]/[endChar] 是分片在章节纯文本中的字符区间（左闭右开）。
class TtsChunk {
  TtsChunk({
    required this.index,
    required this.startChar,
    required this.endChar,
    required this.text,
  });

  final int index;
  final int startChar;
  final int endChar;
  final String text;

  /// 合成产物路径（tts/<bookId>/<chapterId>/<index>.mp3）
  String? filePath;

  /// 音频字节数，用于估算时长（48kbps CBR MP3）
  int bytes = 0;

  /// 词边界（含句边界），偏移为「分片内」毫秒
  final List<TtsWord> words = <TtsWord>[];

  /// 估算时长
  Duration get estimatedDuration {
    if (bytes > 0) {
      return Duration(milliseconds: (bytes * 8 / 48000 * 1000).round());
    }
    return Duration.zero;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'index': index,
        'startChar': startChar,
        'endChar': endChar,
        'file': filePath,
        'bytes': bytes,
        'words': words.map((TtsWord w) => w.toJson()).toList(),
      };

  factory TtsChunk.fromJson(Map<String, dynamic> m) {
    final TtsChunk c = TtsChunk(
      index: m['index'] as int? ?? 0,
      startChar: m['startChar'] as int? ?? 0,
      endChar: m['endChar'] as int? ?? 0,
      text: '',
    )
      ..filePath = m['file'] as String?
      ..bytes = m['bytes'] as int? ?? 0;
    final List<dynamic>? ws = m['words'] as List<dynamic>?;
    if (ws != null) {
      c.words.addAll(ws.map((dynamic e) => TtsWord.fromJson(e as Map<String, dynamic>)));
    }
    return c;
  }
}

/// 词边界：用于「文字高亮跟随」。
class TtsWord {
  const TtsWord({
    required this.charStart,
    required this.charEnd,
    required this.offsetMs,
    required this.text,
  });

  /// 在章节纯文本中的起始字符偏移（全局，已加上分片基址）
  final int charStart;
  final int charEnd;

  /// 相对分片起点的毫秒偏移
  final int offsetMs;

  final String text;

  Map<String, dynamic> toJson() => <String, dynamic>{
        's': charStart,
        'e': charEnd,
        'o': offsetMs,
        't': text,
      };

  factory TtsWord.fromJson(Map<String, dynamic> m) => TtsWord(
        charStart: m['s'] as int? ?? 0,
        charEnd: m['e'] as int? ?? 0,
        offsetMs: m['o'] as int? ?? 0,
        text: m['t'] as String? ?? '',
      );
}

/// 一次朗读会话的完整数据（章节 → 分片 → 词边界）。
class TtsChapterTask {
  TtsChapterTask({
    required this.bookId,
    required this.chapterId,
    required this.chapterTitle,
    required this.plainText,
    required this.chunks,
    required this.settingsSignature,
  });

  final String bookId;
  final String chapterId;
  final String chapterTitle;
  final String plainText;
  final List<TtsChunk> chunks;

  /// 影响合成结果的参数签名（音色+语速+音调），变化时需要重新合成
  final String settingsSignature;

  Duration get estimatedDuration => chunks.fold<Duration>(
        Duration.zero,
        (Duration acc, TtsChunk c) => acc + c.estimatedDuration,
      );
}

/// 合成过程中的流式事件。
sealed class TtsEvent {
  const TtsEvent();
}

/// 音频数据块
final class TtsAudioData extends TtsEvent {
  const TtsAudioData(this.bytes);

  final Uint8List bytes;
}

/// 词边界事件
final class TtsBoundary extends TtsEvent {
  const TtsBoundary(this.charStart, this.charEnd, this.offsetMs, this.text);

  final int charStart;
  final int charEnd;
  final int offsetMs;
  final String text;
}

/// 本次请求结束
final class TtsEnd extends TtsEvent {
  const TtsEnd();
}
