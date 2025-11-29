/// Network Service Placeholder
///
/// This file provides a template for implementing network functionality.
/// The template intentionally doesn't include an HTTP client by default
/// to keep dependencies minimal.
///
/// ## Adding Network Support
///
/// To add HTTP networking, add the `http` package to your pubspec.yaml:
///
/// ```yaml
/// dependencies:
///   http: ^1.2.0
/// ```
///
/// Then run `flutter pub get` and implement your network service.
///
/// ## Example Implementation
///
/// ```dart
/// import 'dart:convert';
/// import 'package:http/http.dart' as http;
///
/// class NetworkService {
///   final String baseUrl;
///   final http.Client _client;
///
///   NetworkService({
///     required this.baseUrl,
///     http.Client? client,
///   }) : _client = client ?? http.Client();
///
///   /// Performs a GET request to the specified [endpoint].
///   ///
///   /// Returns the decoded JSON response.
///   /// Throws [NetworkException] on failure.
///   Future<Map<String, dynamic>> get(
///     String endpoint, {
///     Map<String, String>? headers,
///   }) async {
///     final uri = Uri.parse('$baseUrl$endpoint');
///     final response = await _client.get(
///       uri,
///       headers: {
///         'Content-Type': 'application/json',
///         ...?headers,
///       },
///     );
///
///     return _handleResponse(response);
///   }
///
///   /// Performs a POST request to the specified [endpoint].
///   ///
///   /// [body] will be JSON encoded before sending.
///   /// Returns the decoded JSON response.
///   /// Throws [NetworkException] on failure.
///   Future<Map<String, dynamic>> post(
///     String endpoint, {
///     Map<String, dynamic>? body,
///     Map<String, String>? headers,
///   }) async {
///     final uri = Uri.parse('$baseUrl$endpoint');
///     final response = await _client.post(
///       uri,
///       headers: {
///         'Content-Type': 'application/json',
///         ...?headers,
///       },
///       body: body != null ? jsonEncode(body) : null,
///     );
///
///     return _handleResponse(response);
///   }
///
///   Map<String, dynamic> _handleResponse(http.Response response) {
///     if (response.statusCode >= 200 && response.statusCode < 300) {
///       if (response.body.isEmpty) {
///         return {};
///       }
///       return jsonDecode(response.body) as Map<String, dynamic>;
///     }
///
///     throw NetworkException(
///       statusCode: response.statusCode,
///       message: response.body,
///     );
///   }
///
///   void dispose() {
///     _client.close();
///   }
/// }
///
/// class NetworkException implements Exception {
///   final int statusCode;
///   final String message;
///
///   NetworkException({
///     required this.statusCode,
///     required this.message,
///   });
///
///   @override
///   String toString() => 'NetworkException: $statusCode - $message';
/// }
/// ```
///
/// ## Alternative Packages
///
/// For more advanced networking needs, consider:
///
/// - **dio** (^5.4.0): Feature-rich HTTP client with interceptors,
///   global configuration, FormData, request cancellation, and more.
///
/// - **retrofit** (^4.1.0): Type-safe REST API client generator
///   that works with dio.
///
/// - **chopper** (^7.2.0): Another type-safe HTTP client with
///   built-in converter support.
///
/// ## Network Security
///
/// This template includes a network security configuration that:
/// - Disables cleartext (HTTP) traffic by default
/// - Allows localhost connections for development
/// - Allows 10.0.2.2 for Android emulator
///
/// See: android/app/src/main/res/xml/network_security_config.xml
library;
