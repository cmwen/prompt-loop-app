import 'package:equatable/equatable.dart';

import 'skill.dart';

/// Priority levels for sub-skills
enum Priority {
  high,
  medium,
  low;

  String get displayName {
    switch (this) {
      case Priority.high:
        return 'High';
      case Priority.medium:
        return 'Medium';
      case Priority.low:
        return 'Low';
    }
  }

  static Priority fromString(String value) {
    return Priority.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => Priority.medium,
    );
  }
}

/// SubSkill entity representing a component skill within a larger skill
class SubSkill extends Equatable {
  final int? id;
  final int skillId;
  final String name;
  final String? description;
  final SkillLevel currentLevel;
  final SkillLevel? targetLevel;
  final Priority priority;
  final int progressPercent;
  final bool isLlmGenerated;
  final DateTime createdAt;

  const SubSkill({
    this.id,
    required this.skillId,
    required this.name,
    this.description,
    this.currentLevel = SkillLevel.beginner,
    this.targetLevel,
    this.priority = Priority.medium,
    this.progressPercent = 0,
    this.isLlmGenerated = false,
    required this.createdAt,
  });

  /// Create a copy with modified fields
  SubSkill copyWith({
    int? id,
    int? skillId,
    String? name,
    String? description,
    SkillLevel? currentLevel,
    SkillLevel? targetLevel,
    Priority? priority,
    int? progressPercent,
    bool? isLlmGenerated,
    DateTime? createdAt,
  }) {
    return SubSkill(
      id: id ?? this.id,
      skillId: skillId ?? this.skillId,
      name: name ?? this.name,
      description: description ?? this.description,
      currentLevel: currentLevel ?? this.currentLevel,
      targetLevel: targetLevel ?? this.targetLevel,
      priority: priority ?? this.priority,
      progressPercent: progressPercent ?? this.progressPercent,
      isLlmGenerated: isLlmGenerated ?? this.isLlmGenerated,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    skillId,
    name,
    description,
    currentLevel,
    targetLevel,
    priority,
    progressPercent,
    isLlmGenerated,
    createdAt,
  ];
}
