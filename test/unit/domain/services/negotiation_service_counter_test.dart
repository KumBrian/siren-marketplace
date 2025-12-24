import 'package:dart_either/dart_either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/entities/product.dart';
import 'package:siren_marketplace/core/domain/entities/species.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/repositories/i_catch_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_offer_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_order_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_product_repository.dart';
import 'package:siren_marketplace/core/domain/services/negotiation_service.dart';
import 'package:siren_marketplace/core/domain/value_objects/offer_terms.dart';
import 'package:siren_marketplace/core/domain/value_objects/price.dart';
import 'package:siren_marketplace/core/domain/value_objects/price_per_kg.dart';
import 'package:siren_marketplace/core/domain/value_objects/weight.dart';
import 'package:siren_marketplace/core/network/api_result.dart'; // Failure

import 'negotiation_service_counter_test.mocks.dart';

@GenerateMocks([
  IOfferRepository,
  IOrderRepository,
  ICatchRepository,
  IProductRepository,
])
void main() {
  late NegotiationService service;
  late MockIOfferRepository mockOfferRepository;
  late MockIOrderRepository mockOrderRepository;
  late MockICatchRepository mockCatchRepository;
  late MockIProductRepository mockProductRepository;

  setUpAll(() {
    provideDummy<Either<Failure, Product?>>(const Right(null));
  });

  setUp(() {
    mockOfferRepository = MockIOfferRepository();
    mockOrderRepository = MockIOrderRepository();
    mockCatchRepository = MockICatchRepository();
    mockProductRepository = MockIProductRepository();

    service = NegotiationService(
      offerRepository: mockOfferRepository,
      orderRepository: mockOrderRepository,
      catchRepository: mockCatchRepository,
      productRepository: mockProductRepository,
    );
  });

  group('NegotiationService.counterOffer', () {
    final offerId = 'offer-1';
    final userId = 'fisher-1';
    final buyerId = 'buyer-1';
    final productId = 'product-1';

    final initialWeight = Weight.fromGrams(1000);
    final initialPrice = Price.fromAmount(1000); // 1000 cents
    final initialTerms = OfferTerms.create(
      totalPrice: initialPrice,
      weight: initialWeight,
    );

    final offer = Offer(
      id: offerId,
      productId: productId,
      fisherId: userId,
      buyerId: buyerId,
      currentTerms: initialTerms,
      status: OfferStatus.pending,
      dateCreated: DateTime.now(),
      dateUpdated: DateTime.now(),
      waitingFor: UserRole.fisher,
    );

    test(
      'should succeed when weight is unchanged and price is different',
      () async {
        // Arrange
        final newPrice = Price.fromAmount(1100);
        final newTerms = OfferTerms.create(
          totalPrice: newPrice,
          weight: initialWeight,
        );

        // Simulate fetch behavior: First call returns original, second returns updated
        var getByIdCallCount = 0;
        final updatedOffer = offer.copyWith(currentTerms: newTerms);

        when(mockOfferRepository.getById(offerId)).thenAnswer((_) async {
          if (getByIdCallCount == 0) {
            getByIdCallCount++;
            return offer;
          }
          return updatedOffer;
        });

        final product = Product(
          id: productId,
          name: "Test Shrimp",
          marketName: "Test Market",
          status: "available",
          pricePerKg: PricePerKg.fromAmount(100),
          totalPrice: Price.fromAmount(2000),
          initialWeight: Weight.fromGrams(2000),
          availableWeight: Weight.fromGrams(2000),
          size: "Large",
          datePosted: DateTime.now(),
          locationName: "Ocean",
          latitude: 0,
          longitude: 0,
          species: Species(
            id: 's1',
            name: 'Shrimp',
            scientificName: 'S. sp.',
            image: '',
            uid: 'u1',
          ),
          fisherId: userId,
          fisher: null,
          images: [],
        );

        when(
          mockProductRepository.getProductById(productId),
        ).thenAnswer((_) async => Right(product));
        when(
          mockOfferRepository.counterOffer(any, any, any),
        ).thenAnswer((_) async => null);

        // Act
        final result = await service.counterOffer(
          offerId: offerId,
          userId: userId,
          newTerms: newTerms,
        );

        // Assert
        verify(
          mockOfferRepository.counterOffer(offerId, UserRole.fisher, newTerms),
        ).called(1);
        expect(result.currentTerms, equals(newTerms));
      },
    );

    test('should throw ArgumentError when weight is changed', () async {
      // Arrange
      final newWeight = Weight.fromGrams(1200);
      final newPrice = Price.fromAmount(1100);
      final newTerms = OfferTerms.create(
        totalPrice: newPrice,
        weight: newWeight,
      );

      when(mockOfferRepository.getById(offerId)).thenAnswer((_) async => offer);

      // Act & Assert
      expect(
        () => service.counterOffer(
          offerId: offerId,
          userId: userId,
          newTerms: newTerms,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Weight cannot be changed'),
          ),
        ),
      );
    });

    test('should throw ArgumentError when terms are identical', () async {
      // Arrange
      when(mockOfferRepository.getById(offerId)).thenAnswer((_) async => offer);

      // Act & Assert
      expect(
        () => service.counterOffer(
          offerId: offerId,
          userId: userId,
          newTerms: initialTerms,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('must be different'),
          ),
        ),
      );
    });
  });
}
