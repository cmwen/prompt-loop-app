import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prompt_loop_app/core/router/app_router.dart';
import 'package:prompt_loop_app/core/theme/app_colors.dart';
import 'package:prompt_loop_app/features/skills/providers/skills_provider.dart';
import 'package:prompt_loop_app/features/tasks/providers/tasks_provider.dart';
import 'package:prompt_loop_app/features/practice/providers/practice_provider.dart';
import 'package:prompt_loop_app/features/purpose/providers/purpose_provider.dart';
import 'package:prompt_loop_app/shared/widgets/app_card.dart';
import 'package:prompt_loop_app/shared/widgets/progress_indicators.dart';
import 'package:prompt_loop_app/shared/widgets/loading_indicator.dart';
import 'package:prompt_loop_app/shared/widgets/empty_state.dart';

/// Home screen showing today's overview and quick actions.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skills = ref.watch(skillsProvider);
    final todaysTasks = ref.watch(todaysTasksProvider);
    final todaysPracticeTime = ref.watch(todaysPracticeTimeProvider);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Prompt Loop'),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // TODO: Show notifications
                },
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Purpose reminder card
                _PurposeReminderCard(),
                const SizedBox(height: 16),
                
                // Today's stats
                _TodaysStatsCard(
                  practiceTime: todaysPracticeTime,
                  tasksCompleted: todaysTasks,
                ),
                const SizedBox(height: 24),
                
                // Today's tasks section
                _SectionHeader(
                  title: "Today's Tasks",
                  onSeeAll: () => context.goNamed(AppRoutes.tasks),
                ),
                const SizedBox(height: 8),
                todaysTasks.when(
                  data: (tasks) {
                    if (tasks.isEmpty) {
                      return const SizedBox(
                        height: 100,
                        child: Center(
                          child: Text('No tasks for today! 🎉'),
                        ),
                      );
                    }
                    return Column(
                      children: tasks.take(3).map((task) => TaskCard(
                        title: task.title,
                        subtitle: '${task.estimatedMinutes} min',
                        difficulty: task.difficulty,
                        isCompleted: task.isCompleted,
                        onTap: () {
                          context.goNamed(
                            AppRoutes.practiceSession,
                            pathParameters: {'skillId': task.skillId.toString()},
                            extra: task.id,
                          );
                        },
                        onComplete: () {
                          ref.read(tasksProvider.notifier).completeTask(task.id!);
                        },
                      )).toList(),
                    );
                  },
                  loading: () => const LoadingIndicator(),
                  error: (e, _) => Text('Error: $e'),
                ),
                const SizedBox(height: 24),
                
                // Skills section
                _SectionHeader(
                  title: 'Your Skills',
                  onSeeAll: () => context.goNamed(AppRoutes.skills),
                ),
                const SizedBox(height: 8),
                skills.when(
                  data: (skillList) {
                    if (skillList.isEmpty) {
                      return SkillsEmptyState(
                        onAddSkill: () => context.goNamed(AppRoutes.addSkill),
                      );
                    }
                    return Column(
                      children: skillList.take(3).map((skill) => SkillCard(
                        name: skill.name,
                        level: skill.level.displayName,
                        progress: skill.progressPercentage / 100,
                        onTap: () {
                          context.goNamed(
                            AppRoutes.skillDetail,
                            pathParameters: {'id': skill.id.toString()},
                          );
                        },
                      )).toList(),
                    );
                  },
                  loading: () => const LoadingIndicator(),
                  error: (e, _) => Text('Error: $e'),
                ),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Show quick action bottom sheet
          _showQuickActionsSheet(context, ref);
        },
        icon: const Icon(Icons.add),
        label: const Text('Practice'),
      ),
    );
  }
  
  void _showQuickActionsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.psychology),
                title: const Text('Add New Skill'),
                subtitle: const Text('Start learning something new'),
                onTap: () {
                  Navigator.pop(context);
                  context.goNamed(AppRoutes.addSkill);
                },
              ),
              ListTile(
                leading: const Icon(Icons.play_circle),
                title: const Text('Start Practice Session'),
                subtitle: const Text('Practice an existing skill'),
                onTap: () {
                  Navigator.pop(context);
                  context.goNamed(AppRoutes.skills);
                },
              ),
              ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: const Text('Generate Tasks with AI'),
                subtitle: const Text('Get personalized practice tasks'),
                onTap: () {
                  Navigator.pop(context);
                  context.goNamed(
                    AppRoutes.copyPasteWorkflow,
                    extra: CopyPasteWorkflowType.taskGeneration,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Purpose reminder card at the top of home screen.
class _PurposeReminderCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skills = ref.watch(skillsProvider);
    
    return skills.when(
      data: (skillList) {
        if (skillList.isEmpty) return const SizedBox.shrink();
        
        // Get a random purpose from the first skill
        final firstSkill = skillList.first;
        final purposes = ref.watch(purposesBySkillProvider(firstSkill.id!));
        
        return purposes.when(
          data: (purposeList) {
            if (purposeList.isEmpty) return const SizedBox.shrink();
            
            final purpose = purposeList.first;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Remember your why',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"${purpose.description}"',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '— For ${firstSkill.name}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Today's stats card.
class _TodaysStatsCard extends StatelessWidget {
  final AsyncValue<Duration> practiceTime;
  final AsyncValue<List<dynamic>> tasksCompleted;
  
  const _TodaysStatsCard({
    required this.practiceTime,
    required this.tasksCompleted,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.timer_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 12),
                practiceTime.when(
                  data: (duration) => Text(
                    '${duration.inMinutes} min',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  loading: () => const Text('--'),
                  error: (_, __) => const Text('--'),
                ),
                const SizedBox(height: 4),
                Text(
                  'Practice today',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.success,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 12),
                tasksCompleted.when(
                  data: (tasks) {
                    final completed = tasks.where((t) => t.isCompleted).length;
                    return Text(
                      '$completed/${tasks.length}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                  loading: () => const Text('--'),
                  error: (_, __) => const Text('--'),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tasks completed',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Section header with title and see all button.
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  
  const _SectionHeader({
    required this.title,
    this.onSeeAll,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text('See All'),
          ),
      ],
    );
  }
}
