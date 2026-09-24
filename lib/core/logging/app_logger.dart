import 'dart:developer' as dev;

/// 极简日志门面。
///
/// 统一入口便于后续替换为 Sentry / 自研埋点，
/// 同时保证 release 包中不会通过 print 泄漏内容（linter 已禁用 print）。
class AppLogger {
  const AppLogger._();

  static bool enabled = true;

  static void d(String tag, String message) => _log('D', tag, message);

  static void i(String tag, String message) => _log('I', tag, message);

  static void w(String tag, String message) => _log('W', tag, message);

  static void e(String tag, String message, [Object? error, StackTrace? st]) {
    _log('E', tag, message);
    if (error != null) {
      dev.log(
        '[$tag] $message',
        name: 'moread',
        level: 1000,
        error: error,
        stackTrace: st,
      );
    }
  }

  static void _log(String level, String tag, String message) {
    if (!enabled) return;
    dev.log('$level/$tag: $message', name: 'moread', level: _levelOf(level));
  }

  static int _levelOf(String level) => switch (level) {
        'D' => 500,
        'I' => 800,
        'W' => 900,
        _ => 1000,
      };
}
