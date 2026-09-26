import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:moread/services/tts/edge_tts_protocol.dart';

void main() {
  group('EdgeTtsProtocol.secMsGec', () {
    test('5 分钟窗口内 token 稳定', () {
      final DateTime base = DateTime.utc(2026, 9, 24, 10, 0, 0);
      final String a = EdgeTtsProtocol.secMsGec(base);
      final String b = EdgeTtsProtocol.secMsGec(base.add(const Duration(minutes: 4)));
      expect(a, b);
    });

    test('跨过 5 分钟边界后 token 变化', () {
      final DateTime base = DateTime.utc(2026, 9, 24, 10, 0, 0);
      final String a = EdgeTtsProtocol.secMsGec(base);
      final String b = EdgeTtsProtocol.secMsGec(base.add(const Duration(minutes: 6)));
      expect(a, isNot(b));
    });

    test('输出为 64 位大写十六进制', () {
      final String token =
          EdgeTtsProtocol.secMsGec(DateTime.utc(2026, 1, 1));
      expect(token.length, 64);
      expect(RegExp(r'^[0-9A-F]{64}$').hasMatch(token), isTrue);
    });
  });

  group('EdgeTtsProtocol.buildSsml', () {
    test('包含音色与 prosody 参数', () {
      final String ssml = EdgeTtsProtocol.buildSsml(
        text: '你好',
        voice: 'zh-CN-XiaoxiaoNeural',
        ratePercent: 10,
        pitchHz: -5,
        volumePercent: 0,
      );
      expect(ssml, contains('zh-CN-XiaoxiaoNeural'));
      expect(ssml, contains('rate="+10%"'));
      expect(ssml, contains('pitch="-5Hz"'));
      expect(ssml, contains('你好'));
    });

    test('转义 XML 特殊字符', () {
      final String ssml = EdgeTtsProtocol.buildSsml(
        text: 'a < b & c',
        voice: 'zh-CN-YunxiNeural',
      );
      expect(ssml, contains('&lt;'));
      expect(ssml, contains('&amp;'));
      expect(ssml, isNot(contains('a < b')));
    });
  });

  group('EdgeTtsProtocol.parseFrame', () {
    test('解析音频帧头与负载', () {
      final List<int> header = 'Path:audio\r\nContent-Type:audio/mpeg\r\n\r\n'.codeUnits;
      final List<int> payload = <int>[1, 2, 3, 4];
      final frame = EdgeTtsProtocol.parseFrame(
        Uint8List.fromList(<int>[...header, ...payload]),
      );
      expect(frame, isNotNull);
      expect(frame!.isAudio, isTrue);
      expect(frame.payload.length, 4);
    });

    test('无分隔符时返回 null', () {
      expect(
        EdgeTtsProtocol.parseFrame(Uint8List.fromList(<int>[1, 2, 3])),
        isNull,
      );
    });
  });

  group('EdgeTtsProtocol.word boundaries', () {
    test('解析 Metadata 中的 WordBoundary', () {
      const String json = '{"Metadata":[{"Type":"WordBoundary",'
          '"Data":{"Offset":10000000,"Duration":2000000,'
          '"text":{"Text":"你好","BoundaryType":"WORD"}}}]}';
      // 真实场景：WebSocket 帧负载是 UTF-8 字节，不能用 codeUnits（UTF-16）
      final List<EdgeWordBoundary> list = EdgeTtsProtocol.parseWordBoundaries(
        Uint8List.fromList(utf8.encode(json)),
      );
      expect(list.length, 1);
      expect(list.first.text, '你好');
      // 100ns tick -> ms
      expect(EdgeTtsProtocol.ticksToMs(list.first.offsetTicks), 1000);
    });
  });
}
