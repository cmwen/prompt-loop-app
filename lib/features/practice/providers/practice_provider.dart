import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deliberate_practice_app/data/providers/repository_providers.dart';
import 'package:deliberate_practice_app/domain/entities/practice_session.dart';
import 'package:deliberate_practice_app/domain/entities/streak.dart';
import 'package:deliberate_practice_app/domain/entities/struggle_entry.dart';

/// Provider for all practice sessions.
final practiceSessionsProvider =
    StateNotifierProvider<
      PracticeSessionsNotifier,
      AsyncValue<List<PracticeSession>>
    >((ref) {
      return PracticeSessionsNotifier(ref);
    });

/// Provider for practice sessions by task.
final sessionsByTaskProvider =
    FutureProvider.family<List<PracticeSession>, int>((ref, taskId) async {
      final repository = await ref.watch(practiceRepositoryProvider.future);
      return repository.getSessionsForTask(taskId);
    });

/// Provider for practice sessions by date range.
final sessionsByDateRangeProvider =
    FutureProvider.family<
      List<PracticeSession>,
      ({DateTime start, DateTime end})
    >((ref, range) async {
      final repository = await ref.watch(practiceRepositoryProvider.future);
      return repository.getSessionsForDateRange(range.start, range.end);
    });

/// Provider for today's sessions.
final todaysSessionsProvider = FutureProvider<List<PracticeSession>>((
  ref,
) async {
  final repository = await ref.watch(practiceRepositoryProvider.future);
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));
  return repository.getSessionsForDateRange(startOfDay, endOfDay);
});

/// Provider for streak for a skill.
final streakProvider = FutureProvider.family<Streak, int>((ref, skillId) async {
  final repository = await ref.watch(practiceRepositoryProvider.future);
  return repository.getStreak(skillId);
});

/// Provider for struggle entries by session.
final struggleEntriesBySessionProvider =
    FutureProvider.family<List<StruggleEntry>, int>((ref, sessionId) async {
      final repository = await ref.watch(practiceRepositoryProvider.future);
      return repository.getStruggleEntriesForSession(sessionId);
    });

/// Provider for total practice time today.
final todaysPracticeTimeProvider = FutureProvider<Duration>((ref) async {
  final sessions = await ref.watch(todaysSessionsProvider.future);
  final totalSeconds = sessions.fold<int>(
    0,
    (sum, s) => sum + (s.actualDurationSeconds ?? 0),
  );
  return Duration(seconds: totalSeconds);
});

/// Provider for total practice time this week.
final weeklyPracticeTimeProvider = FutureProvider<Duration>((ref) async {
  final repository = await ref.watch(practiceRepositoryProvider.future);
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
  final sessions = await repository.getSessionsForDateRange(start, now);
  final totalSeconds = sessions.fold<int>(
    0,
    (sum, s) => sum + (s.actualDurationSeconds ?? 0),
  );
  return Duration(seconds: totalSeconds);
});

/// Practice sessions state notifier.
class PracticeSessionsNotifier
    extends StateNotifier<AsyncValue<List<PracticeSession>>> {
  final Ref _ref;

  PracticeSessionsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadSessions();
  }

  Future<void> loadSessions() async {
    try {
      state = const AsyncValue.loading();
      final repository = await _ref.read(practiceRepositoryProvider.future);
      // Get sessions from the last 30 days by default
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      final sessions = await repository.getSessionsForDateRange(
        thirtyDaysAgo,
        now,
      );
      state = AsyncValue.data(sessions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<int> startSession(int taskId) async {
    try {
      final repository = await _ref.read(practiceRepositoryProvider.future);
      final id = await repository.startSession(taskId);
      await loadSessions();
      _invalidateRelatedProviders(taskId);
      return id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> completeSession({
    required int sessionId,
    required int durationSeconds,
    String? notes,
    int? rating,
    List<String>? criteriaMet,
  }) async {
    try {
      final repository = await _ref.read(practiceRepositoryProvider.future);
      await repository.completeSession(
        sessionId: sessionId,
        durationSeconds: durationSeconds,
        notes: notes,
        rating: rating,
        criteriaMet: criteriaMet,
      );
      await loadSessions();
      _invalidateRelatedProviders(0);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> createStruggleEntry({
    required int sessionId,
    required String content,
    String? wiseFeedback,
  }) async {
    try {
      final repository = await _ref.read(practiceRepositoryProvider.future);
      final id = await repository.saveStruggleEntry(
        sessionId: sessionId,
        content: content,
        wiseFeedback: wiseFeedback,
      );
      _ref.invalidate(struggleEntriesBySessionProvider(sessionId));
      return id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> recordPracticeForStreak(int skillId) async {
    try {
      final repository = await _ref.read(practiceRepositoryProvider.future);
      await repository.recordPracticeForStreak(skillId);
      _ref.invalidate(streakProvider(skillId));
    } catch (e) {
      rethrow;
    }
  }

  void _invalidateRelatedProviders(int taskId) {
    _ref.invalidate(sessionsByTaskProvider(taskId));
    _ref.invalidate(todaysSessionsProvider);
    _ref.invalidate(todaysPracticeTimeProvider);
    _ref.invalidate(weeklyPracticeTimeProvider);
  }
}
