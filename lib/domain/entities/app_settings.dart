import 'package:equatable/equatable.dart';

/// LLM mode selection
enum LlmMode {
  copyPaste,
  byok;

  String get displayName {
    switch (this) {
      case LlmMode.copyPaste:
        return 'Copy-Paste';
      case LlmMode.byok:
        return 'Bring Your Own Key';
    }
  }

  String get dbValue {
    switch (this) {
      case LlmMode.copyPaste:
        return 'copy_paste';
      case LlmMode.byok:
        return 'byok';
    }
  }

  static LlmMode fromString(String value) {
    switch (value) {
      case 'byok':
        return LlmMode.byok;
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

/// Theme mode
enum ThemeMode {
  light,
  dark,
  system;

  static ThemeMode fromString(String value) {
    return ThemeMode.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => ThemeMode.system,
    );
  }
}

/// App settings entity
class AppSettings extends Equatable {
  final LlmMode llmMode;
  final LlmProvider llmProvider;
  final String? llmModel;
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final String dailyReminderTime;
  final bool showPurposeReminder;
  final bool streakRecoveryEnabled;
  final bool onboardingCompleted;

  const AppSettings({
    this.llmMode = LlmMode.copyPaste,
    this.llmProvider = LlmProvider.openai,
    this.llmModel,
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.dailyReminderTime = '09:00',
    this.showPurposeReminder = true,
    this.streakRecoveryEnabled = true,
    this.onboardingCompleted = false,
  });

  bool get isDarkMode => themeMode == ThemeMode.dark;

  /// Create a copy with modified fields
  AppSettings copyWith({
    LlmMode? llmMode,
    LlmProvider? llmProvider,
    String? llmModel,
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    String? dailyReminderTime,
    bool? showPurposeReminder,
    bool? streakRecoveryEnabled,
    bool? onboardingCompleted,
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
  ];
}
