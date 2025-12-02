import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_loop/core/router/app_router.dart';
import 'package:prompt_loop/core/theme/app_theme.dart';
import 'package:prompt_loop/domain/entities/app_settings.dart';
import 'package:prompt_loop/features/settings/providers/settings_provider.dart';

/// The main application widget.
class PromptLoopApp extends ConsumerWidget {
  const PromptLoopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);

    // Determine theme mode based on settings
    final themeMode = settings.when(
      data: (s) {
        switch (s.themeMode) {
          case AppThemeMode.light:
            return ThemeMode.light;
          case AppThemeMode.dark:
            return ThemeMode.dark;
          case AppThemeMode.system:
            return ThemeMode.system;
        }
      },
      loading: () => ThemeMode.system,
      error: (_, __) => ThemeMode.system,
    );

    return MaterialApp.router(
      title: 'Prompt Loop',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Router configuration
      routerConfig: router,
    );
  }
}
