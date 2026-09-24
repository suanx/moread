import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../../core/utils/text_utils.dart';

/// Edge-TTS 私有协议实现（逆向自 Microsoft Edge 的「大声朗读」功能）。
///
/// 协议要点：
/// 1. WebSocket 端点带 `TrustedClientToken` 与 `Sec-MS-GEC` 两个参数；
/// 2. `Sec-MS-GEC = upper(sha256("<WindowsFileTime(向下取整到5分钟)><Token>"))`；
/// 3. 连接后先发 `speech.config`（开启词边界），再发 `ssml`；
/// 4. 服务端以二进制帧回传 MP3，头部分行以 `\r\n\r\n` 结束；
/// 5. `Path: audio.metadata` 帧携带 WordBoundary 事件（单位：100ns tick），
///    这正是「文字高亮跟随」的数据来源。
///
/// ⚠️ 该接口为微软内部接口，仅限学习/自用；商用请改用 Azure Cognitive Services。
abstract final class EdgeTtsProtocol {
  /// 固定的客户端令牌（Edge 扩展公开常量）
  static const String trustedClientToken = '6A5AA1D4EAFF4E9FB37E23D68491D6F4';

  static const String endpoint =
      'wss://speech.platform.bing.com/consumer/speech/synthesize/readaloud/edge/v1';

  static const String origin =
      'chrome-extension://jdiccldimpdaibmpdkjnbmckianbfoldm';

  static const String userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.2210.91';

  /// 默认音频格式：24kHz / 48kbps / 单声道 MP3（CBR，便于按字节数估算时长）
  static const String outputFormat = 'audio-24khz-48kbitrate-mono-mp3';

  // =========================================================================
  // 鉴权
  // =========================================================================

  /// 生成 Sec-MS-GEC（有效期 5 分钟）
  static String secMsGec([DateTime? now]) {
    final int unixSeconds =
        (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch ~/ 1000;
    // 1601-01-01 到 1970-01-01 的秒数
    const int winEpoch = 11644473600;
    const int fiveMinutes = 300;
    final int rounded =
        ((unixSeconds + winEpoch) ~/ fiveMinutes) * fiveMinutes;
    final int ticks = rounded * 10000000; // 100ns 单位
    final String input = '$ticks$trustedClientToken';
    return sha256.convert(utf8.encode(input)).toString().toUpperCase();
  }

  /// 构造带鉴权参数的 WebSocket 地址
  static Uri buildUri(String connectionId, [DateTime? now]) => Uri.parse(
        '$endpoint'
        '?TrustedClientToken=$trustedClientToken'
        '&Sec-MS-GEC=${secMsGec(now)}'
        '&ConnectionId=$connectionId',
      );

  static Map<String, String> buildHeaders() => <String, String>{
        'Pragma': 'no-cache',
        'Cache-Control': 'no-cache',
        'Origin': origin,
        'User-Agent': userAgent,
        'Accept-Encoding': 'gzip, deflate, br',
      };

  // =========================================================================
  // 请求报文
  // =========================================================================

  /// speech.config：开启词边界（WordBoundary）与句边界
  static String speechConfigMessage([
    String format = outputFormat,
  ]) =>
      'Content-Type:application/json; charset=utf-8\r\n'
      'Path:speech.config\r\n\r\n'
      '{"context":{"synthesis":{"audio":{"metadataoptions":'
      '{"sentenceBoundaryEnabled":"false","wordBoundaryEnabled":"true"},'
      '"outputFormat":"$format"}}}}';

  /// ssml 报文：头部 + SSML 正文
  static String ssmlMessage(String ssml, [DateTime? now]) {
    final String ts = _xTimestamp(now ?? DateTime.now());
    return 'Path:ssml\r\n'
        'X-RequestId:${_uuid()}\r\n'
        'X-Timestamp:$ts\r\n'
        'Content-Type:application/ssml+xml\r\n\r\n'
        '$ssml';
  }

  /// 构造 SSML：支持音色 / 语速 / 音调 / 音量
  static String buildSsml({
    required String text,
    required String voice,
    int ratePercent = 0,
    int pitchHz = 0,
    int volumePercent = 0,
    String? lang,
  }) {
    final String locale = lang ?? _localeOfVoice(voice);
    final String rate = _signed(ratePercent, '%');
    final String pitch = _signed(pitchHz, 'Hz');
    final String volume = _signed(volumePercent, '%');
    return '<speak version="1.0" xmlns="http://www.w3.org/2001/10/Synthesis" '
        'xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="$locale">'
        '<voice name="$voice">'
        '<prosody pitch="$pitch" rate="$rate" volume="$volume">'
        '${TextUtils.escapeXml(_sanitize(text))}'
        '</prosody></voice></speak>';
  }

  /// 仅移除 TTS 无法处理的控制字符。
  ///
  /// ⚠️ 不可做空白折叠或 trim：合成文本必须与原文逐字符对应，
  /// 否则 WordBoundary 计算出的字符偏移将无法用于高亮定位。
  static String _sanitize(String text) =>
      text.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');

  static String _signed(int v, String unit) =>
      '${v >= 0 ? '+' : ''}$v$unit';

  static String _localeOfVoice(String voice) {
    final List<String> parts = voice.split('-');
    if (parts.length >= 2) return '${parts[0]}-${parts[1]}';
    return 'zh-CN';
  }

  static String _xTimestamp(DateTime now) {
    final DateTime utc = now.toUtc();
    String two(int v) => v.toString().padLeft(2, '0');
    String three(int v) => v.toString().padLeft(3, '0');
    return '${utc.year}-${two(utc.month)}-${two(utc.day)}'
        'T${two(utc.hour)}:${two(utc.minute)}:${two(utc.second)}'
        '.${three(utc.millisecond)}Z';
  }

  static String _uuid() {
    final DateTime n = DateTime.now();
    final int r = n.microsecondsSinceEpoch;
    return '${r.toRadixString(16)}${n.microsecond.toRadixString(16)}'
        .padRight(32, '0')
        .substring(0, 32);
  }

  // =========================================================================
  // 响应解析
  // =========================================================================

  /// 解析服务端帧：header 与 payload 以 `\r\n\r\n` 分隔
  static TtsFrame? parseFrame(Uint8List data) {
    const List<int> sep = <int>[13, 10, 13, 10];
    int idx = -1;
    for (int i = 0; i + 3 < data.length; i++) {
      if (data[i] == sep[0] &&
          data[i + 1] == sep[1] &&
          data[i + 2] == sep[2] &&
          data[i + 3] == sep[3]) {
        idx = i;
        break;
      }
    }
    if (idx < 0) return null;

    final String headerBlock =
        utf8.decode(data.sublist(0, idx), allowMalformed: true);
    final Map<String, String> headers = <String, String>{};
    for (final String line in headerBlock.split('\r\n')) {
      final int c = line.indexOf(':');
      if (c <= 0) continue;
      headers[line.substring(0, c).trim().toLowerCase()] =
          line.substring(c + 1).trim();
    }
    final Uint8List payload =
        idx + 4 <= data.length ? data.sublist(idx + 4) : Uint8List(0);
    return TtsFrame(headers: headers, payload: payload);
  }

  /// 解析 `audio.metadata` 里的 WordBoundary 列表
  static List<EdgeWordBoundary> parseWordBoundaries(Uint8List payload) {
    final List<EdgeWordBoundary> out = <EdgeWordBoundary>[];
    try {
      final String json = utf8.decode(payload, allowMalformed: true);
      final dynamic decoded = jsonDecode(json);
      if (decoded is! Map<String, dynamic>) return out;
      final dynamic metadata = decoded['Metadata'];
      if (metadata is! List<dynamic>) return out;
      for (final dynamic item in metadata) {
        if (item is! Map<String, dynamic>) continue;
        if (item['Type'] != 'WordBoundary') continue;
        final dynamic d = item['Data'];
        if (d is! Map<String, dynamic>) continue;
        final int offset = (d['Offset'] as num?)?.toInt() ?? 0;
        final int duration = (d['Duration'] as num?)?.toInt() ?? 0;
        final dynamic t = d['text'];
        final String text = t is Map<String, dynamic>
            ? (t['Text'] as String? ?? '')
            : (t?.toString() ?? '');
        out.add(
          EdgeWordBoundary(
            offsetTicks: offset,
            durationTicks: duration,
            text: text,
          ),
        );
      }
    } catch (_) {
      // 元数据解析失败不影响音频播放，仅降级为「无高亮」
    }
    return out;
  }

  /// 100ns tick → 毫秒
  static int ticksToMs(int ticks) => ticks ~/ 10000;
}

/// 服务端帧
class TtsFrame {
  const TtsFrame({required this.headers, required this.payload});

  final Map<String, String> headers;
  final Uint8List payload;

  String? operator [](String key) => headers[key.toLowerCase()];

  String get path => headers['path'] ?? '';

  String get contentType => headers['content-type'] ?? '';

  bool get isAudio => path == 'audio';

  bool get isMetadata => path == 'audio.metadata';

  bool get isTurnEnd => path == 'turn.end';

  bool get isResponse => path == 'response';
}

/// 词边界（Edge 原始单位：100ns tick）
class EdgeWordBoundary {
  const EdgeWordBoundary({
    required this.offsetTicks,
    required this.durationTicks,
    required this.text,
  });

  final int offsetTicks;
  final int durationTicks;
  final String text;
}
