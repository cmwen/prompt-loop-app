/// Capabilities of a language model
class ModelCapabilities {
  /// Whether the model supports tool/function calling
  final bool supportsToolCalling;

  /// Whether the model supports vision (image inputs)
  final bool supportsVision;

  /// Whether the model supports explicit thinking/reasoning modes
  final bool supportsThinking;

  /// Maximum context window size in tokens
  final int contextWindow;

  /// Model family/series (e.g., 'llama', 'qwen', 'mistral')
  final String? modelFamily;

  /// Alternative names/versions for this model
  final List<String> aliases;

  /// Short description of the model
  final String? description;

  /// Recommended use cases
  final List<String>? useCases;

  const ModelCapabilities({
    required this.supportsToolCalling,
    required this.supportsVision,
    required this.supportsThinking,
    required this.contextWindow,
    this.modelFamily,
    this.aliases = const [],
    this.description,
    this.useCases,
  });

  @override
  String toString() {
    final features = <String>[];
    if (supportsToolCalling) features.add('🔧 tools');
    if (supportsVision) features.add('👁️ vision');
    if (supportsThinking) features.add('🧠 thinking');
    return 'ModelCapabilities(${features.join(', ')}, ctx: ${contextWindow ~/ 1000}k)';
  }
}

/// Registry of model capabilities
/// Data sourced from web research on Ollama models (2025)
class ModelRegistry {
  static const Map<String, ModelCapabilities> _registry = {
    // Llama 3.x series - Meta
    'llama3.1': ModelCapabilities(
      supportsToolCalling: true,
      supportsVision: false,
      supportsThinking: false,
      contextWindow: 128000,
      modelFamily: 'llama',
      aliases: ['llama3.1:8b', 'llama3.1:70b', 'llama3.1:405b'],
      description:
          'Meta\'s Llama 3.1 - balanced performance for most scenarios',
      useCases: ['general chat', 'tool calling', 'instruction following'],
    ),
    'llama3.2': ModelCapabilities(
      supportsToolCalling: true,
      supportsVision: true,
      supportsThinking: false,
      contextWindow: 128000,
      modelFamily: 'llama',
      aliases: ['llama3.2:1b', 'llama3.2:3b', 'llama3.2-vision'],
      description: 'Meta\'s Llama 3.2 with vision support',
      useCases: ['multimodal', 'tool calling', 'edge deployment'],
    ),
    'llama3.3': ModelCapabilities(
      supportsToolCalling: true,
      supportsVision: true,
      supportsThinking: false,
      contextWindow: 128000,
      modelFamily: 'llama',
      aliases: ['llama3.3:70b'],
      description: 'Latest Llama 3.3 with improved capabilities',
      useCases: ['long context', 'multimodal', 'tool calling'],
    ),

    // Qwen 2.x series - Alibaba
    'qwen2.5': ModelCapabilities(
      supportsToolCalling: true,
      supportsVision: false,
      supportsThinking: false,
      contextWindow: 128000,
      modelFamily: 'qwen',
      aliases: [
        'qwen2.5:0.5b',
        'qwen2.5:1.5b',
        'qwen2.5:7b',
        'qwen2.5:14b',
        'qwen2.5:32b',
        'qwen2.5:72b',
      ],
      description:
          'Alibaba\'s Qwen 2.5 - excellent for coding and structured outputs',
      useCases: [
        'coding',
        'math',
        'multilingual',
        'structured outputs',
        'tool calling',
      ],
    ),
    'qwen2.5-coder': ModelCapabilities(
      supportsToolCalling: true,
      supportsVision: false,
      supportsThinking: false,
      contextWindow: 128000,
      modelFamily: 'qwen',
      aliases: ['qwen2.5-coder:1.5b', 'qwen2.5-coder:7b', 'qwen2.5-coder:32b'],
      description: 'Qwen 2.5 specialized for coding tasks',
      useCases: ['code generation', 'code completion', 'debugging'],
    ),

    // DeepSeek series
    'deepseek-v3': ModelCapabilities(
      supportsToolCalling: true,
      supportsVision: false,
      supportsThinking: true,
      contextWindow: 128000,
      modelFamily: 'deepseek',
      aliases: ['deepseek-v3:671b'],
      description: 'DeepSeek V3 MoE - efficient reasoning and thinking',
      useCases: ['reasoning', 'math', 'coding', 'thinking mode'],
    ),
    'deepseek-coder': ModelCapabilities(
      supportsToolCalling: true,
      supportsVision: false,
      supportsThinking: false,
      contextWindow: 128000,
      modelFamily: 'deepseek',
      aliases: [
        'deepseek-coder:1.3b',
        'deepseek-coder:6.7b',
        'deepseek-coder:33b',
      ],
      description: 'DeepSeek specialized for coding',
      useCases: ['code generation', 'agentic workflows', 'tool calling'],
    ),

    // Mistral series
    'mistral': ModelCapabilities(
      supportsToolCalling: true,
      supportsVision: false,
      supportsThinking: false,
      contextWindow: 128000,
      modelFamily: 'mistral',
      aliases: ['mistral:7b', 'mistral:latest'],
      description: 'Mistral - fast and efficient open model',
      useCases: ['general chat', 'fast inference', 'local deployment'],
    ),
    'mistral-large': ModelCapabilities(
      supportsToolCalling: true,
      supportsVision: false,
      supportsThinking: false,
      contextWindow: 128000,
      modelFamily: 'mistral',
      aliases: ['mistral-large:123b'],
      description: 'Mistral Large - high performance model',
      useCases: ['complex reasoning', 'multilingual', 'tool calling'],
    ),
    'mixtral': ModelCapabilities(
      supportsToolCalling: true,
      supportsVision: false,
      supportsThinking: false,
      contextWindow: 128000,
      modelFamily: 'mistral',
      aliases: ['mixtral:8x7b', 'mixtral:8x22b'],
      description: 'Mixtral MoE - efficient and powerful',
      useCases: ['complex tasks', 'multi-step reasoning', 'tool calling'],
    ),
    'codestral': ModelCapabilities(
      supportsToolCalling: true,
      supportsVision: false,
      supportsThinking: false,
      contextWindow: 128000,
      modelFamily: 'mistral',
      aliases: ['codestral:22b'],
      description:
          'Mistral Codestral - specialized for coding and agentic tasks',
      useCases: ['code generation', 'agentic workflows', 'tool calling'],
    ),
    'pixtral': ModelCapabilities(
      supportsToolCalling: true,
      supportsVision: true,
      supportsThinking: false,
      contextWindow: 128000,
      modelFamily: 'mistral',
      aliases: ['pixtral:12b'],
      description: 'Mistral Pixtral - multimodal vision-language model',
      useCases: ['image understanding', 'multimodal', 'visual reasoning'],
    ),

    // Gemma series - Google
    'gemma2': ModelCapabilities(
      supportsToolCalling: true,
      supportsVision: false,
      supportsThinking: false,
      contextWindow: 128000,
      modelFamily: 'gemma',
      aliases: ['gemma2:2b', 'gemma2:9b', 'gemma2:27b'],
      description: 'Google Gemma 2 - lightweight and efficient',
      useCases: ['edge deployment', 'function calling', 'custom applications'],
    ),

    // Phi series - Microsoft
    'phi3': ModelCapabilities(
      supportsToolCalling: false,
      supportsVision: false,
      supportsThinking: false,
      contextWindow: 128000,
      modelFamily: 'phi',
      aliases: ['phi3:mini', 'phi3:medium'],
      description: 'Microsoft Phi-3 - compact and efficient',
      useCases: ['low-resource deployment', 'research', 'experimentation'],
    ),
    'phi4': ModelCapabilities(
      supportsToolCalling: true,
      supportsVision: false,
      supportsThinking: false,
      contextWindow: 128000,
      modelFamily: 'phi',
      aliases: ['phi4:14b'],
      description: 'Microsoft Phi-4 - improved function calling',
      useCases: ['function calling', 'edge devices', 'efficient inference'],
    ),
    // Community and other popular models
    'vicuna-13b': ModelCapabilities(
      supportsToolCalling: false,
      supportsVision: false,
      supportsThinking: false,
      contextWindow: 8192,
      modelFamily: 'vicuna',
      aliases: ['vicuna-13b-v1.3', 'vicuna-13b-1.5'],
      description: 'Vicuna 13B - strong instruction-following for chat',
      useCases: ['chat', 'instruction following', 'research'],
    ),
    'vicuna-7b': ModelCapabilities(
      supportsToolCalling: false,
      supportsVision: false,
      supportsThinking: false,
      contextWindow: 8192,
      modelFamily: 'vicuna',
      aliases: ['vicuna-7b-v1.1'],
      description: 'Vicuna 7B - lightweight instruction model',
      useCases: ['chat', 'edge experiments'],
    ),
    'alpaca-7b': ModelCapabilities(
      supportsToolCalling: false,
      supportsVision: false,
      supportsThinking: false,
      contextWindow: 8192,
      modelFamily: 'alpaca',
      aliases: ['alpaca-7b'],
      description: 'Alpaca 7B - research/instruction-tuned model',
      useCases: ['experimentation', 'instruction tuning'],
    ),
    'llama2-70b': ModelCapabilities(
      supportsToolCalling: true,
      supportsVision: false,
      supportsThinking: false,
      contextWindow: 131072,
      modelFamily: 'llama',
      aliases: ['llama2:70b', 'llama2-70b'],
      description: 'Llama 2 70B - high-capacity open model',
      useCases: ['long-context tasks', 'knowledge work', 'research'],
    ),
    'gpt4all-j': ModelCapabilities(
      supportsToolCalling: false,
      supportsVision: false,
      supportsThinking: false,
      contextWindow: 8192,
      modelFamily: 'gpt4all',
      aliases: ['gpt4all-j-v1'],
      description: 'GPT4All-J - local small-footprint model',
      useCases: ['local inference', 'experimentation'],
    ),
    'mpt-30b': ModelCapabilities(
      supportsToolCalling: false,
      supportsVision: false,
      supportsThinking: false,
      contextWindow: 65536,
      modelFamily: 'mpt',
      aliases: ['mpt-30b', 'mpt-30b-instruct'],
      description: 'MosaicML MPT-30B - high-throughput model for many tasks',
      useCases: ['inference', 'instruction following', 'batch processing'],
    ),
    // Models referenced on Ollama search results
    'gpt-oss': ModelCapabilities(
      supportsToolCalling: true,
      supportsVision: false,
      supportsThinking: true,
      contextWindow: 131072,
      modelFamily: 'gpt-oss',
      aliases: ['gpt-oss:20b', 'gpt-oss:120b'],
      description:
          'GPT-OSS - open-weight family focused on reasoning and agentic tasks',
      useCases: ['reasoning', 'agentic workflows', 'tool calling'],
    ),
    'gemma3': ModelCapabilities(
      supportsToolCalling: true,
      supportsVision: true,
      supportsThinking: false,
      contextWindow: 131072,
      modelFamily: 'gemma',
      aliases: ['gemma3:270m', 'gemma3:1b', 'gemma3:4b', 'gemma3:12b', 'gemma3:27b'],
      description: 'Gemma 3 - efficient family from Google DeepMind with vision variants',
      useCases: ['multimodal', 'edge deployment', 'tool calling'],
    ),
    'qwen3': ModelCapabilities(
      supportsToolCalling: true,
      supportsVision: false,
      supportsThinking: true,
      contextWindow: 131072,
      modelFamily: 'qwen',
      aliases: ['qwen3:0.6b', 'qwen3:1.7b', 'qwen3:4b', 'qwen3:8b', 'qwen3:14b', 'qwen3:30b', 'qwen3:235b'],
      description: 'Qwen 3 - latest Qwen series with dense and MoE variants',
      useCases: ['long-context tasks', 'tool calling', 'reasoning'],
    ),
    'ministral-3': ModelCapabilities(
      supportsToolCalling: true,
      supportsVision: true,
      supportsThinking: false,
      contextWindow: 131072,
      modelFamily: 'ministral',
      aliases: ['ministral-3:3b', 'ministral-3:8b', 'ministral-3:14b'],
      description: 'Ministral 3 - edge-focused family with vision and tool support (listed on Ollama)',
      useCases: ['edge deployment', 'multimodal', 'tool calling'],
    ),
  };

  /// Get capabilities for a specific model
  static ModelCapabilities? getCapabilities(String modelName) {
    // Normalize model name (remove tags like :8b, :latest)
    final normalizedName = _normalizeModelName(modelName);

    // Direct lookup
    if (_registry.containsKey(normalizedName)) {
      return _registry[normalizedName];
    }

    // Check aliases
    for (final entry in _registry.entries) {
      if (entry.value.aliases.contains(modelName)) {
        return entry.value;
      }
      // Check if any alias starts with the normalized name
      for (final alias in entry.value.aliases) {
        if (_normalizeModelName(alias) == normalizedName) {
          return entry.value;
        }
      }
    }

    return null;
  }

  /// Find models that support a specific capability
  static List<String> findModelsByCapability({
    bool? supportsToolCalling,
    bool? supportsVision,
    bool? supportsThinking,
    int? minContextWindow,
    String? modelFamily,
  }) {
    final results = <String>[];

    for (final entry in _registry.entries) {
      final caps = entry.value;
      var matches = true;

      if (supportsToolCalling != null &&
          caps.supportsToolCalling != supportsToolCalling) {
        matches = false;
      }
      if (supportsVision != null && caps.supportsVision != supportsVision) {
        matches = false;
      }
      if (supportsThinking != null &&
          caps.supportsThinking != supportsThinking) {
        matches = false;
      }
      if (minContextWindow != null && caps.contextWindow < minContextWindow) {
        matches = false;
      }
      if (modelFamily != null && caps.modelFamily != modelFamily) {
        matches = false;
      }

      if (matches) {
        results.add(entry.key);
      }
    }

    return results;
  }

  /// Get all registered model names
  static List<String> getAllModelNames() {
    return _registry.keys.toList();
  }

  /// Get all model families
  static List<String> getAllModelFamilies() {
    final families = <String>{};
    for (final caps in _registry.values) {
      if (caps.modelFamily != null) {
        families.add(caps.modelFamily!);
      }
    }
    return families.toList()..sort();
  }

  /// Normalize model name by removing version tags
  static String _normalizeModelName(String modelName) {
    // Remove everything after : (version tags)
    final colonIndex = modelName.indexOf(':');
    if (colonIndex != -1) {
      return modelName.substring(0, colonIndex);
    }
    return modelName;
  }

  /// Check if a model supports tool calling
  static bool supportsToolCalling(String modelName) {
    return getCapabilities(modelName)?.supportsToolCalling ?? false;
  }

  /// Check if a model supports vision
  static bool supportsVision(String modelName) {
    return getCapabilities(modelName)?.supportsVision ?? false;
  }

  /// Check if a model supports thinking mode
  static bool supportsThinking(String modelName) {
    return getCapabilities(modelName)?.supportsThinking ?? false;
  }
}
