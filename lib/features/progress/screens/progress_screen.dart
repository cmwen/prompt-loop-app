import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deliberate_practice_app/core/theme/app_colors.dart';
import 'package:deliberate_practice_app/features/practice/providers/practice_provider.dart';
import 'package:deliberate_practice_app/features/skills/providers/skills_provider.dart';
import 'package:deliberate_practice_app/shared/widgets/app_card.dart';
import 'package:deliberate_practice_app/shared/widgets/progress_indicators.dart';
import 'package:deliberate_practice_app/shared/widgets/loading_indicator.dart';

/// Progress screen showing overall progress and statistics.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skills = ref.watch(skillsProvider);
    final weeklyTime = ref.watch(weeklyPracticeTimeProvider);
    final todaysSessions = ref.watch(todaysSessionsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Progress')),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Weekly summary
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Week',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _StatItem(
                              icon: Icons.timer_outlined,
                              iconColor: Theme.of(context).colorScheme.primary,
                              label: 'Practice Time',
                              value: weeklyTime.when(
                                data: (d) =>
                                    '${d.inHours}h ${d.inMinutes % 60}m',
                                loading: () => '--',
                                error: (_, __) => '--',
                              ),
                            ),
                          ),
                          Expanded(
                            child: _StatItem(
                              icon: Icons.check_circle_outline,
                              iconColor: AppColors.success,
                              label: 'Sessions',
                              value: todaysSessions.when(
                                data: (s) => '${s.length}',
                                loading: () => '--',
                                error: (_, __) => '--',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Skills progress
                Text(
                  'Skills Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                skills.when(
                  data: (skillList) {
                    if (skillList.isEmpty) {
                      return const AppCard(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('Add skills to track your progress'),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: skillList
                          .map(
                            (skill) => AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              skill.name,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleSmall,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              skill.currentLevel.displayName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      CircularProgressWithLabel(
                                        value: 0.0, // TODO: Calculate progress
                                        size: 50,
                                        strokeWidth: 5,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _SkillStreakInfo(skillId: skill.id!),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                  loading: () => const LoadingIndicator(),
                  error: (e, _) => Text('Error: $e'),
                ),
                const SizedBox(height: 24),

                // Motivation section
                AppCard(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha(25),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: AppColors.warning,
                        size: 40,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Keep Going!',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Consistency is more important than intensity. Small daily practices compound over time.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100), // Bottom padding
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Single stat item for the weekly summary.
class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Streak information for a skill.
class _SkillStreakInfo extends ConsumerWidget {
  final int skillId;

  const _SkillStreakInfo({required this.skillId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider(skillId));

    return streak.when(
      data: (s) {
        return StreakIndicator(
          currentStreak: s.currentCount,
          bestStreak: s.longestCount,
          isActiveToday: s.practicedToday,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
