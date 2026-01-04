import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prompt_loop/core/router/app_router.dart';
import 'package:prompt_loop/features/skills/providers/skills_provider.dart';
import 'package:prompt_loop/features/practice/providers/practice_provider.dart';
import 'package:prompt_loop/shared/widgets/app_card.dart';
import 'package:prompt_loop/shared/widgets/empty_state.dart';
import 'package:prompt_loop/shared/widgets/loading_indicator.dart';

/// Skills list screen showing all user skills.
class SkillsListScreen extends ConsumerWidget {
  const SkillsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skills = ref.watch(skillsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Skills'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // TODO: Implement search
                },
              ),
            ],
          ),
          skills.when(
            data: (skillList) {
              if (skillList.isEmpty) {
                return SliverFillRemaining(
                  child: SkillsEmptyState(
                    onAddSkill: () => context.goNamed(AppRoutes.addSkill),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final skill = skillList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Consumer(
                        builder: (context, ref, _) {
                          final progress = ref.watch(
                            skillProgressPercentProvider(skill.id!),
                          );
                          return progress.when(
                            data: (percent) => SkillCard(
                              name: skill.name,
                              level: skill.currentLevel.displayName,
                              progress: percent / 100,
                              onTap: () {
                                context.goNamed(
                                  AppRoutes.skillDetail,
                                  pathParameters: {'id': skill.id.toString()},
                                );
                              },
                              trailing: IconButton(
                                icon: const Icon(Icons.play_circle_outline),
                                onPressed: () {
                                  context.goNamed(
                                    AppRoutes.practiceSession,
                                    pathParameters: {
                                      'skillId': skill.id.toString(),
                                    },
                                  );
                                },
                              ),
                            ),
                            loading: () => SkillCard(
                              name: skill.name,
                              level: skill.currentLevel.displayName,
                              progress: 0.0,
                              onTap: () {
                                context.goNamed(
                                  AppRoutes.skillDetail,
                                  pathParameters: {'id': skill.id.toString()},
                                );
                              },
                              trailing: IconButton(
                                icon: const Icon(Icons.play_circle_outline),
                                onPressed: () {
                                  context.goNamed(
                                    AppRoutes.practiceSession,
                                    pathParameters: {
                                      'skillId': skill.id.toString(),
                                    },
                                  );
                                },
                              ),
                            ),
                            error: (_, _) => SkillCard(
                              name: skill.name,
                              level: skill.currentLevel.displayName,
                              progress: 0.0,
                              onTap: () {
                                context.goNamed(
                                  AppRoutes.skillDetail,
                                  pathParameters: {'id': skill.id.toString()},
                                );
                              },
                              trailing: IconButton(
                                icon: const Icon(Icons.play_circle_outline),
                                onPressed: () {
                                  context.goNamed(
                                    AppRoutes.practiceSession,
                                    pathParameters: {
                                      'skillId': skill.id.toString(),
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }, childCount: skillList.length),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: LoadingIndicator(message: 'Loading skills...'),
            ),
            error: (e, _) =>
                SliverFillRemaining(child: Center(child: Text('Error: $e'))),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed(AppRoutes.addSkill),
        icon: const Icon(Icons.add),
        label: const Text('Add Skill'),
      ),
    );
  }
}
