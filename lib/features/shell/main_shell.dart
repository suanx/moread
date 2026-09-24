import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// 主容器：底部三 Tab（书架 / 发现 / 我的）。
///
/// 使用 go_router 的 `StatefulShellRoute.indexedStack`，
/// 保证切换 Tab 时各分支的滚动位置与状态不丢失。
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        height: AppSize.bottomBarHeight + 12,
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: AppColors.brandLight,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (int i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: '书架',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: '发现',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
