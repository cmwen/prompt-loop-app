import 'package:flutter_test/flutter_test.dart';
import 'package:prompt_loop/domain/entities/notification_item.dart';
import 'package:prompt_loop/services/notification_service.dart';

void main() {
  group('NotificationStateNotifier', () {
    late NotificationStateNotifier notifier;

    setUp(() {
      notifier = NotificationStateNotifier();
    });

    group('initial state', () {
      test('starts with empty set', () {
        expect(notifier.state, isEmpty);
      });
    });

    group('markAsRead', () {
      test('adds notification id to state', () {
        notifier.markAsRead('notification_1');

        expect(notifier.state, contains('notification_1'));
        expect(notifier.state.length, 1);
      });

      test('can add multiple notification ids', () {
        notifier.markAsRead('notification_1');
        notifier.markAsRead('notification_2');
        notifier.markAsRead('notification_3');

        expect(notifier.state.length, 3);
        expect(notifier.state, contains('notification_1'));
        expect(notifier.state, contains('notification_2'));
        expect(notifier.state, contains('notification_3'));
      });

      test('does not duplicate ids', () {
        notifier.markAsRead('notification_1');
        notifier.markAsRead('notification_1');

        expect(notifier.state.length, 1);
      });
    });

    group('markAllAsRead', () {
      test('adds all notification ids to state', () {
        notifier.markAllAsRead([
          'notification_1',
          'notification_2',
          'notification_3',
        ]);

        expect(notifier.state.length, 3);
        expect(notifier.state, contains('notification_1'));
        expect(notifier.state, contains('notification_2'));
        expect(notifier.state, contains('notification_3'));
      });

      test('handles empty list', () {
        notifier.markAllAsRead([]);

        expect(notifier.state, isEmpty);
      });

      test('merges with existing read notifications', () {
        notifier.markAsRead('existing_notification');
        notifier.markAllAsRead(['notification_1', 'notification_2']);

        expect(notifier.state.length, 3);
        expect(notifier.state, contains('existing_notification'));
        expect(notifier.state, contains('notification_1'));
        expect(notifier.state, contains('notification_2'));
      });
    });

    group('isRead', () {
      test('returns false for unread notification', () {
        expect(notifier.isRead('notification_1'), isFalse);
      });

      test('returns true for read notification', () {
        notifier.markAsRead('notification_1');

        expect(notifier.isRead('notification_1'), isTrue);
      });

      test('returns true after markAllAsRead', () {
        notifier.markAllAsRead(['notification_1', 'notification_2']);

        expect(notifier.isRead('notification_1'), isTrue);
        expect(notifier.isRead('notification_2'), isTrue);
        expect(notifier.isRead('notification_3'), isFalse);
      });
    });
  });

  group('NotificationItem integration', () {
    test('can create task reminder notification', () {
      final notification = NotificationItem(
        id: 'task_reminder_1',
        type: NotificationType.taskReminder,
        title: 'Complete your task',
        message: 'You have 3 tasks to complete today',
        timestamp: DateTime.now(),
        relatedTaskId: 42,
      );

      expect(notification.type, NotificationType.taskReminder);
      expect(notification.type.displayName, 'Task Reminder');
      expect(notification.type.icon, '📋');
    });

    test('can create streak reminder notification', () {
      final notification = NotificationItem(
        id: 'streak_reminder_1',
        type: NotificationType.streakReminder,
        title: "Don't break your streak!",
        message: 'Practice today to maintain your 7-day streak',
        timestamp: DateTime.now(),
      );

      expect(notification.type, NotificationType.streakReminder);
      expect(notification.type.displayName, 'Streak Reminder');
      expect(notification.type.icon, '🔥');
    });

    test('can create practice reminder notification', () {
      final notification = NotificationItem(
        id: 'practice_reminder_1',
        type: NotificationType.practiceReminder,
        title: 'Keep going!',
        message: "You've practiced 15 minutes today. Keep it up!",
        timestamp: DateTime.now(),
        relatedSkillId: 10,
      );

      expect(notification.type, NotificationType.practiceReminder);
      expect(notification.type.displayName, 'Practice Reminder');
      expect(notification.type.icon, '🎯');
    });
  });

  group('Notification filtering', () {
    test('can filter unread notifications', () {
      final notifications = [
        NotificationItem(
          id: '1',
          type: NotificationType.taskReminder,
          title: 'Task 1',
          message: 'Message',
          timestamp: DateTime.now(),
          isRead: false,
        ),
        NotificationItem(
          id: '2',
          type: NotificationType.taskReminder,
          title: 'Task 2',
          message: 'Message',
          timestamp: DateTime.now(),
          isRead: true,
        ),
        NotificationItem(
          id: '3',
          type: NotificationType.streakReminder,
          title: 'Streak',
          message: 'Message',
          timestamp: DateTime.now(),
          isRead: false,
        ),
      ];

      final unreadNotifications = notifications
          .where((n) => !n.isRead)
          .toList();

      expect(unreadNotifications.length, 2);
      expect(unreadNotifications[0].id, '1');
      expect(unreadNotifications[1].id, '3');
    });

    test('can filter by notification type', () {
      final notifications = [
        NotificationItem(
          id: '1',
          type: NotificationType.taskReminder,
          title: 'Task',
          message: 'Message',
          timestamp: DateTime.now(),
        ),
        NotificationItem(
          id: '2',
          type: NotificationType.streakReminder,
          title: 'Streak',
          message: 'Message',
          timestamp: DateTime.now(),
        ),
        NotificationItem(
          id: '3',
          type: NotificationType.taskReminder,
          title: 'Another Task',
          message: 'Message',
          timestamp: DateTime.now(),
        ),
      ];

      final taskNotifications = notifications
          .where((n) => n.type == NotificationType.taskReminder)
          .toList();

      expect(taskNotifications.length, 2);
    });

    test('can sort notifications by timestamp', () {
      final earlier = DateTime(2024, 1, 15, 10, 0);
      final later = DateTime(2024, 1, 15, 12, 0);
      final latest = DateTime(2024, 1, 15, 14, 0);

      final notifications = [
        NotificationItem(
          id: '1',
          type: NotificationType.taskReminder,
          title: 'Earlier',
          message: 'Message',
          timestamp: earlier,
        ),
        NotificationItem(
          id: '3',
          type: NotificationType.taskReminder,
          title: 'Latest',
          message: 'Message',
          timestamp: latest,
        ),
        NotificationItem(
          id: '2',
          type: NotificationType.taskReminder,
          title: 'Later',
          message: 'Message',
          timestamp: later,
        ),
      ];

      // Sort newest first
      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      expect(notifications[0].id, '3'); // Latest
      expect(notifications[1].id, '2'); // Later
      expect(notifications[2].id, '1'); // Earlier
    });
  });
}
