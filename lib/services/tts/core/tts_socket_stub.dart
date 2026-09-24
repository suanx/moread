import 'dart:async';

import 'tts_socket_base.dart';

/// 未支持平台兜底
Future<TtsSocket> openTtsSocket(Uri uri, Map<String, String> headers) async {
  throw UnsupportedError('当前平台不支持 WebSocket 朗读（tts_socket_stub.dart）');
}
