import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/env.dart';
import '../constants/api_constants.dart';
import 'api_exception.dart';

/// Thin HTTP wrapper around Dio.
///
/// * Injects the API key on every request.
/// * Normalises every failure to an [ApiException].
/// * Returns plain JSON maps/lists – providers map them to models.
///
/// Swapping the weather provider means writing a new provider class against
/// this client (or a sibling client); repositories and UI stay untouched.
class ApiClient {
  ApiClient({Dio? dio, String? apiKey, String? baseUrl})
      : _apiKey = apiKey ?? Env.openWeatherApiKey,
        _dio = dio ?? _createDio(baseUrl ?? Env.openWeatherBaseUrl) {
    _dio.interceptors.add(_ApiKeyInterceptor(_apiKey));
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: false,
          requestHeader: false,
          responseHeader: false,
          responseBody: false,
          logPrint: (message) => debugPrint('[API] $message'),
        ),
      );
    }
  }

  final Dio _dio;
  final String _apiKey;

  bool get hasApiKey => _apiKey.isNotEmpty;

  static Dio _createDio(String baseUrl) => Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: ApiConstants.connectTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
          responseType: ResponseType.json,
          headers: const {'Accept': 'application/json'},
        ),
      );

  /// GET returning a JSON object. Throws [EmptyResponseException] on an
  /// empty body because every object endpoint we use must return data.
  Future<Map<String, dynamic>> getMap(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    final data = await _get(path, queryParameters, cancelToken);
    if (data is Map<String, dynamic>) {
      if (data.isEmpty) throw const EmptyResponseException();
      return data;
    }
    if (data is Map) {
      if (data.isEmpty) throw const EmptyResponseException();
      return Map<String, dynamic>.from(data);
    }
    throw const UnknownApiException('Expected a JSON object.');
  }

  /// GET returning a JSON array. An empty array is a valid result
  /// (e.g. no cities matched a search), so it is returned as-is.
  Future<List<dynamic>> getList(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    final data = await _get(path, queryParameters, cancelToken);
    if (data is List) return data;
    if (data == null) return const [];
    throw const UnknownApiException('Expected a JSON array.');
  }

  Future<dynamic> _get(
    String path,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  ) async {
    if (!hasApiKey) throw const MissingApiKeyException();
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      if (response.data == null) throw const EmptyResponseException();
      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

class _ApiKeyInterceptor extends Interceptor {
  const _ApiKeyInterceptor(this.apiKey);

  final String apiKey;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters['appid'] = apiKey;
    handler.next(options);
  }
}
