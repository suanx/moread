import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai/ai_cards_page.dart';
import '../../features/ai/ai_center_page.dart';
import '../../features/ai/ai_chat_page.dart';
import '../../features/ai/ai_mindmap_page.dart';
import '../../features/ai/ai_summary_page.dart';
import '../../features/book_detail/book_detail_page.dart';
import '../../features/bookshelf/bookshelf_page.dart';
import '../../features/discover/discover_page.dart';
import '../../features/library/import_page.dart';
import '../../features/reader/reader_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/shell/main_shell.dart';
import '../../features/stats/stats_page.dart';

/// 应用路由。
///
/// 采用 `StatefulShellRoute.indexedStack` 承载底部三 Tab，
/// 其余页面为全屏 push 页。
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  return GoRouter(
    initialLocation: '/discover',
    debugLogDiagnostics: false,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (BuildContext context, GoRouterState state,
                StatefulNavigationShell shell) =>
            MainShell(navigationShell: shell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/discover',
                builder: (_, __) => const DiscoverPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/shelf',
                builder: (_, __) => const BookshelfPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/me',
                builder: (_, __) => const StatsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/book/:bookId',
        builder: (BuildContext context, GoRouterState state) =>
            BookDetailPage(bookId: state.pathParameters['bookId']!),
      ),
      GoRoute(
        path: '/reader/:bookId',
        builder: (BuildContext context, GoRouterState state) =>
            ReaderPage(bookId: state.pathParameters['bookId']!),
      ),
      GoRoute(
        path: '/import',
        builder: (_, __) => const ImportPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsPage(),
      ),
      // ---------------- AI 中心及其四类能力 ----------------
      GoRoute(
        path: '/ai/:bookId',
        builder: (BuildContext context, GoRouterState state) =>
            AiCenterPage(bookId: state.pathParameters['bookId']!),
        routes: <RouteBase>[
          GoRoute(
            path: 'chat',
            builder: (BuildContext context, GoRouterState state) => AiChatPage(
              bookId: state.pathParameters['bookId']!,
              initialQuestion: state.extra is String ? state.extra! as String : null,
            ),
          ),
          GoRoute(
            path: 'summary',
            builder: (BuildContext context, GoRouterState state) =>
                AiSummaryPage(bookId: state.pathParameters['bookId']!),
          ),
          GoRoute(
            path: 'cards',
            builder: (BuildContext context, GoRouterState state) =>
                AiCardsPage(bookId: state.pathParameters['bookId']!),
          ),
          GoRoute(
            path: 'mindmap',
            builder: (BuildContext context, GoRouterState state) =>
                AiMindMapPage(bookId: state.pathParameters['bookId']!),
          ),
        ],
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
      appBar: AppBar(title: const Text('页面不存在')),
      body: Center(child: Text('无法打开 ${state.uri}')),
    ),
  );
});
