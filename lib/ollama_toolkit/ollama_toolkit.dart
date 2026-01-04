/// Ollama Toolkit - Complete Ollama integration for Flutter
///
/// This library provides:
/// - Full Ollama API client (chat, generate, embeddings)
/// - Model registry with capabilities (tool calling, vision, thinking)
/// - LangChain-inspired agent framework
/// - Configuration management with SharedPreferences
/// - UI components for Ollama integration
///
/// Example:
/// ```dart
/// // Create client
/// final client = OllamaClient(baseUrl: 'http://localhost:11434');
///
/// // Simple chat
/// final response = await client.chat(
///   'llama3.2',
///   [OllamaMessage.user('Hello!')],
/// );
///
/// // Agent with tools
/// final agent = OllamaAgent(
///   client: client,
///   model: 'llama3.2',
/// );
///
/// final result = await agent.runWithTools(
///   'What is 2+2?',
///   [CalculatorTool()],
/// );
/// ```
library;

// Models
export 'models/ollama_message.dart';
export 'models/ollama_model.dart';
export 'models/ollama_request.dart';
export 'models/ollama_response.dart';
export 'models/ollama_tool.dart';

// Services
export 'services/ollama_client.dart';
export 'services/ollama_config_service.dart';

// Thinking Loop
export 'thinking_loop/agent.dart';
export 'thinking_loop/memory.dart';
export 'thinking_loop/ollama_agent.dart';
export 'thinking_loop/tools.dart';
