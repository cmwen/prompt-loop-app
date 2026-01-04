import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ollama_message.dart';
import '../models/ollama_request.dart';
import '../models/ollama_response.dart';

/// Exception thrown when Ollama API request fails
class OllamaException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  OllamaException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() {
    if (statusCode != null) {
      return 'OllamaException: $message (status: $statusCode)';
    }
    return 'OllamaException: $message';
  }
}

/// Client for interacting with Ollama API
class OllamaClient {
  /// Base URL for Ollama server
  final String baseUrl;

  /// Timeout for HTTP requests
  final Duration timeout;

  /// HTTP client (can be injected for testing)
  final http.Client _httpClient;

  OllamaClient({
    this.baseUrl = 'http://localhost:11434',
    this.timeout = const Duration(seconds: 60),
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Generate a completion from a prompt
  Future<OllamaGenerateResponse> generate(
    String model,
    String prompt, {
    String? system,
    Map<String, dynamic>? options,
    List<int>? context,
  }) async {
    final request = OllamaGenerateRequest(
      model: model,
      prompt: prompt,
      stream: false,
      system: system,
      options: options,
      context: context,
    );

    final response = await _post('/api/generate', request.toJson());
    return OllamaGenerateResponse.fromJson(response);
  }

  /// Generate a completion with streaming
  Stream<OllamaGenerateResponse> generateStream(
    String model,
    String prompt, {
    String? system,
    Map<String, dynamic>? options,
    List<int>? context,
  }) {
    final request = OllamaGenerateRequest(
      model: model,
      prompt: prompt,
      stream: true,
      system: system,
      options: options,
      context: context,
    );

    return _postStream(
      '/api/generate',
      request.toJson(),
    ).map((json) => OllamaGenerateResponse.fromJson(json));
  }

  /// Chat with the model
  Future<OllamaChatResponse> chat(
    String model,
    List<OllamaMessage> messages, {
    Map<String, dynamic>? options,
  }) async {
    final request = OllamaChatRequest(
      model: model,
      messages: messages,
      stream: false,
      options: options,
    );

    final response = await _post('/api/chat', request.toJson());
    return OllamaChatResponse.fromJson(response);
  }

  /// Chat with streaming
  Stream<OllamaChatResponse> chatStream(
    String model,
    List<OllamaMessage> messages, {
    Map<String, dynamic>? options,
  }) {
    final request = OllamaChatRequest(
      model: model,
      messages: messages,
      stream: true,
      options: options,
    );

    return _postStream(
      '/api/chat',
      request.toJson(),
    ).map((json) => OllamaChatResponse.fromJson(json));
  }

  /// List available models
  Future<OllamaModelsResponse> listModels() async {
    final response = await _get('/api/tags');
    return OllamaModelsResponse.fromJson(response);
  }

  /// Show information about a specific model
  Future<OllamaModelInfo> showModel(String model) async {
    final response = await _post('/api/show', {'name': model});
    return OllamaModelInfo.fromJson(response);
  }

  /// Pull a model from the registry
  Future<void> pullModel(
    String model, {
    void Function(double)? onProgress,
  }) async {
    final stream = _postStream('/api/pull', {'name': model, 'stream': true});

    await for (final json in stream) {
      if (json['status'] == 'success') {
        break;
      }
      if (onProgress != null &&
          json['completed'] != null &&
          json['total'] != null) {
        final progress = (json['completed'] as num) / (json['total'] as num);
        onProgress(progress);
      }
    }
  }

  /// Delete a model
  Future<void> deleteModel(String model) async {
    await _delete('/api/delete', {'name': model});
  }

  /// Generate embeddings for text
  Future<OllamaEmbeddingResponse> embeddings(
    String model,
    String prompt, {
    Map<String, dynamic>? options,
  }) async {
    final request = OllamaEmbeddingRequest(
      model: model,
      prompt: prompt,
      options: options,
    );

    final response = await _post('/api/embeddings', request.toJson());
    return OllamaEmbeddingResponse.fromJson(response);
  }

  /// Test connection to Ollama server
  Future<bool> testConnection() async {
    try {
      await listModels();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// GET request
  Future<Map<String, dynamic>> _get(String path) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final response = await _httpClient.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw OllamaException(
          'Request failed: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw OllamaException('Request timeout after ${timeout.inSeconds}s');
    } catch (e) {
      if (e is OllamaException) rethrow;
      throw OllamaException('Request failed: $e', originalError: e);
    }
  }

  /// POST request
  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final response = await _httpClient
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw OllamaException(
          'Request failed: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw OllamaException('Request timeout after ${timeout.inSeconds}s');
    } catch (e) {
      if (e is OllamaException) rethrow;
      throw OllamaException('Request failed: $e', originalError: e);
    }
  }

  /// DELETE request
  Future<void> _delete(String path, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final response = await _httpClient
          .delete(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(timeout);

      if (response.statusCode != 200) {
        throw OllamaException(
          'Request failed: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw OllamaException('Request timeout after ${timeout.inSeconds}s');
    } catch (e) {
      if (e is OllamaException) rethrow;
      throw OllamaException('Request failed: $e', originalError: e);
    }
  }

  /// POST request with streaming response
  Stream<Map<String, dynamic>> _postStream(
    String path,
    Map<String, dynamic> body,
  ) async* {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final request = http.Request('POST', uri);
      request.headers['Content-Type'] = 'application/json';
      request.body = json.encode(body);

      final response = await _httpClient.send(request).timeout(timeout);

      if (response.statusCode != 200) {
        final errorBody = await response.stream.bytesToString();
        throw OllamaException(
          'Request failed: $errorBody',
          statusCode: response.statusCode,
        );
      }

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (line.trim().isNotEmpty) {
            try {
              yield json.decode(line) as Map<String, dynamic>;
            } catch (e) {
              // Skip invalid JSON lines
            }
          }
        }
      }
    } on TimeoutException {
      throw OllamaException('Request timeout after ${timeout.inSeconds}s');
    } catch (e) {
      if (e is OllamaException) rethrow;
      throw OllamaException('Streaming request failed: $e', originalError: e);
    }
  }

  /// Close the HTTP client
  void dispose() {
    _httpClient.close();
  }
}
