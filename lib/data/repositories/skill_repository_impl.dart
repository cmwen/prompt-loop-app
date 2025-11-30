import 'package:sqflite/sqflite.dart';

import '../../../core/constants/db_constants.dart';
import '../../../core/utils/extensions.dart';
import '../../../domain/entities/skill.dart';
import '../../../domain/entities/sub_skill.dart';
import '../../../domain/repositories/skill_repository.dart';

/// Implementation of SkillRepository using SQLite
class SkillRepositoryImpl implements SkillRepository {
  final Database _db;

  SkillRepositoryImpl(this._db);

  @override
  Future<List<Skill>> getAllSkills() async {
    final maps = await _db.query(
      DbConstants.tableSkills,
      where: '${DbConstants.colIsArchived} = ?',
      whereArgs: [0],
      orderBy: '${DbConstants.colCreatedAt} DESC',
    );
    return maps.map(_mapToSkill).toList();
  }

  @override
  Future<List<Skill>> getArchivedSkills() async {
    final maps = await _db.query(
      DbConstants.tableSkills,
      where: '${DbConstants.colIsArchived} = ?',
      whereArgs: [1],
      orderBy: '${DbConstants.colCreatedAt} DESC',
    );
    return maps.map(_mapToSkill).toList();
  }

  @override
  Future<Skill?> getSkillById(int id) async {
    final maps = await _db.query(
      DbConstants.tableSkills,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return _mapToSkill(maps.first);
  }

  @override
  Future<int> createSkill(Skill skill) async {
    final now = DateTime.now().toIsoString();
    return _db.insert(DbConstants.tableSkills, {
      DbConstants.colName: skill.name,
      DbConstants.colDescription: skill.description,
      DbConstants.colCurrentLevel: skill.currentLevel.name,
      DbConstants.colTargetLevel: skill.targetLevel?.name,
      DbConstants.colIsArchived: skill.isArchived ? 1 : 0,
      DbConstants.colCreatedAt: now,
    });
  }

  @override
  Future<void> updateSkill(Skill skill) async {
    await _db.update(
      DbConstants.tableSkills,
      {
        DbConstants.colName: skill.name,
        DbConstants.colDescription: skill.description,
        DbConstants.colCurrentLevel: skill.currentLevel.name,
        DbConstants.colTargetLevel: skill.targetLevel?.name,
        DbConstants.colIsArchived: skill.isArchived ? 1 : 0,
        DbConstants.colUpdatedAt: DateTime.now().toIsoString(),
      },
      where: '${DbConstants.colId} = ?',
      whereArgs: [skill.id],
    );
  }

  @override
  Future<void> archiveSkill(int id) async {
    await _db.update(
      DbConstants.tableSkills,
      {
        DbConstants.colIsArchived: 1,
        DbConstants.colUpdatedAt: DateTime.now().toIsoString(),
      },
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> restoreSkill(int id) async {
    await _db.update(
      DbConstants.tableSkills,
      {
        DbConstants.colIsArchived: 0,
        DbConstants.colUpdatedAt: DateTime.now().toIsoString(),
      },
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteSkill(int id) async {
    await _db.delete(
      DbConstants.tableSkills,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<SubSkill>> getSubSkills(int skillId) async {
    final maps = await _db.query(
      DbConstants.tableSubSkills,
      where: '${DbConstants.colSkillId} = ?',
      whereArgs: [skillId],
      orderBy:
          '${DbConstants.colPriority} ASC, ${DbConstants.colCreatedAt} ASC',
    );
    return maps.map(_mapToSubSkill).toList();
  }

  @override
  Future<int> createSubSkill(SubSkill subSkill) async {
    return _db.insert(DbConstants.tableSubSkills, {
      DbConstants.colSkillId: subSkill.skillId,
      DbConstants.colName: subSkill.name,
      DbConstants.colDescription: subSkill.description,
      DbConstants.colCurrentLevel: subSkill.currentLevel.name,
      DbConstants.colTargetLevel: subSkill.targetLevel?.name,
      DbConstants.colPriority: subSkill.priority.name,
      DbConstants.colProgressPercent: subSkill.progressPercent,
      DbConstants.colLlmGenerated: subSkill.isLlmGenerated ? 1 : 0,
      DbConstants.colCreatedAt: DateTime.now().toIsoString(),
    });
  }

  @override
  Future<void> updateSubSkill(SubSkill subSkill) async {
    await _db.update(
      DbConstants.tableSubSkills,
      {
        DbConstants.colName: subSkill.name,
        DbConstants.colDescription: subSkill.description,
        DbConstants.colCurrentLevel: subSkill.currentLevel.name,
        DbConstants.colTargetLevel: subSkill.targetLevel?.name,
        DbConstants.colPriority: subSkill.priority.name,
        DbConstants.colProgressPercent: subSkill.progressPercent,
      },
      where: '${DbConstants.colId} = ?',
      whereArgs: [subSkill.id],
    );
  }

  @override
  Future<void> deleteSubSkill(int id) async {
    await _db.delete(
      DbConstants.tableSubSkills,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> createSkillFromAnalysis({
    required String name,
    String? description,
    required List<SubSkill> subSkills,
  }) async {
    return _db.transaction((txn) async {
      // Create skill
      final skillId = await txn.insert(DbConstants.tableSkills, {
        DbConstants.colName: name,
        DbConstants.colDescription: description,
        DbConstants.colCurrentLevel: SkillLevel.beginner.name,
        DbConstants.colIsArchived: 0,
        DbConstants.colCreatedAt: DateTime.now().toIsoString(),
      });

      // Create sub-skills
      for (final subSkill in subSkills) {
        await txn.insert(DbConstants.tableSubSkills, {
          DbConstants.colSkillId: skillId,
          DbConstants.colName: subSkill.name,
          DbConstants.colDescription: subSkill.description,
          DbConstants.colCurrentLevel: subSkill.currentLevel.name,
          DbConstants.colTargetLevel: subSkill.targetLevel?.name,
          DbConstants.colPriority: subSkill.priority.name,
          DbConstants.colProgressPercent: 0,
          DbConstants.colLlmGenerated: 1,
          DbConstants.colCreatedAt: DateTime.now().toIsoString(),
        });
      }

      // Create streak entry for skill
      await txn.insert(DbConstants.tableStreaks, {
        DbConstants.colSkillId: skillId,
        DbConstants.colCurrentCount: 0,
        DbConstants.colLongestCount: 0,
        DbConstants.colUpdatedAt: DateTime.now().toIsoString(),
      });

      return skillId;
    });
  }

  Skill _mapToSkill(Map<String, dynamic> map) {
    return Skill(
      id: map[DbConstants.colId] as int,
      name: map[DbConstants.colName] as String,
      description: map[DbConstants.colDescription] as String?,
      currentLevel: SkillLevel.fromString(
        map[DbConstants.colCurrentLevel] as String? ?? 'beginner',
      ),
      targetLevel: map[DbConstants.colTargetLevel] != null
          ? SkillLevel.fromString(map[DbConstants.colTargetLevel] as String)
          : null,
      isArchived: (map[DbConstants.colIsArchived] as int?) == 1,
      createdAt:
          (map[DbConstants.colCreatedAt] as String).tryParseDateTime() ??
          DateTime.now(),
      updatedAt: (map[DbConstants.colUpdatedAt] as String?)?.tryParseDateTime(),
    );
  }

  SubSkill _mapToSubSkill(Map<String, dynamic> map) {
    return SubSkill(
      id: map[DbConstants.colId] as int,
      skillId: map[DbConstants.colSkillId] as int,
      name: map[DbConstants.colName] as String,
      description: map[DbConstants.colDescription] as String?,
      currentLevel: SkillLevel.fromString(
        map[DbConstants.colCurrentLevel] as String? ?? 'beginner',
      ),
      targetLevel: map[DbConstants.colTargetLevel] != null
          ? SkillLevel.fromString(map[DbConstants.colTargetLevel] as String)
          : null,
      priority: Priority.fromString(
        map[DbConstants.colPriority] as String? ?? 'medium',
      ),
      progressPercent: map[DbConstants.colProgressPercent] as int? ?? 0,
      isLlmGenerated: (map[DbConstants.colLlmGenerated] as int?) == 1,
      createdAt:
          (map[DbConstants.colCreatedAt] as String).tryParseDateTime() ??
          DateTime.now(),
    );
  }
}
