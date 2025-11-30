import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deliberate_practice_app/data/providers/repository_providers.dart';
import 'package:deliberate_practice_app/domain/entities/purpose.dart';

/// Provider for all purposes.
final purposesProvider = StateNotifierProvider<PurposesNotifier, AsyncValue<List<Purpose>>>((ref) {
  return PurposesNotifier(ref);
});

/// Provider for purposes by skill.
final purposesBySkillProvider = FutureProvider.family<List<Purpose>, int>((ref, skillId) async {
  final repository = await ref.watch(purposeRepositoryProvider.future);
  return repository.getPurposesBySkill(skillId);
});

/// Provider for a random purpose reminder for a skill.
final purposeReminderProvider = FutureProvider.family<Purpose?, int>((ref, skillId) async {
  final purposes = await ref.watch(purposesBySkillProvider(skillId).future);
  if (purposes.isEmpty) return null;
  
  // Return a random purpose
  purposes.shuffle();
  return purposes.first;
});

/// Provider for purpose statistics.
final purposeStatsProvider = FutureProvider<PurposeStats>((ref) async {
  final purposes = ref.watch(purposesProvider);
  
  return purposes.when(
    data: (list) {
      final categoryCount = <PurposeCategory, int>{};
      for (final purpose in list) {
        categoryCount[purpose.category] = (categoryCount[purpose.category] ?? 0) + 1;
      }
      return PurposeStats(
        totalCount: list.length,
        categoryCount: categoryCount,
      );
    },
    loading: () => const PurposeStats(totalCount: 0, categoryCount: {}),
    error: (_, __) => const PurposeStats(totalCount: 0, categoryCount: {}),
  );
});

/// Statistics about purposes.
class PurposeStats {
  final int totalCount;
  final Map<PurposeCategory, int> categoryCount;
  
  const PurposeStats({
    required this.totalCount,
    required this.categoryCount,
  });
}

/// Purposes state notifier.
class PurposesNotifier extends StateNotifier<AsyncValue<List<Purpose>>> {
  final Ref _ref;
  
  PurposesNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadPurposes();
  }
  
  Future<void> loadPurposes() async {
    try {
      state = const AsyncValue.loading();
      final repository = await _ref.read(purposeRepositoryProvider.future);
      final purposes = await repository.getAllPurposes();
      state = AsyncValue.data(purposes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<int> createPurpose(Purpose purpose) async {
    try {
      final repository = await _ref.read(purposeRepositoryProvider.future);
      final id = await repository.createPurpose(purpose);
      await loadPurposes();
      _ref.invalidate(purposesBySkillProvider(purpose.skillId));
      _ref.invalidate(purposeReminderProvider(purpose.skillId));
      return id;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updatePurpose(Purpose purpose) async {
    try {
      final repository = await _ref.read(purposeRepositoryProvider.future);
      await repository.updatePurpose(purpose);
      await loadPurposes();
      _ref.invalidate(purposesBySkillProvider(purpose.skillId));
      _ref.invalidate(purposeReminderProvider(purpose.skillId));
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> deletePurpose(int id, int skillId) async {
    try {
      final repository = await _ref.read(purposeRepositoryProvider.future);
      await repository.deletePurpose(id);
      await loadPurposes();
      _ref.invalidate(purposesBySkillProvider(skillId));
      _ref.invalidate(purposeReminderProvider(skillId));
    } catch (e) {
      rethrow;
    }
  }
}
