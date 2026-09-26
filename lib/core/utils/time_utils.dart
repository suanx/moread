/// 时间 / 时长格式化工具。
///
/// 刻意不依赖 intl：
/// 1. intl 与 flutter_localizations 的版本约束容易冲突（曾导致 CI 依赖解析失败）；
/// 2. intl 的 DateFormat 需先 `initializeDateFormatting`，否则运行时抛异常；
/// 3. 本项目只需要极少量固定格式，手写更可控。
abstract final class TimeUtils {
  static String _two(int v) => v.toString().padLeft(2, '0');

  /// 2026-09-24
  static String date(int millis) {
    final DateTime t = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${t.year}-${_two(t.month)}-${_two(t.day)}';
  }

  /// 09-24
  static String monthDay(int millis) {
    final DateTime t = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${_two(t.month)}-${_two(t.day)}';
  }

  /// 14:05
  static String hourMinute(int millis) {
    final DateTime t = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${_two(t.hour)}:${_two(t.minute)}';
  }

  /// 相对时间：刚刚 / N 分钟前 / N 小时前 / 昨天 / N 天前 / 日期
  static String relative(int millis) {
    final DateTime t = DateTime.fromMillisecondsSinceEpoch(millis);
    final Duration diff = DateTime.now().difference(t);
    if (diff.isNegative) return date(millis);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes} 分钟前';
    if (diff.inHours < 24) return '${diff.inHours} 小时前';
    if (_isYesterday(t)) return '昨天';
    if (diff.inDays < 30) return '${diff.inDays} 天前';
    return date(millis);
  }

  static bool _isYesterday(DateTime t) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime target = DateTime(t.year, t.month, t.day);
    return today.difference(target).inDays == 1;
  }

  /// 秒 -> 1h23m / 45m / 30s
  static String durationShort(int seconds) {
    final int s = seconds < 0 ? 0 : seconds;
    if (s < 60) return '${s}s';
    final int m = s ~/ 60;
    if (m < 60) return '${m}m';
    final int h = m ~/ 60;
    final int rest = m % 60;
    return rest == 0 ? '${h}h' : '${h}h${rest}m';
  }

  /// 秒 -> 01:23:45 / 23:45
  static String durationClock(int seconds) {
    final int s = seconds < 0 ? 0 : seconds;
    final int h = s ~/ 3600;
    final int m = (s % 3600) ~/ 60;
    final int sec = s % 60;
    return h > 0 ? '${_two(h)}:${_two(m)}:${_two(sec)}' : '${_two(m)}:${_two(sec)}';
  }
}
