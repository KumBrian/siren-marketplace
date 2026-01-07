import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:siren_marketplace/core/data/mappers/review_mapper.dart';
import 'package:siren_marketplace/core/data/models/order_model.dart';
import 'package:siren_marketplace/core/services/connectivity_service.dart';
import 'package:siren_marketplace/core/data/repositories/order_repository_impl.dart';
import 'package:siren_marketplace/core/domain/entities/order.dart';
import 'package:siren_marketplace/core/domain/enums/order_status.dart';
import 'package:siren_marketplace/core/domain/exceptions/not_found_exception.dart';
import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_data.dart';

void main() {
  late OrderRepositoryImpl repository;
  late MockIOrderDataSource mockRemoteDataSource;
  late MockIOrderDataSource mockLocalDataSource;
  late MockConnectivityService mockConnectivityService;

  setUp(() {
    mockRemoteDataSource = MockIOrderDataSource();
    mockLocalDataSource = MockIOrderDataSource();
    mockConnectivityService = MockConnectivityService();

    // Default to online
    when(
      mockConnectivityService.checkConnectivity(),
    ).thenAnswer((_) async => NetworkStatus.online);

    repository = OrderRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      connectivityService: mockConnectivityService,
    );
  });

  group('OrderRepositoryImpl', () {
    final testOrder = TestData.createOrder();

    // ... (existing imports)

    OrderModel createModelFromEntity(Order entity) {
      return OrderModel(
        id: entity.id,
        offerId: entity.offerId,
        catchId: entity.catchId,
        fisherId: entity.fisherId,
        buyerId: entity.buyerId,
        termsPrice: entity.terms.totalPrice.amount,
        termsWeight: entity.terms.weight.grams,
        termsPricePerKg: entity.terms.pricePerKg.amountPerKg,
        status: entity.status.name,
        dateCreated: entity.dateCreated.toIso8601String(),
        dateUpdated: entity.dateUpdated.toIso8601String(),
        hasReviewFromFisher: entity.hasReviewFromFisher,
        hasReviewFromBuyer: entity.hasReviewFromBuyer,
        fisherReview: entity.fisherReview != null
            ? jsonEncode(ReviewMapper.toModel(entity.fisherReview!).toJson())
            : null,
        buyerReview: entity.buyerReview != null
            ? jsonEncode(ReviewMapper.toModel(entity.buyerReview!).toJson())
            : null,
        cancellationReason: entity.cancellationReason,
      );
    }

    final testModel = createModelFromEntity(testOrder);

    test('create calls dataSource.create and returns id', () async {
      when(mockRemoteDataSource.create(any)).thenAnswer((_) async => 'new-id');

      final result = await repository.create(testOrder);

      expect(result, 'new-id');
      verify(mockRemoteDataSource.create(any)).called(1);
    });

    test('getById returns mapped entity from local when offline', () async {
      // Arrange
      when(
        mockConnectivityService.checkConnectivity(),
      ).thenAnswer((_) async => NetworkStatus.offline);
      when(
        mockLocalDataSource.getById(testModel.id),
      ).thenAnswer((_) async => testModel);

      // Act
      final result = await repository.getById(testModel.id);

      // Assert
      expect(result, isA<Order>());
      expect(result.id, testModel.id);
      verify(mockConnectivityService.checkConnectivity()).called(1);
      verify(mockLocalDataSource.getById(testModel.id)).called(1);
      verifyNever(mockRemoteDataSource.getById(any));
    });

    test('getById returns mapped entity when found', () async {
      when(
        mockRemoteDataSource.getById(testOrder.id),
      ).thenAnswer((_) async => testModel);
      when(mockLocalDataSource.saveBatch([testModel])).thenAnswer((_) async {});

      final result = await repository.getById(testOrder.id);

      expect(result.id, testOrder.id);
      verify(mockRemoteDataSource.getById(testOrder.id)).called(1);
      verify(mockLocalDataSource.saveBatch([testModel])).called(1);
    });

    test('getById throws NotFoundException when not found', () async {
      when(
        mockRemoteDataSource.getById('unknown'),
      ).thenAnswer((_) async => null);
      when(
        mockLocalDataSource.getById('unknown'),
      ).thenAnswer((_) async => null);

      expect(
        () => repository.getById('unknown'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test(
      'getReviewableOrders returns only reviewable orders for user',
      () async {
        // Arrange
        // Create a completed order that can be reviewed by fisher
        // (no review object)
        final reviewableOrder = testOrder.copyWith(
          status: OrderStatus.completed,
          fisherReview: null,
        );
        final reviewableModel = createModelFromEntity(reviewableOrder);

        // Create a completed order that is already reviewed by fisher
        // (has review object)
        final alreadyReviewedOrder = testOrder.copyWith(
          status: OrderStatus.completed,
          fisherReview: TestData.createReview(reviewerId: testOrder.fisherId),
        );
        final alreadyReviewedModel = createModelFromEntity(
          alreadyReviewedOrder,
        );

        when(
          mockRemoteDataSource.getByStatus(OrderStatus.completed),
        ).thenAnswer((_) async => [reviewableModel, alreadyReviewedModel]);

        when(
          mockLocalDataSource.saveBatch([
            reviewableModel,
            alreadyReviewedModel,
          ]),
        ).thenAnswer((_) async {});

        // Act
        final result = await repository.getReviewableOrders(testOrder.fisherId);

        // Assert
        expect(result.length, 1);
        expect(result.first.id, reviewableOrder.id);
        verify(
          mockRemoteDataSource.getByStatus(OrderStatus.completed),
        ).called(1);
        verify(
          mockLocalDataSource.saveBatch([
            reviewableModel,
            alreadyReviewedModel,
          ]),
        ).called(1);
      },
    );
  });
}
