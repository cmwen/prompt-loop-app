import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prompt_loop/data/providers/repository_providers.dart';
import 'package:prompt_loop/domain/entities/app_settings.dart';

/// Current app settings state.
final settingsProvider =
    NotifierProvider<SettingsNotifier, AsyncValue<AppSettings>>(
      SettingsNotifier.new,
    );

/// Whether onboarding has been completed.
final onboardingCompletedProvider = Provider<AsyncValue<bool>>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.when(
    data: (s) => AsyncValue.data(s.onboardingCompleted),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

/// Current LLM mode.
final llmModeProvider = Provider<AsyncValue<LlmMode>>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.when(
    data: (s) => AsyncValue.data(s.llmMode),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

/// Settings state notifier for managing app settings.
class SettingsNotifier extends Notifier<AsyncValue<AppSettings>> {
  @override
  AsyncValue<AppSettings> build() {
    _loadSettings();
    return const AsyncValue.loading();
  }

  Future<void> _loadSettings() async {
    try {
      final repository = await ref.read(settingsRepositoryProvider.future);
      final settings = await repository.loadSettings();
      state = AsyncValue.data(settings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    await _loadSettings();
  }

  Future<void> updateSettings(AppSettings settings) async {
    try {
      final repository = await ref.read(settingsRepositoryProvider.future);
      final settingsMap = {
        'llm_mode': settings.llmMode.dbValue,
        'llm_provider': settings.llmProvider.name,
        'llm_model': settings.llmModel ?? '',
        'theme_mode': settings.themeMode.name,
        'notifications_enabled': settings.notificationsEnabled.toString(),
        'daily_reminder_time': settings.dailyReminderTime,
        'show_purpose_reminder': settings.showPurposeReminder.toString(),
        'streak_recovery_enabled': settings.streakRecoveryEnabled.toString(),
        'onboarding_completed': settings.onboardingCompleted.toString(),
        'ollama_base_url': settings.ollamaBaseUrl,
        'ollama_default_model': settings.ollamaDefaultModel ?? '',
      };
      await repository.saveSettings(settingsMap);
      state = AsyncValue.data(settings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> completeOnboarding() async {
    try {
      final repository = await ref.read(settingsRepositoryProvider.future);
      await repository.completeOnboarding();
      await _loadSettings();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> resetOnboarding() async {
    try {
      final repository = await ref.read(settingsRepositoryProvider.future);
      await repository.resetOnboarding();
      await _loadSettings();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setLlmMode(LlmMode mode) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(llmMode: mode));
    }
  }

  Future<void> setLlmProvider(LlmProvider provider) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(llmProvider: provider));
    }
  }

  Future<void> setDarkMode(bool isDark) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(
        current.copyWith(
          themeMode: isDark ? AppThemeMode.dark : AppThemeMode.light,
        ),
      );
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(themeMode: mode));
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(notificationsEnabled: enabled));
    }
  }

  Future<void> setDailyReminderTime(String? time) async {
    final current = state.value;
    if (current != null) {
      await updateSettings(current.copyWith(dailyReminderTime: time));
    }
  }

  Future<void> saveApiKey(String apiKey) async {
    try {
      final repository = await ref.read(settingsRepositoryProvider.future);
      await repository.saveSetting('llm_api_key', apiKey);
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getApiKey() async {
    try {
      final repository = await ref.read(settingsRepositoryProvider.future);
      return await repository.getSetting('llm_api_key');
    } catch (e) {
      return null;
    }
  }

  Future<void> clearApiKey() async {
    try {
      final repository = await ref.read(settingsRepositoryProvider.future);
      await repository.saveSetting('llm_api_key', '');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setOllamaBaseUrl(String url) async {
    final current = state.valueOrNull;
    if (current != null) {
      await updateSettings(current.copyWith(ollamaBaseUrl: url));
    }
  }

  Future<void> setOllamaDefaultModel(String? model) async {
    final current = state.valueOrNull;
    if (current != null) {
      await updateSettings(current.copyWith(ollamaDefaultModel: model));
    }
  }
}
