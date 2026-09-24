/// 统一错误模型。
///
/// 所有 Service / Repository 只允许抛出或返回 [Failure]，
/// UI 层通过 [Failure.message] 给用户可读提示，通过 [Failure.code] 做程序分支。
class Failure implements Exception {
  const Failure({
    required this.code,
    required this.message,
    this.cause,
    this.stackTrace,
  });

  /// 稳定的错误码，便于埋点与分支判断
  final String code;

  /// 面向用户的中文提示
  final String message;

  final Object? cause;
  final StackTrace? stackTrace;

  // ---- 常用错误码 ----
  static const String unknown = 'unknown';
  static const String fileNotFound = 'file_not_found';
  static const String parseFailed = 'parse_failed';
  static const String permissionDenied = 'permission_denied';
  static const String networkError = 'network_error';
  static const String ttsError = 'tts_error';
  static const String dbError = 'db_error';
  static const String unsupportedFormat = 'unsupported_format';

  factory Failure.from(Object error, StackTrace? st, {String? fallback}) =>
      error is Failure
          ? error
          : Failure(
              code: Failure.unknown,
              message: fallback ?? '操作失败：${error.toString()}',
              cause: error,
              stackTrace: st,
            );

  @override
  String toString() => 'Failure($code): $message';
}
