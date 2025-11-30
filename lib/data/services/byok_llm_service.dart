import 'dart:convert';

import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:deliberate_practice_app/core/constants/llm_constants.dart';
import 'package:deliberate_practice_app/core/utils/json_validator.dart';
import 'package:deliberate_practice_app/domain/entities/skill.dart';
import 'package:deliberate_practice_app/domain/entities/sub_skill.dart';
import 'package:deliberate_practice_app/domain/entities/task.dart';
import 'package:deliberate_practice_app/domain/entities/app_settings.dart';
import 'package:deliberate_practice_app/domain/services/llm_service.dart';

/// BYOK (Bring Your Own Key) LLM service for direct API integration.
///
/// This service allows users to use their own API keys for
/// OpenAI, Google AI, or Anthropic to get seamless LLM integration.
class ByokLlmService implements LlmService {
  final String apiKey;
  final LlmProvider provider;
  final String? model;
  
  late final ChatOpenAI? _openAiClient;
  
  ByokLlmService({
    required this.apiKey,
    required this.provider,
    this.model,
  }) {
    _initializeClient();
  }

  void _initializeClient() {
    switch (provider) {
      case LlmProvider.openai:
        _openAiClient = ChatOpenAI(
          apiKey: apiKey,
          defaultOptions: ChatOpenAIOptions(
            model: model ?? 'gpt-4o-mini',
            temperature: 0.7,
          ),
        );
        break;
      case LlmProvider.google:
        // Google AI would use different package
        // For now, we'll mark as unavailable
        _openAiClient = null;
        break;
      case LlmProvider.anthropic:
        // Anthropic would use different package
        // For now, we'll mark as unavailable
        _openAiClient = null;
        break;
    }
  }

  @override
  String get modeName => 'BYOK (${provider.name})';

  @override
  bool get isAvailable => apiKey.isNotEmpty && _openAiClient != null;

  @override
  Future<LlmResult<SkillAnalysisResult>> analyzeSkill(
    SkillAnalysisRequest request,
  ) async {
    if (!isAvailable) {
      return LlmResult.failure('BYOK service not configured');
    }
    
    try {
      final systemPrompt = '''
${LlmConstants.skillAnalysisSystemPrompt}

${LlmConstants.jsonInstructions}

You must respond with valid JSON matching this schema:
${LlmConstants.skillAnalysisSchema}
''';

      final userPrompt = request.toPromptContext();
      
      final messages = [
        ChatMessage.system(systemPrompt),
        ChatMessage.humanText(userPrompt),
      ];
      
      final response = await _openAiClient!.invoke(PromptValue.chat(messages));
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
      final systemPrompt = '''
${LlmConstants.taskGenerationSystemPrompt}

${LlmConstants.jsonInstructions}

You must respond with valid JSON matching this schema:
${LlmConstants.taskGenerationSchema}
''';

      final userPrompt = request.toPromptContext();
      
      final messages = [
        ChatMessage.system(systemPrompt),
        ChatMessage.humanText(userPrompt),
      ];
      
      final response = await _openAiClient!.invoke(PromptValue.chat(messages));
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
      final systemPrompt = '''
${LlmConstants.struggleAnalysisSystemPrompt}

${LlmConstants.jsonInstructions}

You must respond with valid JSON matching this schema:
${LlmConstants.wiseFeedbackSchema}
''';

      final userPrompt = request.toPromptContext();
      
      final messages = [
        ChatMessage.system(systemPrompt),
        ChatMessage.humanText(userPrompt),
      ];
      
      final response = await _openAiClient!.invoke(PromptValue.chat(messages));
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
      
      if (cleanedJson == null) {
        return LlmResult.failure(
          'Could not find valid JSON in response',
          rawResponse: response,
        );
      }
      
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

  LlmResult<List<TaskSuggestion>> _parseTaskGenerationResponse(String response) {
    try {
      final cleanedJson = JsonValidator.cleanLlmResponse(response);
      
      if (cleanedJson == null) {
        return LlmResult.failure(
          'Could not find valid JSON in response',
          rawResponse: response,
        );
      }
      
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
        final successCriteriaJson = taskMap['success_criteria'] as List<dynamic>? ?? [];
        
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
      
      if (cleanedJson == null) {
        return LlmResult.failure(
          'Could not find valid JSON in response',
          rawResponse: response,
        );
      }
      
      final json = jsonDecode(cleanedJson) as Map<String, dynamic>;
      
      if (!json.containsKey('high_standards_message') ||
          !json.containsKey('belief_message')) {
        return LlmResult.failure(
          'Missing required fields for wise feedback',
          rawResponse: response,
        );
      }
      
      final suggestionsJson = json['actionable_suggestions'] as List<dynamic>? ?? [];
      
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
