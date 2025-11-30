/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Deliberate Practice';
  static const String appVersion = '1.0.0';

  // LLM Modes
  static const String llmModeCopyPaste = 'copy_paste';
  static const String llmModeByok = 'byok';

  // LLM Providers
  static const String providerOpenAI = 'openai';
  static const String providerAnthropic = 'anthropic';
  static const String providerGoogle = 'google';

  // Skill Levels
  static const String levelBeginner = 'beginner';
  static const String levelIntermediate = 'intermediate';
  static const String levelAdvanced = 'advanced';
  static const String levelExpert = 'expert';

  // Task Frequencies
  static const String frequencyDaily = 'daily';
  static const String frequencyWeekly = 'weekly';
  static const String frequencyCustom = 'custom';

  // Priority Levels
  static const String priorityHigh = 'high';
  static const String priorityMedium = 'medium';
  static const String priorityLow = 'low';

  // Purpose Categories
  static const String purposePersonalExpression = 'personal_expression';
  static const String purposeConnectingWithOthers = 'connecting_with_others';
  static const String purposeCareerGrowth = 'career_growth';
  static const String purposeSelfImprovement = 'self_improvement';
  static const String purposeContributingBeyondSelf =
      'contributing_beyond_self';
  static const String purposeOther = 'other';

  // Milestone Types
  static const String milestonePracticeTime = 'practice_time';
  static const String milestoneTaskCount = 'task_count';
  static const String milestoneStreak = 'streak';
  static const String milestoneCustom = 'custom';

  // Durations
  static const int defaultTaskDurationMinutes = 15;
  static const int minTaskDurationMinutes = 5;
  static const int maxTaskDurationMinutes = 120;

  // Difficulty
  static const int minDifficulty = 1;
  static const int maxDifficulty = 10;
  static const int defaultDifficulty = 5;

  // Rating
  static const int minRating = 1;
  static const int maxRating = 5;

  // External URLs
  static const String chatGptUrl = 'https://chat.openai.com';
  static const String claudeUrl = 'https://claude.ai';
  static const String geminiUrl = 'https://gemini.google.com';
}
