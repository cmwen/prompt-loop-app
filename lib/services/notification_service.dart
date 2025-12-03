import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/notification_item.dart';
import '../features/tasks/providers/tasks_provider.dart';
import '../features/practice/providers/practice_provider.dart';

/// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref);
});

/// Provider for all notifications
final notificationsProvider = FutureProvider<List<NotificationItem>>((
  ref,
) async {
  final service = ref.watch(notificationServiceProvider);
  return service.getNotifications();
});

/// Provider for unread notification count
final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final notifications = await ref.watch(notificationsProvider.future);
  return notifications.where((n) => !n.isRead).length;
});

/// StateNotifier for managing notification read state
final notificationStateProvider =
    StateNotifierProvider<NotificationStateNotifier, Set<String>>((ref) {
      return NotificationStateNotifier();
    });

/// Notification state notifier to track read notifications
class NotificationStateNotifier extends StateNotifier<Set<String>> {
  NotificationStateNotifier() : super({});

  void markAsRead(String notificationId) {
    state = {...state, notificationId};
  }

  void markAllAsRead(List<String> notificationIds) {
    state = {...state, ...notificationIds};
  }

  bool isRead(String notificationId) {
    return state.contains(notificationId);
  }
}

/// Service for generating and managing notifications
class NotificationService {
  final Ref _ref;

  NotificationService(this._ref);

  /// Get all pending notifications
  Future<List<NotificationItem>> getNotifications() async {
    final notifications = <NotificationItem>[];
    final readNotifications = _ref.read(notificationStateProvider);

    // Get task reminders
    final taskNotifications = await _generateTaskReminders(readNotifications);
    notifications.addAll(taskNotifications);

    // Get streak reminders
    final streakNotifications = await _generateStreakReminders(
      readNotifications,
    );
    notifications.addAll(streakNotifications);

    // Get practice reminders
    final practiceNotifications = await _generatePracticeReminders(
      readNotifications,
    );
    notifications.addAll(practiceNotifications);

    // Sort by timestamp (newest first)
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return notifications;
  }

  /// Generate task reminder notifications
  Future<List<NotificationItem>> _generateTaskReminders(
    Set<String> readNotifications,
  ) async {
    final notifications = <NotificationItem>[];

    try {
      final tasks = await _ref.read(todaysTasksProvider.future);
      final incompleteTasks = tasks.where((t) => !t.isCompleted).toList();

      if (incompleteTasks.isEmpty) return notifications;

      // Create a notification for incomplete tasks
      final notificationId =
          'task_reminder_${DateTime.now().toIso8601String().substring(0, 10)}';

      notifications.add(
        NotificationItem(
          id: notificationId,
          type: NotificationType.taskReminder,
          title: 'Tasks due today',
          message: incompleteTasks.length == 1
              ? 'You have 1 task to complete today: "${incompleteTasks.first.title}"'
              : 'You have ${incompleteTasks.length} tasks to complete today',
          timestamp: DateTime.now(),
          isRead: readNotifications.contains(notificationId),
          relatedTaskId: incompleteTasks.first.id,
        ),
      );
    } catch (_) {
      // Ignore errors in notification generation
    }

    return notifications;
  }

  /// Generate streak reminder notifications
  Future<List<NotificationItem>> _generateStreakReminders(
    Set<String> readNotifications,
  ) async {
    final notifications = <NotificationItem>[];

    try {
      final todaysPractice = await _ref.read(todaysPracticeTimeProvider.future);

      // If no practice today, remind about streak
      if (todaysPractice.inMinutes == 0) {
        final notificationId =
            'streak_reminder_${DateTime.now().toIso8601String().substring(0, 10)}';

        notifications.add(
          NotificationItem(
            id: notificationId,
            type: NotificationType.streakReminder,
            title: "Don't break your streak!",
            message:
                'Practice today to maintain your streak. Even 5 minutes counts!',
            timestamp: DateTime.now(),
            isRead: readNotifications.contains(notificationId),
          ),
        );
      }
    } catch (_) {
      // Ignore errors in notification generation
    }

    return notifications;
  }

  /// Generate practice reminder notifications
  Future<List<NotificationItem>> _generatePracticeReminders(
    Set<String> readNotifications,
  ) async {
    final notifications = <NotificationItem>[];

    try {
      final todaysPractice = await _ref.read(todaysPracticeTimeProvider.future);

      // Suggest more practice if less than 30 minutes
      if (todaysPractice.inMinutes > 0 && todaysPractice.inMinutes < 30) {
        final notificationId =
            'practice_reminder_${DateTime.now().toIso8601String().substring(0, 10)}';

        notifications.add(
          NotificationItem(
            id: notificationId,
            type: NotificationType.practiceReminder,
            title: 'Keep going!',
            message:
                "You've practiced ${todaysPractice.inMinutes} minutes today. A bit more practice will help you improve faster!",
            timestamp: DateTime.now(),
            isRead: readNotifications.contains(notificationId),
          ),
        );
      }
    } catch (_) {
      // Ignore errors in notification generation
    }

    return notifications;
  }

  /// Mark a notification as read
  void markAsRead(String notificationId) {
    _ref.read(notificationStateProvider.notifier).markAsRead(notificationId);
  }

  /// Mark all notifications as read
  void markAllAsRead(List<NotificationItem> notifications) {
    final ids = notifications.map((n) => n.id).toList();
    _ref.read(notificationStateProvider.notifier).markAllAsRead(ids);
  }
}
