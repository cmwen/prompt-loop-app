import 'package:equatable/equatable.dart';

/// Task frequency
enum TaskFrequency {
  daily,
  weekly,
  custom;

  String get displayName {
    switch (this) {
      case TaskFrequency.daily:
        return 'Daily';
      case TaskFrequency.weekly:
        return 'Weekly';
      case TaskFrequency.custom:
        return 'Custom';
    }
  }

  static TaskFrequency fromString(String value) {
    return TaskFrequency.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => TaskFrequency.daily,
    );
  }
}

/// Task entity representing a practice task
class Task extends Equatable {
  final int? id;
  final int skillId;
  final int? subSkillId;
  final String title;
  final String? description;
  final int durationMinutes;
  final TaskFrequency frequency;
  final int difficulty;
  final List<String> successCriteria;
  final bool isCompleted;
  final DateTime? scheduledDate;
  final DateTime? completedAt;
  final bool isLlmGenerated;
  final DateTime createdAt;

  // Optional joined data
  final String? skillName;
  final String? subSkillName;

  const Task({
    this.id,
    required this.skillId,
    this.subSkillId,
    required this.title,
    this.description,
    this.durationMinutes = 15,
    this.frequency = TaskFrequency.daily,
    this.difficulty = 5,
    this.successCriteria = const [],
    this.isCompleted = false,
    this.scheduledDate,
    this.completedAt,
    this.isLlmGenerated = false,
    required this.createdAt,
    this.skillName,
    this.subSkillName,
  });

  /// Create a copy with modified fields
  Task copyWith({
    int? id,
    int? skillId,
    int? subSkillId,
    String? title,
    String? description,
    int? durationMinutes,
    TaskFrequency? frequency,
    int? difficulty,
    List<String>? successCriteria,
    bool? isCompleted,
    DateTime? scheduledDate,
    DateTime? completedAt,
    bool? isLlmGenerated,
    DateTime? createdAt,
    String? skillName,
    String? subSkillName,
  }) {
    return Task(
      id: id ?? this.id,
      skillId: skillId ?? this.skillId,
      subSkillId: subSkillId ?? this.subSkillId,
      title: title ?? this.title,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      frequency: frequency ?? this.frequency,
      difficulty: difficulty ?? this.difficulty,
      successCriteria: successCriteria ?? this.successCriteria,
      isCompleted: isCompleted ?? this.isCompleted,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedAt: completedAt ?? this.completedAt,
      isLlmGenerated: isLlmGenerated ?? this.isLlmGenerated,
      createdAt: createdAt ?? this.createdAt,
      skillName: skillName ?? this.skillName,
      subSkillName: subSkillName ?? this.subSkillName,
    );
  }

  @override
  List<Object?> get props => [
    id,
    skillId,
    subSkillId,
    title,
    description,
    durationMinutes,
    frequency,
    difficulty,
    successCriteria,
    isCompleted,
    scheduledDate,
    completedAt,
    isLlmGenerated,
    createdAt,
  ];
}
