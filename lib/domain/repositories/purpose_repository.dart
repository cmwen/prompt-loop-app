import '../entities/purpose.dart';

/// Purpose repository interface (Duckworth: connecting practice to meaning)
abstract class PurposeRepository {
  /// Get purpose for a skill
  Future<Purpose?> getPurposeForSkill(int skillId);

  /// Save or update purpose for a skill
  Future<int> savePurpose(Purpose purpose);

  /// Update purpose statement
  Future<void> updatePurpose(Purpose purpose);

  /// Delete purpose
  Future<void> deletePurpose(int skillId);
}
