import '../entities/app_settings.dart';

/// Settings repository interface
abstract class SettingsRepository {
  /// Load all settings
  Future<AppSettings> loadSettings();

  /// Save a single setting
  Future<void> saveSetting(String key, String value);

  /// Save multiple settings
  Future<void> saveSettings(Map<String, String> settings);

  /// Get a single setting value
  Future<String?> getSetting(String key);

  /// Mark onboarding as completed
  Future<void> completeOnboarding();

  /// Reset onboarding status
  Future<void> resetOnboarding();

  /// Reset all settings to defaults
  Future<void> resetSettings();
}
