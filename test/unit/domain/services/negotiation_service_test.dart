import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/entities/order.dart';
import 'package:siren_marketplace/core/domain/enums/catch_status.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/enums/order_status.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/services/negotiation_service.dart';
import 'package:siren_marketplace/core/domain/value_objects/weight.dart';
import 'package:siren_marketplace/core/domain/repositories/i_product_repository.dart';
import 'package:siren_marketplace/core/domain/value_objects/price.dart';
import 'package:dart_either/dart_either.dart';
import 'package:siren_marketplace/core/network/api_result.dart';
import 'package:siren_marketplace/core/domain/entities/product.dart';
import 'package:siren_marketplace/core/domain/services/message_service.dart';
import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_data.dart';

void main() {
  provideDummy<Either<Failure, Product?>>(const Right(null));

  late NegotiationService service;
  late MockIOfferRepository mockOfferRepository;
  late MockIOrderRepository mockOrderRepository;
  late MockICatchRepository mockCatchRepository;
  late MockIProductRepository mockProductRepository;
  // late MockIProductRepository mockProductRepository; // duplicate

  setUp(() {
    mockOfferRepository = MockIOfferRepository();
    mockOrderRepository = MockIOrderRepository();
    mockCatchRepository = MockICatchRepository();
    mockProductRepository = MockIProductRepository();
    // mockMessageService = MockMessageService(); // unused

    service = NegotiationService(
      offerRepository: mockOfferRepository,
      orderRepository: mockOrderRepository,
      catchRepository: mockCatchRepository,
      productRepository: mockProductRepository,
    );
  });

  group('NegotiationService', () {
    final testCatch = TestData.createCatch(
      availableWeight: Weight.fromKg(100),
      status: CatchStatus.available,
    );
    final testTerms = TestData.createOfferTerms(weight: Weight.fromKg(10));
    final fisherId = 'fisher-1';
    final buyerId = 'buyer-1';

    group('createOffer', () {
      test('creates offer when valid', () async {
        when(
          mockCatchRepository.getById(testCatch.id),
        ).thenAnswer((_) async => testCatch);
        when(mockOfferRepository.create(any)).thenAnswer((_) async => 'new-id');
        when(
          mockProductRepository.getProductById(testCatch.id),
        ).thenAnswer((_) async => const Right(null));

        final result = await service.createOffer(
          productId: testCatch.id,
          buyerId: buyerId,
          fisherId: fisherId,
          terms: testTerms,
        );

        expect(result.productId, testCatch.id);
        expect(result.buyerId, buyerId);
        expect(result.fisherId, fisherId);
        expect(result.currentTerms, testTerms);
        expect(result.status, OfferStatus.pending);
        verify(mockOfferRepository.create(any)).called(1);
      });

      test('throws ArgumentError when catch not found', () async {
        when(
          mockCatchRepository.getById('unknown'),
        ).thenAnswer((_) async => null);
        when(
          mockProductRepository.getProductById('unknown'),
        ).thenAnswer((_) async => const Right(null));

        expect(
          () => service.createOffer(
            productId: 'unknown',
            buyerId: buyerId,
            fisherId: fisherId,
            terms: testTerms,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws StateError when catch cannot receive offers', () async {
        final soldCatch = testCatch.copyWith(status: CatchStatus.soldOut);
        when(
          mockCatchRepository.getById(soldCatch.id),
        ).thenAnswer((_) async => soldCatch);
        when(
          mockProductRepository.getProductById(soldCatch.id),
        ).thenAnswer((_) async => const Right(null));

        expect(
          () => service.createOffer(
            productId: soldCatch.id,
            buyerId: buyerId,
            fisherId: fisherId,
            terms: testTerms,
          ),
          throwsA(isA<StateError>()),
        );
      });

      test('throws ArgumentError when weight exceeds available', () async {
        final heavyTerms = TestData.createOfferTerms(
          weight: Weight.fromKg(200),
        );
        when(
          mockCatchRepository.getById(testCatch.id),
        ).thenAnswer((_) async => testCatch);
        when(
          mockProductRepository.getProductById(testCatch.id),
        ).thenAnswer((_) async => const Right(null));

        expect(
          () => service.createOffer(
            productId: testCatch.id,
            buyerId: buyerId,
            fisherId: fisherId,
            terms: heavyTerms,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('acceptOffer', () {
      final pendingOffer = TestData.createOffer(
        status: OfferStatus.pending,
        waitingFor: UserRole.fisher,
        productId: testCatch.id,
        currentTerms: testTerms,
      );

      test('accepts offer, updates catch, creates order', () async {
        final acceptedOrder = TestData.createOrder(
          status: OrderStatus.accepted,
          catchId: testCatch.id,
          offerId: pendingOffer.id,
          terms: testTerms,
        );

        when(
          mockOfferRepository.getById(pendingOffer.id),
        ).thenAnswer((_) async => pendingOffer);

        when(
          mockOfferRepository.acceptOffer(
            any,
            any,
            message: anyNamed('message'),
          ),
        ).thenAnswer((_) async => {});

        when(
          mockOrderRepository.getByOfferId(pendingOffer.id),
        ).thenAnswer((_) async => acceptedOrder);

        when(
          mockCatchRepository.getById(testCatch.id),
        ).thenAnswer((_) async => testCatch);

        final result = await service.acceptOffer(
          offerId: pendingOffer.id,
          userId: pendingOffer.fisherId,
        );

        expect(result.status, OrderStatus.accepted);
        expect(result.id, acceptedOrder.id);

        // Verify acceptOffer called with correct parameters
        verify(
          mockOfferRepository.acceptOffer(
            pendingOffer.id,
            UserRole.fisher,
            message: 'Offer accepted',
          ),
        ).called(1);

        // Verify order fetched
        verify(mockOrderRepository.getByOfferId(pendingOffer.id)).called(1);
      });

      test('throws ArgumentError when offer not found', () async {
        when(
          mockOfferRepository.getById('unknown'),
        ).thenAnswer((_) async => null);

        expect(
          () => service.acceptOffer(offerId: 'unknown', userId: fisherId),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws StateError when user cannot accept', () async {
        when(
          mockOfferRepository.getById(pendingOffer.id),
        ).thenAnswer((_) async => pendingOffer);

        // Buyer cannot accept when waiting for fisher
        expect(
          () => service.acceptOffer(offerId: pendingOffer.id, userId: buyerId),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('rejectOffer', () {
      final pendingOffer = TestData.createOffer(
        status: OfferStatus.pending,
        waitingFor: UserRole.fisher,
      );

      test('rejects offer', () async {
        final rejectedOffer = pendingOffer.reject();

        var getByIdCallCount = 0;
        when(mockOfferRepository.getById(pendingOffer.id)).thenAnswer((
          _,
        ) async {
          if (getByIdCallCount == 0) {
            getByIdCallCount++;
            return pendingOffer;
          }
          return rejectedOffer;
        });

        final result = await service.rejectOffer(
          offerId: pendingOffer.id,
          userId: pendingOffer.fisherId,
        );

        expect(result.status, OfferStatus.rejected);

        verify(
          mockOfferRepository.rejectOffer(
            pendingOffer.id,
            UserRole.fisher,
            message: 'Offer rejected',
          ),
        ).called(1);
      });

      test('throws StateError when user cannot reject', () async {
        when(
          mockOfferRepository.getById(pendingOffer.id),
        ).thenAnswer((_) async => pendingOffer);

        expect(
          () => service.rejectOffer(offerId: pendingOffer.id, userId: buyerId),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('counterOffer', () {
      final pendingOffer = TestData.createOffer(
        status: OfferStatus.pending,
        waitingFor: UserRole.fisher,
        productId: testCatch.id,
        currentTerms: testTerms,
      );
      // Fixed weight: must allow changing price but weight must remain same
      final newTerms = TestData.createOfferTerms(
        weight: testTerms.weight,
        totalPrice: Price.fromAmount(200), // Changed price
      );

      test('counters offer', () async {
        final counteredOffer = pendingOffer.copyWith(
          currentTerms: newTerms,
          waitingFor: UserRole.buyer,
          status: OfferStatus.pending,
        );

        when(
          mockOfferRepository.getById(pendingOffer.id),
        ).thenAnswer((_) async => pendingOffer);

        // Second call returns updated offer
        // Note: Mockito sequencing needs careful handling if we use same matcher.
        // But here we can use thenAnswer with a counter or side effect,
        // or just rely on Mockito's ability to return different values if we use different invocations (but arguments are same).
        // Actually, Mockito.when(...).thenAnswer() overrides previous when.
        // We can't easily sequence multiple calls with identical arguments using standard `when` syntax
        // unless we use `thenAnswer` with a mutable variable or `responses` list.

        var getByIdCallCount = 0;
        when(mockOfferRepository.getById(pendingOffer.id)).thenAnswer((
          _,
        ) async {
          if (getByIdCallCount == 0) {
            getByIdCallCount++;
            return pendingOffer;
          }
          return counteredOffer;
        });

        when(
          mockCatchRepository.getById(testCatch.id),
        ).thenAnswer((_) async => testCatch);

        when(
          mockOfferRepository.counterOffer(any, any, any),
        ).thenAnswer((_) async => {});

        when(
          mockProductRepository.getProductById(testCatch.id),
        ).thenAnswer((_) async => const Right(null));

        final result = await service.counterOffer(
          offerId: pendingOffer.id,
          userId: pendingOffer.fisherId,
          newTerms: newTerms,
        );

        verify(
          mockOfferRepository.counterOffer(
            pendingOffer.id,
            UserRole.fisher,
            newTerms,
          ),
        ).called(1);
      });

      test('throws ArgumentError when new terms are same', () async {
        when(
          mockOfferRepository.getById(pendingOffer.id),
        ).thenAnswer((_) async => pendingOffer);

        expect(
          () => service.counterOffer(
            offerId: pendingOffer.id,
            userId: pendingOffer.fisherId,
            newTerms: testTerms, // Same terms
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws ArgumentError when weight exceeds available', () async {
        final heavyTerms = TestData.createOfferTerms(
          weight: Weight.fromKg(200),
        );
        when(
          mockOfferRepository.getById(pendingOffer.id),
        ).thenAnswer((_) async => pendingOffer);
        when(
          mockCatchRepository.getById(testCatch.id),
        ).thenAnswer((_) async => testCatch);
        when(
          mockProductRepository.getProductById(testCatch.id),
        ).thenAnswer((_) async => const Right(null));

        expect(
          () => service.counterOffer(
            offerId: pendingOffer.id,
            userId: pendingOffer.fisherId,
            newTerms: heavyTerms,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('relistOrder', () {
      final acceptedOrder = TestData.createOrder(
        status: OrderStatus.accepted,
        catchId: testCatch.id,
        offerId: 'offer-1',
        terms: testTerms,
      );
      final relatedOffer = TestData.createOffer(id: 'offer-1');

      test('cancels order, rejects offer, restores catch weight', () async {
        when(
          mockOrderRepository.getById(acceptedOrder.id),
        ).thenAnswer((_) async => acceptedOrder);
        when(
          mockOfferRepository.getById(acceptedOrder.offerId),
        ).thenAnswer((_) async => relatedOffer);
        when(
          mockCatchRepository.getById(acceptedOrder.catchId),
        ).thenAnswer((_) async => testCatch);

        when(mockOrderRepository.update(any)).thenAnswer((_) async => {});
        when(mockOfferRepository.update(any)).thenAnswer((_) async => {});
        when(mockCatchRepository.update(any)).thenAnswer((_) async => {});

        await service.relistOrder(
          orderId: acceptedOrder.id,
          reason: 'Test reason',
        );

        // Verify order cancelled
        final capturedOrder =
            verify(mockOrderRepository.update(captureAny)).captured.first
                as Order;
        expect(capturedOrder.status, OrderStatus.cancelled);
        expect(capturedOrder.cancellationReason, 'Test reason');

        // Verify offer rejected
        final capturedOffer =
            verify(mockOfferRepository.update(captureAny)).captured.first
                as Offer;
        expect(capturedOffer.status, OfferStatus.rejected);

        // Verify catch restored
        final capturedCatch =
            verify(mockCatchRepository.update(captureAny)).captured.first
                as Catch;
        expect(
          capturedCatch.availableWeight.grams,
          testCatch.availableWeight.grams + testTerms.weight.grams,
        );
      });

      test('throws StateError when order not active', () async {
        final completedOrder = acceptedOrder.copyWith(
          status: OrderStatus.completed,
        );
        when(
          mockOrderRepository.getById(completedOrder.id),
        ).thenAnswer((_) async => completedOrder);

        expect(
          () =>
              service.relistOrder(orderId: completedOrder.id, reason: 'reason'),
          throwsA(isA<StateError>()),
        );
      });
    });
  });
}
