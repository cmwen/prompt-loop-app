/// Represents a message in an Ollama chat conversation.
class OllamaMessage {
  /// Role of the message sender: 'system', 'user', 'assistant', or 'tool'
  final String role;

  /// Content of the message
  final String content;

  /// Optional list of base64-encoded images for vision models
  final List<String>? images;

  /// Optional list of tool calls made by the assistant
  final List<ToolCall>? toolCalls;

  const OllamaMessage({
    required this.role,
    required this.content,
    this.images,
    this.toolCalls,
  });

  factory OllamaMessage.system(String content) {
    return OllamaMessage(role: 'system', content: content);
  }

  factory OllamaMessage.user(String content, {List<String>? images}) {
    return OllamaMessage(role: 'user', content: content, images: images);
  }

  factory OllamaMessage.assistant(String content, {List<ToolCall>? toolCalls}) {
    return OllamaMessage(
      role: 'assistant',
      content: content,
      toolCalls: toolCalls,
    );
  }

  factory OllamaMessage.tool(String content) {
    return OllamaMessage(role: 'tool', content: content);
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'role': role, 'content': content};

    if (images != null && images!.isNotEmpty) {
      json['images'] = images;
    }

    if (toolCalls != null && toolCalls!.isNotEmpty) {
      json['tool_calls'] = toolCalls!.map((tc) => tc.toJson()).toList();
    }

    return json;
  }

  factory OllamaMessage.fromJson(Map<String, dynamic> json) {
    return OllamaMessage(
      role: json['role'] as String,
      content: json['content'] as String,
      images: (json['images'] as List<dynamic>?)?.cast<String>(),
      toolCalls: (json['tool_calls'] as List<dynamic>?)
          ?.map((tc) => ToolCall.fromJson(tc as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'OllamaMessage(role: $role, content: ${content.substring(0, content.length > 50 ? 50 : content.length)}...)';
  }
}

/// Represents a tool call made by the model
class ToolCall {
  /// Unique identifier for the tool call
  final String id;

  /// Name of the tool to call
  final String name;

  /// Arguments to pass to the tool as a JSON object
  final Map<String, dynamic> arguments;

  const ToolCall({
    required this.id,
    required this.name,
    required this.arguments,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'arguments': arguments};
  }

  factory ToolCall.fromJson(Map<String, dynamic> json) {
    return ToolCall(
      id: json['id'] as String,
      name: json['name'] as String,
      arguments: json['arguments'] as Map<String, dynamic>,
    );
  }

  @override
  String toString() => 'ToolCall(id: $id, name: $name)';
}
