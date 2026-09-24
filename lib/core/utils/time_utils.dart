import 'package:intl/intl.dart';

/// 时间 / 时长格式化工具。
abstract final class TimeUtils {
  static final DateFormat _ymd = DateFormat('yyyy-MM-dd');
  static final DateFormat _md = DateFormat('MM-dd');
  static final DateFormat _hm = DateFormat('HH:mm');

  static String date(int millis) => _ymd.format(DateTime.fromMillisecondsSinceEpoch(millis));

  static String monthDay(int millis) => _md.format(DateTime.fromMillisecondsSinceEpoch(millis));

  static String hourMinute(int millis) => _hm.format(DateTime.fromMillisecondsSinceEpoch(millis));

  /// 相对时间：刚刚 / N 分钟前 / N 小时前 / 昨天 / 日期
  static String relative(int millis) {
    final DateTime t = DateTime.fromMillisecondsSinceEpoch(millis);
    final Duration diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes} 分钟前';
    if (diff.inHours < 24) return '${diff.inHours} 小时前';
    if (diff.inDays < 2) return '昨天';
    if (diff.inDays < 30) return '${diff.inDays} 天前';
    return _ymd.format(t);
  }

  /// 秒 -> 1h23m / 45m / 30s
  static String durationShort(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final int m = seconds ~/ 60;
    if (m < 60) return '${m}m';
    final int h = m ~/ 60;
    final int rest = m % 60;
    return rest == 0 ? '${h}h' : '${h}h${rest}m';
  }

  /// 秒 -> 01:23:45 / 23:45
  static String durationClock(int seconds) {
    final int h = seconds ~/ 3600;
    final int m = (seconds % 3600) ~/ 60;
    final int s = seconds % 60;
    final String mm = m.toString().padLeft(2, '0');
    final String ss = s.toString().padLeft(2, '0');
    return h > 0 ? '${h.toString().padLeft(2, '0')}:$mm:$ss' : '$mm:$ss';
  }
}
