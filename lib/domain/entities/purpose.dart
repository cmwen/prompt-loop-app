import 'package:equatable/equatable.dart';

/// Purpose categories (Duckworth: connecting practice to meaning)
enum PurposeCategory {
  personalExpression,
  connectingWithOthers,
  careerGrowth,
  selfImprovement,
  contributingBeyondSelf,
  other;

  String get displayName {
    switch (this) {
      case PurposeCategory.personalExpression:
        return 'Personal expression & creativity';
      case PurposeCategory.connectingWithOthers:
        return 'Connecting with others';
      case PurposeCategory.careerGrowth:
        return 'Career or professional growth';
      case PurposeCategory.selfImprovement:
        return 'Challenge & self-improvement';
      case PurposeCategory.contributingBeyondSelf:
        return 'Contributing to something beyond myself';
      case PurposeCategory.other:
        return 'Other';
    }
  }

  String get dbValue {
    switch (this) {
      case PurposeCategory.personalExpression:
        return 'personal_expression';
      case PurposeCategory.connectingWithOthers:
        return 'connecting_with_others';
      case PurposeCategory.careerGrowth:
        return 'career_growth';
      case PurposeCategory.selfImprovement:
        return 'self_improvement';
      case PurposeCategory.contributingBeyondSelf:
        return 'contributing_beyond_self';
      case PurposeCategory.other:
        return 'other';
    }
  }

  static PurposeCategory fromString(String value) {
    switch (value) {
      case 'personal_expression':
        return PurposeCategory.personalExpression;
      case 'connecting_with_others':
        return PurposeCategory.connectingWithOthers;
      case 'career_growth':
        return PurposeCategory.careerGrowth;
      case 'self_improvement':
        return PurposeCategory.selfImprovement;
      case 'contributing_beyond_self':
        return PurposeCategory.contributingBeyondSelf;
      case 'other':
      default:
        return PurposeCategory.other;
    }
  }
}

/// Purpose entity (Duckworth: connecting skill practice to personal meaning)
class Purpose extends Equatable {
  final int? id;
  final int skillId;
  final String statement;
  final PurposeCategory category;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Purpose({
    this.id,
    required this.skillId,
    required this.statement,
    required this.category,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create a copy with modified fields
  Purpose copyWith({
    int? id,
    int? skillId,
    String? statement,
    PurposeCategory? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Purpose(
      id: id ?? this.id,
      skillId: skillId ?? this.skillId,
      statement: statement ?? this.statement,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    skillId,
    statement,
    category,
    createdAt,
    updatedAt,
  ];
}
