import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:siren_marketplace/core/data/models/user_model.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository_impl.dart';
import 'package:siren_marketplace/core/domain/entities/user.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/value_objects/rating.dart';
import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_data.dart';

void main() {
  late UserRepositoryImpl repository;
  late MockIUserDataSource mockRemoteDataSource;
  late MockIUserDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockIUserDataSource();
    mockLocalDataSource = MockIUserDataSource();
    repository = UserRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      connectivityService: MockConnectivityService(),
    );
  });

  group('UserRepositoryImpl', () {
    final testUser = TestData.createUser();

    UserModel createModelFromEntity(User entity) {
      return UserModel(
        id: entity.id,
        name: entity.name,
        avatarUrl: entity.avatarUrl,
        rating: entity.rating.value,
        reviewCount: entity.reviewCount,
        currentRole: entity.currentRole.name,
      );
    }

    final testModel = createModelFromEntity(testUser);

    test('create calls dataSource.create', () async {
      when(mockRemoteDataSource.create(any)).thenAnswer((_) async => {});

      await repository.create(testUser);

      verify(mockRemoteDataSource.create(any)).called(1);
    });

    test('getById returns mapped entity when found', () async {
      when(
        mockRemoteDataSource.getById(testUser.id),
      ).thenAnswer((_) async => testModel);

      final result = await repository.getById(testUser.id);

      expect(result, isNotNull);
      expect(result!.id, testUser.id);
      verify(mockRemoteDataSource.getById(testUser.id)).called(1);
    });

    test('updateRole fetches user and updates role', () async {
      // Arrange
      when(
        mockRemoteDataSource.getById(testUser.id),
      ).thenAnswer((_) async => testModel);
      when(mockRemoteDataSource.update(any)).thenAnswer((_) async => {});

      // Act
      await repository.updateRole(testUser.id, UserRole.buyer);

      // Assert
      final capturedModel =
          verify(mockRemoteDataSource.update(captureAny)).captured.first
              as UserModel;
      expect(capturedModel.currentRole, UserRole.buyer.name);
    });

    test('updateRole throws ArgumentError when user not found', () async {
      when(
        mockRemoteDataSource.getById('unknown'),
      ).thenAnswer((_) async => null);

      expect(
        () => repository.updateRole('unknown', UserRole.buyer),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('updateRating calls dataSource.updateRating', () async {
      when(
        mockRemoteDataSource.updateRating(
          userId: anyNamed('userId'),
          rating: anyNamed('rating'),
          reviewCount: anyNamed('reviewCount'),
        ),
      ).thenAnswer((_) async => {});

      await repository.updateRating(
        userId: testUser.id,
        rating: Rating.fromValue(4.8),
        reviewCount: 15,
      );

      verify(
        mockRemoteDataSource.updateRating(
          userId: testUser.id,
          rating: 4.8,
          reviewCount: 15,
        ),
      ).called(1);
    });

    test('exists calls dataSource.exists', () async {
      when(
        mockRemoteDataSource.exists(testUser.id),
      ).thenAnswer((_) async => true);

      final result = await repository.exists(testUser.id);

      expect(result, true);
      verify(mockRemoteDataSource.exists(testUser.id)).called(1);
    });
  });
}
