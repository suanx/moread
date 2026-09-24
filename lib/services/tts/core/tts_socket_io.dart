import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'tts_socket_base.dart';

/// native 实现：基于 `dart:io` 的 WebSocket，可携带自定义 Header。
Future<TtsSocket> openTtsSocket(Uri uri, Map<String, String> headers) async {
  final WebSocket ws = await WebSocket.connect(
    uri.toString(),
    headers: headers,
  );
  return _IoTtsSocket(ws);
}

class _IoTtsSocket implements TtsSocket {
  _IoTtsSocket(WebSocket ws) : _ws = ws {
    // 广播流：订阅前到达的数据会被缓冲，不会丢失首帧
    ws.listen(
      (dynamic data) {
        if (data is String) {
          _controller.add(data);
        } else if (data is List<int>) {
          _controller.add(Uint8List.fromList(data));
        }
      },
      onError: _controller.addError,
      onDone: _controller.close,
      cancelOnError: false,
    );
  }

  final WebSocket _ws;
  final StreamController<Object> _controller = StreamController<Object>.broadcast();

  @override
  Stream<Object> get messages => _controller.stream;

  @override
  void sendText(String text) => _ws.add(text);

  @override
  void sendBytes(Uint8List data) => _ws.add(data);

  @override
  Future<void> close() => _ws.close();
}
