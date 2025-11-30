import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deliberate_practice_app/data/providers/repository_providers.dart';
import 'package:deliberate_practice_app/domain/entities/skill.dart';
import 'package:deliberate_practice_app/domain/entities/sub_skill.dart';

/// Provider for the list of all active skills.
final skillsProvider =
    StateNotifierProvider<SkillsNotifier, AsyncValue<List<Skill>>>((ref) {
      return SkillsNotifier(ref);
    });

/// Provider for a single skill by ID.
final skillByIdProvider = Provider.family<AsyncValue<Skill?>, int>((ref, id) {
  final skills = ref.watch(skillsProvider);
  return skills.when(
    data: (list) => AsyncValue.data(list.where((s) => s.id == id).firstOrNull),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

/// Provider for sub-skills of a specific skill.
final subSkillsProvider = FutureProvider.family<List<SubSkill>, int>((
  ref,
  skillId,
) async {
  final repository = await ref.watch(skillRepositoryProvider.future);
  return repository.getSubSkills(skillId);
});

/// Skills state notifier.
class SkillsNotifier extends StateNotifier<AsyncValue<List<Skill>>> {
  final Ref _ref;

  SkillsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadSkills();
  }

  Future<void> loadSkills() async {
    try {
      state = const AsyncValue.loading();
      final repository = await _ref.read(skillRepositoryProvider.future);
      final skills = await repository.getAllSkills();
      state = AsyncValue.data(skills);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<int> createSkill(Skill skill) async {
    try {
      final repository = await _ref.read(skillRepositoryProvider.future);
      final id = await repository.createSkill(skill);
      await loadSkills();
      return id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSkill(Skill skill) async {
    try {
      final repository = await _ref.read(skillRepositoryProvider.future);
      await repository.updateSkill(skill);
      await loadSkills();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSkill(int id) async {
    try {
      final repository = await _ref.read(skillRepositoryProvider.future);
      await repository.deleteSkill(id);
      await loadSkills();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> archiveSkill(int id) async {
    try {
      final repository = await _ref.read(skillRepositoryProvider.future);
      await repository.archiveSkill(id);
      await loadSkills();
    } catch (e) {
      rethrow;
    }
  }

  Future<int> createSubSkill(SubSkill subSkill) async {
    try {
      final repository = await _ref.read(skillRepositoryProvider.future);
      final id = await repository.createSubSkill(subSkill);
      // Invalidate sub-skills provider for this skill
      _ref.invalidate(subSkillsProvider(subSkill.skillId));
      return id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSubSkill(SubSkill subSkill) async {
    try {
      final repository = await _ref.read(skillRepositoryProvider.future);
      await repository.updateSubSkill(subSkill);
      _ref.invalidate(subSkillsProvider(subSkill.skillId));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSubSkill(int id, int skillId) async {
    try {
      final repository = await _ref.read(skillRepositoryProvider.future);
      await repository.deleteSubSkill(id);
      _ref.invalidate(subSkillsProvider(skillId));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSubSkillProgress(
    int subSkillId,
    int skillId,
    int progress,
  ) async {
    try {
      final repository = await _ref.read(skillRepositoryProvider.future);
      final subSkills = await repository.getSubSkills(skillId);
      final subSkill = subSkills.firstWhere((s) => s.id == subSkillId);
      await repository.updateSubSkill(
        subSkill.copyWith(progressPercent: progress),
      );
      _ref.invalidate(subSkillsProvider(skillId));
      await loadSkills();
    } catch (e) {
      rethrow;
    }
  }
}
