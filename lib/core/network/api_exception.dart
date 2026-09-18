import 'dart:io';

import 'package:dio/dio.dart';

/// Every failure that can leave the network layer.
///
/// Repositories and controllers switch over these to decide what to show,
/// so UI code never needs to know about Dio.
sealed class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  /// Developer-facing message (may contain the raw API message).
  final String message;
  final int? statusCode;

  /// Friendly message safe to show in the UI.
  String get userMessage;

  /// Whether retrying the same request could succeed.
  bool get isRetryable => false;

  factory ApiException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkTimeoutException();
      case DioExceptionType.connectionError:
        return const NoInternetException();
      case DioExceptionType.badCertificate:
        return const UnknownApiException('Secure connection failed.');
      case DioExceptionType.cancel:
        return const RequestCancelledException();
      case DioExceptionType.badResponse:
        return ApiException.fromStatusCode(
          error.response?.statusCode,
          extractMessage(error.response?.data),
        );
      case DioExceptionType.unknown:
        if (error.error is SocketException) return const NoInternetException();
        return UnknownApiException(error.message ?? 'Unexpected error.');
      case DioExceptionType.transformTimeout:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  factory ApiException.fromStatusCode(int? statusCode, [String? apiMessage]) {
    final message = apiMessage ?? 'HTTP $statusCode';
    if (statusCode == null) return UnknownApiException(message);
    if (statusCode == 401) return InvalidApiKeyException(message);
    if (statusCode == 404) return NotFoundException(message);
    if (statusCode == 429) return RateLimitException(message);
    if (statusCode >= 500) return ServerException(message, statusCode: statusCode);
    return UnknownApiException(message, statusCode: statusCode);
  }

  /// OpenWeatherMap error bodies look like `{"cod": "404", "message": "city not found"}`.
  static String? extractMessage(dynamic data) {
    if (data is Map && data['message'] is String) return data['message'] as String;
    if (data is String && data.isNotEmpty) return data;
    return null;
  }

  @override
  String toString() => '$runtimeType(statusCode: $statusCode, message: $message)';
}

class NoInternetException extends ApiException {
  const NoInternetException() : super('No internet connection.');

  @override
  String get userMessage =>
      'You appear to be offline. Check your connection and try again.';

  @override
  bool get isRetryable => true;
}

class NetworkTimeoutException extends ApiException {
  const NetworkTimeoutException() : super('The request timed out.');

  @override
  String get userMessage =>
      'The weather service is taking too long to respond. Please try again.';

  @override
  bool get isRetryable => true;
}

class InvalidApiKeyException extends ApiException {
  const InvalidApiKeyException([String message = 'Invalid API key.'])
      : super(message, statusCode: 401);

  @override
  String get userMessage =>
      'The weather API key is invalid or not yet active. Check OPENWEATHER_API_KEY in your .env file.';
}

class MissingApiKeyException extends ApiException {
  const MissingApiKeyException() : super('OPENWEATHER_API_KEY is not set.');

  @override
  String get userMessage =>
      'No weather API key configured. Add OPENWEATHER_API_KEY to your .env file.';
}

class RateLimitException extends ApiException {
  const RateLimitException([String message = 'Rate limit exceeded.'])
      : super(message, statusCode: 429);

  @override
  String get userMessage =>
      'Too many requests right now. Please wait a moment and try again.';

  @override
  bool get isRetryable => true;
}

class NotFoundException extends ApiException {
  const NotFoundException([String message = 'Not found.'])
      : super(message, statusCode: 404);

  @override
  String get userMessage =>
      "We couldn't find that location. Try a different city name.";
}

class ServerException extends ApiException {
  const ServerException(super.message, {super.statusCode});

  @override
  String get userMessage =>
      'The weather service is having trouble. Please try again later.';

  @override
  bool get isRetryable => true;
}

class EmptyResponseException extends ApiException {
  const EmptyResponseException() : super('The API returned an empty response.');

  @override
  String get userMessage => 'No weather data was returned. Please try again.';

  @override
  bool get isRetryable => true;
}

class RequestCancelledException extends ApiException {
  const RequestCancelledException() : super('Request cancelled.');

  @override
  String get userMessage => 'Request cancelled.';
}

class UnknownApiException extends ApiException {
  const UnknownApiException(super.message, {super.statusCode});

  @override
  String get userMessage => 'Something went wrong. Please try again.';

  @override
  bool get isRetryable => true;
}
