import 'dart:convert';

import 'package:prompt_loop/core/constants/llm_constants.dart';
import 'package:prompt_loop/core/utils/json_validator.dart';
import 'package:prompt_loop/domain/entities/skill.dart';
import 'package:prompt_loop/domain/entities/sub_skill.dart';
import 'package:prompt_loop/domain/entities/task.dart';
import 'package:prompt_loop/domain/services/llm_service.dart';

/// Callback for when a prompt is ready to be copied.
typedef PromptReadyCallback = Future<void> Function(String prompt);

/// Callback to get pasted response from user.
typedef ResponseReceivedCallback = Future<String?> Function();

/// Copy-paste LLM service for users without API keys.
///
/// This service generates prompts that users can copy to their preferred
/// LLM (ChatGPT, Claude, etc.) and then paste the response back.
/// This is the MVP priority mode.
class CopyPasteLlmService implements LlmService {
  final PromptReadyCallback onPromptReady;
  final ResponseReceivedCallback onResponseReceived;

  const CopyPasteLlmService({
    required this.onPromptReady,
    required this.onResponseReceived,
  });

  @override
  String get modeName => 'Copy-Paste';

  @override
  bool get isAvailable => true; // Always available

  @override
  Future<LlmResult<SkillAnalysisResult>> analyzeSkill(
    SkillAnalysisRequest request,
  ) async {
    // Generate the prompt
    final prompt = _buildSkillAnalysisPrompt(request);

    // Notify that prompt is ready
    await onPromptReady(prompt);

    // Wait for response
    final response = await onResponseReceived();
    if (response == null || response.isEmpty) {
      return LlmResult.failure('No response received');
    }

    // Parse and validate response
    return _parseSkillAnalysisResponse(response);
  }

  @override
  Future<LlmResult<List<TaskSuggestion>>> generateTasks(
    TaskGenerationRequest request,
  ) async {
    final prompt = _buildTaskGenerationPrompt(request);

    await onPromptReady(prompt);

    final response = await onResponseReceived();
    if (response == null || response.isEmpty) {
      return LlmResult.failure('No response received');
    }

    return _parseTaskGenerationResponse(response);
  }

  @override
  Future<LlmResult<WiseFeedbackResult>> analyzeStruggle(
    StruggleAnalysisRequest request,
  ) async {
    final prompt = _buildStruggleAnalysisPrompt(request);

    await onPromptReady(prompt);

    final response = await onResponseReceived();
    if (response == null || response.isEmpty) {
      return LlmResult.failure('No response received');
    }

    return _parseWiseFeedbackResponse(response);
  }

  // -- Prompt Builders --

  String _buildSkillAnalysisPrompt(SkillAnalysisRequest request) {
    return PromptTemplates.skillAnalysis(
      skillName: request.skillDescription,
      userContext: request.toPromptContext(),
      purposeStatement: request.goals,
    );
  }

  String _buildTaskGenerationPrompt(TaskGenerationRequest request) {
    return PromptTemplates.taskGeneration(
      skillName: request.skill.name,
      subSkillName: request.subSkills.firstOrNull?.name ?? '',
      currentLevel: request.skill.currentLevel.name,
      recentStruggle: null,
    );
  }

  String _buildStruggleAnalysisPrompt(StruggleAnalysisRequest request) {
    return PromptTemplates.wiseFeedback(
      skillName: request.skillName,
      struggleDescription: request.struggleDescription,
      taskTitle: '',
    );
  }

  // -- Response Parsers --

  LlmResult<SkillAnalysisResult> _parseSkillAnalysisResponse(String response) {
    try {
      final cleanedJson = JsonValidator.cleanLlmResponse(response);

      final json = jsonDecode(cleanedJson) as Map<String, dynamic>;

      // Validate required fields
      if (!json.containsKey('skill_name') ||
          !json.containsKey('skill_description') ||
          !json.containsKey('sub_skills')) {
        return LlmResult.failure(
          'Missing required fields in response',
          rawResponse: response,
        );
      }

      // Parse sub-skills
      final subSkillsJson = json['sub_skills'] as List<dynamic>;
      final subSkills = subSkillsJson.map((s) {
        final subSkillMap = s as Map<String, dynamic>;
        return SubSkillSuggestion(
          name: subSkillMap['name'] as String,
          description: subSkillMap['description'] as String,
          priority: _parsePriority(subSkillMap['priority'] as String?),
          estimatedHours: subSkillMap['estimated_hours'] as int? ?? 10,
        );
      }).toList();

      // Parse learning path
      final learningPathJson = json['learning_path'] as List<dynamic>? ?? [];
      final learningPath = learningPathJson.cast<String>();

      final result = SkillAnalysisResult(
        skillName: json['skill_name'] as String,
        skillDescription: json['skill_description'] as String,
        suggestedLevel: _parseSkillLevel(json['suggested_level'] as String?),
        subSkills: subSkills,
        learningPath: learningPath,
      );

      return LlmResult.success(result, rawResponse: response);
    } catch (e) {
      return LlmResult.failure(
        'Failed to parse response: $e',
        rawResponse: response,
      );
    }
  }

  LlmResult<List<TaskSuggestion>> _parseTaskGenerationResponse(
    String response,
  ) {
    try {
      final cleanedJson = JsonValidator.cleanLlmResponse(response);

      final json = jsonDecode(cleanedJson) as Map<String, dynamic>;

      if (!json.containsKey('tasks')) {
        return LlmResult.failure(
          'Missing "tasks" field in response',
          rawResponse: response,
        );
      }

      final tasksJson = json['tasks'] as List<dynamic>;
      final tasks = tasksJson.map((t) {
        final taskMap = t as Map<String, dynamic>;
        final successCriteriaJson =
            taskMap['success_criteria'] as List<dynamic>? ?? [];

        return TaskSuggestion(
          title: taskMap['title'] as String,
          description: taskMap['description'] as String,
          durationMinutes: taskMap['estimated_minutes'] as int? ?? 30,
          difficulty: taskMap['difficulty'] as int? ?? 5,
          successCriteria: successCriteriaJson.cast<String>(),
          frequency: _parseFrequency(taskMap['frequency'] as String?),
          targetSubSkillName: taskMap['target_sub_skill'] as String?,
        );
      }).toList();

      return LlmResult.success(tasks, rawResponse: response);
    } catch (e) {
      return LlmResult.failure(
        'Failed to parse response: $e',
        rawResponse: response,
      );
    }
  }

  LlmResult<WiseFeedbackResult> _parseWiseFeedbackResponse(String response) {
    try {
      final cleanedJson = JsonValidator.cleanLlmResponse(response);

      final json = jsonDecode(cleanedJson) as Map<String, dynamic>;

      if (!json.containsKey('high_standards_message') ||
          !json.containsKey('belief_message')) {
        return LlmResult.failure(
          'Missing required fields for wise feedback',
          rawResponse: response,
        );
      }

      final suggestionsJson =
          json['actionable_suggestions'] as List<dynamic>? ?? [];

      final result = WiseFeedbackResult(
        highStandardsMessage: json['high_standards_message'] as String,
        beliefMessage: json['belief_message'] as String,
        actionableSuggestions: suggestionsJson.cast<String>(),
        encouragement: json['encouragement'] as String? ?? '',
      );

      return LlmResult.success(result, rawResponse: response);
    } catch (e) {
      return LlmResult.failure(
        'Failed to parse response: $e',
        rawResponse: response,
      );
    }
  }

  // -- Helper Parsers --

  Priority _parsePriority(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return Priority.high;
      case 'low':
        return Priority.low;
      case 'medium':
      default:
        return Priority.medium;
    }
  }

  SkillLevel _parseSkillLevel(String? level) {
    switch (level?.toLowerCase()) {
      case 'novice':
        return SkillLevel.beginner;
      case 'advanced_beginner':
      case 'advancedbeginner':
        return SkillLevel.intermediate;
      case 'competent':
        return SkillLevel.intermediate;
      case 'proficient':
        return SkillLevel.advanced;
      case 'expert':
        return SkillLevel.expert;
      default:
        return SkillLevel.beginner;
    }
  }

  TaskFrequency _parseFrequency(String? frequency) {
    switch (frequency?.toLowerCase()) {
      case 'daily':
        return TaskFrequency.daily;
      case 'weekly':
        return TaskFrequency.weekly;
      case 'biweekly':
        return TaskFrequency.weekly;
      case 'monthly':
        return TaskFrequency.custom;
      case 'once':
        return TaskFrequency.custom;
      default:
        return TaskFrequency.weekly;
    }
  }
}

/// Helper class for managing the copy-paste workflow UI state.
class CopyPasteWorkflowState {
  final CopyPasteStep currentStep;
  final String? currentPrompt;
  final String? pastedResponse;
  final String? errorMessage;

  const CopyPasteWorkflowState({
    required this.currentStep,
    this.currentPrompt,
    this.pastedResponse,
    this.errorMessage,
  });

  const CopyPasteWorkflowState.initial()
    : currentStep = CopyPasteStep.idle,
      currentPrompt = null,
      pastedResponse = null,
      errorMessage = null;

  CopyPasteWorkflowState copyWith({
    CopyPasteStep? currentStep,
    String? currentPrompt,
    String? pastedResponse,
    String? errorMessage,
  }) {
    return CopyPasteWorkflowState(
      currentStep: currentStep ?? this.currentStep,
      currentPrompt: currentPrompt ?? this.currentPrompt,
      pastedResponse: pastedResponse ?? this.pastedResponse,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Steps in the copy-paste workflow.
enum CopyPasteStep {
  /// No active operation
  idle,

  /// Prompt is ready to be copied
  promptReady,

  /// Waiting for user to paste response
  awaitingResponse,

  /// Processing the pasted response
  processing,

  /// Operation completed successfully
  completed,

  /// Error occurred
  error,
}
