import 'dart:async';
import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'tts_socket_base.dart';

/// Web 实现：浏览器不允许自定义 Origin / User-Agent，
/// 因此该通道对 Edge-TTS 属于「尽力而为」。
Future<TtsSocket> openTtsSocket(Uri uri, Map<String, String> headers) async {
  final WebSocketChannel channel = WebSocketChannel.connect(uri);
  return _WebTtsSocket(channel);
}

class _WebTtsSocket implements TtsSocket {
  _WebTtsSocket(this._channel);

  final WebSocketChannel _channel;

  @override
  Stream<Object> get messages => _channel.stream.map<Object>((dynamic data) {
        if (data is String) return data;
        if (data is Uint8List) return data;
        if (data is List<int>) return Uint8List.fromList(data);
        return data.toString();
      });

  @override
  void sendText(String text) => _channel.sink.add(text);

  @override
  void sendBytes(Uint8List data) => _channel.sink.add(data);

  @override
  Future<void> close() => _channel.sink.close();
}
