import '../services/ollama_client.dart';
import '../models/ollama_message.dart';
import 'agent.dart';
import 'memory.dart';
import 'tools.dart';

/// Ollama-based agent implementation
class OllamaAgent implements Agent {
  final OllamaClient client;
  final String model;
  final Memory memory;
  final int maxIterations;
  final String? systemPrompt;

  OllamaAgent({
    required this.client,
    required this.model,
    Memory? memory,
    this.maxIterations = 10,
    this.systemPrompt,
  }) : memory = memory ?? ConversationMemory();

  @override
  Future<AgentResponse> run(String input) async {
    return runWithTools(input, []);
  }

  @override
  Future<AgentResponse> runWithTools(String input, List<Tool> tools) async {
    final steps = <AgentStep>[];

    try {
      // Add system prompt if provided
      if (systemPrompt != null && memory.length == 0) {
        memory.addMessage(OllamaMessage.system(systemPrompt!));
      }

      // Add user input
      memory.addMessage(OllamaMessage.user(input));
      steps.add(AgentStep(type: 'input', content: input));

      String finalResponse = '';
      var iteration = 0;

      while (iteration < maxIterations) {
        iteration++;

        // Call Ollama with current conversation and tools
        final response = await client.chat(
          model,
          memory.getMessages(),
          options: tools.isNotEmpty
              ? {'tools': tools.map((t) => t.toDefinition()).toList()}
              : null,
        );

        final message = response.message;
        memory.addMessage(message);

        // Check if model wants to call tools
        if (message.toolCalls != null && message.toolCalls!.isNotEmpty) {
          // Execute each tool call
          for (final toolCall in message.toolCalls!) {
            steps.add(
              AgentStep(
                type: 'tool_call',
                content: 'Calling ${toolCall.name}',
                toolName: toolCall.name,
                toolArgs: toolCall.arguments,
              ),
            );

            // Find and execute the tool
            final tool = tools.firstWhere(
              (t) => t.name == toolCall.name,
              orElse: () => throw Exception('Tool not found: ${toolCall.name}'),
            );

            final result = await tool.execute(toolCall.arguments);

            steps.add(
              AgentStep(
                type: 'tool_result',
                content: result,
                toolName: toolCall.name,
              ),
            );

            // Add tool result to memory
            memory.addMessage(OllamaMessage.tool(result));
          }

          // Continue loop to get next response
          continue;
        }

        // No tool calls, this is the final answer
        finalResponse = message.content;
        steps.add(AgentStep(type: 'answer', content: finalResponse));
        break;
      }

      if (iteration >= maxIterations) {
        return AgentResponse(
          response: finalResponse.isEmpty
              ? 'Max iterations reached without final answer'
              : finalResponse,
          steps: steps,
          success: false,
          error: 'Max iterations reached',
        );
      }

      return AgentResponse(
        response: finalResponse,
        steps: steps,
        success: true,
      );
    } catch (e) {
      return AgentResponse(
        response: '',
        steps: steps,
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Clear conversation memory
  void clearMemory() {
    memory.clear();
  }
}
