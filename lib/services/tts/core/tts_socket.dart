import 'tts_socket_base.dart';
import 'tts_socket_stub.dart'
    if (dart.library.io) 'tts_socket_io.dart'
    if (dart.library.html) 'tts_socket_web.dart';

export 'tts_socket_base.dart';

/// 建立 Edge-TTS WebSocket 连接。
///
/// 各平台实现：
/// - native：`tts_socket_io.dart`（dart:io，支持自定义 Header）
/// - web：`tts_socket_web.dart`（web_socket_channel，无法自定义 Header）
/// - 其它：`tts_socket_stub.dart`（明确抛错）
Future<TtsSocket> connectTtsSocket(
  Uri uri, {
  Map<String, String> headers = const <String, String>{},
}) =>
    openTtsSocket(uri, headers);
