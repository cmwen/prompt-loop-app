/// Database table and column name constants
class DbConstants {
  DbConstants._();

  // Database
  static const String databaseName = 'deliberate_practice.db';
  static const int databaseVersion = 1;

  // Tables
  static const String tableUsers = 'users';
  static const String tableSkills = 'skills';
  static const String tableSubSkills = 'sub_skills';
  static const String tablePurposes = 'purposes';
  static const String tableTasks = 'tasks';
  static const String tablePracticeSessions = 'practice_sessions';
  static const String tableStruggleEntries = 'struggle_entries';
  static const String tableStreaks = 'streaks';
  static const String tableMilestones = 'milestones';
  static const String tableSettings = 'settings';

  // Common Columns
  static const String colId = 'id';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  // Users Columns
  static const String colOnboardingCompleted = 'onboarding_completed';

  // Skills Columns
  static const String colUserId = 'user_id';
  static const String colName = 'name';
  static const String colDescription = 'description';
  static const String colCurrentLevel = 'current_level';
  static const String colTargetLevel = 'target_level';
  static const String colIsArchived = 'is_archived';

  // SubSkills Columns
  static const String colSkillId = 'skill_id';
  static const String colPriority = 'priority';
  static const String colProgressPercent = 'progress_percent';
  static const String colLlmGenerated = 'llm_generated';

  // Purposes Columns
  static const String colStatement = 'statement';
  static const String colCategory = 'category';

  // Tasks Columns
  static const String colSubSkillId = 'sub_skill_id';
  static const String colTitle = 'title';
  static const String colDurationMinutes = 'duration_minutes';
  static const String colFrequency = 'frequency';
  static const String colDifficulty = 'difficulty';
  static const String colSuccessCriteria = 'success_criteria';
  static const String colIsCompleted = 'is_completed';
  static const String colScheduledDate = 'scheduled_date';
  static const String colCompletedAt = 'completed_at';

  // Practice Sessions Columns
  static const String colTaskId = 'task_id';
  static const String colStartedAt = 'started_at';
  static const String colActualDurationSeconds = 'actual_duration_seconds';
  static const String colNotes = 'notes';
  static const String colRating = 'rating';
  static const String colCriteriaMet = 'criteria_met';

  // Struggle Entries Columns
  static const String colSessionId = 'session_id';
  static const String colContent = 'content';
  static const String colWiseFeedback = 'wise_feedback';

  // Streaks Columns
  static const String colCurrentCount = 'current_count';
  static const String colLongestCount = 'longest_count';
  static const String colLastPracticeDate = 'last_practice_date';

  // Milestones Columns
  static const String colMilestoneType = 'milestone_type';
  static const String colTargetValue = 'target_value';
  static const String colCurrentValue = 'current_value';
  static const String colAchievedAt = 'achieved_at';

  // Settings Columns
  static const String colKey = 'key';
  static const String colValue = 'value';
}
