import 'package:flutter_test/flutter_test.dart';
import 'package:siren_marketplace/core/domain/entities/order.dart';
import 'package:siren_marketplace/core/domain/enums/order_status.dart';
import '../../../helpers/test_data.dart';

void main() {
  group('Order Entity', () {
    late Order testOrder;
    const fisherId = 'fisher-123';
    const buyerId = 'buyer-456';

    setUp(() {
      testOrder = TestData.createOrder(
        fisherId: fisherId,
        buyerId: buyerId,
        status: OrderStatus.accepted,
      );
    });

    group('Business Logic - Status Checks', () {
      test('isActive returns true for accepted status', () {
        final activeOrder = testOrder.copyWith(status: OrderStatus.accepted);

        expect(activeOrder.isActive, true);
      });

      test('isActive returns false for completed status', () {
        final completedOrder = testOrder.copyWith(
          status: OrderStatus.completed,
        );

        expect(completedOrder.isActive, false);
      });

      test('isActive returns false for cancelled status', () {
        final cancelledOrder = testOrder.copyWith(
          status: OrderStatus.cancelled,
        );

        expect(cancelledOrder.isActive, false);
      });

      test('isCompleted returns true for completed status', () {
        final completedOrder = testOrder.copyWith(
          status: OrderStatus.completed,
        );

        expect(completedOrder.isCompleted, true);
      });

      test('isCancelled returns true for cancelled status', () {
        final cancelledOrder = testOrder.copyWith(
          status: OrderStatus.cancelled,
        );

        expect(cancelledOrder.isCancelled, true);
      });

      test('canBeReviewed returns true for completed orders', () {
        final completedOrder = testOrder.copyWith(
          status: OrderStatus.completed,
        );

        expect(completedOrder.canBeReviewed, true);
      });

      test('canBeReviewed returns false for active orders', () {
        final activeOrder = testOrder.copyWith(status: OrderStatus.accepted);

        expect(activeOrder.canBeReviewed, false);
      });

      test('canBeReviewed returns false for cancelled orders', () {
        final cancelledOrder = testOrder.copyWith(
          status: OrderStatus.cancelled,
        );

        expect(cancelledOrder.canBeReviewed, false);
      });
    });

    group('Business Logic - Review Permissions', () {
      test(
        'canBeReviewedBy returns true for fisher when completed and no fisher review',
        () {
          final order = testOrder.copyWith(
            status: OrderStatus.completed,
            fisherReview: null,
          );

          expect(order.canBeReviewedBy(fisherId), true);
        },
      );

      test(
        'canBeReviewedBy returns false for fisher when already reviewed',
        () {
          final order = testOrder.copyWith(
            status: OrderStatus.completed,
            fisherReview: TestData.createReview(reviewerId: fisherId),
          );

          expect(order.canBeReviewedBy(fisherId), false);
        },
      );

      test(
        'canBeReviewedBy returns true for buyer when completed and no buyer review',
        () {
          final order = testOrder.copyWith(
            status: OrderStatus.completed,
            buyerReview: null,
          );

          expect(order.canBeReviewedBy(buyerId), true);
        },
      );

      test('canBeReviewedBy returns false for buyer when already reviewed', () {
        final order = testOrder.copyWith(
          status: OrderStatus.completed,
          buyerReview: TestData.createReview(reviewerId: buyerId),
        );

        expect(order.canBeReviewedBy(buyerId), false);
      });

      test('canBeReviewedBy returns false when order is not completed', () {
        final activeOrder = testOrder.copyWith(
          status: OrderStatus.accepted,
          fisherReview: null,
        );

        expect(activeOrder.canBeReviewedBy(fisherId), false);
      });

      test('canBeReviewedBy returns false for unknown user', () {
        final order = testOrder.copyWith(status: OrderStatus.completed);

        expect(order.canBeReviewedBy('unknown-user'), false);
      });
    });

    group('Business Logic - Review Tracking', () {
      test('hasReview returns true when fisher reviewed buyer', () {
        final order = testOrder.copyWith(
          fisherReview: TestData.createReview(reviewerId: fisherId),
        );

        expect(order.hasReview(fisherId, buyerId), true);
      });

      test('hasReview returns false when fisher has not reviewed buyer', () {
        final order = testOrder.copyWith(fisherReview: null);

        expect(order.hasReview(fisherId, buyerId), false);
      });

      test('hasReview returns true when buyer reviewed fisher', () {
        final order = testOrder.copyWith(
          buyerReview: TestData.createReview(reviewerId: buyerId),
        );

        expect(order.hasReview(buyerId, fisherId), true);
      });

      test('hasReview returns false when buyer has not reviewed fisher', () {
        final order = testOrder.copyWith(buyerReview: null);

        expect(order.hasReview(buyerId, fisherId), false);
      });
    });

    group('Business Logic - Counterparty', () {
      test('getCounterpartyId returns buyer when given fisher', () {
        expect(testOrder.getCounterpartyId(fisherId), buyerId);
      });

      test('getCounterpartyId returns fisher when given buyer', () {
        expect(testOrder.getCounterpartyId(buyerId), fisherId);
      });

      test('getCounterpartyId throws for unknown user', () {
        expect(
          () => testOrder.getCounterpartyId('unknown-user'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Domain Actions - Complete', () {
      test('markAsCompleted changes status to completed', () {
        final activeOrder = testOrder.copyWith(status: OrderStatus.accepted);

        final result = activeOrder.markAsCompleted();

        expect(result.status, OrderStatus.completed);
      });

      test('markAsCompleted updates dateUpdated', () {
        final activeOrder = testOrder.copyWith(
          status: OrderStatus.accepted,
          dateUpdated: DateTime(2025, 1, 1),
        );

        final result = activeOrder.markAsCompleted();

        expect(result.dateUpdated.isAfter(activeOrder.dateUpdated), true);
      });

      test('markAsCompleted throws when order is not active', () {
        final completedOrder = testOrder.copyWith(
          status: OrderStatus.completed,
        );

        expect(
          () => completedOrder.markAsCompleted(),
          throwsA(isA<StateError>()),
        );
      });

      test('markAsCompleted preserves other properties', () {
        final activeOrder = testOrder.copyWith(status: OrderStatus.accepted);

        final result = activeOrder.markAsCompleted();

        expect(result.id, activeOrder.id);
        expect(result.offerId, activeOrder.offerId);
        expect(result.fisherId, activeOrder.fisherId);
        expect(result.buyerId, activeOrder.buyerId);
        expect(result.terms, activeOrder.terms);
      });
    });

    group('Domain Actions - Cancel', () {
      test('markAsCancelled changes status to cancelled', () {
        final activeOrder = testOrder.copyWith(status: OrderStatus.accepted);

        final result = activeOrder.markAsCancelled();

        expect(result.status, OrderStatus.cancelled);
      });

      test('markAsCancelled updates dateUpdated', () {
        final activeOrder = testOrder.copyWith(
          status: OrderStatus.accepted,
          dateUpdated: DateTime(2025, 1, 1),
        );

        final result = activeOrder.markAsCancelled();

        expect(result.dateUpdated.isAfter(activeOrder.dateUpdated), true);
      });

      test('markAsCancelled can include cancellation reason', () {
        final activeOrder = testOrder.copyWith(status: OrderStatus.accepted);

        final result = activeOrder.markAsCancelled(
          reason: 'Customer requested cancellation',
        );

        expect(result.cancellationReason, 'Customer requested cancellation');
      });

      test('markAsCancelled works without reason', () {
        final activeOrder = testOrder.copyWith(status: OrderStatus.accepted);

        final result = activeOrder.markAsCancelled();

        expect(result.status, OrderStatus.cancelled);
        expect(result.cancellationReason, null);
      });

      test('markAsCancelled throws when order is not active', () {
        final completedOrder = testOrder.copyWith(
          status: OrderStatus.completed,
        );

        expect(
          () => completedOrder.markAsCancelled(),
          throwsA(isA<StateError>()),
        );
      });

      test('markAsCancelled throws when order is already cancelled', () {
        final cancelledOrder = testOrder.copyWith(
          status: OrderStatus.cancelled,
        );

        expect(
          () => cancelledOrder.markAsCancelled(),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('Equality', () {
      test('two orders with same values are equal', () {
        final fixedDate = DateTime(2025, 1, 1, 12, 0);
        final order1 = TestData.createOrder(
          id: 'same-id',
          dateCreated: fixedDate,
          dateUpdated: fixedDate,
        );
        final order2 = TestData.createOrder(
          id: 'same-id',
          dateCreated: fixedDate,
          dateUpdated: fixedDate,
        );

        expect(order1, equals(order2));
        expect(order1.hashCode, equals(order2.hashCode));
      });

      test('two orders with different ids are not equal', () {
        final order1 = TestData.createOrder(id: 'id-1');
        final order2 = TestData.createOrder(id: 'id-2');

        expect(order1, isNot(equals(order2)));
      });

      test('two orders with different status are not equal', () {
        final fixedDate = DateTime(2025, 1, 1);
        final order1 = TestData.createOrder(
          id: 'same',
        ).copyWith(status: OrderStatus.accepted, dateUpdated: fixedDate);
        final order2 = TestData.createOrder(
          id: 'same',
        ).copyWith(status: OrderStatus.completed, dateUpdated: fixedDate);

        expect(order1, isNot(equals(order2)));
      });

      test('two orders with different review flags are not equal', () {
        final fixedDate = DateTime(2025, 1, 1);
        final order1 = TestData.createOrder(id: 'same').copyWith(
          fisherReview: TestData.createReview(reviewerId: fisherId),
          buyerReview: null,
          dateUpdated: fixedDate,
        );
        final order2 = TestData.createOrder(id: 'same').copyWith(
          fisherReview: null,
          buyerReview: TestData.createReview(reviewerId: buyerId),
          dateUpdated: fixedDate,
        );

        expect(order1, isNot(equals(order2)));
      });
    });

    group('CopyWith', () {
      test('copyWith creates new instance with updated values', () {
        final original = testOrder;
        final review = TestData.createReview(reviewerId: fisherId);

        final updated = original.copyWith(
          status: OrderStatus.completed,
          fisherReview: review,
        );

        expect(updated.status, OrderStatus.completed);
        expect(updated.fisherReview, review);
        expect(updated.id, original.id);
      });

      test('copyWith preserves unchanged values', () {
        final original = testOrder;
        final updated = original.copyWith(status: OrderStatus.cancelled);

        expect(updated.offerId, original.offerId);
        expect(updated.catchId, original.catchId);
        expect(updated.fisherId, original.fisherId);
        expect(updated.buyerId, original.buyerId);
        expect(updated.terms, original.terms);
      });

      test('copyWith can update cancellation reason', () {
        final original = testOrder;
        final updated = original.copyWith(cancellationReason: 'Test reason');

        expect(updated.cancellationReason, 'Test reason');
      });
    });
  });
}
