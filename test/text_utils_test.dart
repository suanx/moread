import 'package:flutter_test/flutter_test.dart';

import 'package:moread/core/utils/text_utils.dart';

void main() {
  group('TextUtils.stripHtml', () {
    test('移除标签并保留段落换行', () {
      const String html = '<p>第一段</p><p>第二段<br/>继续</p>';
      final String plain = TextUtils.stripHtml(html);
      expect(plain, contains('第一段'));
      expect(plain, contains('第二段'));
      expect(plain, isNot(contains('<p>')));
    });

    test('丢弃 script / style', () {
      const String html = '<style>a{}</style><script>x</script><p>正文</p>';
      final String plain = TextUtils.stripHtml(html);
      expect(plain, isNot(contains('a{')));
      expect(plain, isNot(contains('x')));
      expect(plain, contains('正文'));
    });
  });

  group('TextUtils.countWords', () {
    test('中文按字、英文按词', () {
      // 4 个汉字 + 2 个英文单词
      expect(TextUtils.countWords('你好世界 hello world'), 6);
      expect(TextUtils.countWords(''), 0);
    });
  });

  group('TextUtils.splitForSpeech', () {
    test('长文本被切成多片且不丢字符', () {
      final String text = List<String>.filled(2000, '句子一。').join();
      final List<TextRange> ranges = TextUtils.splitForSpeech(text, maxChars: 500);
      expect(ranges.length, greaterThan(1));
      expect(ranges.first.start, 0);
      expect(ranges.last.end, text.length);
      for (int i = 1; i < ranges.length; i++) {
        expect(ranges[i].start, ranges[i - 1].end);
      }
    });

    test('空文本返回空列表', () {
      expect(TextUtils.splitForSpeech('   '), isEmpty);
    });
  });

  group('TextUtils.splitSentences', () {
    test('按句末标点切分', () {
      final List<TextRange> s = TextUtils.splitSentences('你好。世界！');
      expect(s.length, 2);
      expect(s.first.end, 3);
    });
  });

  group('TextUtils.decodeBytes', () {
    test('正确处理 UTF-8 BOM', () {
      final List<int> bytes = <int>[0xEF, 0xBB, 0xBF] +
          <int>[0xE4, 0xBD, 0xA0, 0xE5, 0xA5, 0xBD];
      expect(TextUtils.decodeBytes(bytes), '你好');
    });

    test('非法 UTF-8 不抛异常', () {
      expect(TextUtils.decodeBytes(<int>[0xC3, 0x28, 0x41]), isNotEmpty);
    });
  });
}
