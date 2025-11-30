import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:deliberate_practice_app/core/router/app_router.dart';
import 'package:deliberate_practice_app/features/tasks/providers/tasks_provider.dart';
import 'package:deliberate_practice_app/shared/widgets/app_card.dart';
import 'package:deliberate_practice_app/shared/widgets/empty_state.dart';
import 'package:deliberate_practice_app/shared/widgets/loading_indicator.dart';

/// Tasks screen showing all tasks grouped by status.
class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todaysTasks = ref.watch(todaysTasksProvider);
    final upcomingTasks = ref.watch(upcomingTasksProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar.large(
              title: const Text('Tasks'),
              pinned: true,
              floating: true,
              forceElevated: innerBoxIsScrolled,
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Today'),
                  Tab(text: 'All Tasks'),
                ],
              ),
            ),
          ],
          body: TabBarView(
            children: [
              // Today's tasks
              todaysTasks.when(
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return const AllTasksCompletedState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TaskCard(
                          title: task.title,
                          subtitle: '${task.durationMinutes} min',
                          difficulty: task.difficulty,
                          isCompleted: task.isCompleted,
                          onTap: () {
                            context.goNamed(
                              AppRoutes.practiceSession,
                              pathParameters: {
                                'skillId': task.skillId.toString(),
                              },
                              extra: task.id,
                            );
                          },
                          onComplete: () {
                            ref
                                .read(tasksProvider.notifier)
                                .completeTask(task.id!);
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () =>
                    const LoadingIndicator(message: 'Loading tasks...'),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),

              // All tasks
              upcomingTasks.when(
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return TasksEmptyState(
                      onGenerateTasks: () {
                        context.goNamed(
                          AppRoutes.copyPasteWorkflow,
                          extra: CopyPasteWorkflowType.taskGeneration,
                        );
                      },
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TaskCard(
                          title: task.title,
                          subtitle:
                              '${task.frequency.name} • ${task.durationMinutes} min',
                          difficulty: task.difficulty,
                          isCompleted: task.isCompleted,
                          onTap: () {
                            context.goNamed(
                              AppRoutes.practiceSession,
                              pathParameters: {
                                'skillId': task.skillId.toString(),
                              },
                              extra: task.id,
                            );
                          },
                          onComplete: () {
                            if (task.isCompleted) {
                              ref
                                  .read(tasksProvider.notifier)
                                  .uncompleteTask(task.id!);
                            } else {
                              ref
                                  .read(tasksProvider.notifier)
                                  .completeTask(task.id!);
                            }
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () =>
                    const LoadingIndicator(message: 'Loading tasks...'),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            context.goNamed(
              AppRoutes.copyPasteWorkflow,
              extra: CopyPasteWorkflowType.taskGeneration,
            );
          },
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Generate Tasks'),
        ),
      ),
    );
  }
}
