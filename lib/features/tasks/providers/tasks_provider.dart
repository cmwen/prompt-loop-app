import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_loop/data/providers/repository_providers.dart';
import 'package:prompt_loop/domain/entities/task.dart';

/// Provider for all tasks.
final tasksProvider =
    StateNotifierProvider<TasksNotifier, AsyncValue<List<Task>>>((ref) {
      return TasksNotifier(ref);
    });

/// Provider for tasks by skill.
final tasksBySkillProvider = FutureProvider.family<List<Task>, int>((
  ref,
  skillId,
) async {
  final repository = await ref.watch(taskRepositoryProvider.future);
  return repository.getTasksForSkill(skillId);
});

/// Provider for tasks by sub-skill.
final tasksBySubSkillProvider = FutureProvider.family<List<Task>, int>((
  ref,
  subSkillId,
) async {
  final repository = await ref.watch(taskRepositoryProvider.future);
  return repository.getTasksForSkill(subSkillId); // TODO: Filter by subSkill
});

/// Provider for today's tasks.
final todaysTasksProvider = FutureProvider<List<Task>>((ref) async {
  final repository = await ref.watch(taskRepositoryProvider.future);
  final allTasks = await repository.getAllTasks();
  final today = DateTime.now();
  final todayStr = DateTime(today.year, today.month, today.day);

  return allTasks.where((task) {
    // Include tasks scheduled for today regardless of completion
    if (task.scheduledDate != null) {
      final scheduledDay = DateTime(
        task.scheduledDate!.year,
        task.scheduledDate!.month,
        task.scheduledDate!.day,
      );
      if (scheduledDay.isAtSameMomentAs(todayStr)) {
        return true;
      }
    }

    // For unscheduled tasks, check completion and frequency
    if (task.isCompleted) {
      // Check if completed today
      if (task.completedAt != null) {
        final completedDay = DateTime(
          task.completedAt!.year,
          task.completedAt!.month,
          task.completedAt!.day,
        );
        return completedDay.isAtSameMomentAs(todayStr);
      }
      return false;
    }

    // Check if task is due today based on frequency
    switch (task.frequency) {
      case TaskFrequency.daily:
        return true;
      case TaskFrequency.weekly:
        if (task.completedAt == null) return true;
        final daysSinceComplete = today.difference(task.completedAt!).inDays;
        return daysSinceComplete >= 7;
      case TaskFrequency.custom:
        return true;
    }
  }).toList();
});

/// Provider for upcoming tasks (next 7 days).
final upcomingTasksProvider = FutureProvider<List<Task>>((ref) async {
  final repository = await ref.watch(taskRepositoryProvider.future);
  final allTasks = await repository.getAllTasks();

  return allTasks;
});

/// Tasks state notifier.
class TasksNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final Ref _ref;

  TasksNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      state = const AsyncValue.loading();
      final repository = await _ref.read(taskRepositoryProvider.future);
      final tasks = await repository.getAllTasks();
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<int> createTask(Task task) async {
    try {
      final repository = await _ref.read(taskRepositoryProvider.future);
      final id = await repository.createTask(task);
      await loadTasks();
      _invalidateRelatedProviders(task);
      return id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      final repository = await _ref.read(taskRepositoryProvider.future);
      await repository.updateTask(task);
      await loadTasks();
      _invalidateRelatedProviders(task);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      final repository = await _ref.read(taskRepositoryProvider.future);
      await repository.deleteTask(id);
      await loadTasks();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> completeTask(int id) async {
    try {
      final repository = await _ref.read(taskRepositoryProvider.future);
      await repository.completeTask(id);
      await loadTasks();
      _ref.invalidate(todaysTasksProvider);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uncompleteTask(int id) async {
    try {
      final repository = await _ref.read(taskRepositoryProvider.future);
      final task = await repository.getTaskById(id);
      if (task != null) {
        await repository.updateTask(task.copyWith(isCompleted: false));
      }
      await loadTasks();
      _ref.invalidate(todaysTasksProvider);
    } catch (e) {
      rethrow;
    }
  }

  void _invalidateRelatedProviders(Task task) {
    _ref.invalidate(tasksBySkillProvider(task.skillId));
    if (task.subSkillId != null) {
      _ref.invalidate(tasksBySubSkillProvider(task.subSkillId!));
    }
    _ref.invalidate(todaysTasksProvider);
    _ref.invalidate(upcomingTasksProvider);
  }
}
