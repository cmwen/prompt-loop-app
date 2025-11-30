import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:deliberate_practice_app/core/router/app_router.dart';
import 'package:deliberate_practice_app/core/theme/app_colors.dart';
import 'package:deliberate_practice_app/features/skills/providers/skills_provider.dart';
import 'package:deliberate_practice_app/features/tasks/providers/tasks_provider.dart';
import 'package:deliberate_practice_app/features/practice/providers/practice_provider.dart';
import 'package:deliberate_practice_app/features/purpose/providers/purpose_provider.dart';
import 'package:deliberate_practice_app/shared/widgets/app_card.dart';
import 'package:deliberate_practice_app/shared/widgets/progress_indicators.dart';
import 'package:deliberate_practice_app/shared/widgets/loading_indicator.dart';
import 'package:deliberate_practice_app/shared/widgets/empty_state.dart';

/// Skill detail screen showing full skill info, tasks, and progress.
class SkillDetailScreen extends ConsumerWidget {
  final int skillId;
  
  const SkillDetailScreen({
    super.key,
    required this.skillId,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skill = ref.watch(skillByIdProvider(skillId));
    final subSkills = ref.watch(subSkillsProvider(skillId));
    final tasks = ref.watch(tasksBySkillProvider(skillId));
    final streak = ref.watch(currentStreakProvider(skillId));
    final purposes = ref.watch(purposesBySkillProvider(skillId));
    
    return skill.when(
      data: (skillData) {
        if (skillData == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Skill not found')),
          );
        }
        
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Text(skillData.name),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () {
                      // TODO: Edit skill
                    },
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'archive',
                        child: Text('Archive Skill'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Skill'),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'archive') {
                        await ref.read(skillsProvider.notifier).archiveSkill(skillId);
                        if (context.mounted) context.pop();
                      } else if (value == 'delete') {
                        // Show confirmation dialog
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Skill'),
                            content: const Text('Are you sure you want to delete this skill? This action cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          await ref.read(skillsProvider.notifier).deleteSkill(skillId);
                          if (context.mounted) context.pop();
                        }
                      }
                    },
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Progress overview
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircularProgressWithLabel(
                                value: 0.0, // TODO: Calculate progress
                                size: 60,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      skillData.currentLevel.displayName,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    streak.when(
                                      data: (s) => s != null
                                          ? StreakIndicator(
                                              currentStreak: s.currentCount,
                                              bestStreak: s.longestCount,
                                              isActiveToday: s.practicedToday,
                                            )
                                          : const Text('Start your streak!'),
                                      loading: () => const SizedBox.shrink(),
                                      error: (_, __) => const SizedBox.shrink(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (skillData.description != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              skillData.description!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Purpose section
                    purposes.when(
                      data: (purposeList) {
                        if (purposeList.isEmpty) {
                          return AppCard(
                            onTap: () {
                              context.goNamed(
                                AppRoutes.purposeSetup,
                                extra: skillId,
                              );
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Connect to your purpose',
                                        style: Theme.of(context).textTheme.titleSmall,
                                      ),
                                      Text(
                                        'Why does this skill matter to you?',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          );
                        }
                        
                        return AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Your Why',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ...purposeList.map((p) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '• ${p.description}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              )),
                            ],
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 24),
                    
                    // Sub-skills section
                    Text(
                      'Sub-Skills',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    subSkills.when(
                      data: (subSkillList) {
                        if (subSkillList.isEmpty) {
                          return AppCard(
                            onTap: () {
                              context.goNamed(
                                AppRoutes.copyPasteWorkflow,
                                extra: CopyPasteWorkflowType.skillAnalysis,
                              );
                            },
                            child: const Center(
                              child: Column(
                                children: [
                                  Icon(Icons.auto_awesome, size: 32),
                                  SizedBox(height: 8),
                                  Text('Generate sub-skills with AI'),
                                ],
                              ),
                            ),
                          );
                        }
                        
                        return Column(
                          children: subSkillList.map((subSkill) => AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        subSkill.name,
                                        style: Theme.of(context).textTheme.titleSmall,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getPriorityColor(subSkill.priority).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        subSkill.priority.name,
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: _getPriorityColor(subSkill.priority),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (subSkill.description != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    subSkill.description!,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                ProgressBar(
                                  value: 0.0, // TODO: Calculate progress
                                  height: 6,
                                ),
                              ],
                            ),
                          )).toList(),
                        );
                      },
                      loading: () => const LoadingIndicator(),
                      error: (e, _) => Text('Error: $e'),
                    ),
                    const SizedBox(height: 24),
                    
                    // Tasks section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Practice Tasks',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            context.goNamed(
                              AppRoutes.copyPasteWorkflow,
                              extra: CopyPasteWorkflowType.taskGeneration,
                            );
                          },
                          icon: const Icon(Icons.auto_awesome, size: 16),
                          label: const Text('Generate'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    tasks.when(
                      data: (taskList) {
                        if (taskList.isEmpty) {
                          return const TasksEmptyState();
                        }
                        
                        return Column(
                          children: taskList.map((task) => TaskCard(
                            title: task.title,
                            subtitle: '${task.durationMinutes} min • ${task.frequency.name}',
                            difficulty: task.difficulty,
                            isCompleted: task.isCompleted,
                            onTap: () {
                              context.goNamed(
                                AppRoutes.practiceSession,
                                pathParameters: {'skillId': skillId.toString()},
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
                    const SizedBox(height: 100), // Bottom padding for FAB
                  ]),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              context.goNamed(
                AppRoutes.practiceSession,
                pathParameters: {'skillId': skillId.toString()},
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Practice'),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const LoadingIndicator(message: 'Loading skill...'),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
  
  Color _getPriorityColor(priority) {
    switch (priority.toString()) {
      case 'Priority.high':
        return AppColors.error;
      case 'Priority.medium':
        return AppColors.warning;
      case 'Priority.low':
        return AppColors.success;
      default:
        return Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    }
  }
}
