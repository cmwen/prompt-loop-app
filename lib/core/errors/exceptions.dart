/// Base class for data-level exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Database exception
class DatabaseException extends AppException {
  const DatabaseException({required super.message, super.code});
}

/// Cache exception
class CacheException extends AppException {
  const CacheException({required super.message, super.code});
}

/// API exception
class ApiException extends AppException {
  final int? statusCode;

  const ApiException({required super.message, super.code, this.statusCode});
}

/// JSON parsing exception
class JsonParseException extends AppException {
  final String? rawJson;

  const JsonParseException({required super.message, this.rawJson, super.code});
}

/// Validation exception
class ValidationException extends AppException {
  final Map<String, String> fieldErrors;

  const ValidationException({
    required super.message,
    this.fieldErrors = const {},
    super.code,
  });
}
