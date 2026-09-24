import 'dart:typed_data';

/// WebSocket 抽象：屏蔽 native(dart:io) 与 web(web_socket_channel) 的差异。
///
/// 之所以需要自定义头：Edge-TTS 服务端要求特定 `Origin` 与浏览器 `User-Agent`，
/// `dart:io` 的 `WebSocket.connect` 支持自定义头，而 Web 平台由浏览器接管无法设置，
/// 因此 Web 端朗读为「尽力而为」，失败时上层给出降级提示。
abstract interface class TtsSocket {
  /// 发送文本帧
  void sendText(String text);

  /// 发送二进制帧
  void sendBytes(Uint8List data);

  /// 收到的消息：String（文本帧）或 Uint8List（二进制帧）
  Stream<Object> get messages;

  Future<void> close();
}
