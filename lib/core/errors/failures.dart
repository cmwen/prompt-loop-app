import 'package:equatable/equatable.dart';

/// Base class for domain-level failures
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Database operation failure
class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message, super.code});
}

/// LLM service failure
class LlmFailure extends Failure {
  const LlmFailure({required super.message, super.code});

  factory LlmFailure.apiError(String details) =>
      LlmFailure(message: 'API error: $details', code: 'LLM_API_ERROR');

  factory LlmFailure.parseError(String details) => LlmFailure(
    message: 'Failed to parse response: $details',
    code: 'LLM_PARSE_ERROR',
  );

  factory LlmFailure.validationError(List<String> errors) => LlmFailure(
    message: 'Validation failed: ${errors.join(", ")}',
    code: 'LLM_VALIDATION_ERROR',
  );

  factory LlmFailure.networkError() => const LlmFailure(
    message: 'Network error. Please check your connection.',
    code: 'LLM_NETWORK_ERROR',
  );

  factory LlmFailure.invalidApiKey() => const LlmFailure(
    message: 'Invalid API key. Please check your settings.',
    code: 'LLM_INVALID_API_KEY',
  );
}

/// Validation failure
class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;

  const ValidationFailure({
    required super.message,
    this.fieldErrors = const {},
    super.code,
  });

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, super.code});
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}
