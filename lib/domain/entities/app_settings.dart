import 'package:equatable/equatable.dart';

/// LLM mode selection
enum LlmMode {
  copyPaste,
  ollama;

  String get displayName {
    switch (this) {
      case LlmMode.copyPaste:
        return 'Copy-Paste';
      case LlmMode.ollama:
        return 'Ollama';
    }
  }

  String get dbValue {
    switch (this) {
      case LlmMode.copyPaste:
        return 'copy_paste';
      case LlmMode.ollama:
        return 'ollama';
    }
  }

  static LlmMode fromString(String value) {
    switch (value) {
      case 'ollama':
        return LlmMode.ollama;
      case 'copy_paste':
      default:
        return LlmMode.copyPaste;
    }
  }
}

/// LLM provider options
enum LlmProvider {
  openai,
  anthropic,
  google;

  String get displayName {
    switch (this) {
      case LlmProvider.openai:
        return 'OpenAI';
      case LlmProvider.anthropic:
        return 'Anthropic';
      case LlmProvider.google:
        return 'Google';
    }
  }

  static LlmProvider fromString(String value) {
    return LlmProvider.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => LlmProvider.openai,
    );
  }
}

/// App theme mode
enum AppThemeMode {
  light,
  dark,
  system;

  String get displayName {
    switch (this) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System Default';
    }
  }

  String get description {
    switch (this) {
      case AppThemeMode.light:
        return 'Always use light theme';
      case AppThemeMode.dark:
        return 'Always use dark theme';
      case AppThemeMode.system:
        return 'Follow system settings';
    }
  }

  static AppThemeMode fromString(String value) {
    return AppThemeMode.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => AppThemeMode.system,
    );
  }
}

/// App settings entity
class AppSettings extends Equatable {
  final LlmMode llmMode;
  final LlmProvider llmProvider;
  final String? llmModel;
  final AppThemeMode themeMode;
  final bool notificationsEnabled;
  final String dailyReminderTime;
  final bool showPurposeReminder;
  final bool streakRecoveryEnabled;
  final bool onboardingCompleted;

  // Ollama-specific settings
  final String ollamaBaseUrl;
  final String? ollamaDefaultModel;

  const AppSettings({
    this.llmMode = LlmMode.copyPaste,
    this.llmProvider = LlmProvider.openai,
    this.llmModel,
    this.themeMode = AppThemeMode.system,
    this.notificationsEnabled = true,
    this.dailyReminderTime = '09:00',
    this.showPurposeReminder = true,
    this.streakRecoveryEnabled = true,
    this.onboardingCompleted = false,
    this.ollamaBaseUrl = 'http://localhost:11434',
    this.ollamaDefaultModel,
  });

  bool get isDarkMode => themeMode == AppThemeMode.dark;

  /// Create a copy with modified fields
  AppSettings copyWith({
    LlmMode? llmMode,
    LlmProvider? llmProvider,
    String? llmModel,
    AppThemeMode? themeMode,
    bool? notificationsEnabled,
    String? dailyReminderTime,
    bool? showPurposeReminder,
    bool? streakRecoveryEnabled,
    bool? onboardingCompleted,
    String? ollamaBaseUrl,
    String? ollamaDefaultModel,
  }) {
    return AppSettings(
      llmMode: llmMode ?? this.llmMode,
      llmProvider: llmProvider ?? this.llmProvider,
      llmModel: llmModel ?? this.llmModel,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      showPurposeReminder: showPurposeReminder ?? this.showPurposeReminder,
      streakRecoveryEnabled:
          streakRecoveryEnabled ?? this.streakRecoveryEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      ollamaBaseUrl: ollamaBaseUrl ?? this.ollamaBaseUrl,
      ollamaDefaultModel: ollamaDefaultModel ?? this.ollamaDefaultModel,
    );
  }

  @override
  List<Object?> get props => [
    llmMode,
    llmProvider,
    llmModel,
    themeMode,
    notificationsEnabled,
    dailyReminderTime,
    showPurposeReminder,
    streakRecoveryEnabled,
    onboardingCompleted,
    ollamaBaseUrl,
    ollamaDefaultModel,
  ];
}
