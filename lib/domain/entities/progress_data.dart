import 'package:equatable/equatable.dart';

/// Progress data for charts and analytics
class ProgressData extends Equatable {
  final DateTime date;
  final int practiceMinutes;
  final int tasksCompleted;
  final int sessionsCount;

  const ProgressData({
    required this.date,
    this.practiceMinutes = 0,
    this.tasksCompleted = 0,
    this.sessionsCount = 0,
  });

  @override
  List<Object?> get props => [
    date,
    practiceMinutes,
    tasksCompleted,
    sessionsCount,
  ];
}

/// Skill progress summary
class SkillProgressSummary extends Equatable {
  final int skillId;
  final String skillName;
  final int totalPracticeMinutes;
  final int totalTasksCompleted;
  final int totalSessions;
  final double overallProgress;
  final int currentStreak;
  final int longestStreak;
  final List<ProgressData> dailyProgress;
  final Map<String, double> subSkillProgress;

  const SkillProgressSummary({
    required this.skillId,
    required this.skillName,
    this.totalPracticeMinutes = 0,
    this.totalTasksCompleted = 0,
    this.totalSessions = 0,
    this.overallProgress = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.dailyProgress = const [],
    this.subSkillProgress = const {},
  });

  @override
  List<Object?> get props => [
    skillId,
    skillName,
    totalPracticeMinutes,
    totalTasksCompleted,
    totalSessions,
    overallProgress,
    currentStreak,
    longestStreak,
    dailyProgress,
    subSkillProgress,
  ];
}
