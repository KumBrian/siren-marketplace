import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
// Import your TokenStorage service here if you have one

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl:
            "https://api.marketplace.dev.siren.dhi-cm.com/api/v1", // distinct from url path
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add Interceptors
    _dio.interceptors.addAll([
      _authInterceptor(),

      // Only log in debug mode
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    ]);
  }

  // Public getter to access the underlying Dio instance if strictly necessary
  Dio get dio => _dio;

  // Interceptor to inject the Token
  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // TODO: Fetch your token from secure storage
        // const String? token = await _storage.read(key: 'auth_token');
        const String? token = "YOUR_MOCK_TOKEN";

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Handle token refresh logic here
          // If refresh fails, log out the user
        }
        return handler.next(e);
      },
    );
  }
}
