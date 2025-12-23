import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:siren_marketplace/core/data/api/api_interceptor.dart';
import 'package:siren_marketplace/core/data/storage/token_storage.dart';

@GenerateNiceMocks([
  MockSpec<TokenStorage>(),
  MockSpec<Dio>(),
  MockSpec<ErrorInterceptorHandler>(),
])
import 'api_interceptor_test.mocks.dart';

void main() {
  late ApiInterceptor interceptor;
  late MockTokenStorage mockTokenStorage;
  late MockDio mockDio;
  late MockErrorInterceptorHandler mockHandler;

  setUp(() {
    mockTokenStorage = MockTokenStorage();
    mockDio = MockDio();
    mockHandler = MockErrorInterceptorHandler();
    interceptor = ApiInterceptor(mockTokenStorage, mockDio);
  });

  group('ApiInterceptor onError', () {
    test('should propagate 401 error if message implies permission denied', () async {
      // Arrange
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 401,
        data: {'detail': 'You do not have access to this product'},
      );
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: response,
        type: DioExceptionType.badResponse,
      );

      // Act
      await interceptor.onError(error, mockHandler);

      // Assert
      // Should call handler.next(err) immediately without trying refresh
      verify(mockHandler.next(error)).called(1);
      // Ensure we didn't try to get token for refresh (simplest way to check we didn't enter refresh logic)
      // Note: _tryRefreshToken calls getAccessToken. verifyNever(mockTokenStorage.getAccessToken()) might be valid
      // BUT getAccessToken is also called in onRequest.
      // Ideally we check logs or state, but since _tryRefreshToken is private, we infer behavior from the output.
      // If refresh logic WAS entered, it would likely fail or do other things.
      // But purely calling handler.next(err) with the ORIGINAL error means we skipped the refresh attempt
      // (because successful refresh would retry, failed refresh would reject/clear tokens).
    });

    test('should propagate 401 error if message says Access denied', () async {
      // Arrange
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 401,
        data: {'message': 'Access denied'},
      );
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: response,
        type: DioExceptionType.badResponse,
      );

      // Act
      await interceptor.onError(error, mockHandler);

      // Assert
      verify(mockHandler.next(error)).called(1);
    });
  });
}
