import 'dart:async';
import 'tools.dart';

/// Base class for chains - composable processing units
abstract class Chain {
  /// Process input and return output
  Future<ChainOutput> call(ChainInput input);
}

/// Input for a chain
class ChainInput {
  final String text;
  final Map<String, dynamic> metadata;

  ChainInput(this.text, {this.metadata = const {}});

  @override
  String toString() => 'ChainInput(text: $text)';
}

/// Output from a chain
class ChainOutput {
  final String text;
  final Map<String, dynamic> metadata;

  ChainOutput(this.text, {this.metadata = const {}});

  @override
  String toString() => 'ChainOutput(text: $text)';
}

/// Base class for agents
abstract class Agent {
  /// Run the agent with an input query
  Future<AgentResponse> run(String input);

  /// Run the agent with tools available
  Future<AgentResponse> runWithTools(String input, List<Tool> tools);
}

/// Response from an agent
class AgentResponse {
  /// Final response text
  final String response;

  /// List of intermediate steps taken
  final List<AgentStep> steps;

  /// Whether the agent completed successfully
  final bool success;

  /// Optional error message
  final String? error;

  const AgentResponse({
    required this.response,
    required this.steps,
    this.success = true,
    this.error,
  });

  @override
  String toString() =>
      'AgentResponse(success: $success, steps: ${steps.length})';
}

/// A step taken by an agent
class AgentStep {
  /// Type of step: 'thought', 'tool_call', 'tool_result', 'answer'
  final String type;

  /// Content of the step
  final String content;

  /// Tool name if this is a tool-related step
  final String? toolName;

  /// Tool arguments if this is a tool call
  final Map<String, dynamic>? toolArgs;

  /// Timestamp of the step
  final DateTime timestamp;

  AgentStep({
    required this.type,
    required this.content,
    this.toolName,
    this.toolArgs,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => 'AgentStep(type: $type, tool: $toolName)';
}
