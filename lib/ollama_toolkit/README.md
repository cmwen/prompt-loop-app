# Ollama Toolkit

A comprehensive Flutter toolkit for integrating Ollama LLMs into Android apps.

## Features

- 🚀 **Full Ollama API Support**: Generate, chat, embeddings, model management
- 🧠 **Model Registry**: Capabilities database for 15+ models (tool calling, vision, thinking)
- 🤖 **Agent Framework**: LangChain-inspired thinking loops with tool support
- 💾 **Configuration Service**: Persist settings with SharedPreferences
- 🎨 **UI Components**: Pre-built configuration screens (coming soon)
- 🔧 **Zero External Dependencies**: Only uses `http` and existing dependencies

## Quick Start

### 1. Import the Toolkit

```dart
import 'package:min_flutter_template/ollama_toolkit/ollama_toolkit.dart';
```

### 2. Create a Client

```dart
final client = OllamaClient(
  baseUrl: 'http://localhost:11434',
  timeout: Duration(seconds: 60),
);
```

### 3. Simple Chat

```dart
final response = await client.chat(
  'llama3.2',
  [
    OllamaMessage.user('Tell me a joke!'),
  ],
);

print(response.message.content);
```

### 4. Streaming Chat

```dart
await for (final chunk in client.chatStream('llama3.2', messages)) {
  print(chunk.message.content);
}
```

## Agent Framework

### Basic Agent

```dart
final agent = OllamaAgent(
  client: client,
  model: 'llama3.2',
  systemPrompt: 'You are a helpful assistant.',
);

final result = await agent.run('What is the capital of France?');
print(result.response);
```

### Agent with Tools

```dart
final agent = OllamaAgent(
  client: client,
  model: 'llama3.2',
);

final tools = [
  CalculatorTool(),
  CurrentTimeTool(),
];

final result = await agent.runWithTools(
  'What is 25 * 4 and what time is it?',
  tools,
);

print(result.response);
for (final step in result.steps) {
  print('${step.type}: ${step.content}');
}
```

### Custom Tools

```dart
class WeatherTool extends Tool {
  @override
  String get name => 'get_weather';

  @override
  String get description => 'Get current weather for a city';

  @override
  Map<String, dynamic> get parameters => {
    'type': 'object',
    'properties': {
      'city': {
        'type': 'string',
        'description': 'City name',
      },
    },
    'required': ['city'],
  };

  @override
  Future<String> execute(Map<String, dynamic> args) async {
    final city = args['city'] as String;
    // Call weather API here
    return 'Weather in $city: Sunny, 72°F';
  }
}
```

## Model Registry

Check model capabilities before using:

```dart
// Check if model supports tool calling
final supportsTools = ModelRegistry.supportsToolCalling('llama3.2');

// Get full capabilities
final caps = ModelRegistry.getCapabilities('qwen2.5');
print(caps?.contextWindow); // 128000

// Find models by capability
final toolModels = ModelRegistry.findModelsByCapability(
  supportsToolCalling: true,
  supportsVision: true,
);
```

### Supported Models

| Model | Tool Calling | Vision | Thinking | Context |
|-------|-------------|--------|----------|---------|
| llama3.2 | ✅ | ✅ | ❌ | 128k |
| llama3.3 | ✅ | ✅ | ❌ | 128k |
| qwen2.5 | ✅ | ❌ | ❌ | 128k |
| qwen2.5-coder | ✅ | ❌ | ❌ | 128k |
| deepseek-v3 | ✅ | ❌ | ✅ | 128k |
| mistral | ✅ | ❌ | ❌ | 128k |
| mixtral | ✅ | ❌ | ❌ | 128k |
| codestral | ✅ | ❌ | ❌ | 128k |
| pixtral | ✅ | ✅ | ❌ | 128k |
| gemma2 | ✅ | ❌ | ❌ | 128k |
| phi4 | ✅ | ❌ | ❌ | 128k |

Additional community and popular models:

| vicuna-13b | ❌ | ❌ | ❌ | 8k |
| vicuna-7b | ❌ | ❌ | ❌ | 8k |
| alpaca-7b | ❌ | ❌ | ❌ | 8k |
| llama2-70b | ✅ | ❌ | ❌ | 131k |
| gpt4all-j | ❌ | ❌ | ❌ | 8k |
| mpt-30b | ❌ | ❌ | ❌ | 65k |

| gpt-oss | ✅ | ❌ | ✅ | 131k |
| gemma3 | ✅ | ✅ | ❌ | 131k |
| qwen3 | ✅ | ❌ | ✅ | 131k |
| ministral-3 | ✅ | ✅ | ❌ | 131k |

For the most up-to-date list of models available through Ollama and community pulls, see https://ollama.com/search

## Configuration Service

Persist Ollama settings:

```dart
final config = OllamaConfigService();

// Set base URL
await config.setBaseUrl('http://192.168.1.100:11434');

// Set default model
await config.setDefaultModel('llama3.2');

// Get configuration
final baseUrl = await config.getBaseUrl();
final model = await config.getDefaultModel();

// Model history (recently used)
await config.setLastUsedModel('qwen2.5');
final history = await config.getModelHistory();
```

## Memory Management

Control conversation history:

```dart
// Unlimited memory
final memory = ConversationMemory();

// Sliding window (last N messages)
final memory = SlidingWindowMemory(windowSize: 10);

// System prompt + sliding window
final memory = SystemPlusSlidingMemory(windowSize: 10);

final agent = OllamaAgent(
  client: client,
  model: 'llama3.2',
  memory: memory,
);
```

## API Reference

### OllamaClient

- `generate()` - Generate completion from prompt
- `generateStream()` - Streaming generation
- `chat()` - Chat with message history
- `chatStream()` - Streaming chat
- `listModels()` - List available models
- `showModel()` - Get model info
- `pullModel()` - Download model
- `deleteModel()` - Remove model
- `embeddings()` - Generate embeddings
- `testConnection()` - Test server connection

### OllamaAgent

- `run()` - Run agent with input
- `runWithTools()` - Run with tools available
- `clearMemory()` - Clear conversation history

### ModelRegistry

- `getCapabilities()` - Get model capabilities
- `findModelsByCapability()` - Search by features
- `supportsToolCalling()` - Check tool support
- `supportsVision()` - Check vision support
- `supportsThinking()` - Check thinking mode

## Architecture

```
┌─────────────────────────────────────┐
│         UI Layer (Future)           │
│  Config screens, Model selectors    │
└─────────────────────────────────────┘
              │
┌─────────────────────────────────────┐
│       Thinking Loop Framework       │
│  Agent, Memory, Tools, Chains       │
└─────────────────────────────────────┘
              │
┌─────────────────────────────────────┐
│         Service Layer               │
│  OllamaClient, ModelRegistry,       │
│  ConfigService                      │
└─────────────────────────────────────┘
```

## Testing

```bash
# Run tests
flutter test test/ollama_toolkit/

# With coverage
flutter test --coverage
```

## Examples

See `test/ollama_toolkit/` for complete examples.

## Requirements

- Flutter 3.10.1+
- Dart 3.10.1+
- Ollama server running (locally or remote)
- http: ^1.2.0

## Contributing

This toolkit is part of the min-android-app-template. Contributions welcome!

## License

Same as parent project (see LICENSE in repository root).

## AI Agent Integration

This toolkit is designed for easy AI agent integration. See `.github/skills/ollama-integration/` for the agent skill definition.

Quick AI prompts:

```
Add a chat screen using ollama_toolkit with llama3.2 model.
```

```
Create an agent that uses CalculatorTool and CurrentTimeTool.
```

```
Add Ollama configuration screen with model selection.
```
