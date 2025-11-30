import 'package:equatable/equatable.dart';

/// Streak entity for tracking practice consistency
class Streak extends Equatable {
  final int? id;
  final int skillId;
  final int currentCount;
  final int longestCount;
  final DateTime? lastPracticeDate;
  final DateTime updatedAt;

  const Streak({
    this.id,
    required this.skillId,
    this.currentCount = 0,
    this.longestCount = 0,
    this.lastPracticeDate,
    required this.updatedAt,
  });

  /// Check if streak is active (practiced today or yesterday)
  bool get isActive {
    if (lastPracticeDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastDate = DateTime(
      lastPracticeDate!.year,
      lastPracticeDate!.month,
      lastPracticeDate!.day,
    );
    return lastDate == today || lastDate == yesterday;
  }

  /// Check if practiced today
  bool get practicedToday {
    if (lastPracticeDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      lastPracticeDate!.year,
      lastPracticeDate!.month,
      lastPracticeDate!.day,
    );
    return lastDate == today;
  }

  /// Create a copy with modified fields
  Streak copyWith({
    int? id,
    int? skillId,
    int? currentCount,
    int? longestCount,
    DateTime? lastPracticeDate,
    DateTime? updatedAt,
  }) {
    return Streak(
      id: id ?? this.id,
      skillId: skillId ?? this.skillId,
      currentCount: currentCount ?? this.currentCount,
      longestCount: longestCount ?? this.longestCount,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    skillId,
    currentCount,
    longestCount,
    lastPracticeDate,
    updatedAt,
  ];
}
