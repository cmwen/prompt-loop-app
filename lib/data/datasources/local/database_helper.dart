import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/constants/db_constants.dart';

/// Database helper for SQLite operations
class DatabaseHelper {
  static Database? _database;

  DatabaseHelper._();

  /// Get the database instance
  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DbConstants.databaseName);

    return openDatabase(
      path,
      version: DbConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  static Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE ${DbConstants.tableUsers} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colCreatedAt} TEXT NOT NULL DEFAULT (datetime('now')),
        ${DbConstants.colOnboardingCompleted} INTEGER DEFAULT 0
      )
    ''');

    // Skills table
    await db.execute('''
      CREATE TABLE ${DbConstants.tableSkills} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colUserId} INTEGER NOT NULL DEFAULT 1,
        ${DbConstants.colName} TEXT NOT NULL,
        ${DbConstants.colDescription} TEXT,
        ${DbConstants.colCurrentLevel} TEXT CHECK(${DbConstants.colCurrentLevel} IN ('beginner','intermediate','advanced','expert')) DEFAULT 'beginner',
        ${DbConstants.colTargetLevel} TEXT CHECK(${DbConstants.colTargetLevel} IN ('beginner','intermediate','advanced','expert')),
        ${DbConstants.colIsArchived} INTEGER DEFAULT 0,
        ${DbConstants.colCreatedAt} TEXT NOT NULL DEFAULT (datetime('now')),
        ${DbConstants.colUpdatedAt} TEXT,
        FOREIGN KEY (${DbConstants.colUserId}) REFERENCES ${DbConstants.tableUsers}(${DbConstants.colId})
      )
    ''');

    // Sub-skills table
    await db.execute('''
      CREATE TABLE ${DbConstants.tableSubSkills} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colSkillId} INTEGER NOT NULL,
        ${DbConstants.colName} TEXT NOT NULL,
        ${DbConstants.colDescription} TEXT,
        ${DbConstants.colCurrentLevel} TEXT CHECK(${DbConstants.colCurrentLevel} IN ('beginner','intermediate','advanced','expert')) DEFAULT 'beginner',
        ${DbConstants.colTargetLevel} TEXT,
        ${DbConstants.colPriority} TEXT CHECK(${DbConstants.colPriority} IN ('high','medium','low')) DEFAULT 'medium',
        ${DbConstants.colProgressPercent} INTEGER DEFAULT 0 CHECK(${DbConstants.colProgressPercent} BETWEEN 0 AND 100),
        ${DbConstants.colLlmGenerated} INTEGER DEFAULT 0,
        ${DbConstants.colCreatedAt} TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (${DbConstants.colSkillId}) REFERENCES ${DbConstants.tableSkills}(${DbConstants.colId}) ON DELETE CASCADE
      )
    ''');

    // Purposes table (Duckworth addition)
    await db.execute('''
      CREATE TABLE ${DbConstants.tablePurposes} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colSkillId} INTEGER NOT NULL UNIQUE,
        ${DbConstants.colStatement} TEXT NOT NULL,
        ${DbConstants.colCategory} TEXT CHECK(${DbConstants.colCategory} IN (
          'personal_expression',
          'connecting_with_others',
          'career_growth',
          'self_improvement',
          'contributing_beyond_self',
          'other'
        )),
        ${DbConstants.colCreatedAt} TEXT NOT NULL DEFAULT (datetime('now')),
        ${DbConstants.colUpdatedAt} TEXT,
        FOREIGN KEY (${DbConstants.colSkillId}) REFERENCES ${DbConstants.tableSkills}(${DbConstants.colId}) ON DELETE CASCADE
      )
    ''');

    // Tasks table
    await db.execute('''
      CREATE TABLE ${DbConstants.tableTasks} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colSkillId} INTEGER NOT NULL,
        ${DbConstants.colSubSkillId} INTEGER,
        ${DbConstants.colTitle} TEXT NOT NULL,
        ${DbConstants.colDescription} TEXT,
        ${DbConstants.colDurationMinutes} INTEGER DEFAULT 15,
        ${DbConstants.colFrequency} TEXT CHECK(${DbConstants.colFrequency} IN ('daily','weekly','custom')) DEFAULT 'daily',
        ${DbConstants.colDifficulty} INTEGER DEFAULT 5 CHECK(${DbConstants.colDifficulty} BETWEEN 1 AND 10),
        ${DbConstants.colSuccessCriteria} TEXT,
        ${DbConstants.colIsCompleted} INTEGER DEFAULT 0,
        ${DbConstants.colScheduledDate} TEXT,
        ${DbConstants.colCompletedAt} TEXT,
        ${DbConstants.colLlmGenerated} INTEGER DEFAULT 0,
        ${DbConstants.colCreatedAt} TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (${DbConstants.colSkillId}) REFERENCES ${DbConstants.tableSkills}(${DbConstants.colId}) ON DELETE CASCADE,
        FOREIGN KEY (${DbConstants.colSubSkillId}) REFERENCES ${DbConstants.tableSubSkills}(${DbConstants.colId}) ON DELETE SET NULL
      )
    ''');

    // Practice sessions table
    await db.execute('''
      CREATE TABLE ${DbConstants.tablePracticeSessions} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colTaskId} INTEGER NOT NULL,
        ${DbConstants.colStartedAt} TEXT NOT NULL,
        ${DbConstants.colCompletedAt} TEXT,
        ${DbConstants.colActualDurationSeconds} INTEGER,
        ${DbConstants.colNotes} TEXT,
        ${DbConstants.colRating} INTEGER CHECK(${DbConstants.colRating} BETWEEN 1 AND 5),
        ${DbConstants.colCriteriaMet} TEXT,
        ${DbConstants.colCreatedAt} TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (${DbConstants.colTaskId}) REFERENCES ${DbConstants.tableTasks}(${DbConstants.colId}) ON DELETE CASCADE
      )
    ''');

    // Struggle entries table (Duckworth addition)
    await db.execute('''
      CREATE TABLE ${DbConstants.tableStruggleEntries} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colSessionId} INTEGER NOT NULL,
        ${DbConstants.colContent} TEXT NOT NULL,
        ${DbConstants.colWiseFeedback} TEXT,
        ${DbConstants.colCreatedAt} TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (${DbConstants.colSessionId}) REFERENCES ${DbConstants.tablePracticeSessions}(${DbConstants.colId}) ON DELETE CASCADE
      )
    ''');

    // Streaks table
    await db.execute('''
      CREATE TABLE ${DbConstants.tableStreaks} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colSkillId} INTEGER NOT NULL UNIQUE,
        ${DbConstants.colCurrentCount} INTEGER DEFAULT 0,
        ${DbConstants.colLongestCount} INTEGER DEFAULT 0,
        ${DbConstants.colLastPracticeDate} TEXT,
        ${DbConstants.colUpdatedAt} TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (${DbConstants.colSkillId}) REFERENCES ${DbConstants.tableSkills}(${DbConstants.colId}) ON DELETE CASCADE
      )
    ''');

    // Milestones table
    await db.execute('''
      CREATE TABLE ${DbConstants.tableMilestones} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colSkillId} INTEGER NOT NULL,
        ${DbConstants.colTitle} TEXT NOT NULL,
        ${DbConstants.colDescription} TEXT,
        ${DbConstants.colMilestoneType} TEXT CHECK(${DbConstants.colMilestoneType} IN ('practice_time','task_count','streak','custom')),
        ${DbConstants.colTargetValue} INTEGER NOT NULL,
        ${DbConstants.colCurrentValue} INTEGER DEFAULT 0,
        ${DbConstants.colAchievedAt} TEXT,
        ${DbConstants.colCreatedAt} TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (${DbConstants.colSkillId}) REFERENCES ${DbConstants.tableSkills}(${DbConstants.colId}) ON DELETE CASCADE
      )
    ''');

    // Settings table
    await db.execute('''
      CREATE TABLE ${DbConstants.tableSettings} (
        ${DbConstants.colKey} TEXT PRIMARY KEY,
        ${DbConstants.colValue} TEXT NOT NULL,
        ${DbConstants.colUpdatedAt} TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // Create indexes
    await db.execute(
        'CREATE INDEX idx_tasks_skill ON ${DbConstants.tableTasks}(${DbConstants.colSkillId})');
    await db.execute(
        'CREATE INDEX idx_tasks_scheduled ON ${DbConstants.tableTasks}(${DbConstants.colScheduledDate})');
    await db.execute(
        'CREATE INDEX idx_tasks_completed ON ${DbConstants.tableTasks}(${DbConstants.colIsCompleted})');
    await db.execute(
        'CREATE INDEX idx_sessions_task ON ${DbConstants.tablePracticeSessions}(${DbConstants.colTaskId})');
    await db.execute(
        'CREATE INDEX idx_sub_skills_skill ON ${DbConstants.tableSubSkills}(${DbConstants.colSkillId})');
    await db.execute(
        'CREATE INDEX idx_streaks_skill ON ${DbConstants.tableStreaks}(${DbConstants.colSkillId})');

    // Insert default settings
    await _insertDefaultSettings(db);

    // Insert default user
    await db.insert(DbConstants.tableUsers, {
      DbConstants.colOnboardingCompleted: 0,
    });
  }

  /// Insert default settings
  static Future<void> _insertDefaultSettings(Database db) async {
    final defaults = {
      'llm_mode': 'copy_paste',
      'llm_provider': 'openai',
      'theme_mode': 'system',
      'notification_enabled': 'true',
      'daily_reminder_time': '09:00',
      'show_purpose_reminder': 'true',
      'streak_recovery_enabled': 'true',
    };

    for (final entry in defaults.entries) {
      await db.insert(DbConstants.tableSettings, {
        DbConstants.colKey: entry.key,
        DbConstants.colValue: entry.value,
      });
    }
  }

  /// Handle database upgrades
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // Future migration logic goes here
    // if (oldVersion < 2) {
    //   // Migration from v1 to v2
    // }
  }

  /// Close the database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Delete the database (for testing/reset)
  static Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DbConstants.databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
