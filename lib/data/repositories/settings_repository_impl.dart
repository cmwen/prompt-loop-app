import 'package:sqflite/sqflite.dart';

import '../../../core/constants/db_constants.dart';
import '../../../core/utils/extensions.dart';
import '../../../domain/entities/app_settings.dart';
import '../../../domain/repositories/settings_repository.dart';

/// Implementation of SettingsRepository using SQLite
class SettingsRepositoryImpl implements SettingsRepository {
  final Database _db;

  SettingsRepositoryImpl(this._db);

  @override
  Future<AppSettings> loadSettings() async {
    final maps = await _db.query(DbConstants.tableSettings);

    final settingsMap = <String, String>{};
    for (final map in maps) {
      settingsMap[map[DbConstants.colKey] as String] =
          map[DbConstants.colValue] as String;
    }

    // Also check onboarding status from users table
    final users = await _db.query(DbConstants.tableUsers, limit: 1);
    final onboardingCompleted =
        users.isNotEmpty &&
        (users.first[DbConstants.colOnboardingCompleted] as int?) == 1;

    return AppSettings(
      llmMode: LlmMode.fromString(settingsMap['llm_mode'] ?? 'copy_paste'),
      llmProvider: LlmProvider.fromString(
        settingsMap['llm_provider'] ?? 'openai',
      ),
      themeMode: AppThemeMode.fromString(settingsMap['theme_mode'] ?? 'system'),
      notificationsEnabled:
          settingsMap['notification_enabled']?.toLowerCase() == 'true',
      dailyReminderTime: settingsMap['daily_reminder_time'] ?? '09:00',
      showPurposeReminder:
          settingsMap['show_purpose_reminder']?.toLowerCase() != 'false',
      streakRecoveryEnabled:
          settingsMap['streak_recovery_enabled']?.toLowerCase() != 'false',
      onboardingCompleted: onboardingCompleted,
      ollamaBaseUrl: settingsMap['ollama_base_url'] ?? 'http://localhost:11434',
      ollamaDefaultModel:
          settingsMap['ollama_default_model']?.isNotEmpty == true
          ? settingsMap['ollama_default_model']
          : null,
    );
  }

  @override
  Future<void> saveSetting(String key, String value) async {
    await _db.insert(DbConstants.tableSettings, {
      DbConstants.colKey: key,
      DbConstants.colValue: value,
      DbConstants.colUpdatedAt: DateTime.now().toIsoString(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> saveSettings(Map<String, String> settings) async {
    await _db.transaction((txn) async {
      for (final entry in settings.entries) {
        await txn.insert(DbConstants.tableSettings, {
          DbConstants.colKey: entry.key,
          DbConstants.colValue: entry.value,
          DbConstants.colUpdatedAt: DateTime.now().toIsoString(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  @override
  Future<String?> getSetting(String key) async {
    final maps = await _db.query(
      DbConstants.tableSettings,
      where: '${DbConstants.colKey} = ?',
      whereArgs: [key],
    );
    if (maps.isEmpty) return null;
    return maps.first[DbConstants.colValue] as String?;
  }

  @override
  Future<void> completeOnboarding() async {
    await _db.update(DbConstants.tableUsers, {
      DbConstants.colOnboardingCompleted: 1,
    });
  }

  @override
  Future<void> resetOnboarding() async {
    await _db.update(DbConstants.tableUsers, {
      DbConstants.colOnboardingCompleted: 0,
    });
  }

  @override
  Future<void> resetSettings() async {
    await _db.delete(DbConstants.tableSettings);

    // Re-insert defaults
    final defaults = {
      'llm_mode': 'copy_paste',
      'llm_provider': 'openai',
      'theme_mode': 'system',
      'notification_enabled': 'true',
      'daily_reminder_time': '09:00',
      'show_purpose_reminder': 'true',
      'streak_recovery_enabled': 'true',
    };

    await saveSettings(defaults);
  }
}
