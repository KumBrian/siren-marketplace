import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:siren_marketplace/core/data/models/user_model.dart';
import 'package:siren_marketplace/core/data/repositories/session_repository_impl.dart';
import 'package:siren_marketplace/core/domain/entities/user.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_data.dart';

void main() {
  late SessionRepositoryImpl repository;
  late MockISessionDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockISessionDataSource();
    repository = SessionRepositoryImpl(dataSource: mockDataSource);
  });

  group('SessionRepositoryImpl', () {
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

    test('getCurrentUser returns mapped entity when found', () async {
      when(mockDataSource.getCurrentUser()).thenAnswer((_) async => testModel);

      final result = await repository.getCurrentUser();

      expect(result, isNotNull);
      expect(result!.id, testUser.id);
      verify(mockDataSource.getCurrentUser()).called(1);
    });

    test('getCurrentUser returns null when not found', () async {
      when(mockDataSource.getCurrentUser()).thenAnswer((_) async => null);

      final result = await repository.getCurrentUser();

      expect(result, null);
      verify(mockDataSource.getCurrentUser()).called(1);
    });

    test('getCurrentRole returns mapped role when found', () async {
      when(mockDataSource.getCurrentRole()).thenAnswer((_) async => 'fisher');

      final result = await repository.getCurrentRole();

      expect(result, UserRole.fisher);
      verify(mockDataSource.getCurrentRole()).called(1);
    });

    test('getCurrentRole returns null when not found', () async {
      when(mockDataSource.getCurrentRole()).thenAnswer((_) async => null);

      final result = await repository.getCurrentRole();

      expect(result, null);
      verify(mockDataSource.getCurrentRole()).called(1);
    });

    test('saveCurrentUser calls dataSource.saveCurrentUser', () async {
      when(mockDataSource.saveCurrentUser(any)).thenAnswer((_) async => {});

      await repository.saveCurrentUser(testUser);

      verify(mockDataSource.saveCurrentUser(any)).called(1);
    });

    test('saveCurrentRole calls dataSource.saveCurrentRole', () async {
      when(mockDataSource.saveCurrentRole(any)).thenAnswer((_) async => {});

      await repository.saveCurrentRole(UserRole.buyer);

      verify(mockDataSource.saveCurrentRole('buyer')).called(1);
    });

    test('clearSession calls dataSource.clearSession', () async {
      when(mockDataSource.clearSession()).thenAnswer((_) async => {});

      await repository.clearSession();

      verify(mockDataSource.clearSession()).called(1);
    });

    test('isLoggedIn calls dataSource.isLoggedIn', () async {
      when(mockDataSource.isLoggedIn()).thenAnswer((_) async => true);

      final result = await repository.isLoggedIn();

      expect(result, true);
      verify(mockDataSource.isLoggedIn()).called(1);
    });
  });
}
