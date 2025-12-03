import 'package:flutter_test/flutter_test.dart';
import 'package:prompt_loop/domain/entities/notification_item.dart';

void main() {
  group('NotificationItem', () {
    final now = DateTime(2024, 1, 15, 10, 30);

    group('constructor', () {
      test('creates notification with required fields', () {
        final notification = NotificationItem(
          id: 'notification_1',
          type: NotificationType.taskReminder,
          title: 'Task due',
          message: 'Complete your practice task',
          timestamp: now,
        );

        expect(notification.id, 'notification_1');
        expect(notification.type, NotificationType.taskReminder);
        expect(notification.title, 'Task due');
        expect(notification.message, 'Complete your practice task');
        expect(notification.timestamp, now);
        expect(notification.isRead, isFalse);
        expect(notification.relatedTaskId, isNull);
        expect(notification.relatedSkillId, isNull);
      });

      test('creates notification with all fields', () {
        final notification = NotificationItem(
          id: 'notification_2',
          type: NotificationType.streakReminder,
          title: 'Keep your streak',
          message: 'Practice today to maintain your streak',
          timestamp: now,
          isRead: true,
          relatedTaskId: 42,
          relatedSkillId: 10,
        );

        expect(notification.id, 'notification_2');
        expect(notification.type, NotificationType.streakReminder);
        expect(notification.isRead, isTrue);
        expect(notification.relatedTaskId, 42);
        expect(notification.relatedSkillId, 10);
      });
    });

    group('copyWith', () {
      late NotificationItem originalNotification;

      setUp(() {
        originalNotification = NotificationItem(
          id: 'original_id',
          type: NotificationType.taskReminder,
          title: 'Original Title',
          message: 'Original message',
          timestamp: now,
          isRead: false,
        );
      });

      test('returns identical notification when no parameters provided', () {
        final copied = originalNotification.copyWith();

        expect(copied, equals(originalNotification));
        expect(copied.id, originalNotification.id);
        expect(copied.title, originalNotification.title);
      });

      test('updates only specified fields', () {
        final copied = originalNotification.copyWith(
          title: 'Updated Title',
          isRead: true,
        );

        expect(copied.title, 'Updated Title');
        expect(copied.isRead, isTrue);
        // Unchanged fields
        expect(copied.id, originalNotification.id);
        expect(copied.type, originalNotification.type);
        expect(copied.message, originalNotification.message);
        expect(copied.timestamp, originalNotification.timestamp);
      });

      test('can update type', () {
        final copied = originalNotification.copyWith(
          type: NotificationType.practiceReminder,
        );

        expect(copied.type, NotificationType.practiceReminder);
      });

      test('can update related IDs', () {
        final copied = originalNotification.copyWith(
          relatedTaskId: 100,
          relatedSkillId: 200,
        );

        expect(copied.relatedTaskId, 100);
        expect(copied.relatedSkillId, 200);
      });
    });

    group('Equatable', () {
      test('two notifications with same properties are equal', () {
        final notification1 = NotificationItem(
          id: 'id_1',
          type: NotificationType.taskReminder,
          title: 'Title',
          message: 'Message',
          timestamp: now,
        );
        final notification2 = NotificationItem(
          id: 'id_1',
          type: NotificationType.taskReminder,
          title: 'Title',
          message: 'Message',
          timestamp: now,
        );

        expect(notification1, equals(notification2));
        expect(notification1.hashCode, equals(notification2.hashCode));
      });

      test('two notifications with different properties are not equal', () {
        final notification1 = NotificationItem(
          id: 'id_1',
          type: NotificationType.taskReminder,
          title: 'Title 1',
          message: 'Message',
          timestamp: now,
        );
        final notification2 = NotificationItem(
          id: 'id_2',
          type: NotificationType.taskReminder,
          title: 'Title 2',
          message: 'Message',
          timestamp: now,
        );

        expect(notification1, isNot(equals(notification2)));
      });

      test('notifications with different isRead are not equal', () {
        final notification1 = NotificationItem(
          id: 'id_1',
          type: NotificationType.taskReminder,
          title: 'Title',
          message: 'Message',
          timestamp: now,
          isRead: false,
        );
        final notification2 = NotificationItem(
          id: 'id_1',
          type: NotificationType.taskReminder,
          title: 'Title',
          message: 'Message',
          timestamp: now,
          isRead: true,
        );

        expect(notification1, isNot(equals(notification2)));
      });
    });
  });

  group('NotificationType', () {
    group('displayName', () {
      test('taskReminder returns Task Reminder', () {
        expect(NotificationType.taskReminder.displayName, 'Task Reminder');
      });

      test('streakReminder returns Streak Reminder', () {
        expect(NotificationType.streakReminder.displayName, 'Streak Reminder');
      });

      test('practiceReminder returns Practice Reminder', () {
        expect(
          NotificationType.practiceReminder.displayName,
          'Practice Reminder',
        );
      });
    });

    group('icon', () {
      test('taskReminder returns clipboard icon', () {
        expect(NotificationType.taskReminder.icon, '📋');
      });

      test('streakReminder returns fire icon', () {
        expect(NotificationType.streakReminder.icon, '🔥');
      });

      test('practiceReminder returns target icon', () {
        expect(NotificationType.practiceReminder.icon, '🎯');
      });
    });

    group('all values exist', () {
      test('has exactly 3 values', () {
        expect(NotificationType.values.length, 3);
      });

      test('contains expected values', () {
        expect(
          NotificationType.values,
          contains(NotificationType.taskReminder),
        );
        expect(
          NotificationType.values,
          contains(NotificationType.streakReminder),
        );
        expect(
          NotificationType.values,
          contains(NotificationType.practiceReminder),
        );
      });
    });
  });
}
