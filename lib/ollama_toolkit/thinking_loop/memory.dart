import '../models/ollama_message.dart';

/// Abstract base class for conversation memory
abstract class Memory {
  /// Add a message to memory
  void addMessage(OllamaMessage message);

  /// Get all messages from memory
  List<OllamaMessage> getMessages();

  /// Clear all messages from memory
  void clear();

  /// Get the number of messages in memory
  int get length;
}

/// Simple in-memory conversation history
class ConversationMemory implements Memory {
  final List<OllamaMessage> _messages = [];

  /// Optional maximum number of messages to keep
  final int? maxMessages;

  ConversationMemory({this.maxMessages});

  @override
  void addMessage(OllamaMessage message) {
    _messages.add(message);

    // Trim if exceeds max (keep most recent)
    if (maxMessages != null && _messages.length > maxMessages!) {
      _messages.removeAt(0);
    }
  }

  @override
  List<OllamaMessage> getMessages() {
    return List.unmodifiable(_messages);
  }

  @override
  void clear() {
    _messages.clear();
  }

  @override
  int get length => _messages.length;

  @override
  String toString() => 'ConversationMemory(messages: $length)';
}

/// Memory that keeps a sliding window of messages
class SlidingWindowMemory implements Memory {
  final List<OllamaMessage> _messages = [];
  final int windowSize;

  SlidingWindowMemory({required this.windowSize});

  @override
  void addMessage(OllamaMessage message) {
    _messages.add(message);

    // Keep only the last N messages
    while (_messages.length > windowSize) {
      _messages.removeAt(0);
    }
  }

  @override
  List<OllamaMessage> getMessages() {
    return List.unmodifiable(_messages);
  }

  @override
  void clear() {
    _messages.clear();
  }

  @override
  int get length => _messages.length;

  @override
  String toString() =>
      'SlidingWindowMemory(size: $windowSize, messages: $length)';
}

/// Memory that keeps system message plus sliding window
class SystemPlusSlidingMemory implements Memory {
  final List<OllamaMessage> _messages = [];
  final int windowSize;

  SystemPlusSlidingMemory({required this.windowSize});

  @override
  void addMessage(OllamaMessage message) {
    _messages.add(message);

    // Keep system messages and recent messages
    final systemMessages = _messages.where((m) => m.role == 'system').toList();
    final otherMessages = _messages.where((m) => m.role != 'system').toList();

    // Keep only last N non-system messages
    while (otherMessages.length > windowSize) {
      otherMessages.removeAt(0);
    }

    _messages.clear();
    _messages.addAll(systemMessages);
    _messages.addAll(otherMessages);
  }

  @override
  List<OllamaMessage> getMessages() {
    return List.unmodifiable(_messages);
  }

  @override
  void clear() {
    _messages.clear();
  }

  @override
  int get length => _messages.length;

  @override
  String toString() =>
      'SystemPlusSlidingMemory(windowSize: $windowSize, messages: $length)';
}
