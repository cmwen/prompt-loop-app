import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_loop/data/providers/repository_providers.dart';
import 'package:prompt_loop/domain/entities/purpose.dart';

/// Provider for all purposes.
final purposesProvider =
    NotifierProvider<PurposesNotifier, AsyncValue<List<Purpose>>>(
      PurposesNotifier.new,
    );

/// Provider for purpose by skill.
final purposeBySkillProvider = FutureProvider.family<Purpose?, int>((
  ref,
  skillId,
) async {
  final repository = await ref.watch(purposeRepositoryProvider.future);
  return repository.getPurposeForSkill(skillId);
});

/// Provider for purpose statistics.
final purposeStatsProvider = FutureProvider<PurposeStats>((ref) async {
  final purposes = ref.watch(purposesProvider);

  return purposes.when(
    data: (list) {
      final categoryCount = <PurposeCategory, int>{};
      for (final purpose in list) {
        categoryCount[purpose.category] =
            (categoryCount[purpose.category] ?? 0) + 1;
      }
      return PurposeStats(
        totalCount: list.length,
        categoryCount: categoryCount,
      );
    },
    loading: () => const PurposeStats(totalCount: 0, categoryCount: {}),
    error: (_, _) => const PurposeStats(totalCount: 0, categoryCount: {}),
  );
});

/// Statistics about purposes.
class PurposeStats {
  final int totalCount;
  final Map<PurposeCategory, int> categoryCount;

  const PurposeStats({required this.totalCount, required this.categoryCount});
}

/// Purposes state notifier.
class PurposesNotifier extends Notifier<AsyncValue<List<Purpose>>> {
  @override
  AsyncValue<List<Purpose>> build() {
    loadPurposes();
    return const AsyncValue.loading();
  }

  Future<void> loadPurposes() async {
    try {
      state = const AsyncValue.loading();
      final repository = await ref.read(purposeRepositoryProvider.future);
      final purposes = await repository.getAllPurposes();
      state = AsyncValue.data(purposes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<int> createPurpose(Purpose purpose) async {
    try {
      final repository = await ref.read(purposeRepositoryProvider.future);
      final id = await repository.savePurpose(purpose);
      await loadPurposes();
      ref.invalidate(purposeBySkillProvider(purpose.skillId));
      return id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePurpose(Purpose purpose) async {
    try {
      final repository = await ref.read(purposeRepositoryProvider.future);
      await repository.updatePurpose(purpose);
      await loadPurposes();
      ref.invalidate(purposeBySkillProvider(purpose.skillId));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePurpose(int id, int skillId) async {
    try {
      final repository = await ref.read(purposeRepositoryProvider.future);
      await repository.deletePurpose(id);
      await loadPurposes();
      ref.invalidate(purposeBySkillProvider(skillId));
    } catch (e) {
      rethrow;
    }
  }
}
