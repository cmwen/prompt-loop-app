import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../../core/constants/db_constants.dart';
import '../../../core/utils/extensions.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/repositories/task_repository.dart';

/// Implementation of TaskRepository using SQLite
class TaskRepositoryImpl implements TaskRepository {
  final Database _db;

  TaskRepositoryImpl(this._db);

  @override
  Future<List<Task>> getTasksForSkill(int skillId) async {
    final maps = await _db.rawQuery(
      '''
      SELECT t.*, s.${DbConstants.colName} as skill_name, ss.${DbConstants.colName} as sub_skill_name
      FROM ${DbConstants.tableTasks} t
      LEFT JOIN ${DbConstants.tableSkills} s ON t.${DbConstants.colSkillId} = s.${DbConstants.colId}
      LEFT JOIN ${DbConstants.tableSubSkills} ss ON t.${DbConstants.colSubSkillId} = ss.${DbConstants.colId}
      WHERE t.${DbConstants.colSkillId} = ?
      ORDER BY t.${DbConstants.colCreatedAt} DESC
    ''',
      [skillId],
    );
    return maps.map(_mapToTask).toList();
  }

  @override
  Future<List<Task>> getTasksForDate(DateTime date) async {
    final dateStr = date.toDateString();
    final maps = await _db.rawQuery(
      '''
      SELECT t.*, s.${DbConstants.colName} as skill_name, ss.${DbConstants.colName} as sub_skill_name
      FROM ${DbConstants.tableTasks} t
      LEFT JOIN ${DbConstants.tableSkills} s ON t.${DbConstants.colSkillId} = s.${DbConstants.colId}
      LEFT JOIN ${DbConstants.tableSubSkills} ss ON t.${DbConstants.colSubSkillId} = ss.${DbConstants.colId}
      WHERE t.${DbConstants.colScheduledDate} = ?
      ORDER BY t.${DbConstants.colIsCompleted} ASC, t.${DbConstants.colDifficulty} ASC
    ''',
      [dateStr],
    );
    return maps.map(_mapToTask).toList();
  }

  @override
  Future<List<Task>> getTodaysTasks() async {
    return getTasksForDate(DateTime.now());
  }

  @override
  Future<List<Task>> getIncompleteTasks() async {
    final maps = await _db.rawQuery('''
      SELECT t.*, s.${DbConstants.colName} as skill_name, ss.${DbConstants.colName} as sub_skill_name
      FROM ${DbConstants.tableTasks} t
      LEFT JOIN ${DbConstants.tableSkills} s ON t.${DbConstants.colSkillId} = s.${DbConstants.colId}
      LEFT JOIN ${DbConstants.tableSubSkills} ss ON t.${DbConstants.colSubSkillId} = ss.${DbConstants.colId}
      WHERE t.${DbConstants.colIsCompleted} = 0
      ORDER BY t.${DbConstants.colScheduledDate} ASC, t.${DbConstants.colDifficulty} ASC
    ''');
    return maps.map(_mapToTask).toList();
  }

  @override
  Future<Task?> getTaskById(int id) async {
    final maps = await _db.rawQuery(
      '''
      SELECT t.*, s.${DbConstants.colName} as skill_name, ss.${DbConstants.colName} as sub_skill_name
      FROM ${DbConstants.tableTasks} t
      LEFT JOIN ${DbConstants.tableSkills} s ON t.${DbConstants.colSkillId} = s.${DbConstants.colId}
      LEFT JOIN ${DbConstants.tableSubSkills} ss ON t.${DbConstants.colSubSkillId} = ss.${DbConstants.colId}
      WHERE t.${DbConstants.colId} = ?
    ''',
      [id],
    );
    if (maps.isEmpty) return null;
    return _mapToTask(maps.first);
  }

  @override
  Future<int> createTask(Task task) async {
    return _db.insert(DbConstants.tableTasks, {
      DbConstants.colSkillId: task.skillId,
      DbConstants.colSubSkillId: task.subSkillId,
      DbConstants.colTitle: task.title,
      DbConstants.colDescription: task.description,
      DbConstants.colDurationMinutes: task.durationMinutes,
      DbConstants.colFrequency: task.frequency.name,
      DbConstants.colDifficulty: task.difficulty,
      DbConstants.colSuccessCriteria: jsonEncode(task.successCriteria),
      DbConstants.colIsCompleted: 0,
      DbConstants.colScheduledDate: task.scheduledDate?.toDateString(),
      DbConstants.colLlmGenerated: task.isLlmGenerated ? 1 : 0,
      DbConstants.colCreatedAt: DateTime.now().toIsoString(),
    });
  }

  @override
  Future<void> updateTask(Task task) async {
    await _db.update(
      DbConstants.tableTasks,
      {
        DbConstants.colTitle: task.title,
        DbConstants.colDescription: task.description,
        DbConstants.colDurationMinutes: task.durationMinutes,
        DbConstants.colFrequency: task.frequency.name,
        DbConstants.colDifficulty: task.difficulty,
        DbConstants.colSuccessCriteria: jsonEncode(task.successCriteria),
        DbConstants.colScheduledDate: task.scheduledDate?.toDateString(),
      },
      where: '${DbConstants.colId} = ?',
      whereArgs: [task.id],
    );
  }

  @override
  Future<void> completeTask(int id) async {
    await _db.update(
      DbConstants.tableTasks,
      {
        DbConstants.colIsCompleted: 1,
        DbConstants.colCompletedAt: DateTime.now().toIsoString(),
      },
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteTask(int id) async {
    await _db.delete(
      DbConstants.tableTasks,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<int>> createTasksFromGeneration(List<Task> tasks) async {
    final ids = <int>[];
    await _db.transaction((txn) async {
      for (final task in tasks) {
        final id = await txn.insert(DbConstants.tableTasks, {
          DbConstants.colSkillId: task.skillId,
          DbConstants.colSubSkillId: task.subSkillId,
          DbConstants.colTitle: task.title,
          DbConstants.colDescription: task.description,
          DbConstants.colDurationMinutes: task.durationMinutes,
          DbConstants.colFrequency: task.frequency.name,
          DbConstants.colDifficulty: task.difficulty,
          DbConstants.colSuccessCriteria: jsonEncode(task.successCriteria),
          DbConstants.colIsCompleted: 0,
          DbConstants.colScheduledDate: DateTime.now().toDateString(),
          DbConstants.colLlmGenerated: 1,
          DbConstants.colCreatedAt: DateTime.now().toIsoString(),
        });
        ids.add(id);
      }
    });
    return ids;
  }

  @override
  Future<void> scheduleTasksForToday(List<int> taskIds) async {
    final today = DateTime.now().toDateString();
    await _db.transaction((txn) async {
      for (final id in taskIds) {
        await txn.update(
          DbConstants.tableTasks,
          {DbConstants.colScheduledDate: today},
          where: '${DbConstants.colId} = ?',
          whereArgs: [id],
        );
      }
    });
  }

  Task _mapToTask(Map<String, dynamic> map) {
    List<String> successCriteria = [];
    final criteriaJson = map[DbConstants.colSuccessCriteria] as String?;
    if (criteriaJson != null && criteriaJson.isNotEmpty) {
      try {
        successCriteria = List<String>.from(jsonDecode(criteriaJson));
      } catch (_) {}
    }

    return Task(
      id: map[DbConstants.colId] as int,
      skillId: map[DbConstants.colSkillId] as int,
      subSkillId: map[DbConstants.colSubSkillId] as int?,
      title: map[DbConstants.colTitle] as String,
      description: map[DbConstants.colDescription] as String?,
      durationMinutes: map[DbConstants.colDurationMinutes] as int? ?? 15,
      frequency: TaskFrequency.fromString(
        map[DbConstants.colFrequency] as String? ?? 'daily',
      ),
      difficulty: map[DbConstants.colDifficulty] as int? ?? 5,
      successCriteria: successCriteria,
      isCompleted: (map[DbConstants.colIsCompleted] as int?) == 1,
      scheduledDate: (map[DbConstants.colScheduledDate] as String?)
          ?.tryParseDateTime(),
      completedAt: (map[DbConstants.colCompletedAt] as String?)
          ?.tryParseDateTime(),
      isLlmGenerated: (map[DbConstants.colLlmGenerated] as int?) == 1,
      createdAt:
          (map[DbConstants.colCreatedAt] as String).tryParseDateTime() ??
          DateTime.now(),
      skillName: map['skill_name'] as String?,
      subSkillName: map['sub_skill_name'] as String?,
    );
  }
}
