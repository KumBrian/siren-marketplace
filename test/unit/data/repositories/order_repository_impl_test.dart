import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:siren_marketplace/core/data/models/order_model.dart';
import 'package:siren_marketplace/core/data/repositories/order_repository_impl.dart';
import 'package:siren_marketplace/core/domain/entities/order.dart';
import 'package:siren_marketplace/core/domain/enums/order_status.dart';
import 'package:siren_marketplace/core/domain/exceptions/not_found_exception.dart';
import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_data.dart';

void main() {
  late OrderRepositoryImpl repository;
  late MockIOrderDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockIOrderDataSource();
    repository = OrderRepositoryImpl(dataSource: mockDataSource);
  });

  group('OrderRepositoryImpl', () {
    final testOrder = TestData.createOrder();

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
        cancellationReason: entity.cancellationReason,
      );
    }

    final testModel = createModelFromEntity(testOrder);

    test('create calls dataSource.create and returns id', () async {
      when(mockDataSource.create(any)).thenAnswer((_) async => 'new-id');

      final result = await repository.create(testOrder);

      expect(result, 'new-id');
      verify(mockDataSource.create(any)).called(1);
    });

    test('getById returns mapped entity when found', () async {
      when(
        mockDataSource.getById(testOrder.id),
      ).thenAnswer((_) async => testModel);

      final result = await repository.getById(testOrder.id);

      expect(result.id, testOrder.id);
      verify(mockDataSource.getById(testOrder.id)).called(1);
    });

    test('getById throws NotFoundException when not found', () async {
      when(mockDataSource.getById('unknown')).thenAnswer((_) async => null);

      expect(
        () => repository.getById('unknown'),
        throwsA(isA<NotFoundException>()),
      );
      verify(mockDataSource.getById('unknown')).called(1);
    });

    test(
      'getReviewableOrders returns only reviewable orders for user',
      () async {
        // Arrange
        // Create a completed order that can be reviewed by fisher
        final reviewableOrder = testOrder.copyWith(
          status: OrderStatus.completed,
          hasReviewFromFisher: false,
        );
        final reviewableModel = createModelFromEntity(reviewableOrder);

        // Create a completed order that is already reviewed by fisher
        final alreadyReviewedOrder = testOrder.copyWith(
          status: OrderStatus.completed,
          hasReviewFromFisher: true,
        );
        final alreadyReviewedModel = createModelFromEntity(
          alreadyReviewedOrder,
        );

        when(
          mockDataSource.getByStatus(OrderStatus.completed),
        ).thenAnswer((_) async => [reviewableModel, alreadyReviewedModel]);

        // Act
        final result = await repository.getReviewableOrders(testOrder.fisherId);

        // Assert
        expect(result.length, 1);
        expect(result.first.id, reviewableOrder.id);
        verify(mockDataSource.getByStatus(OrderStatus.completed)).called(1);
      },
    );
  });
}
