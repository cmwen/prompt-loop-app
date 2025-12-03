import 'package:equatable/equatable.dart';

/// Types of notifications in the app
enum NotificationType {
  taskReminder,
  streakReminder,
  practiceReminder;

  String get displayName {
    switch (this) {
      case NotificationType.taskReminder:
        return 'Task Reminder';
      case NotificationType.streakReminder:
        return 'Streak Reminder';
      case NotificationType.practiceReminder:
        return 'Practice Reminder';
    }
  }

  String get icon {
    switch (this) {
      case NotificationType.taskReminder:
        return '📋';
      case NotificationType.streakReminder:
        return '🔥';
      case NotificationType.practiceReminder:
        return '🎯';
    }
  }
}

/// A notification item in the app
class NotificationItem extends Equatable {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final int? relatedTaskId;
  final int? relatedSkillId;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.relatedTaskId,
    this.relatedSkillId,
  });

  /// Create a copy with modified fields
  NotificationItem copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    int? relatedTaskId,
    int? relatedSkillId,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      relatedTaskId: relatedTaskId ?? this.relatedTaskId,
      relatedSkillId: relatedSkillId ?? this.relatedSkillId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    message,
    timestamp,
    isRead,
    relatedTaskId,
    relatedSkillId,
  ];
}
