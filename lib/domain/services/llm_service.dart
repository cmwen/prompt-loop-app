import 'package:prompt_loop_app/domain/entities/skill.dart';
import 'package:prompt_loop_app/domain/entities/sub_skill.dart';
import 'package:prompt_loop_app/domain/entities/task.dart';

/// Result of an LLM analysis or generation operation.
class LlmResult<T> {
  final T? data;
  final String? error;
  final String? rawResponse;

  const LlmResult._({this.data, this.error, this.rawResponse});

  factory LlmResult.success(T data, {String? rawResponse}) =>
      LlmResult._(data: data, rawResponse: rawResponse);

  factory LlmResult.failure(String error, {String? rawResponse}) =>
      LlmResult._(error: error, rawResponse: rawResponse);

  bool get isSuccess => data != null && error == null;
  bool get isFailure => error != null;
}

/// Request for skill analysis.
class SkillAnalysisRequest {
  final String skillDescription;
  final String? currentLevel;
  final String? timeAvailable;
  final String? goals;

  const SkillAnalysisRequest({
    required this.skillDescription,
    this.currentLevel,
    this.timeAvailable,
    this.goals,
  });

  String toPromptContext() {
    final buffer = StringBuffer();
    buffer.writeln('Skill to analyze: $skillDescription');
    if (currentLevel != null) {
      buffer.writeln('Current level: $currentLevel');
    }
    if (timeAvailable != null) {
      buffer.writeln('Time available per week: $timeAvailable');
    }
    if (goals != null) {
      buffer.writeln('Goals: $goals');
    }
    return buffer.toString();
  }
}

/// Result of skill analysis containing skill structure.
class SkillAnalysisResult {
  final String skillName;
  final String skillDescription;
  final SkillLevel suggestedLevel;
  final List<SubSkillSuggestion> subSkills;
  final List<String> learningPath;

  const SkillAnalysisResult({
    required this.skillName,
    required this.skillDescription,
    required this.suggestedLevel,
    required this.subSkills,
    required this.learningPath,
  });
}

/// Suggested sub-skill from analysis.
class SubSkillSuggestion {
  final String name;
  final String description;
  final Priority priority;
  final int estimatedHours;

  const SubSkillSuggestion({
    required this.name,
    required this.description,
    required this.priority,
    required this.estimatedHours,
  });
}

/// Request for task generation.
class TaskGenerationRequest {
  final Skill skill;
  final List<SubSkill> subSkills;
  final int? numberOfTasks;
  final TaskFrequency? preferredFrequency;
  final String? focusArea;

  const TaskGenerationRequest({
    required this.skill,
    required this.subSkills,
    this.numberOfTasks,
    this.preferredFrequency,
    this.focusArea,
  });

  String toPromptContext() {
    final buffer = StringBuffer();
    buffer.writeln('Skill: ${skill.name}');
    buffer.writeln('Current level: ${skill.level.name}');
    buffer.writeln('Sub-skills to focus on:');
    for (final subSkill in subSkills) {
      buffer.writeln('  - ${subSkill.name} (${subSkill.priority.name} priority)');
    }
    if (focusArea != null) {
      buffer.writeln('Focus area: $focusArea');
    }
    if (numberOfTasks != null) {
      buffer.writeln('Number of tasks to generate: $numberOfTasks');
    }
    if (preferredFrequency != null) {
      buffer.writeln('Preferred frequency: ${preferredFrequency!.name}');
    }
    return buffer.toString();
  }
}

/// Suggested task from generation.
class TaskSuggestion {
  final String title;
  final String description;
  final int estimatedMinutes;
  final int difficulty;
  final List<String> successCriteria;
  final TaskFrequency frequency;
  final String? targetSubSkillName;

  const TaskSuggestion({
    required this.title,
    required this.description,
    required this.estimatedMinutes,
    required this.difficulty,
    required this.successCriteria,
    required this.frequency,
    this.targetSubSkillName,
  });
}

/// Request for struggle analysis (wise feedback).
class StruggleAnalysisRequest {
  final String skillName;
  final String struggleDescription;
  final List<String>? previousStruggles;
  final String? whatWasTried;

  const StruggleAnalysisRequest({
    required this.skillName,
    required this.struggleDescription,
    this.previousStruggles,
    this.whatWasTried,
  });

  String toPromptContext() {
    final buffer = StringBuffer();
    buffer.writeln('Skill: $skillName');
    buffer.writeln('Current struggle: $struggleDescription');
    if (whatWasTried != null) {
      buffer.writeln('What was tried: $whatWasTried');
    }
    if (previousStruggles != null && previousStruggles!.isNotEmpty) {
      buffer.writeln('Previous struggles:');
      for (final struggle in previousStruggles!) {
        buffer.writeln('  - $struggle');
      }
    }
    return buffer.toString();
  }
}

/// Wise feedback response following Duckworth's principles.
class WiseFeedbackResult {
  final String highStandardsMessage;
  final String beliefMessage;
  final List<String> actionableSuggestions;
  final String encouragement;

  const WiseFeedbackResult({
    required this.highStandardsMessage,
    required this.beliefMessage,
    required this.actionableSuggestions,
    required this.encouragement,
  });
}

/// Abstract LLM service for skill analysis and task generation.
///
/// This service provides a unified interface for LLM operations
/// regardless of the mode (BYOK or copy-paste).
abstract class LlmService {
  /// Analyzes a skill description and returns structured breakdown.
  Future<LlmResult<SkillAnalysisResult>> analyzeSkill(
    SkillAnalysisRequest request,
  );

  /// Generates deliberate practice tasks for a skill.
  Future<LlmResult<List<TaskSuggestion>>> generateTasks(
    TaskGenerationRequest request,
  );

  /// Provides wise feedback for a struggle entry.
  Future<LlmResult<WiseFeedbackResult>> analyzeStruggle(
    StruggleAnalysisRequest request,
  );

  /// Whether this service mode is currently available.
  bool get isAvailable;

  /// The name of this LLM service mode.
  String get modeName;
}
