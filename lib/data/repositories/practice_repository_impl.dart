import 'dart:convert';
import 'dart:math';

import 'package:sqflite/sqflite.dart';

import '../../../core/constants/db_constants.dart';
import '../../../core/utils/extensions.dart';
import '../../../domain/entities/practice_session.dart';
import '../../../domain/entities/streak.dart';
import '../../../domain/entities/struggle_entry.dart';
import '../../../domain/repositories/practice_repository.dart';

/// Implementation of PracticeRepository using SQLite
class PracticeRepositoryImpl implements PracticeRepository {
  final Database _db;

  PracticeRepositoryImpl(this._db);

  @override
  Future<int> startSession(int taskId) async {
    final now = DateTime.now().toIsoString();
    return _db.insert(DbConstants.tablePracticeSessions, {
      DbConstants.colTaskId: taskId,
      DbConstants.colStartedAt: now,
      DbConstants.colCreatedAt: now,
    });
  }

  @override
  Future<void> completeSession({
    required int sessionId,
    required int durationSeconds,
    String? notes,
    int? rating,
    List<String>? criteriaMet,
  }) async {
    await _db.update(
      DbConstants.tablePracticeSessions,
      {
        DbConstants.colCompletedAt: DateTime.now().toIsoString(),
        DbConstants.colActualDurationSeconds: durationSeconds,
        DbConstants.colNotes: notes,
        DbConstants.colRating: rating,
        DbConstants.colCriteriaMet: criteriaMet != null
            ? jsonEncode(criteriaMet)
            : null,
      },
      where: '${DbConstants.colId} = ?',
      whereArgs: [sessionId],
    );
  }

  @override
  Future<PracticeSession?> getSessionById(int id) async {
    final maps = await _db.query(
      DbConstants.tablePracticeSessions,
      where: '${DbConstants.colId} = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return _mapToSession(maps.first);
  }

  @override
  Future<List<PracticeSession>> getSessionsForTask(int taskId) async {
    final maps = await _db.query(
      DbConstants.tablePracticeSessions,
      where: '${DbConstants.colTaskId} = ?',
      whereArgs: [taskId],
      orderBy: '${DbConstants.colStartedAt} DESC',
    );
    return maps.map(_mapToSession).toList();
  }

  @override
  Future<List<PracticeSession>> getSessionsForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final maps = await _db.query(
      DbConstants.tablePracticeSessions,
      where:
          '${DbConstants.colStartedAt} >= ? AND ${DbConstants.colStartedAt} <= ?',
      whereArgs: [start.toIsoString(), end.toIsoString()],
      orderBy: '${DbConstants.colStartedAt} DESC',
    );
    return maps.map(_mapToSession).toList();
  }

  @override
  Future<int> getTotalPracticeTime(int skillId) async {
    final result = await _db.rawQuery(
      '''
      SELECT SUM(ps.${DbConstants.colActualDurationSeconds}) as total
      FROM ${DbConstants.tablePracticeSessions} ps
      JOIN ${DbConstants.tableTasks} t ON ps.${DbConstants.colTaskId} = t.${DbConstants.colId}
      WHERE t.${DbConstants.colSkillId} = ?
      AND ps.${DbConstants.colCompletedAt} IS NOT NULL
    ''',
      [skillId],
    );

    if (result.isEmpty) return 0;
    return (result.first['total'] as int?) ?? 0;
  }

  @override
  Future<int> saveStruggleEntry({
    required int sessionId,
    required String content,
    String? wiseFeedback,
  }) async {
    return _db.insert(DbConstants.tableStruggleEntries, {
      DbConstants.colSessionId: sessionId,
      DbConstants.colContent: content,
      DbConstants.colWiseFeedback: wiseFeedback,
      DbConstants.colCreatedAt: DateTime.now().toIsoString(),
    });
  }

  @override
  Future<List<StruggleEntry>> getStruggleEntriesForSession(
    int sessionId,
  ) async {
    final maps = await _db.query(
      DbConstants.tableStruggleEntries,
      where: '${DbConstants.colSessionId} = ?',
      whereArgs: [sessionId],
      orderBy: '${DbConstants.colCreatedAt} DESC',
    );
    return maps.map(_mapToStruggleEntry).toList();
  }

  @override
  Future<Streak> getStreak(int skillId) async {
    final maps = await _db.query(
      DbConstants.tableStreaks,
      where: '${DbConstants.colSkillId} = ?',
      whereArgs: [skillId],
    );

    if (maps.isEmpty) {
      // Create new streak entry
      final now = DateTime.now().toIsoString();
      await _db.insert(DbConstants.tableStreaks, {
        DbConstants.colSkillId: skillId,
        DbConstants.colCurrentCount: 0,
        DbConstants.colLongestCount: 0,
        DbConstants.colUpdatedAt: now,
      });
      return Streak(
        skillId: skillId,
        currentCount: 0,
        longestCount: 0,
        updatedAt: DateTime.now(),
      );
    }

    return _mapToStreak(maps.first);
  }

  @override
  Future<void> recordPracticeForStreak(int skillId) async {
    final current = await getStreak(skillId);
    final now = DateTime.now();
    final today = now.toDateString();
    final yesterday = now.subtract(const Duration(days: 1)).toDateString();

    int newCount;
    if (current.lastPracticeDate?.toDateString() == yesterday) {
      // Continuing streak
      newCount = current.currentCount + 1;
    } else if (current.lastPracticeDate?.toDateString() == today) {
      // Already practiced today
      newCount = current.currentCount;
    } else {
      // Streak broken, but we recover gracefully (Duckworth: no punishment)
      newCount = 1;
    }

    final newLongest = max(newCount, current.longestCount);

    await _db.update(
      DbConstants.tableStreaks,
      {
        DbConstants.colCurrentCount: newCount,
        DbConstants.colLongestCount: newLongest,
        DbConstants.colLastPracticeDate: today,
        DbConstants.colUpdatedAt: now.toIsoString(),
      },
      where: '${DbConstants.colSkillId} = ?',
      whereArgs: [skillId],
    );
  }

  @override
  Future<List<Streak>> getAllStreaks() async {
    final maps = await _db.query(DbConstants.tableStreaks);
    return maps.map(_mapToStreak).toList();
  }

  @override
  Future<int> getCompletedTasksCount(int skillId) async {
    final result = await _db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM ${DbConstants.tableTasks}
      WHERE ${DbConstants.colSkillId} = ?
      AND ${DbConstants.colIsCompleted} = 1
    ''',
      [skillId],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  @override
  Future<int> getTotalTasksCount(int skillId) async {
    final result = await _db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM ${DbConstants.tableTasks}
      WHERE ${DbConstants.colSkillId} = ?
    ''',
      [skillId],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  @override
  Future<int> getCompletedTasksCountForDay(int skillId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final result = await _db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM ${DbConstants.tableTasks} t
      JOIN ${DbConstants.tablePracticeSessions} ps ON t.${DbConstants.colId} = ps.${DbConstants.colTaskId}
      WHERE t.${DbConstants.colSkillId} = ?
      AND ps.${DbConstants.colCompletedAt} >= ?
      AND ps.${DbConstants.colCompletedAt} < ?
    ''',
      [skillId, startOfDay.toIsoString(), endOfDay.toIsoString()],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  @override
  Future<double> getSkillProgressPercent(int skillId) async {
    // Calculate progress based on completed practice sessions vs total tasks
    final totalTasks = await getTotalTasksCount(skillId);
    if (totalTasks == 0) return 0.0;
    
    // Count unique tasks that have completed practice sessions
    final result = await _db.rawQuery(
      '''
      SELECT COUNT(DISTINCT ps.${DbConstants.colTaskId}) as completed_count
      FROM ${DbConstants.tablePracticeSessions} ps
      JOIN ${DbConstants.tableTasks} t ON ps.${DbConstants.colTaskId} = t.${DbConstants.colId}
      WHERE t.${DbConstants.colSkillId} = ?
      AND ps.${DbConstants.colCompletedAt} IS NOT NULL
    ''',
      [skillId],
    );
    
    final completedCount = (result.first['completed_count'] as int?) ?? 0;
    return ((completedCount / totalTasks) * 100).clamp(0, 100);
  }

  @override
  Future<List<Map<String, dynamic>>> getDailyProgressData(
    int skillId,
    int daysBack,
  ) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: daysBack));
    
    final result = await _db.rawQuery(
      '''
      SELECT 
        DATE(ps.${DbConstants.colCompletedAt}) as day,
        COUNT(DISTINCT ps.${DbConstants.colId}) as tasks_completed,
        SUM(ps.${DbConstants.colActualDurationSeconds}) as total_seconds
      FROM ${DbConstants.tablePracticeSessions} ps
      JOIN ${DbConstants.tableTasks} t ON ps.${DbConstants.colTaskId} = t.${DbConstants.colId}
      WHERE t.${DbConstants.colSkillId} = ?
      AND ps.${DbConstants.colCompletedAt} IS NOT NULL
      AND DATE(ps.${DbConstants.colCompletedAt}) >= DATE(?)
      AND DATE(ps.${DbConstants.colCompletedAt}) <= DATE(?)
      GROUP BY DATE(ps.${DbConstants.colCompletedAt})
      ORDER BY day DESC
    ''',
      [skillId, startDate.toIsoString(), endDate.toIsoString()],
    );
    
    return result;
  }

  PracticeSession _mapToSession(Map<String, dynamic> map) {
    List<String> criteriaMet = [];
    final criteriaJson = map[DbConstants.colCriteriaMet] as String?;
    if (criteriaJson != null && criteriaJson.isNotEmpty) {
      try {
        criteriaMet = List<String>.from(jsonDecode(criteriaJson));
      } catch (_) {}
    }

    return PracticeSession(
      id: map[DbConstants.colId] as int,
      taskId: map[DbConstants.colTaskId] as int,
      startedAt:
          (map[DbConstants.colStartedAt] as String).tryParseDateTime() ??
          DateTime.now(),
      completedAt: (map[DbConstants.colCompletedAt] as String?)
          ?.tryParseDateTime(),
      actualDurationSeconds: map[DbConstants.colActualDurationSeconds] as int?,
      notes: map[DbConstants.colNotes] as String?,
      rating: map[DbConstants.colRating] as int?,
      criteriaMet: criteriaMet,
      createdAt:
          (map[DbConstants.colCreatedAt] as String).tryParseDateTime() ??
          DateTime.now(),
    );
  }

  StruggleEntry _mapToStruggleEntry(Map<String, dynamic> map) {
    return StruggleEntry(
      id: map[DbConstants.colId] as int,
      sessionId: map[DbConstants.colSessionId] as int,
      content: map[DbConstants.colContent] as String,
      wiseFeedback: map[DbConstants.colWiseFeedback] as String?,
      createdAt:
          (map[DbConstants.colCreatedAt] as String).tryParseDateTime() ??
          DateTime.now(),
    );
  }

  Streak _mapToStreak(Map<String, dynamic> map) {
    return Streak(
      id: map[DbConstants.colId] as int,
      skillId: map[DbConstants.colSkillId] as int,
      currentCount: map[DbConstants.colCurrentCount] as int? ?? 0,
      longestCount: map[DbConstants.colLongestCount] as int? ?? 0,
      lastPracticeDate: (map[DbConstants.colLastPracticeDate] as String?)
          ?.tryParseDateTime(),
      updatedAt:
          (map[DbConstants.colUpdatedAt] as String).tryParseDateTime() ??
          DateTime.now(),
    );
  }
}
