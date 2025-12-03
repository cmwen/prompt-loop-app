import 'package:flutter_test/flutter_test.dart';
import 'package:prompt_loop/domain/entities/task.dart';

void main() {
  group('Task', () {
    final now = DateTime(2024, 1, 15, 10, 30);

    group('constructor', () {
      test('creates task with required fields', () {
        final task = Task(skillId: 1, title: 'Practice scales', createdAt: now);

        expect(task.skillId, 1);
        expect(task.title, 'Practice scales');
        expect(task.createdAt, now);
        expect(task.id, isNull);
        expect(task.subSkillId, isNull);
        expect(task.description, isNull);
        expect(task.durationMinutes, 15);
        expect(task.frequency, TaskFrequency.daily);
        expect(task.difficulty, 5);
        expect(task.successCriteria, isEmpty);
        expect(task.isCompleted, isFalse);
        expect(task.scheduledDate, isNull);
        expect(task.completedAt, isNull);
        expect(task.isLlmGenerated, isFalse);
      });

      test('creates task with all fields', () {
        final scheduledDate = DateTime(2024, 1, 16);
        final completedAt = DateTime(2024, 1, 16, 14, 0);

        final task = Task(
          id: 42,
          skillId: 1,
          subSkillId: 5,
          title: 'Practice chord progressions',
          description: 'Focus on ii-V-I progressions',
          durationMinutes: 30,
          frequency: TaskFrequency.weekly,
          difficulty: 7,
          successCriteria: ['Play without mistakes', 'Maintain tempo'],
          isCompleted: true,
          scheduledDate: scheduledDate,
          completedAt: completedAt,
          isLlmGenerated: true,
          createdAt: now,
          skillName: 'Guitar',
          subSkillName: 'Chords',
        );

        expect(task.id, 42);
        expect(task.subSkillId, 5);
        expect(task.description, 'Focus on ii-V-I progressions');
        expect(task.durationMinutes, 30);
        expect(task.frequency, TaskFrequency.weekly);
        expect(task.difficulty, 7);
        expect(task.successCriteria, [
          'Play without mistakes',
          'Maintain tempo',
        ]);
        expect(task.isCompleted, isTrue);
        expect(task.scheduledDate, scheduledDate);
        expect(task.completedAt, completedAt);
        expect(task.isLlmGenerated, isTrue);
        expect(task.skillName, 'Guitar');
        expect(task.subSkillName, 'Chords');
      });
    });

    group('copyWith', () {
      late Task originalTask;

      setUp(() {
        originalTask = Task(
          id: 1,
          skillId: 10,
          subSkillId: 20,
          title: 'Original Task',
          description: 'Original description',
          durationMinutes: 15,
          frequency: TaskFrequency.daily,
          difficulty: 5,
          successCriteria: ['Criterion 1'],
          isCompleted: false,
          createdAt: now,
        );
      });

      test('returns identical task when no parameters provided', () {
        final copied = originalTask.copyWith();

        expect(copied, equals(originalTask));
        expect(copied.id, originalTask.id);
        expect(copied.title, originalTask.title);
        expect(copied.skillId, originalTask.skillId);
      });

      test('updates only specified fields', () {
        final copied = originalTask.copyWith(
          title: 'Updated Task',
          isCompleted: true,
          difficulty: 8,
        );

        expect(copied.title, 'Updated Task');
        expect(copied.isCompleted, isTrue);
        expect(copied.difficulty, 8);
        // Unchanged fields
        expect(copied.id, originalTask.id);
        expect(copied.skillId, originalTask.skillId);
        expect(copied.description, originalTask.description);
        expect(copied.frequency, originalTask.frequency);
      });

      test('can update scheduledDate and completedAt', () {
        final newScheduledDate = DateTime(2024, 2, 1);
        final newCompletedAt = DateTime(2024, 2, 1, 15, 0);

        final copied = originalTask.copyWith(
          scheduledDate: newScheduledDate,
          completedAt: newCompletedAt,
        );

        expect(copied.scheduledDate, newScheduledDate);
        expect(copied.completedAt, newCompletedAt);
      });

      test('can update success criteria list', () {
        final newCriteria = ['New criterion 1', 'New criterion 2'];

        final copied = originalTask.copyWith(successCriteria: newCriteria);

        expect(copied.successCriteria, newCriteria);
        expect(copied.successCriteria.length, 2);
      });
    });

    group('Equatable', () {
      test('two tasks with same properties are equal', () {
        final task1 = Task(id: 1, skillId: 10, title: 'Task', createdAt: now);
        final task2 = Task(id: 1, skillId: 10, title: 'Task', createdAt: now);

        expect(task1, equals(task2));
        expect(task1.hashCode, equals(task2.hashCode));
      });

      test('two tasks with different properties are not equal', () {
        final task1 = Task(id: 1, skillId: 10, title: 'Task 1', createdAt: now);
        final task2 = Task(id: 2, skillId: 10, title: 'Task 2', createdAt: now);

        expect(task1, isNot(equals(task2)));
      });

      test('skillName and subSkillName are not included in equality', () {
        final task1 = Task(
          id: 1,
          skillId: 10,
          title: 'Task',
          createdAt: now,
          skillName: 'Guitar',
        );
        final task2 = Task(
          id: 1,
          skillId: 10,
          title: 'Task',
          createdAt: now,
          skillName: 'Piano',
        );

        // They should be equal because skillName is not in props
        expect(task1, equals(task2));
      });
    });
  });

  group('TaskFrequency', () {
    group('displayName', () {
      test('daily returns Daily', () {
        expect(TaskFrequency.daily.displayName, 'Daily');
      });

      test('weekly returns Weekly', () {
        expect(TaskFrequency.weekly.displayName, 'Weekly');
      });

      test('custom returns Custom', () {
        expect(TaskFrequency.custom.displayName, 'Custom');
      });
    });

    group('fromString', () {
      test('parses daily', () {
        expect(TaskFrequency.fromString('daily'), TaskFrequency.daily);
      });

      test('parses weekly', () {
        expect(TaskFrequency.fromString('weekly'), TaskFrequency.weekly);
      });

      test('parses custom', () {
        expect(TaskFrequency.fromString('custom'), TaskFrequency.custom);
      });

      test('parses case insensitive', () {
        expect(TaskFrequency.fromString('DAILY'), TaskFrequency.daily);
        expect(TaskFrequency.fromString('Weekly'), TaskFrequency.weekly);
        expect(TaskFrequency.fromString('CUSTOM'), TaskFrequency.custom);
      });

      test('returns daily for unknown value', () {
        expect(TaskFrequency.fromString('unknown'), TaskFrequency.daily);
        expect(TaskFrequency.fromString(''), TaskFrequency.daily);
        expect(TaskFrequency.fromString('monthly'), TaskFrequency.daily);
      });
    });
  });
}
