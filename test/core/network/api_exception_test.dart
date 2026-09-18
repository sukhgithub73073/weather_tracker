import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weathertracker/core/network/api_exception.dart';

void main() {
  final options = RequestOptions(path: '/data/2.5/weather');

  DioException dioError(DioExceptionType type, {int? status, dynamic data, Object? error}) {
    return DioException(
      requestOptions: options,
      type: type,
      error: error,
      response: status == null
          ? null
          : Response<dynamic>(requestOptions: options, statusCode: status, data: data),
    );
  }

  group('ApiException.fromDio', () {
    test('timeouts map to NetworkTimeoutException', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        final exception = ApiException.fromDio(dioError(type));
        expect(exception, isA<NetworkTimeoutException>());
        expect(exception.isRetryable, isTrue);
      }
    });

    test('connection errors map to NoInternetException', () {
      expect(
        ApiException.fromDio(dioError(DioExceptionType.connectionError)),
        isA<NoInternetException>(),
      );
    });

    test('cancelled requests map to RequestCancelledException', () {
      expect(
        ApiException.fromDio(dioError(DioExceptionType.cancel)),
        isA<RequestCancelledException>(),
      );
    });

    test('401 maps to InvalidApiKeyException with the API message', () {
      final exception = ApiException.fromDio(dioError(
        DioExceptionType.badResponse,
        status: 401,
        data: {'cod': 401, 'message': 'Invalid API key.'},
      ));
      expect(exception, isA<InvalidApiKeyException>());
      expect(exception.message, 'Invalid API key.');
      expect(exception.statusCode, 401);
      expect(exception.isRetryable, isFalse);
    });

    test('404 maps to NotFoundException', () {
      final exception = ApiException.fromDio(dioError(
        DioExceptionType.badResponse,
        status: 404,
        data: {'cod': '404', 'message': 'city not found'},
      ));
      expect(exception, isA<NotFoundException>());
      expect(exception.message, 'city not found');
    });

    test('429 maps to RateLimitException', () {
      expect(
        ApiException.fromDio(dioError(DioExceptionType.badResponse, status: 429)),
        isA<RateLimitException>(),
      );
    });

    test('5xx maps to ServerException and keeps the status code', () {
      final exception = ApiException.fromDio(
        dioError(DioExceptionType.badResponse, status: 503),
      );
      expect(exception, isA<ServerException>());
      expect(exception.statusCode, 503);
      expect(exception.isRetryable, isTrue);
    });

    test('other 4xx map to UnknownApiException', () {
      expect(
        ApiException.fromDio(dioError(DioExceptionType.badResponse, status: 418)),
        isA<UnknownApiException>(),
      );
    });
  });

  test('every exception exposes a non-empty user message', () {
    const exceptions = <ApiException>[
      NoInternetException(),
      NetworkTimeoutException(),
      InvalidApiKeyException(),
      MissingApiKeyException(),
      RateLimitException(),
      NotFoundException(),
      ServerException('boom', statusCode: 500),
      EmptyResponseException(),
      RequestCancelledException(),
      UnknownApiException('?'),
    ];
    for (final exception in exceptions) {
      expect(exception.userMessage, isNotEmpty, reason: exception.toString());
    }
  });

  test('extractMessage reads OpenWeatherMap error bodies', () {
    expect(ApiException.extractMessage({'message': 'nope'}), 'nope');
    expect(ApiException.extractMessage('plain text'), 'plain text');
    expect(ApiException.extractMessage({'cod': 500}), isNull);
    expect(ApiException.extractMessage(null), isNull);
  });
}
