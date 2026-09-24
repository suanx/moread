import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// 应用根组件。
class MoreadApp extends ConsumerWidget {
  const MoreadApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: '墨读',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      supportedLocales: const <Locale>[
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      locale: const Locale('zh', 'CN'),
      builder: (BuildContext context, Widget? child) {
        // 全局字号不随系统缩放，保证阅读排版稳定
        final MediaQueryData mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.noScaling),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

/// 应用启动引导：所有「必须在 runApp 之前完成」的初始化集中在此。
abstract final class AppBootstrap {
  static Future<void> init() async {
    // 后台播放：注册通知栏 / 锁屏控制
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.moread.tts.channel',
      androidNotificationChannelName: '墨读朗读',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    );
  }
}
