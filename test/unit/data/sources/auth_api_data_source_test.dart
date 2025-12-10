import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:siren_marketplace/core/data/api/api_client.dart';
import 'package:siren_marketplace/core/data/api/api_config.dart';
import 'package:siren_marketplace/core/data/sources/api/auth_api_data_source.dart';

@GenerateNiceMocks([MockSpec<ApiClient>()])
import 'auth_api_data_source_test.mocks.dart';

void main() {
  late AuthApiDataSource dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = AuthApiDataSource(client: mockApiClient);
  });

  group('AuthApiDataSource', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    const tToken = 'jwt_token_example';
    const tAccountId = 'acc_123';

    test('login should return AuthorizeResponse when successful', () async {
      // Arrange
      final responseData = {
        'token': tToken,
        'account': {
          'id': tAccountId,
          'email': tEmail,
          'role': 'buyer',
          'rating': 4.5,
        },
      };

      when(
        mockApiClient.post(ApiConfig.login, data: anyNamed('data')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiConfig.login),
          data: responseData,
          statusCode: 200,
        ),
      );

      // Act
      final result = await dataSource.login(tEmail, tPassword);

      // Assert
      expect(result.token, tToken);
      expect(result.account.id, tAccountId);
      expect(result.account.email, tEmail);
      verify(
        mockApiClient.post(ApiConfig.login, data: anyNamed('data')),
      ).called(1);
    });

    test('logout should call delete endpoint', () async {
      // Arrange
      when(mockApiClient.delete(ApiConfig.logout)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiConfig.logout),
          statusCode: 200,
        ),
      );

      // Act
      await dataSource.logout();

      // Assert
      verify(mockApiClient.delete(ApiConfig.logout)).called(1);
    });
  });
}
