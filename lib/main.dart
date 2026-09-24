import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/logging/app_logger.dart';
import 'core/storage/app_paths.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrap.init();

  // 捕获 Flutter 框架之外的异常，避免白屏
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    AppLogger.e('Flutter', details.exceptionAsString(), details.exception,
        details.stack);
  };

  runZonedGuarded(
    () async {
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
  );
}
