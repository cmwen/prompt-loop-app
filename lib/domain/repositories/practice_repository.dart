import '../entities/practice_session.dart';
import '../entities/streak.dart';
import '../entities/struggle_entry.dart';

/// Practice repository interface
abstract class PracticeRepository {
  /// Start a new practice session
  Future<int> startSession(int taskId);

  /// Complete a practice session
  Future<void> completeSession({
    required int sessionId,
    required int durationSeconds,
    String? notes,
    int? rating,
    List<String>? criteriaMet,
  });

  /// Get session by ID
  Future<PracticeSession?> getSessionById(int id);

  /// Get all sessions for a task
  Future<List<PracticeSession>> getSessionsForTask(int taskId);

  /// Get sessions for a date range
  Future<List<PracticeSession>> getSessionsForDateRange(
    DateTime start,
    DateTime end,
  );

  /// Get total practice time for a skill (in seconds)
  Future<int> getTotalPracticeTime(int skillId);

  /// Save struggle entry (Duckworth addition)
  Future<int> saveStruggleEntry({
    required int sessionId,
    required String content,
    String? wiseFeedback,
  });

  /// Get struggle entries for a session
  Future<List<StruggleEntry>> getStruggleEntriesForSession(int sessionId);

  /// Get streak for a skill
  Future<Streak> getStreak(int skillId);

  /// Record practice for streak (Duckworth: with recovery)
  Future<void> recordPracticeForStreak(int skillId);

  /// Get all streaks
  Future<List<Streak>> getAllStreaks();

  /// Get total completed tasks for a skill
  Future<int> getCompletedTasksCount(int skillId);

  /// Get total tasks for a skill
  Future<int> getTotalTasksCount(int skillId);

  /// Get completed tasks count for today
  Future<int> getCompletedTasksCountForDay(int skillId, DateTime date);

  /// Get skill progress percentage (0-100)
  Future<double> getSkillProgressPercent(int skillId);

  /// Get daily progress data for a skill
  Future<List<Map<String, dynamic>>> getDailyProgressData(int skillId, int daysBack);
}
