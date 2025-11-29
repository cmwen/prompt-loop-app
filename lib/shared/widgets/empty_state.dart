import 'package:flutter/material.dart';
import 'package:prompt_loop_app/core/theme/app_colors.dart';

/// Empty state widget shown when there's no data.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state specifically for skills.
class SkillsEmptyState extends StatelessWidget {
  final VoidCallback? onAddSkill;
  
  const SkillsEmptyState({
    super.key,
    this.onAddSkill,
  });
  
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.psychology_outlined,
      title: 'No skills yet',
      description: 'Start your learning journey by adding a skill you want to master.',
      actionLabel: 'Add Skill',
      onAction: onAddSkill,
    );
  }
}

/// Empty state specifically for tasks.
class TasksEmptyState extends StatelessWidget {
  final VoidCallback? onGenerateTasks;
  
  const TasksEmptyState({
    super.key,
    this.onGenerateTasks,
  });
  
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.task_alt_outlined,
      title: 'No tasks yet',
      description: 'Use AI to generate deliberate practice tasks for your skills.',
      actionLabel: 'Generate Tasks',
      onAction: onGenerateTasks,
    );
  }
}

/// Empty state for completed all tasks.
class AllTasksCompletedState extends StatelessWidget {
  const AllTasksCompletedState({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration,
                size: 40,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'All done for today!',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Great work! You\'ve completed all your tasks.\nTake a well-deserved break or practice more.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state for no practice sessions.
class NoPracticeSessionsState extends StatelessWidget {
  final String skillName;
  final VoidCallback? onStartPractice;
  
  const NoPracticeSessionsState({
    super.key,
    required this.skillName,
    this.onStartPractice,
  });
  
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.play_circle_outline,
      title: 'No practice sessions yet',
      description: 'Start your first practice session for $skillName.',
      actionLabel: 'Start Practice',
      onAction: onStartPractice,
    );
  }
}
