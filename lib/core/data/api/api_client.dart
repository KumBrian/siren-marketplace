import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'api_config.dart';
import 'api_exception.dart';
import 'api_interceptor.dart';
import '../storage/token_storage.dart';

/// HTTP client for API requests using Dio
class ApiClient {
  late final Dio _dio;
  final TokenStorage _tokenStorage;
  final String _baseUrl;

  /// Create API client with specified base URL
  /// Use [ApiConfig.coreBaseUrl] for auth endpoints
  /// Use [ApiConfig.marketplaceBaseUrl] for marketplace endpoints
  ApiClient({required String baseUrl, TokenStorage? tokenStorage})
    : _baseUrl = baseUrl,
      _tokenStorage = tokenStorage ?? TokenStorage() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(ApiInterceptor(_tokenStorage, _dio));

    // Add retry interceptor
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
      ),
    );

    // Add logger in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          compact: false,
        ),
      );
    }
  }

  /// Factory constructor for Core API client (authentication, accounts)
  factory ApiClient.core({TokenStorage? tokenStorage}) {
    return ApiClient(
      baseUrl: ApiConfig.coreBaseUrl,
      tokenStorage: tokenStorage,
    );
  }

  /// Factory constructor for Marketplace API client (catches, offers, etc.)
  factory ApiClient.marketplace({TokenStorage? tokenStorage}) {
    return ApiClient(
      baseUrl: ApiConfig.marketplaceBaseUrl,
      tokenStorage: tokenStorage,
    );
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors and convert to custom exceptions
  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Request timed out');

      case DioExceptionType.connectionError:
        return NetworkException('Network connection failed');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message =
            error.response?.data?['detail'] ??
            error.response?.data?['message'] ??
            error.response?.statusMessage ??
            'An error occurred';

        switch (statusCode) {
          case 401:
            return UnauthorizedException(message);
          case 404:
            return NotFoundException(message);
          case 422:
            final errors = error.response?.data?['errors'];
            return ValidationException(
              message,
              errors: errors is Map
                  ? Map<String, List<String>>.from(
                      errors.map(
                        (key, value) => MapEntry(
                          key,
                          (value as List).map((e) => e.toString()).toList(),
                        ),
                      ),
                    )
                  : null,
            );
          case 500:
          case 502:
          case 503:
            return ServerException(message);
          default:
            return ApiException(message, statusCode: statusCode);
        }

      case DioExceptionType.cancel:
        return ApiException('Request cancelled');

      default:
        return ApiException(error.message ?? 'An unexpected error occurred');
    }
  }
}
