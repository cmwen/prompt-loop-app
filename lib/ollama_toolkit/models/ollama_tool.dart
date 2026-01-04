/// Defines a tool that can be called by the model
class ToolDefinition {
  /// Name of the tool
  final String name;

  /// Description of what the tool does
  final String description;

  /// JSON Schema describing the tool's parameters
  final Map<String, dynamic> parameters;

  const ToolDefinition({
    required this.name,
    required this.description,
    required this.parameters,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': 'function',
      'function': {
        'name': name,
        'description': description,
        'parameters': parameters,
      },
    };
  }

  factory ToolDefinition.fromJson(Map<String, dynamic> json) {
    final function = json['function'] as Map<String, dynamic>;
    return ToolDefinition(
      name: function['name'] as String,
      description: function['description'] as String,
      parameters: function['parameters'] as Map<String, dynamic>,
    );
  }

  @override
  String toString() => 'ToolDefinition(name: $name)';
}

/// Result from executing a tool
class ToolResult {
  /// ID of the tool call this result is for
  final String toolCallId;

  /// Name of the tool that was executed
  final String toolName;

  /// Result of the tool execution as a string
  final String result;

  /// Whether the tool execution was successful
  final bool success;

  /// Optional error message if execution failed
  final String? error;

  const ToolResult({
    required this.toolCallId,
    required this.toolName,
    required this.result,
    this.success = true,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'tool_call_id': toolCallId,
      'tool_name': toolName,
      'result': result,
      'success': success,
      if (error != null) 'error': error,
    };
  }

  factory ToolResult.fromJson(Map<String, dynamic> json) {
    return ToolResult(
      toolCallId: json['tool_call_id'] as String,
      toolName: json['tool_name'] as String,
      result: json['result'] as String,
      success: json['success'] as bool? ?? true,
      error: json['error'] as String?,
    );
  }

  @override
  String toString() => 'ToolResult(tool: $toolName, success: $success)';
}
