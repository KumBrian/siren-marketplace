import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:siren_marketplace/core/data/models/catch_model.dart';
import 'package:siren_marketplace/core/data/models/species_model.dart';
import 'package:siren_marketplace/core/data/repositories/catch_repository_impl.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/enums/catch_status.dart';
import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_data.dart';

void main() {
  late CatchRepositoryImpl repository;
  late MockICatchDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockICatchDataSource();
    repository = CatchRepositoryImpl(dataSource: mockDataSource);
  });

  group('CatchRepositoryImpl', () {
    final testCatch = TestData.createCatch();

    // Helper to create a model that matches the entity
    CatchModel createModelFromEntity(Catch entity) {
      return CatchModel(
        id: entity.id,
        name: entity.name,
        datePosted: entity.datePosted.toIso8601String(),
        initialWeightGrams: entity.initialWeight.grams,
        availableWeightGrams: entity.availableWeight.grams,
        pricePerKgAmount: entity.pricePerKg.amountPerKg,
        totalPriceAmount: entity.totalPrice.amount,
        size: entity.size,
        market: entity.market,
        images: entity.images,
        species: SpeciesModel(
          id: entity.species.id,
          name: entity.species.name,
          image: entity.species.image,
          scientificName: entity.species.scientificName,
        ),
        fisherId: entity.fisherId,
        status: entity.status.name,
        observationId: entity.observationId,
        locationName: entity.locationName,
        latitude: entity.latitude,
        longitude: entity.longitude,
      );
    }

    final testModel = createModelFromEntity(testCatch);

    test('create calls dataSource.create and returns id', () async {
      // Arrange
      when(mockDataSource.create(any)).thenAnswer((_) async => 'new-id');

      // Act
      final result = await repository.create(testCatch);

      // Assert
      expect(result, 'new-id');
      verify(mockDataSource.create(any)).called(1);
    });

    test('getById returns mapped entity when found', () async {
      // Arrange
      when(
        mockDataSource.getById(testCatch.id),
      ).thenAnswer((_) async => testModel);

      // Act
      final result = await repository.getById(testCatch.id);

      // Assert
      expect(result, isNotNull);
      expect(result!.id, testCatch.id);
      expect(result.name, testCatch.name);
      verify(mockDataSource.getById(testCatch.id)).called(1);
    });

    test('getById returns null when not found', () async {
      // Arrange
      when(mockDataSource.getById('unknown')).thenAnswer((_) async => null);

      // Act
      final result = await repository.getById('unknown');

      // Assert
      expect(result, null);
      verify(mockDataSource.getById('unknown')).called(1);
    });

    test('getByFisherId returns list of mapped entities', () async {
      // Arrange
      when(
        mockDataSource.getByFisherId(testCatch.fisherId),
      ).thenAnswer((_) async => [testModel]);

      // Act
      final result = await repository.getByFisherId(testCatch.fisherId);

      // Assert
      expect(result.length, 1);
      expect(result.first.id, testCatch.id);
      verify(mockDataSource.getByFisherId(testCatch.fisherId)).called(1);
    });

    test('getAvailableCatches returns list of mapped entities', () async {
      // Arrange
      when(
        mockDataSource.getByStatus(CatchStatus.available),
      ).thenAnswer((_) async => [testModel]);

      // Act
      final result = await repository.getAvailableCatches();

      // Assert
      expect(result.length, 1);
      expect(result.first.id, testCatch.id);
      verify(mockDataSource.getByStatus(CatchStatus.available)).called(1);
    });

    test('update calls dataSource.update', () async {
      // Arrange
      when(mockDataSource.update(any)).thenAnswer((_) async => {});

      // Act
      await repository.update(testCatch);

      // Assert
      verify(mockDataSource.update(any)).called(1);
    });

    test('delete calls dataSource.delete', () async {
      // Arrange
      when(mockDataSource.delete(testCatch.id)).thenAnswer((_) async => {});

      // Act
      await repository.delete(testCatch.id);

      // Assert
      verify(mockDataSource.delete(testCatch.id)).called(1);
    });
  });
}
