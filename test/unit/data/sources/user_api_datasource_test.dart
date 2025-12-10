import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:siren_marketplace/core/data/api/api_client.dart';
import 'package:siren_marketplace/core/data/api/api_config.dart';
import 'package:siren_marketplace/core/data/api/api_exception.dart';
import 'package:siren_marketplace/core/data/datasources/api/user_api_datasource.dart';

@GenerateNiceMocks([MockSpec<ApiClient>()])
import 'user_api_datasource_test.mocks.dart';

void main() {
  late UserApiDataSource dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = UserApiDataSource(client: mockApiClient);
  });

  group('UserApiDataSource', () {
    const tUserId = 'user_123';
    const tName = 'Test User';
    const tEmail = 'test@example.com';

    test('getById should return UserModel when successful', () async {
      // Arrange
      final responseData = {
        'id': tUserId,
        'name': tName,
        'email': tEmail,
        'role': 'buyer',
        'rating': 4.5,
      };

      when(mockApiClient.get(ApiConfig.account(tUserId))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiConfig.account(tUserId)),
          data: responseData,
          statusCode: 200,
        ),
      );

      // Act
      final result = await dataSource.getById(tUserId);

      // Assert
      expect(result, isNotNull);
      expect(result!.id, tUserId);
      expect(result.name, tName);
      verify(mockApiClient.get(ApiConfig.account(tUserId))).called(1);
    });

    test('getById should return null when user not found (404)', () async {
      // Arrange
      when(
        mockApiClient.get(ApiConfig.account(tUserId)),
      ).thenThrow(NotFoundException('User not found'));

      // Act
      final result = await dataSource.getById(tUserId);

      // Assert
      expect(result, isNull);
      verify(mockApiClient.get(ApiConfig.account(tUserId))).called(1);
    });
  });
}
