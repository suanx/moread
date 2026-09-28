import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/error/error_screen.dart';
import 'core/logging/app_logger.dart';
import 'core/storage/app_paths.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 让 release 包中的渲染异常可见（否则只有一块灰色空屏，无法定位）
  AppDiagnostics.install();

  // 捕获 Flutter 框架之外的异常，避免白屏。
  // 必须在任何可能抛错的 await 之前注册，否则异常无法被呈现。
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    AppLogger.e('Flutter', details.exceptionAsString(), details.exception,
        details.stack);
  };

  unawaited(runZonedGuarded(
    () async {
      // 后台播放初始化（just_audio_background / audio_service）。
      // 该 init 依赖 AndroidManifest 中声明的 AudioService 服务组件：
      // 声明缺失或绑定失败时会抛 PlatformException（"Unable to bind to
      // AudioService"），若不捕获则 runApp 永远不会执行 → 永久白屏。
      // 因此：失败只降级（朗读通知栏控制不可用），绝不允许阻断启动。
      try {
        await AppBootstrap.init().timeout(const Duration(seconds: 8));
      } catch (e, st) {
        AppLogger.e('Bootstrap', '后台播放初始化失败，已降级启动', e, st);
      }

      try {
        await AppPaths.init();
      } catch (e, st) {
        // 目录初始化失败不应导致白屏，后续页面会给出可读的错误提示
        AppLogger.e('Bootstrap', '目录初始化失败', e, st);
      }

      runApp(const ProviderScope(child: MoreadApp()));
    },
    (Object error, StackTrace stack) {
      AppLogger.e('Zone', '未捕获异常', error, stack);
    },
  ));
}
