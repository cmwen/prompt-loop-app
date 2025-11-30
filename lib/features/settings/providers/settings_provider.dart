import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deliberate_practice_app/data/providers/repository_providers.dart';
import 'package:deliberate_practice_app/domain/entities/app_settings.dart';

/// Current app settings state.
final settingsProvider = StateNotifierProvider<SettingsNotifier, AsyncValue<AppSettings>>((ref) {
  return SettingsNotifier(ref);
});

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
class SettingsNotifier extends StateNotifier<AsyncValue<AppSettings>> {
  final Ref _ref;
  
  SettingsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    try {
      final repository = await _ref.read(settingsRepositoryProvider.future);
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
      final repository = await _ref.read(settingsRepositoryProvider.future);
      await repository.saveSettings(settings);
      state = AsyncValue.data(settings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> completeOnboarding() async {
    final current = state.valueOrNull;
    if (current != null) {
      await updateSettings(current.copyWith(hasCompletedOnboarding: true));
    }
  }
  
  Future<void> setLlmMode(LlmMode mode) async {
    final current = state.valueOrNull;
    if (current != null) {
      await updateSettings(current.copyWith(llmMode: mode));
    }
  }
  
  Future<void> setLlmProvider(LlmProvider provider) async {
    final current = state.valueOrNull;
    if (current != null) {
      await updateSettings(current.copyWith(llmProvider: provider));
    }
  }
  
  Future<void> setDarkMode(bool isDark) async {
    final current = state.valueOrNull;
    if (current != null) {
      await updateSettings(current.copyWith(isDarkMode: isDark));
    }
  }
  
  Future<void> setNotificationsEnabled(bool enabled) async {
    final current = state.valueOrNull;
    if (current != null) {
      await updateSettings(current.copyWith(notificationsEnabled: enabled));
    }
  }
  
  Future<void> setDailyReminderTime(String? time) async {
    final current = state.valueOrNull;
    if (current != null) {
      await updateSettings(current.copyWith(dailyReminderTime: time));
    }
  }
  
  Future<void> saveApiKey(String apiKey) async {
    try {
      final repository = await _ref.read(settingsRepositoryProvider.future);
      await repository.saveApiKey(apiKey);
    } catch (e) {
      // Handle error - might want to show snackbar
      rethrow;
    }
  }
  
  Future<String?> getApiKey() async {
    try {
      final repository = await _ref.read(settingsRepositoryProvider.future);
      return await repository.getApiKey();
    } catch (e) {
      return null;
    }
  }
  
  Future<void> clearApiKey() async {
    try {
      final repository = await _ref.read(settingsRepositoryProvider.future);
      await repository.clearApiKey();
    } catch (e) {
      rethrow;
    }
  }
}
