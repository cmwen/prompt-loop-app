import 'package:equatable/equatable.dart';

/// Practice session entity representing a completed practice session
class PracticeSession extends Equatable {
  final int? id;
  final int taskId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? actualDurationSeconds;
  final String? notes;
  final int? rating;
  final List<String> criteriaMet;
  final DateTime createdAt;

  const PracticeSession({
    this.id,
    required this.taskId,
    required this.startedAt,
    this.completedAt,
    this.actualDurationSeconds,
    this.notes,
    this.rating,
    this.criteriaMet = const [],
    required this.createdAt,
  });

  /// Check if session is currently active
  bool get isActive => completedAt == null;

  /// Get formatted duration
  Duration get duration => Duration(seconds: actualDurationSeconds ?? 0);

  /// Create a copy with modified fields
  PracticeSession copyWith({
    int? id,
    int? taskId,
    DateTime? startedAt,
    DateTime? completedAt,
    int? actualDurationSeconds,
    String? notes,
    int? rating,
    List<String>? criteriaMet,
    DateTime? createdAt,
  }) {
    return PracticeSession(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      actualDurationSeconds: actualDurationSeconds ?? this.actualDurationSeconds,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      criteriaMet: criteriaMet ?? this.criteriaMet,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        startedAt,
        completedAt,
        actualDurationSeconds,
        notes,
        rating,
        criteriaMet,
        createdAt,
      ];
}
