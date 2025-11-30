import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deliberate_practice_app/data/providers/repository_providers.dart';
import 'package:deliberate_practice_app/domain/entities/practice_session.dart';
import 'package:deliberate_practice_app/domain/entities/streak.dart';
import 'package:deliberate_practice_app/domain/entities/struggle_entry.dart';

/// Provider for all practice sessions.
final practiceSessionsProvider = StateNotifierProvider<PracticeSessionsNotifier, AsyncValue<List<PracticeSession>>>((ref) {
  return PracticeSessionsNotifier(ref);
});

/// Provider for practice sessions by skill.
final sessionsBySkillProvider = FutureProvider.family<List<PracticeSession>, int>((ref, skillId) async {
  final repository = await ref.watch(practiceRepositoryProvider.future);
  return repository.getSessionsBySkill(skillId);
});

/// Provider for practice sessions by date range.
final sessionsByDateRangeProvider = FutureProvider.family<List<PracticeSession>, ({DateTime start, DateTime end})>((ref, range) async {
  final repository = await ref.watch(practiceRepositoryProvider.future);
  return repository.getSessionsByDateRange(range.start, range.end);
});

/// Provider for today's sessions.
final todaysSessionsProvider = FutureProvider<List<PracticeSession>>((ref) async {
  final repository = await ref.watch(practiceRepositoryProvider.future);
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));
  return repository.getSessionsByDateRange(startOfDay, endOfDay);
});

/// Provider for current streak for a skill.
final currentStreakProvider = FutureProvider.family<Streak?, int>((ref, skillId) async {
  final repository = await ref.watch(practiceRepositoryProvider.future);
  return repository.getCurrentStreak(skillId);
});

/// Provider for longest streak for a skill.
final longestStreakProvider = FutureProvider.family<Streak?, int>((ref, skillId) async {
  final repository = await ref.watch(practiceRepositoryProvider.future);
  return repository.getLongestStreak(skillId);
});

/// Provider for struggle entries by skill.
final struggleEntriesBySkillProvider = FutureProvider.family<List<StruggleEntry>, int>((ref, skillId) async {
  final repository = await ref.watch(practiceRepositoryProvider.future);
  return repository.getStruggleEntriesBySkill(skillId);
});

/// Provider for total practice time today.
final todaysPracticeTimeProvider = FutureProvider<Duration>((ref) async {
  final sessions = await ref.watch(todaysSessionsProvider.future);
  final totalMinutes = sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
  return Duration(minutes: totalMinutes);
});

/// Provider for total practice time this week.
final weeklyPracticeTimeProvider = FutureProvider<Duration>((ref) async {
  final repository = await ref.watch(practiceRepositoryProvider.future);
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
  final sessions = await repository.getSessionsByDateRange(start, now);
  final totalMinutes = sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
  return Duration(minutes: totalMinutes);
});

/// Practice sessions state notifier.
class PracticeSessionsNotifier extends StateNotifier<AsyncValue<List<PracticeSession>>> {
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
      final sessions = await repository.getSessionsByDateRange(thirtyDaysAgo, now);
      state = AsyncValue.data(sessions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<int> createSession(PracticeSession session) async {
    try {
      final repository = await _ref.read(practiceRepositoryProvider.future);
      final id = await repository.createSession(session);
      await loadSessions();
      _invalidateRelatedProviders(session.skillId);
      return id;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateSession(PracticeSession session) async {
    try {
      final repository = await _ref.read(practiceRepositoryProvider.future);
      await repository.updateSession(session);
      await loadSessions();
      _invalidateRelatedProviders(session.skillId);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> deleteSession(int id, int skillId) async {
    try {
      final repository = await _ref.read(practiceRepositoryProvider.future);
      await repository.deleteSession(id);
      await loadSessions();
      _invalidateRelatedProviders(skillId);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<int> createStruggleEntry(StruggleEntry entry) async {
    try {
      final repository = await _ref.read(practiceRepositoryProvider.future);
      final id = await repository.createStruggleEntry(entry);
      _ref.invalidate(struggleEntriesBySkillProvider(entry.skillId));
      return id;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateStruggleEntry(StruggleEntry entry) async {
    try {
      final repository = await _ref.read(practiceRepositoryProvider.future);
      await repository.updateStruggleEntry(entry);
      _ref.invalidate(struggleEntriesBySkillProvider(entry.skillId));
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> deleteStruggleEntry(int id, int skillId) async {
    try {
      final repository = await _ref.read(practiceRepositoryProvider.future);
      await repository.deleteStruggleEntry(id);
      _ref.invalidate(struggleEntriesBySkillProvider(skillId));
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateStreak(int skillId, {bool practiced = true}) async {
    try {
      final repository = await _ref.read(practiceRepositoryProvider.future);
      await repository.updateStreak(skillId, practiced: practiced);
      _ref.invalidate(currentStreakProvider(skillId));
      _ref.invalidate(longestStreakProvider(skillId));
    } catch (e) {
      rethrow;
    }
  }
  
  void _invalidateRelatedProviders(int skillId) {
    _ref.invalidate(sessionsBySkillProvider(skillId));
    _ref.invalidate(todaysSessionsProvider);
    _ref.invalidate(todaysPracticeTimeProvider);
    _ref.invalidate(weeklyPracticeTimeProvider);
    _ref.invalidate(currentStreakProvider(skillId));
  }
}
