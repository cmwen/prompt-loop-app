import 'package:equatable/equatable.dart';

/// Milestone types
enum MilestoneType {
  practiceTime,
  taskCount,
  streak,
  custom;

  String get displayName {
    switch (this) {
      case MilestoneType.practiceTime:
        return 'Practice Time';
      case MilestoneType.taskCount:
        return 'Tasks Completed';
      case MilestoneType.streak:
        return 'Streak';
      case MilestoneType.custom:
        return 'Custom';
    }
  }

  String get dbValue {
    switch (this) {
      case MilestoneType.practiceTime:
        return 'practice_time';
      case MilestoneType.taskCount:
        return 'task_count';
      case MilestoneType.streak:
        return 'streak';
      case MilestoneType.custom:
        return 'custom';
    }
  }

  static MilestoneType fromString(String value) {
    switch (value) {
      case 'practice_time':
        return MilestoneType.practiceTime;
      case 'task_count':
        return MilestoneType.taskCount;
      case 'streak':
        return MilestoneType.streak;
      case 'custom':
      default:
        return MilestoneType.custom;
    }
  }
}

/// Milestone entity for tracking achievements
class Milestone extends Equatable {
  final int? id;
  final int skillId;
  final String title;
  final String? description;
  final MilestoneType type;
  final int targetValue;
  final int currentValue;
  final DateTime? achievedAt;
  final DateTime createdAt;

  const Milestone({
    this.id,
    required this.skillId,
    required this.title,
    this.description,
    required this.type,
    required this.targetValue,
    this.currentValue = 0,
    this.achievedAt,
    required this.createdAt,
  });

  /// Check if milestone is achieved
  bool get isAchieved => achievedAt != null;

  /// Get progress percentage (0-100)
  double get progressPercent {
    if (targetValue == 0) return 0;
    return (currentValue / targetValue * 100).clamp(0, 100);
  }

  /// Create a copy with modified fields
  Milestone copyWith({
    int? id,
    int? skillId,
    String? title,
    String? description,
    MilestoneType? type,
    int? targetValue,
    int? currentValue,
    DateTime? achievedAt,
    DateTime? createdAt,
  }) {
    return Milestone(
      id: id ?? this.id,
      skillId: skillId ?? this.skillId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      achievedAt: achievedAt ?? this.achievedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    skillId,
    title,
    description,
    type,
    targetValue,
    currentValue,
    achievedAt,
    createdAt,
  ];
}
