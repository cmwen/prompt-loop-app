import '../entities/task.dart';

/// Task repository interface
abstract class TaskRepository {
  /// Get all tasks for a skill
  Future<List<Task>> getTasksForSkill(int skillId);

  /// Get tasks scheduled for a specific date
  Future<List<Task>> getTasksForDate(DateTime date);

  /// Get today's tasks
  Future<List<Task>> getTodaysTasks();

  /// Get incomplete tasks
  Future<List<Task>> getIncompleteTasks();

  /// Get task by ID
  Future<Task?> getTaskById(int id);

  /// Create a new task
  Future<int> createTask(Task task);

  /// Update an existing task
  Future<void> updateTask(Task task);

  /// Mark task as completed
  Future<void> completeTask(int id);

  /// Delete a task
  Future<void> deleteTask(int id);

  /// Create multiple tasks from LLM generation
  Future<List<int>> createTasksFromGeneration(List<Task> tasks);

  /// Schedule tasks for today
  Future<void> scheduleTasksForToday(List<int> taskIds);
}
