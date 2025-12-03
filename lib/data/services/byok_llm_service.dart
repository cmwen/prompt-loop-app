import 'dart:convert';

import 'package:langchain/langchain.dart';
import 'package:langchain_anthropic/langchain_anthropic.dart';
import 'package:langchain_google/langchain_google.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:prompt_loop/core/constants/llm_constants.dart';
import 'package:prompt_loop/core/utils/json_validator.dart';
import 'package:prompt_loop/domain/entities/skill.dart';
import 'package:prompt_loop/domain/entities/sub_skill.dart';
import 'package:prompt_loop/domain/entities/task.dart';
import 'package:prompt_loop/domain/entities/app_settings.dart';
import 'package:prompt_loop/domain/services/llm_service.dart';

/// BYOK (Bring Your Own Key) LLM service for direct API integration.
///
/// This service allows users to use their own API keys for
/// OpenAI, Google AI, or Anthropic to get seamless LLM integration.
class ByokLlmService implements LlmService {
  final String apiKey;
  final LlmProvider provider;
  final String? model;

  final ChatOpenAI? _openAiClient;
  final ChatGoogleGenerativeAI? _googleClient;
  final ChatAnthropic? _anthropicClient;

  ByokLlmService._({
    required this.apiKey,
    required this.provider,
    this.model,
    ChatOpenAI? openAiClient,
    ChatGoogleGenerativeAI? googleClient,
    ChatAnthropic? anthropicClient,
  }) : _openAiClient = openAiClient,
       _googleClient = googleClient,
       _anthropicClient = anthropicClient;

  /// Creates a ByokLlmService with the appropriate client for the provider.
  factory ByokLlmService({
    required String apiKey,
    required LlmProvider provider,
    String? model,
  }) {
    ChatOpenAI? openAiClient;
    ChatGoogleGenerativeAI? googleClient;
    ChatAnthropic? anthropicClient;

    switch (provider) {
      case LlmProvider.openai:
        openAiClient = ChatOpenAI(
          apiKey: apiKey,
          defaultOptions: ChatOpenAIOptions(
            model: model ?? 'gpt-4o-mini',
            temperature: 0.7,
          ),
        );
        break;
      case LlmProvider.google:
        googleClient = ChatGoogleGenerativeAI(
          apiKey: apiKey,
          defaultOptions: ChatGoogleGenerativeAIOptions(
            model: model ?? 'gemini-1.5-flash',
            temperature: 0.7,
          ),
        );
        break;
      case LlmProvider.anthropic:
        anthropicClient = ChatAnthropic(
          apiKey: apiKey,
          defaultOptions: ChatAnthropicOptions(
            model: model ?? 'claude-3-5-sonnet-20241022',
            temperature: 0.7,
          ),
        );
        break;
    }

    return ByokLlmService._(
      apiKey: apiKey,
      provider: provider,
      model: model,
      openAiClient: openAiClient,
      googleClient: googleClient,
      anthropicClient: anthropicClient,
    );
  }

  /// Returns the active chat model based on the current provider.
  BaseChatModel? _getActiveClient() {
    switch (provider) {
      case LlmProvider.openai:
        return _openAiClient;
      case LlmProvider.google:
        return _googleClient;
      case LlmProvider.anthropic:
        return _anthropicClient;
    }
  }

  /// Returns the active client or throws an error if not available.
  /// Use this to reduce null-check duplication across methods.
  BaseChatModel _requireActiveClient() {
    final client = _getActiveClient();
    if (client == null) {
      throw StateError(
        'No LLM client available for provider: ${provider.name}',
      );
    }
    return client;
  }

  @override
  String get modeName => 'BYOK (${provider.name})';

  @override
  bool get isAvailable => apiKey.isNotEmpty && _getActiveClient() != null;

  /// Validates the API key by making a test request
  Future<bool> validateApiKey() async {
    if (!isAvailable) return false;

    try {
      final client = _requireActiveClient();

      // Make a simple test request
      final messages = [
        ChatMessage.humanText('Say "OK" if you can read this.'),
      ];

      final response = await client
          .invoke(PromptValue.chat(messages))
          .timeout(const Duration(seconds: 10));

      return response.output.content.isNotEmpty;
    } catch (e) {
      // API key is invalid or request failed
      return false;
    }
  }

  @override
  Future<LlmResult<SkillAnalysisResult>> analyzeSkill(
    SkillAnalysisRequest request,
  ) async {
    if (!isAvailable) {
      return LlmResult.failure('BYOK service not configured');
    }

    try {
      final client = _requireActiveClient();

      final prompt = PromptTemplates.skillAnalysis(
        skillName: request.skillDescription,
        userContext: request.toPromptContext(),
        purposeStatement: request.goals,
      );

      final messages = [ChatMessage.humanText(prompt)];

      final response = await client.invoke(PromptValue.chat(messages));
      final content = response.output.content;

      return _parseSkillAnalysisResponse(content);
    } catch (e) {
      return LlmResult.failure('API error: $e');
    }
  }

  @override
  Future<LlmResult<List<TaskSuggestion>>> generateTasks(
    TaskGenerationRequest request,
  ) async {
    if (!isAvailable) {
      return LlmResult.failure('BYOK service not configured');
    }

    try {
      final client = _requireActiveClient();

      final prompt = PromptTemplates.taskGeneration(
        skillName: request.skill.name,
        subSkillName: request.subSkills.firstOrNull?.name ?? '',
        currentLevel: request.skill.currentLevel.name,
        recentStruggle: null,
      );

      final messages = [ChatMessage.humanText(prompt)];

      final response = await client.invoke(PromptValue.chat(messages));
      final content = response.output.content;

      return _parseTaskGenerationResponse(content);
    } catch (e) {
      return LlmResult.failure('API error: $e');
    }
  }

  @override
  Future<LlmResult<WiseFeedbackResult>> analyzeStruggle(
    StruggleAnalysisRequest request,
  ) async {
    if (!isAvailable) {
      return LlmResult.failure('BYOK service not configured');
    }

    try {
      final client = _requireActiveClient();

      final prompt = PromptTemplates.wiseFeedback(
        skillName: request.skillName,
        struggleDescription: request.struggleDescription,
        taskTitle: '',
      );

      final messages = [ChatMessage.humanText(prompt)];

      final response = await client.invoke(PromptValue.chat(messages));
      final content = response.output.content;

      return _parseWiseFeedbackResponse(content);
    } catch (e) {
      return LlmResult.failure('API error: $e');
    }
  }

  // -- Response Parsers (shared logic with CopyPaste service) --

  LlmResult<SkillAnalysisResult> _parseSkillAnalysisResponse(String response) {
    try {
      final cleanedJson = JsonValidator.cleanLlmResponse(response);

      final json = jsonDecode(cleanedJson) as Map<String, dynamic>;

      if (!json.containsKey('skill_name') ||
          !json.containsKey('skill_description') ||
          !json.containsKey('sub_skills')) {
        return LlmResult.failure(
          'Missing required fields in response',
          rawResponse: response,
        );
      }

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
