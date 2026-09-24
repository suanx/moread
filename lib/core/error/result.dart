import 'failure.dart';

/// 轻量 Result 类型，避免到处 try/catch。
///
/// ```dart
/// final res = await repo.load();
/// return res.fold(
///   onOk: (v) => ...,
///   onErr: (f) => ...,
/// );
/// ```
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;

  const factory Result.err(Failure failure) = Err<T>;

  bool get isOk => this is Ok<T>;

  bool get isErr => this is Err<T>;

  T? get valueOrNull => this is Ok<T> ? (this as Ok<T>).value : null;

  Failure? get failureOrNull => this is Err<T> ? (this as Err<T>).failure : null;

  R fold<R>({
    required R Function(T value) onOk,
    required R Function(Failure failure) onErr,
  }) =>
      switch (this) {
        Ok<T>(:final T value) => onOk(value),
        Err<T>(:final Failure failure) => onErr(failure),
      };

  /// 把可能抛异常的操作包成 Result
  static Future<Result<T>> guard<T>(
    Future<T> Function() run, {
    String code = Failure.unknown,
    String? message,
  }) async {
    try {
      return Result<T>.ok(await run());
    } on Failure catch (e) {
      return Result<T>.err(e);
    } catch (e, st) {
      return Result<T>.err(
        Failure(code: code, message: message ?? '操作失败：${e.toString()}', cause: e, stackTrace: st),
      );
    }
  }
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
