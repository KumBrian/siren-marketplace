import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:siren_marketplace/core/data/sources/api/auth_api_data_source.dart';
import 'package:siren_marketplace/core/data/storage/token_storage.dart';
import 'package:siren_marketplace/core/domain/repositories/i_session_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_user_repository.dart';
import 'package:siren_marketplace/core/domain/services/session_service.dart';

@GenerateNiceMocks([
  MockSpec<ISessionRepository>(),
  MockSpec<IUserRepository>(),
  MockSpec<IAuthApiDataSource>(),
  MockSpec<TokenStorage>(),
])
import 'session_service_test.mocks.dart';

void main() {
  late SessionService sessionService;
  late MockISessionRepository mockSessionRepository;
  late MockIUserRepository mockUserRepository;
  late MockIAuthApiDataSource mockAuthApiDataSource;
  late MockTokenStorage mockTokenStorage;

  setUp(() {
    mockSessionRepository = MockISessionRepository();
    mockUserRepository = MockIUserRepository();
    mockAuthApiDataSource = MockIAuthApiDataSource();
    mockTokenStorage = MockTokenStorage();

    sessionService = SessionService(
      sessionRepository: mockSessionRepository,
      userRepository: mockUserRepository,
      authApiDataSource: mockAuthApiDataSource,
      tokenStorage: mockTokenStorage,
    );
  });

  group('SessionService', () {
    test('logout should call API logout and clear local sessions', () async {
      // Act
      await sessionService.logout();

      // Assert
      verify(mockAuthApiDataSource.logout()).called(1);
      verify(mockTokenStorage.clearTokens()).called(1);
      verify(mockSessionRepository.clearSession()).called(1);
    });

    test('logout should clear local sessions even if API fails', () async {
      // Arrange
      when(
        mockAuthApiDataSource.logout(),
      ).thenThrow(Exception('Network Error'));

      // Act
      await sessionService.logout();

      // Assert
      verify(mockAuthApiDataSource.logout()).called(1);
      verify(mockTokenStorage.clearTokens()).called(1);
      verify(mockSessionRepository.clearSession()).called(1);
    });
  });
}
