import 'dart:convert';
import 'package:prompt_loop/core/constants/llm_constants.dart';
import 'package:prompt_loop/core/utils/json_validator.dart';
import 'package:prompt_loop/domain/entities/skill.dart';
import 'package:prompt_loop/domain/entities/sub_skill.dart';
import 'package:prompt_loop/domain/entities/task.dart';
import 'package:prompt_loop/domain/services/llm_service.dart';
import 'package:prompt_loop/ollama_toolkit/ollama_toolkit.dart';

/// Ollama LLM service for local AI integration.
///
/// This service uses Ollama for local LLM operations without streaming.
class OllamaLlmService implements LlmService {
  final OllamaClient _client;
  final String _model;

  OllamaLlmService({
    required String baseUrl,
    required String model,
    Duration timeout = const Duration(seconds: 120),
  }) : _client = OllamaClient(baseUrl: baseUrl, timeout: timeout),
       _model = model;

  @override
  String get modeName => 'Ollama ($_model)';

  @override
  bool get isAvailable => true;

  /// Test connection to Ollama server
  Future<bool> testConnection() async {
    try {
      return await _client.testConnection();
    } catch (e) {
      return false;
    }
  }

  /// List available models
  Future<List<String>> listModels() async {
    try {
      final response = await _client.listModels();
      return response.models.map((m) => m.name).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<LlmResult<SkillAnalysisResult>> analyzeSkill(
    SkillAnalysisRequest request,
  ) async {
    try {
      final userPrompt = PromptTemplates.skillAnalysis(
        skillName: request.skillDescription,
        userContext: request.toPromptContext(),
      );

      // Use generate API (no streaming)
      final response = await _client.generate(
        _model,
        userPrompt,
        options: {'temperature': 0.7, 'num_predict': 2048},
      );

      final rawResponse = response.response;

      // Parse JSON response
      final jsonResponse = _extractAndParseJson(rawResponse);
      if (jsonResponse == null) {
        return LlmResult.failure(
          'Failed to parse JSON from response',
          rawResponse: rawResponse,
        );
      }

      // Validate and convert to SkillAnalysisResult
      final result = _parseSkillAnalysis(jsonResponse);
      return LlmResult.success(result, rawResponse: rawResponse);
    } catch (e) {
      return LlmResult.failure(
        'Ollama error: ${e.toString()}',
        rawResponse: null,
      );
    }
  }

  @override
  Future<LlmResult<List<TaskSuggestion>>> generateTasks(
    TaskGenerationRequest request,
  ) async {
    try {
      final subSkillName = request.subSkills.isNotEmpty
          ? request.subSkills.first.name
          : 'general practice';

      final userPrompt = PromptTemplates.taskGeneration(
        skillName: request.skill.name,
        subSkillName: subSkillName,
        currentLevel: request.skill.currentLevel.name,
      );

      // Use generate API (no streaming)
      final response = await _client.generate(
        _model,
        userPrompt,
        options: {'temperature': 0.7, 'num_predict': 2048},
      );

      final rawResponse = response.response;

      // Parse JSON response
      final jsonResponse = _extractAndParseJson(rawResponse);
      if (jsonResponse == null) {
        return LlmResult.failure(
          'Failed to parse JSON from response',
          rawResponse: rawResponse,
        );
      }

      // Validate and convert to TaskSuggestions
      final tasks = _parseTaskSuggestions(jsonResponse);
      return LlmResult.success(tasks, rawResponse: rawResponse);
    } catch (e) {
      return LlmResult.failure(
        'Ollama error: ${e.toString()}',
        rawResponse: null,
      );
    }
  }

  @override
  Future<LlmResult<WiseFeedbackResult>> analyzeStruggle(
    StruggleAnalysisRequest request,
  ) async {
    try {
      final userPrompt = PromptTemplates.wiseFeedback(
        skillName: request.skillName,
        struggleDescription: request.struggleDescription,
        taskTitle: 'Practice Task',
      );

      // Use generate API (no streaming)
      final response = await _client.generate(
        _model,
        userPrompt,
        options: {'temperature': 0.8, 'num_predict': 1024},
      );

      final rawResponse = response.response;

      // Parse JSON response
      final jsonResponse = _extractAndParseJson(rawResponse);
      if (jsonResponse == null) {
        return LlmResult.failure(
          'Failed to parse JSON from response',
          rawResponse: rawResponse,
        );
      }

      // Validate and convert to WiseFeedbackResult
      final feedback = _parseWiseFeedback(jsonResponse);
      return LlmResult.success(feedback, rawResponse: rawResponse);
    } catch (e) {
      return LlmResult.failure(
        'Ollama error: ${e.toString()}',
        rawResponse: null,
      );
    }
  }

  /// Extract and parse JSON from LLM response
  Map<String, dynamic>? _extractAndParseJson(String response) {
    try {
      // Try direct JSON parse first
      return json.decode(response) as Map<String, dynamic>;
    } catch (e) {
      // Extract JSON from markdown code blocks
      final jsonValidator = JsonValidator();
      final cleanedResponse = jsonValidator.extractJson(response);
      if (cleanedResponse != null) {
        try {
          return json.decode(cleanedResponse) as Map<String, dynamic>;
        } catch (e) {
          return null;
        }
      }
      return null;
    }
  }

  /// Parse skill analysis from JSON
  SkillAnalysisResult _parseSkillAnalysis(Map<String, dynamic> json) {
    final subSkillsJson = (json['sub_skills'] as List<dynamic>?) ?? [];
    final subSkills = subSkillsJson.map((subSkillJson) {
      final subSkillMap = subSkillJson as Map<String, dynamic>;
      return SubSkillSuggestion(
        name: subSkillMap['name'] as String? ?? 'Unknown',
        description: subSkillMap['description'] as String? ?? 'No description',
        priority: _parsePriority(subSkillMap['priority'] as String?),
        estimatedHours: subSkillMap['estimated_hours'] as int? ?? 20,
      );
    }).toList();

    final learningPath =
        (json['learning_path'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return SkillAnalysisResult(
      skillName: json['skill_name'] as String? ?? 'Unknown Skill',
      skillDescription: json['skill_description'] as String? ?? '',
      suggestedLevel: _parseSkillLevel(json['suggested_level'] as String?),
      subSkills: subSkills,
      learningPath: learningPath,
    );
  }

  /// Parse task suggestions from JSON
  List<TaskSuggestion> _parseTaskSuggestions(Map<String, dynamic> json) {
    final dataJson = json['data'] as Map<String, dynamic>? ?? json;
    final tasksJson = (dataJson['tasks'] as List<dynamic>?) ?? [];

    return tasksJson.map((taskJson) {
      final taskMap = taskJson as Map<String, dynamic>;
      return TaskSuggestion(
        title: taskMap['title'] as String? ?? 'Untitled Task',
        description: taskMap['description'] as String? ?? 'No description',
        durationMinutes:
            taskMap['durationMinutes'] as int? ??
            taskMap['duration_minutes'] as int? ??
            15,
        difficulty: _parseDifficulty(taskMap['difficulty']),
        successCriteria:
            (taskMap['successCriteria'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            (taskMap['success_criteria'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        frequency: _parseFrequency(taskMap['frequency'] as String?),
        targetSubSkillName: taskMap['subSkillId'] as String?,
      );
    }).toList();
  }

  /// Parse wise feedback from JSON
  WiseFeedbackResult _parseWiseFeedback(Map<String, dynamic> json) {
    final dataJson = json['data'] as Map<String, dynamic>? ?? json;

    return WiseFeedbackResult(
      highStandardsMessage:
          dataJson['acknowledgment'] as String? ??
          dataJson['normalization'] as String? ??
          '',
      beliefMessage:
          dataJson['reframe'] as String? ??
          dataJson['encouragement'] as String? ??
          '',
      actionableSuggestions: [
        dataJson['suggestion'] as String? ?? 'Keep practicing!',
      ],
      encouragement: dataJson['encouragement'] as String? ?? 'Keep going!',
    );
  }

  // Helper parsers
  Priority _parsePriority(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return Priority.high;
      case 'medium':
        return Priority.medium;
      case 'low':
        return Priority.low;
      default:
        return Priority.medium;
    }
  }

  SkillLevel _parseSkillLevel(String? level) {
    switch (level?.toLowerCase()) {
      case 'beginner':
        return SkillLevel.beginner;
      case 'intermediate':
        return SkillLevel.intermediate;
      case 'advanced':
        return SkillLevel.advanced;
      case 'expert':
        return SkillLevel.expert;
      default:
        return SkillLevel.beginner;
    }
  }

  int _parseDifficulty(dynamic difficulty) {
    if (difficulty is int) return difficulty;
    if (difficulty is String) {
      switch (difficulty.toLowerCase()) {
        case 'easy':
          return 1;
        case 'medium':
          return 2;
        case 'hard':
          return 3;
        default:
          return 2;
      }
    }
    return 2;
  }

  TaskFrequency _parseFrequency(String? frequency) {
    switch (frequency?.toLowerCase()) {
      case 'daily':
        return TaskFrequency.daily;
      case 'weekly':
        return TaskFrequency.weekly;
      default:
        return TaskFrequency.weekly;
    }
  }
}
