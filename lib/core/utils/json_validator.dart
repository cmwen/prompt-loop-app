import 'dart:convert';

/// Result of JSON validation
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final Map<String, dynamic>? parsedJson;

  const ValidationResult._({
    required this.isValid,
    required this.errors,
    this.parsedJson,
  });

  factory ValidationResult.success(Map<String, dynamic> json) =>
      ValidationResult._(isValid: true, errors: [], parsedJson: json);

  factory ValidationResult.failure(List<String> errors) =>
      ValidationResult._(isValid: false, errors: errors);
}

/// JSON validator for LLM responses
class JsonValidator {
  /// Validate skill analysis response
  ValidationResult validateSkillAnalysis(String jsonString) {
    final baseResult = _validateBaseStructure(jsonString, 'skill_analysis');
    if (!baseResult.isValid) return baseResult;

    final json = baseResult.parsedJson!;
    final errors = <String>[];

    // Validate data structure
    final data = json['data'] as Map<String, dynamic>?;
    if (data == null) {
      errors.add('Missing "data" field');
      return ValidationResult.failure(errors);
    }

    // Validate skill
    final skill = data['skill'] as Map<String, dynamic>?;
    if (skill == null) {
      errors.add('Missing "skill" field in data');
      return ValidationResult.failure(errors);
    }

    // Validate required skill fields
    if (skill['name'] == null || (skill['name'] as String).isEmpty) {
      errors.add('Skill name is required');
    }

    // Validate subSkills
    final subSkills = skill['subSkills'] as List<dynamic>?;
    if (subSkills == null || subSkills.isEmpty) {
      errors.add('At least one sub-skill is required');
    } else {
      for (var i = 0; i < subSkills.length; i++) {
        final subSkill = subSkills[i] as Map<String, dynamic>;
        if (subSkill['name'] == null || (subSkill['name'] as String).isEmpty) {
          errors.add('Sub-skill ${i + 1} is missing a name');
        }
      }
    }

    if (errors.isNotEmpty) {
      return ValidationResult.failure(errors);
    }

    return ValidationResult.success(json);
  }

  /// Validate task generation response
  ValidationResult validateTaskGeneration(String jsonString) {
    final baseResult = _validateBaseStructure(jsonString, 'task_generation');
    if (!baseResult.isValid) return baseResult;

    final json = baseResult.parsedJson!;
    final errors = <String>[];

    // Validate data structure
    final data = json['data'] as Map<String, dynamic>?;
    if (data == null) {
      errors.add('Missing "data" field');
      return ValidationResult.failure(errors);
    }

    // Validate tasks
    final tasks = data['tasks'] as List<dynamic>?;
    if (tasks == null || tasks.isEmpty) {
      errors.add('At least one task is required');
    } else {
      for (var i = 0; i < tasks.length; i++) {
        final task = tasks[i] as Map<String, dynamic>;
        if (task['title'] == null || (task['title'] as String).isEmpty) {
          errors.add('Task ${i + 1} is missing a title');
        }
        if (task['successCriteria'] == null ||
            (task['successCriteria'] as List).isEmpty) {
          errors.add('Task ${i + 1} needs at least one success criterion');
        }
      }
    }

    if (errors.isNotEmpty) {
      return ValidationResult.failure(errors);
    }

    return ValidationResult.success(json);
  }

  /// Validate wise feedback response
  ValidationResult validateWiseFeedback(String jsonString) {
    final baseResult = _validateBaseStructure(jsonString, 'wise_feedback');
    if (!baseResult.isValid) return baseResult;

    final json = baseResult.parsedJson!;
    final errors = <String>[];

    // Validate data structure
    final data = json['data'] as Map<String, dynamic>?;
    if (data == null) {
      errors.add('Missing "data" field');
      return ValidationResult.failure(errors);
    }

    // Validate required feedback fields
    final requiredFields = [
      'acknowledgment',
      'normalization',
      'reframe',
      'encouragement',
      'suggestion',
    ];
    for (final field in requiredFields) {
      if (data[field] == null || (data[field] as String).isEmpty) {
        errors.add('Missing or empty "$field" field');
      }
    }

    if (errors.isNotEmpty) {
      return ValidationResult.failure(errors);
    }

    return ValidationResult.success(json);
  }

  /// Validate base JSON structure
  ValidationResult _validateBaseStructure(
    String jsonString,
    String expectedType,
  ) {
    final errors = <String>[];

    // Try to parse JSON
    Map<String, dynamic> json;
    try {
      json = jsonDecode(jsonString) as Map<String, dynamic>;
    } on FormatException catch (e) {
      return ValidationResult.failure(['Invalid JSON format: ${e.message}']);
    } catch (e) {
      return ValidationResult.failure(['Failed to parse JSON: $e']);
    }

    // Validate type field
    final type = json['type'] as String?;
    if (type == null) {
      errors.add('Missing "type" field');
    } else if (type != expectedType) {
      errors.add('Expected type "$expectedType" but got "$type"');
    }

    // Validate version field
    final version = json['version'] as String?;
    if (version == null) {
      errors.add('Missing "version" field');
    }

    if (errors.isNotEmpty) {
      return ValidationResult.failure(errors);
    }

    return ValidationResult.success(json);
  }

  /// Try to extract JSON from a string that might have extra text
  String? extractJson(String text) {
    // Find the first { and last }
    final firstBrace = text.indexOf('{');
    final lastBrace = text.lastIndexOf('}');

    if (firstBrace == -1 || lastBrace == -1 || lastBrace < firstBrace) {
      return null;
    }

    return text.substring(firstBrace, lastBrace + 1);
  }

  /// Clean LLM response to extract valid JSON
  static String cleanLlmResponse(String response) {
    // Remove markdown code blocks
    String cleaned = response
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*$'), '');

    // Find JSON object boundaries
    final firstBrace = cleaned.indexOf('{');
    final lastBrace = cleaned.lastIndexOf('}');

    if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
      cleaned = cleaned.substring(firstBrace, lastBrace + 1);
    }

    return cleaned.trim();
  }
}
