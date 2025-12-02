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
  /// This method handles common LLM response issues:
  /// - Markdown code blocks (```json ... ```)
  /// - Extra text before/after JSON
  /// - Smart quotes and other unicode issues
  /// - Whitespace and BOM characters
  static String cleanLlmResponse(String response) {
    var cleaned = response.trim();

    // Step 1: Remove BOM and other invisible characters
    cleaned = cleaned.replaceAll('\uFEFF', '').replaceAll('\u200B', '');

    // Step 2: Remove markdown code blocks (handle various formats)
    // Match ```json, ```JSON, or just ``` with content
    final codeBlockPattern = RegExp(
      r'```(?:json|JSON)?\s*([\s\S]*?)\s*```',
      multiLine: true,
    );
    final codeBlockMatch = codeBlockPattern.firstMatch(cleaned);
    if (codeBlockMatch != null && codeBlockMatch.group(1) != null) {
      cleaned = codeBlockMatch.group(1)!;
    }

    // Step 3: Find JSON object boundaries (first { to last })
    final firstBrace = cleaned.indexOf('{');
    final lastBrace = cleaned.lastIndexOf('}');

    if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
      cleaned = cleaned.substring(firstBrace, lastBrace + 1);
    }

    // Step 4: Fix common unicode character issues
    cleaned = cleaned
        // Smart/curly double quotes to straight quotes
        .replaceAll('"', '"')
        .replaceAll('"', '"')
        .replaceAll('„', '"')
        .replaceAll('‟', '"')
        // Smart/curly single quotes to straight quotes
        .replaceAll(''', "'")
        .replaceAll(''', "'")
        .replaceAll('‚', "'")
        .replaceAll('‛', "'")
        // Em/en dashes to hyphens
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        // Ellipsis to three dots
        .replaceAll('…', '...');

    // Step 5: Remove any remaining control characters except newlines and tabs
    cleaned = cleaned.replaceAll(
      RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'),
      '',
    );

    return cleaned.trim();
  }

  /// Validates and attempts to fix JSON, returning detailed error info
  static JsonParseResult parseWithDiagnostics(String response) {
    final steps = <String>[];
    String cleaned = response;

    // Step 1: Clean the response
    steps.add('Extracting JSON from response...');
    cleaned = cleanLlmResponse(response);

    if (cleaned.isEmpty) {
      return JsonParseResult(
        success: false,
        error: 'No JSON content found in response',
        steps: steps,
        suggestion:
            'Make sure the AI response contains a JSON object starting with { and ending with }',
      );
    }

    steps.add('JSON block found');

    // Step 2: Try to parse
    steps.add('Parsing JSON...');
    try {
      final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
      steps.add('JSON parsed successfully');
      return JsonParseResult(success: true, data: parsed, steps: steps);
    } on FormatException catch (e) {
      final errorMessage = e.message;
      String suggestion = 'Check that the JSON is properly formatted';

      // Provide helpful suggestions based on common errors
      if (errorMessage.contains('Unexpected character')) {
        suggestion =
            'The response may contain extra text. Try asking the AI to respond with ONLY JSON, no additional text.';
      } else if (errorMessage.contains('Unterminated string')) {
        suggestion =
            'A string value is not properly closed with quotes. Check for missing " characters.';
      } else if (errorMessage.contains('Expected')) {
        suggestion =
            'The JSON structure is incomplete. Make sure you copied the entire response.';
      }

      return JsonParseResult(
        success: false,
        error: 'Invalid JSON: $errorMessage',
        steps: steps,
        suggestion: suggestion,
        rawCleaned: cleaned,
      );
    } catch (e) {
      return JsonParseResult(
        success: false,
        error: 'Failed to parse: $e',
        steps: steps,
        suggestion:
            'An unexpected error occurred. Try copying the response again.',
        rawCleaned: cleaned,
      );
    }
  }
}

/// Result of parsing JSON with diagnostics
class JsonParseResult {
  final bool success;
  final Map<String, dynamic>? data;
  final String? error;
  final List<String> steps;
  final String? suggestion;
  final String? rawCleaned;

  const JsonParseResult({
    required this.success,
    this.data,
    this.error,
    this.steps = const [],
    this.suggestion,
    this.rawCleaned,
  });
}
