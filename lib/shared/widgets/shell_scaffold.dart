import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prompt_loop_app/core/router/app_router.dart';
import 'package:prompt_loop_app/core/theme/app_colors.dart';

/// Shell scaffold with bottom navigation for main app screens.
class ShellScaffold extends StatelessWidget {
  final Widget child;
  
  const ShellScaffold({
    super.key,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology),
            label: 'Skills',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            selectedIcon: Icon(Icons.task_alt),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
  
  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppPaths.skills)) return 1;
    if (location.startsWith(AppPaths.tasks)) return 2;
    if (location.startsWith(AppPaths.progress)) return 3;
    if (location.startsWith(AppPaths.settings)) return 4;
    return 0; // Home
  }
  
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.goNamed(AppRoutes.home);
        break;
      case 1:
        context.goNamed(AppRoutes.skills);
        break;
      case 2:
        context.goNamed(AppRoutes.tasks);
        break;
      case 3:
        context.goNamed(AppRoutes.progress);
        break;
      case 4:
        context.goNamed(AppRoutes.settings);
        break;
    }
  }
}
