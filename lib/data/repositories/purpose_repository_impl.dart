import 'package:sqflite/sqflite.dart';

import '../../../core/constants/db_constants.dart';
import '../../../core/utils/extensions.dart';
import '../../../domain/entities/purpose.dart';
import '../../../domain/repositories/purpose_repository.dart';

/// Implementation of PurposeRepository using SQLite
class PurposeRepositoryImpl implements PurposeRepository {
  final Database _db;

  PurposeRepositoryImpl(this._db);

  @override
  Future<Purpose?> getPurposeForSkill(int skillId) async {
    final maps = await _db.query(
      DbConstants.tablePurposes,
      where: '${DbConstants.colSkillId} = ?',
      whereArgs: [skillId],
    );
    if (maps.isEmpty) return null;
    return _mapToPurpose(maps.first);
  }

  @override
  Future<int> savePurpose(Purpose purpose) async {
    // Check if purpose already exists for this skill
    final existing = await getPurposeForSkill(purpose.skillId);

    if (existing != null) {
      // Update existing
      await _db.update(
        DbConstants.tablePurposes,
        {
          DbConstants.colStatement: purpose.statement,
          DbConstants.colCategory: purpose.category.dbValue,
          DbConstants.colUpdatedAt: DateTime.now().toIsoString(),
        },
        where: '${DbConstants.colSkillId} = ?',
        whereArgs: [purpose.skillId],
      );
      return existing.id!;
    } else {
      // Insert new
      return _db.insert(DbConstants.tablePurposes, {
        DbConstants.colSkillId: purpose.skillId,
        DbConstants.colStatement: purpose.statement,
        DbConstants.colCategory: purpose.category.dbValue,
        DbConstants.colCreatedAt: DateTime.now().toIsoString(),
      });
    }
  }

  @override
  Future<void> updatePurpose(Purpose purpose) async {
    await _db.update(
      DbConstants.tablePurposes,
      {
        DbConstants.colStatement: purpose.statement,
        DbConstants.colCategory: purpose.category.dbValue,
        DbConstants.colUpdatedAt: DateTime.now().toIsoString(),
      },
      where: '${DbConstants.colId} = ?',
      whereArgs: [purpose.id],
    );
  }

  @override
  Future<void> deletePurpose(int skillId) async {
    await _db.delete(
      DbConstants.tablePurposes,
      where: '${DbConstants.colSkillId} = ?',
      whereArgs: [skillId],
    );
  }

  Purpose _mapToPurpose(Map<String, dynamic> map) {
    return Purpose(
      id: map[DbConstants.colId] as int,
      skillId: map[DbConstants.colSkillId] as int,
      statement: map[DbConstants.colStatement] as String,
      category: PurposeCategory.fromString(
        map[DbConstants.colCategory] as String? ?? 'other',
      ),
      createdAt:
          (map[DbConstants.colCreatedAt] as String).tryParseDateTime() ??
          DateTime.now(),
      updatedAt: (map[DbConstants.colUpdatedAt] as String?)?.tryParseDateTime(),
    );
  }
}
