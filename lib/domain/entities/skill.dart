import 'package:equatable/equatable.dart';

/// Skill proficiency levels
enum SkillLevel {
  beginner,
  intermediate,
  advanced,
  expert;

  String get displayName {
    switch (this) {
      case SkillLevel.beginner:
        return 'Beginner';
      case SkillLevel.intermediate:
        return 'Intermediate';
      case SkillLevel.advanced:
        return 'Advanced';
      case SkillLevel.expert:
        return 'Expert';
    }
  }

  static SkillLevel fromString(String value) {
    return SkillLevel.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => SkillLevel.beginner,
    );
  }
}

/// Skill entity representing a skill the user wants to master
class Skill extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final SkillLevel currentLevel;
  final SkillLevel? targetLevel;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Skill({
    this.id,
    required this.name,
    this.description,
    this.currentLevel = SkillLevel.beginner,
    this.targetLevel,
    this.isArchived = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create a copy with modified fields
  Skill copyWith({
    int? id,
    String? name,
    String? description,
    SkillLevel? currentLevel,
    SkillLevel? targetLevel,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Skill(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      currentLevel: currentLevel ?? this.currentLevel,
      targetLevel: targetLevel ?? this.targetLevel,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        currentLevel,
        targetLevel,
        isArchived,
        createdAt,
        updatedAt,
      ];
}
