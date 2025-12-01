import '../entities/skill.dart';
import '../entities/sub_skill.dart';

/// Skill repository interface
abstract class SkillRepository {
  /// Get all skills (non-archived)
  Future<List<Skill>> getAllSkills();

  /// Get all archived skills
  Future<List<Skill>> getArchivedSkills();

  /// Get skill by ID
  Future<Skill?> getSkillById(int id);

  /// Get skill by name
  Future<Skill?> getSkillByName(String name);

  /// Create a new skill
  Future<int> createSkill(Skill skill);

  /// Update an existing skill
  Future<void> updateSkill(Skill skill);

  /// Archive a skill
  Future<void> archiveSkill(int id);

  /// Restore an archived skill
  Future<void> restoreSkill(int id);

  /// Delete a skill permanently
  Future<void> deleteSkill(int id);

  /// Get sub-skills for a skill
  Future<List<SubSkill>> getSubSkills(int skillId);

  /// Create a sub-skill
  Future<int> createSubSkill(SubSkill subSkill);

  /// Update a sub-skill
  Future<void> updateSubSkill(SubSkill subSkill);

  /// Delete a sub-skill
  Future<void> deleteSubSkill(int id);

  /// Create skill with sub-skills from LLM analysis
  Future<int> createSkillFromAnalysis({
    required String name,
    String? description,
    required List<SubSkill> subSkills,
  });
}
