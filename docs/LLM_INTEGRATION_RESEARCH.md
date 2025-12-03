# LLM Integration Research: Google Gemini & Anthropic Claude APIs

**Research Date**: December 3, 2025  
**Scope**: Investigation of Dart/Flutter packages for Google Gemini and Anthropic Claude API integration  
**Context**: Prompt Loop app using Flutter 3.10.1+, Dart 3.10.1+, currently with `langchain: ^0.7.0` and `langchain_openai: ^0.7.0`

---

## Executive Summary

This research evaluates packages for integrating Google Gemini and Anthropic Claude APIs into the Prompt Loop skill development app. **The recommended approach is to use the LangChain.dart ecosystem**, specifically `langchain_google` and `langchain_anthropic` packages, which provide a consistent interface matching the existing `langchain_openai` integration.

---

## 1. Google Gemini API Packages for Dart/Flutter

### 1.1 LangChain Google Package (`langchain_google`)

| Attribute | Details |
|-----------|---------|
| **Package Name** | `langchain_google` |
| **pub.dev URL** | https://pub.dev/packages/langchain_google |
| **Compatibility** | ✅ Compatible with `langchain: ^0.7.0` |
| **Source** | [davidmigloz/langchain_dart](https://github.com/davidmigloz/langchain_dart) |
| **Reputation** | High (Benchmark Score: 92.3) |

**Key Features:**
- `ChatGoogleGenerativeAI` - Chat model for Google AI Gemini Developer API
- `ChatVertexAI` - Chat model for GCP Vertex AI
- `ChatFirebaseVertexAI` - Chat model for Firebase Vertex AI
- `GoogleGenerativeAIEmbeddings` - Embeddings support
- Multimodal support (text + images)
- Tool calling/function calling support
- Streaming responses

**Usage Example:**
```dart
import 'package:langchain_google/langchain_google.dart';

final chatModel = ChatGoogleGenerativeAI(
  apiKey: 'YOUR_GOOGLE_API_KEY',
  defaultOptions: ChatGoogleGenerativeAIOptions(
    model: 'gemini-1.5-pro',
    temperature: 0.7,
  ),
);

final result = await chatModel.invoke(
  PromptValue.string('Analyze this skill...'),
);
print(result.output.content);
```

### 1.2 Google AI Dart Client (`googleai_dart`)

| Attribute | Details |
|-----------|---------|
| **Package Name** | `googleai_dart` |
| **pub.dev URL** | https://pub.dev/packages/googleai_dart |
| **Type** | Low-level API client (pure Dart) |
| **Source** | [davidmigloz/langchain_dart](https://github.com/davidmigloz/langchain_dart) |

**Key Notes:**
- This is the underlying client used by `langchain_google`
- Provides direct access to Google AI and Vertex AI APIs
- Pure Dart package (works without Flutter)
- More verbose than using `langchain_google` directly

**Usage Example:**
```dart
import 'package:googleai_dart/googleai_dart.dart';

final client = GoogleAIClient(
  config: GoogleAIConfig.googleAI(
    authProvider: ApiKeyProvider('YOUR_API_KEY'),
  ),
);

final response = await client.models.generateContent(
  model: 'gemini-2.5-flash',
  request: GenerateContentRequest(
    contents: [Content(parts: [TextPart('Hello')], role: 'user')],
  ),
);
```

### 1.3 Official Google Package (`google_generative_ai`) - DEPRECATED

| Attribute | Details |
|-----------|---------|
| **Package Name** | `google_generative_ai` |
| **Status** | ⚠️ **DEPRECATED** |
| **Replacement** | `firebase_ai` (Flutter-only) |

**Important Note:**
> The official `google_generative_ai` Dart package has been deprecated in favor of `firebase_ai`. However, `firebase_ai` is a Flutter package rather than a pure Dart package. The unofficial `googleai_dart` from LangChain.dart provides a pure Dart alternative.

### 1.4 Firebase AI Package (`firebase_ai`)

| Attribute | Details |
|-----------|---------|
| **Package Name** | `firebase_ai` |
| **pub.dev URL** | https://pub.dev/packages/firebase_ai |
| **Type** | Flutter-only package |
| **Integration** | `langchain_firebase` package available |

**Key Features:**
- Official Google package for Gemini/Imagen integration
- Requires Firebase setup
- Supports Vertex AI and Google AI backends
- Image generation with Imagen models
- Live/real-time generative sessions

---

## 2. Anthropic Claude API Packages for Dart/Flutter

### 2.1 LangChain Anthropic Package (`langchain_anthropic`)

| Attribute | Details |
|-----------|---------|
| **Package Name** | `langchain_anthropic` |
| **pub.dev URL** | https://pub.dev/packages/langchain_anthropic |
| **Compatibility** | ✅ Compatible with `langchain: ^0.7.0` |
| **Source** | [davidmigloz/langchain_dart](https://github.com/davidmigloz/langchain_dart) |

**Key Features:**
- `ChatAnthropic` - Main chat model class
- Supports Claude 3.5 Sonnet, Claude 3 Opus, Claude 3 Haiku
- Multimodal support (text + images)
- Tool calling/function calling support
- Streaming responses
- Message batching API for bulk requests

**Usage Example:**
```dart
import 'package:langchain_anthropic/langchain_anthropic.dart';

final chatModel = ChatAnthropic(
  apiKey: 'YOUR_ANTHROPIC_API_KEY',
  defaultOptions: ChatAnthropicOptions(
    model: 'claude-3-5-sonnet-20241022',
    temperature: 0,
  ),
);

final result = await chatModel.invoke(
  PromptValue.string('Analyze this struggle...'),
);
print(result.output.content);
```

### 2.2 Anthropic SDK Dart (`anthropic_sdk_dart`)

| Attribute | Details |
|-----------|---------|
| **Package Name** | `anthropic_sdk_dart` |
| **pub.dev URL** | https://pub.dev/packages/anthropic_sdk_dart |
| **Type** | Low-level API client (pure Dart) |
| **Source** | [davidmigloz/langchain_dart](https://github.com/davidmigloz/langchain_dart) |

**Key Notes:**
- This is the underlying client used by `langchain_anthropic`
- Provides direct access to Anthropic Messages API
- Supports message batching for cost-effective bulk processing
- Pure Dart package

**Usage Example:**
```dart
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

final client = AnthropicClient(apiKey: 'YOUR_API_KEY');

final response = await client.createMessage(
  request: CreateMessageRequest(
    model: Model.model(Models.claude35Sonnet20241022),
    maxTokens: 1024,
    messages: [
      Message(
        role: MessageRole.user,
        content: MessageContent.text('Hello, Claude!'),
      ),
    ],
  ),
);
```

---

## 3. Recommendations for Prompt Loop App

### 3.1 Recommended Package Selection

Given the existing `langchain` and `langchain_openai` setup, **use the LangChain ecosystem packages**:

| Provider | Recommended Package | Version Constraint |
|----------|--------------------|--------------------|
| Google Gemini | `langchain_google` | `^0.7.0` |
| Anthropic Claude | `langchain_anthropic` | `^0.1.0` |

**Rationale:**
1. **Consistent API**: All LangChain packages share the same interface (`ChatModel`, `invoke()`, `stream()`)
2. **Already Integrated**: The existing `LlmService` interface can be extended without changes
3. **Maintained Together**: All packages are versioned together in the LangChain.dart monorepo
4. **Feature Parity**: Tool calling, streaming, and multimodal support across all providers

### 3.2 Updated `pubspec.yaml` Dependencies

```yaml
dependencies:
  # LLM Integration (existing)
  langchain: ^0.8.0+1
  langchain_openai: ^0.8.0+1
  
  # LLM Integration (new - add these)
  langchain_google: ^0.7.0+1        # For Google Gemini
  langchain_anthropic: ^0.3.0+1     # For Anthropic Claude
```

### 3.3 Implementation Strategy

The existing `LlmService` abstract class already defines the required interface:

```dart
abstract class LlmService {
  Future<LlmResult<SkillAnalysisResult>> analyzeSkill(SkillAnalysisRequest request);
  Future<LlmResult<List<TaskSuggestion>>> generateTasks(TaskGenerationRequest request);
  Future<LlmResult<WiseFeedbackResult>> analyzeStruggle(StruggleAnalysisRequest request);
  bool get isAvailable;
  String get modeName;
}
```

Create provider-specific implementations:

```dart
// lib/data/services/gemini_llm_service.dart
class GeminiLlmService implements LlmService {
  final ChatGoogleGenerativeAI _chatModel;
  
  GeminiLlmService({required String apiKey})
      : _chatModel = ChatGoogleGenerativeAI(
          apiKey: apiKey,
          defaultOptions: ChatGoogleGenerativeAIOptions(
            model: 'gemini-1.5-pro',
            temperature: 0.7,
          ),
        );
  
  @override
  String get modeName => 'Google Gemini';
  // ... implement other methods
}

// lib/data/services/claude_llm_service.dart
class ClaudeLlmService implements LlmService {
  final ChatAnthropic _chatModel;
  
  ClaudeLlmService({required String apiKey})
      : _chatModel = ChatAnthropic(
          apiKey: apiKey,
          defaultOptions: ChatAnthropicOptions(
            model: 'claude-3-5-sonnet-20241022',
            temperature: 0.7,
          ),
        );
  
  @override
  String get modeName => 'Claude';
  // ... implement other methods
}
```

---

## 4. API Key Configuration

### 4.1 API Key Formats

| Provider | Format | Where to Obtain |
|----------|--------|-----------------|
| OpenAI | `sk-...` (51 characters) | https://platform.openai.com/api-keys |
| Google AI | `AIza...` (39 characters) | https://aistudio.google.com/app/apikey |
| Anthropic | `sk-ant-...` (variable) | https://console.anthropic.com/settings/keys |

### 4.2 API Key Naming Convention

For environment variables (development):
```bash
export OPENAI_API_KEY="sk-..."
export GOOGLE_API_KEY="AIza..."  # or GOOGLEAI_API_KEY
export ANTHROPIC_API_KEY="sk-ant-..."
```

---

## 5. Security Considerations

### 5.1 Critical Security Rules

> ⚠️ **Remember that your API key is a secret!**  
> Do not share it with others or expose it in any client-side code (browsers, apps). Production requests must be routed through your own backend server where your API key can be securely loaded from an environment variable or key management service.

### 5.2 Recommended Secure Storage for Flutter

The app already includes `flutter_secure_storage: ^9.2.4` which should be used:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiKeyStorage {
  static const _storage = FlutterSecureStorage();
  
  static const _openaiKey = 'openai_api_key';
  static const _googleKey = 'google_api_key';
  static const _anthropicKey = 'anthropic_api_key';
  
  static Future<void> saveOpenAiKey(String key) async {
    await _storage.write(key: _openaiKey, value: key);
  }
  
  static Future<String?> getOpenAiKey() async {
    return _storage.read(key: _openaiKey);
  }
  
  static Future<void> saveGoogleKey(String key) async {
    await _storage.write(key: _googleKey, value: key);
  }
  
  static Future<String?> getGoogleKey() async {
    return _storage.read(key: _googleKey);
  }
  
  static Future<void> saveAnthropicKey(String key) async {
    await _storage.write(key: _anthropicKey, value: key);
  }
  
  static Future<String?> getAnthropicKey() async {
    return _storage.read(key: _anthropicKey);
  }
  
  static Future<void> deleteAllKeys() async {
    await _storage.deleteAll();
  }
}
```

### 5.3 Security Best Practices

1. **Never hardcode API keys** in source code
2. **Use secure storage** (`flutter_secure_storage`) for user-provided keys
3. **Consider proxy architecture** for production:
   - Route API calls through your backend server
   - Keep API keys only on the server side
   - Add rate limiting and abuse prevention
4. **Validate API keys** before storing (format check, test request)
5. **Implement key rotation** reminders for users
6. **Clear keys on logout** or app uninstall
7. **Use Android Keystore / iOS Keychain** (handled by `flutter_secure_storage`)

### 5.4 BYOK (Bring Your Own Key) Pattern

Since Prompt Loop uses BYOK for LLM integration:

```dart
class LlmProviderConfig {
  final String providerName;
  final String? apiKey;
  final bool isConfigured;
  
  LlmProviderConfig({
    required this.providerName,
    this.apiKey,
  }) : isConfigured = apiKey != null && apiKey.isNotEmpty;
  
  factory LlmProviderConfig.openai(String? key) => 
    LlmProviderConfig(providerName: 'OpenAI', apiKey: key);
    
  factory LlmProviderConfig.google(String? key) => 
    LlmProviderConfig(providerName: 'Google Gemini', apiKey: key);
    
  factory LlmProviderConfig.anthropic(String? key) => 
    LlmProviderConfig(providerName: 'Anthropic Claude', apiKey: key);
}
```

---

## 6. Model Recommendations

### 6.1 Recommended Models by Use Case

| Use Case | OpenAI | Google Gemini | Anthropic Claude |
|----------|--------|---------------|------------------|
| **Skill Analysis** | `gpt-4o` | `gemini-1.5-pro` | `claude-3-5-sonnet-20241022` |
| **Task Generation** | `gpt-4o-mini` | `gemini-1.5-flash` | `claude-3-haiku-20240307` |
| **Struggle Analysis** | `gpt-4o` | `gemini-1.5-pro` | `claude-3-5-sonnet-20241022` |
| **Quick Responses** | `gpt-4o-mini` | `gemini-1.5-flash` | `claude-3-haiku-20240307` |

### 6.2 Cost Comparison (as of December 2025)

| Provider | Model | Input (per 1M tokens) | Output (per 1M tokens) |
|----------|-------|----------------------|------------------------|
| OpenAI | gpt-4o | $2.50 | $10.00 |
| OpenAI | gpt-4o-mini | $0.15 | $0.60 |
| Google | gemini-1.5-pro | $1.25 | $5.00 |
| Google | gemini-1.5-flash | $0.075 | $0.30 |
| Anthropic | claude-3.5-sonnet | $3.00 | $15.00 |
| Anthropic | claude-3-haiku | $0.25 | $1.25 |

*Note: Prices may vary. Check provider websites for current pricing.*

---

## 7. Feature Comparison Matrix

| Feature | `langchain_openai` | `langchain_google` | `langchain_anthropic` |
|---------|-------------------|-------------------|----------------------|
| Text Generation | ✅ | ✅ | ✅ |
| Chat/Conversation | ✅ | ✅ | ✅ |
| Streaming | ✅ | ✅ | ✅ |
| Tool/Function Calling | ✅ | ✅ | ✅ |
| Multimodal (Images) | ✅ | ✅ | ✅ |
| Embeddings | ✅ | ✅ | ❌ |
| JSON Mode | ✅ | ✅ | ✅ |
| System Messages | ✅ | ✅ | ✅ |
| Token Counting | ✅ | ✅ | ✅ |

---

## 8. Implementation Checklist

- [ ] Add `langchain_google: ^0.7.0` to pubspec.yaml
- [ ] Add `langchain_anthropic: ^0.1.0` to pubspec.yaml
- [ ] Run `flutter pub get`
- [ ] Create `GeminiLlmService` implementing `LlmService`
- [ ] Create `ClaudeLlmService` implementing `LlmService`
- [ ] Create `ApiKeyStorage` utility for secure key management
- [ ] Update settings screen to allow provider selection
- [ ] Add API key input fields for each provider
- [ ] Implement provider switching logic
- [ ] Add error handling for API failures
- [ ] Test with each provider
- [ ] Update documentation

---

## 9. References

### Documentation
- [LangChain.dart Documentation](https://langchaindart.dev/)
- [LangChain.dart GitHub](https://github.com/davidmigloz/langchain_dart)
- [Google AI for Developers](https://ai.google.dev/)
- [Anthropic API Documentation](https://docs.anthropic.com/)

### Package Links
- [langchain on pub.dev](https://pub.dev/packages/langchain)
- [langchain_google on pub.dev](https://pub.dev/packages/langchain_google)
- [langchain_anthropic on pub.dev](https://pub.dev/packages/langchain_anthropic)
- [langchain_openai on pub.dev](https://pub.dev/packages/langchain_openai)

### API Key Portals
- [OpenAI API Keys](https://platform.openai.com/api-keys)
- [Google AI Studio API Keys](https://aistudio.google.com/app/apikey)
- [Anthropic Console](https://console.anthropic.com/settings/keys)

---

*Research conducted using Context7 documentation retrieval and pub.dev package analysis.*
