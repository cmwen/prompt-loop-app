import 'ollama_message.dart';
import 'ollama_tool.dart';

/// Request for Ollama generate API
class OllamaGenerateRequest {
  /// Model name to use
  final String model;

  /// Prompt text
  final String prompt;

  /// Whether to stream the response
  final bool stream;

  /// Optional model parameters (temperature, top_p, etc.)
  final Map<String, dynamic>? options;

  /// System prompt
  final String? system;

  /// Conversation context from previous requests
  final List<int>? context;

  const OllamaGenerateRequest({
    required this.model,
    required this.prompt,
    this.stream = false,
    this.options,
    this.system,
    this.context,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'model': model,
      'prompt': prompt,
      'stream': stream,
    };

    if (options != null) json['options'] = options;
    if (system != null) json['system'] = system;
    if (context != null) json['context'] = context;

    return json;
  }
}

/// Request for Ollama chat API
class OllamaChatRequest {
  /// Model name to use
  final String model;

  /// List of messages in the conversation
  final List<OllamaMessage> messages;

  /// Whether to stream the response
  final bool stream;

  /// Optional model parameters
  final Map<String, dynamic>? options;

  /// Optional tools that the model can call
  final List<ToolDefinition>? tools;

  const OllamaChatRequest({
    required this.model,
    required this.messages,
    this.stream = false,
    this.options,
    this.tools,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'model': model,
      'messages': messages.map((m) => m.toJson()).toList(),
      'stream': stream,
    };

    if (options != null) json['options'] = options;
    if (tools != null && tools!.isNotEmpty) {
      json['tools'] = tools!.map((t) => t.toJson()).toList();
    }

    return json;
  }
}

/// Request for Ollama embeddings API
class OllamaEmbeddingRequest {
  /// Model name to use
  final String model;

  /// Text to generate embeddings for
  final String prompt;

  /// Optional model parameters
  final Map<String, dynamic>? options;

  const OllamaEmbeddingRequest({
    required this.model,
    required this.prompt,
    this.options,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'model': model, 'prompt': prompt};

    if (options != null) json['options'] = options;

    return json;
  }
}
