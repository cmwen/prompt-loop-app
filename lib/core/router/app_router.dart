import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prompt_loop_app/features/settings/providers/settings_provider.dart';
import 'package:prompt_loop_app/features/home/screens/home_screen.dart';
import 'package:prompt_loop_app/features/skills/screens/skills_list_screen.dart';
import 'package:prompt_loop_app/features/skills/screens/skill_detail_screen.dart';
import 'package:prompt_loop_app/features/skills/screens/add_skill_screen.dart';
import 'package:prompt_loop_app/features/tasks/screens/tasks_screen.dart';
import 'package:prompt_loop_app/features/practice/screens/practice_session_screen.dart';
import 'package:prompt_loop_app/features/progress/screens/progress_screen.dart';
import 'package:prompt_loop_app/features/settings/screens/settings_screen.dart';
import 'package:prompt_loop_app/features/onboarding/screens/onboarding_screen.dart';
import 'package:prompt_loop_app/features/onboarding/screens/purpose_setup_screen.dart';
import 'package:prompt_loop_app/features/llm_workflow/screens/copy_paste_workflow_screen.dart';
import 'package:prompt_loop_app/shared/widgets/shell_scaffold.dart';

/// Route names for navigation.
class AppRoutes {
  static const String onboarding = 'onboarding';
  static const String purposeSetup = 'purpose-setup';
  static const String home = 'home';
  static const String skills = 'skills';
  static const String skillDetail = 'skill-detail';
  static const String addSkill = 'add-skill';
  static const String tasks = 'tasks';
  static const String practiceSession = 'practice-session';
  static const String progress = 'progress';
  static const String settings = 'settings';
  static const String copyPasteWorkflow = 'copy-paste-workflow';
}

/// Route paths.
class AppPaths {
  static const String onboarding = '/onboarding';
  static const String purposeSetup = '/purpose-setup';
  static const String home = '/';
  static const String skills = '/skills';
  static const String skillDetail = '/skills/:id';
  static const String addSkill = '/skills/add';
  static const String tasks = '/tasks';
  static const String practiceSession = '/practice/:skillId';
  static const String progress = '/progress';
  static const String settings = '/settings';
  static const String copyPasteWorkflow = '/llm/copy-paste';
}

/// The main router provider.
final routerProvider = Provider<GoRouter>((ref) {
  final onboardingCompleted = ref.watch(onboardingCompletedProvider);
  
  return GoRouter(
    initialLocation: AppPaths.home,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Check if onboarding is completed
      final isOnboardingRoute = state.matchedLocation == AppPaths.onboarding ||
          state.matchedLocation == AppPaths.purposeSetup;
      
      return onboardingCompleted.when(
        data: (completed) {
          if (!completed && !isOnboardingRoute) {
            return AppPaths.onboarding;
          }
          if (completed && isOnboardingRoute) {
            return AppPaths.home;
          }
          return null;
        },
        loading: () => null,
        error: (_, __) => null,
      );
    },
    routes: [
      // Onboarding routes
      GoRoute(
        name: AppRoutes.onboarding,
        path: AppPaths.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        name: AppRoutes.purposeSetup,
        path: AppPaths.purposeSetup,
        builder: (context, state) {
          final skillId = state.extra as int?;
          return PurposeSetupScreen(skillId: skillId);
        },
      ),
      
      // Main app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return ShellScaffold(child: child);
        },
        routes: [
          GoRoute(
            name: AppRoutes.home,
            path: AppPaths.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            name: AppRoutes.skills,
            path: AppPaths.skills,
            builder: (context, state) => const SkillsListScreen(),
            routes: [
              GoRoute(
                name: AppRoutes.addSkill,
                path: 'add',
                builder: (context, state) => const AddSkillScreen(),
              ),
              GoRoute(
                name: AppRoutes.skillDetail,
                path: ':id',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return SkillDetailScreen(skillId: id);
                },
              ),
            ],
          ),
          GoRoute(
            name: AppRoutes.tasks,
            path: AppPaths.tasks,
            builder: (context, state) => const TasksScreen(),
          ),
          GoRoute(
            name: AppRoutes.progress,
            path: AppPaths.progress,
            builder: (context, state) => const ProgressScreen(),
          ),
          GoRoute(
            name: AppRoutes.settings,
            path: AppPaths.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      
      // Practice session (full screen, outside shell)
      GoRoute(
        name: AppRoutes.practiceSession,
        path: AppPaths.practiceSession,
        builder: (context, state) {
          final skillId = int.parse(state.pathParameters['skillId']!);
          final taskId = state.extra as int?;
          return PracticeSessionScreen(
            skillId: skillId,
            taskId: taskId,
          );
        },
      ),
      
      // LLM workflow screens (full screen, outside shell)
      GoRoute(
        name: AppRoutes.copyPasteWorkflow,
        path: AppPaths.copyPasteWorkflow,
        builder: (context, state) {
          final workflowType = state.extra as CopyPasteWorkflowType?;
          return CopyPasteWorkflowScreen(
            workflowType: workflowType ?? CopyPasteWorkflowType.skillAnalysis,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.matchedLocation),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go(AppPaths.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Workflow types for copy-paste LLM.
enum CopyPasteWorkflowType {
  skillAnalysis,
  taskGeneration,
  struggleAnalysis,
}
