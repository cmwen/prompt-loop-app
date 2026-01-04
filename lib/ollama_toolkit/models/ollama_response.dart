import 'ollama_message.dart';

/// Response from Ollama generate API
class OllamaGenerateResponse {
  /// Model name used
  final String model;

  /// Generated text
  final String response;

  /// Whether this is the final response
  final bool done;

  /// Conversation context for continuing the conversation
  final List<int>? context;

  /// Number of tokens evaluated
  final int? evalCount;

  /// Time spent evaluating in nanoseconds
  final int? evalDuration;

  const OllamaGenerateResponse({
    required this.model,
    required this.response,
    required this.done,
    this.context,
    this.evalCount,
    this.evalDuration,
  });

  factory OllamaGenerateResponse.fromJson(Map<String, dynamic> json) {
    return OllamaGenerateResponse(
      model: json['model'] as String,
      response: json['response'] as String? ?? '',
      done: json['done'] as bool,
      context: (json['context'] as List<dynamic>?)?.cast<int>(),
      evalCount: json['eval_count'] as int?,
      evalDuration: json['eval_duration'] as int?,
    );
  }

  Duration? get evalTime {
    if (evalDuration == null) return null;
    return Duration(microseconds: evalDuration! ~/ 1000);
  }

  @override
  String toString() =>
      'OllamaGenerateResponse(model: $model, done: $done, response: ${response.substring(0, response.length > 50 ? 50 : response.length)}...)';
}

/// Response from Ollama chat API
class OllamaChatResponse {
  /// Model name used
  final String model;

  /// Message from the assistant
  final OllamaMessage message;

  /// Whether this is the final response
  final bool done;

  /// Number of tokens evaluated
  final int? evalCount;

  /// Time spent evaluating in nanoseconds
  final int? evalDuration;

  const OllamaChatResponse({
    required this.model,
    required this.message,
    required this.done,
    this.evalCount,
    this.evalDuration,
  });

  factory OllamaChatResponse.fromJson(Map<String, dynamic> json) {
    return OllamaChatResponse(
      model: json['model'] as String,
      message: OllamaMessage.fromJson(json['message'] as Map<String, dynamic>),
      done: json['done'] as bool,
      evalCount: json['eval_count'] as int?,
      evalDuration: json['eval_duration'] as int?,
    );
  }

  Duration? get evalTime {
    if (evalDuration == null) return null;
    return Duration(microseconds: evalDuration! ~/ 1000);
  }

  @override
  String toString() => 'OllamaChatResponse(model: $model, done: $done)';
}

/// Response from Ollama embeddings API
class OllamaEmbeddingResponse {
  /// Generated embedding vector
  final List<double> embedding;

  const OllamaEmbeddingResponse({required this.embedding});

  factory OllamaEmbeddingResponse.fromJson(Map<String, dynamic> json) {
    return OllamaEmbeddingResponse(
      embedding: (json['embedding'] as List<dynamic>).cast<double>(),
    );
  }

  @override
  String toString() =>
      'OllamaEmbeddingResponse(dimensions: ${embedding.length})';
}

/// Information about an Ollama model
class OllamaModelInfo {
  /// Model name
  final String name;

  /// Modified timestamp
  final DateTime modifiedAt;

  /// Model size in bytes
  final int size;

  /// Model digest/hash
  final String digest;

  /// Model details
  final Map<String, dynamic>? details;

  const OllamaModelInfo({
    required this.name,
    required this.modifiedAt,
    required this.size,
    required this.digest,
    this.details,
  });

  factory OllamaModelInfo.fromJson(Map<String, dynamic> json) {
    return OllamaModelInfo(
      name: json['name'] as String,
      modifiedAt: DateTime.parse(json['modified_at'] as String),
      size: json['size'] as int,
      digest: json['digest'] as String,
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  String toString() => 'OllamaModelInfo(name: $name, size: $sizeFormatted)';
}

/// List of models response
class OllamaModelsResponse {
  /// List of available models
  final List<OllamaModelInfo> models;

  const OllamaModelsResponse({required this.models});

  factory OllamaModelsResponse.fromJson(Map<String, dynamic> json) {
    return OllamaModelsResponse(
      models: (json['models'] as List<dynamic>)
          .map((m) => OllamaModelInfo.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String toString() => 'OllamaModelsResponse(count: ${models.length})';
}
