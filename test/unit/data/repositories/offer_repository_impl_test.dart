import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:siren_marketplace/core/data/models/offer_model.dart';
import 'package:siren_marketplace/core/data/repositories/offer_repository_impl.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/repositories/i_order_repository.dart';
import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_data.dart';

void main() {
  late OfferRepositoryImpl repository;
  late MockIOfferDataSource mockDataSource;
  late MockIOrderRepository mockOrderRepository;
  final sl = GetIt.instance;

  setUp(() {
    mockDataSource = MockIOfferDataSource();
    mockOrderRepository = MockIOrderRepository();

    // Register mock dependencies
    if (sl.isRegistered<IOrderRepository>()) {
      sl.unregister<IOrderRepository>();
    }
    sl.registerSingleton<IOrderRepository>(mockOrderRepository);

    repository = OfferRepositoryImpl(
      remoteDataSource: mockDataSource,
      localDataSource: mockDataSource,
    );
  });

  tearDown(() {
    sl.reset();
  });

  group('OfferRepositoryImpl', () {
    final testOffer = TestData.createOffer();

    OfferModel createModelFromEntity(Offer entity) {
      return OfferModel(
        id: entity.id,
        productId: entity.productId,
        fisherId: entity.fisherId,
        buyerId: entity.buyerId,
        currentPriceAmount: entity.currentTerms.totalPrice.amount,
        currentWeightGrams: entity.currentTerms.weight.grams,
        currentPricePerKgAmount: entity.currentTerms.pricePerKg.amountPerKg,
        previousPriceAmount: entity.previousTerms?.totalPrice.amount,
        previousWeightGrams: entity.previousTerms?.weight.grams,
        previousPricePerKgAmount: entity.previousTerms?.pricePerKg.amountPerKg,
        status: entity.status.name,
        dateCreated: entity.dateCreated.toIso8601String(),
        dateUpdated: entity.dateUpdated.toIso8601String(),
        waitingFor: entity.waitingFor == UserRole.fisher
            ? 'fisher'
            : (entity.waitingFor == UserRole.buyer ? 'buyer' : null),
        hasUpdateForFisher: entity.hasUpdateForFisher,
        hasUpdateForBuyer: entity.hasUpdateForBuyer,
      );
    }

    final testModel = createModelFromEntity(testOffer);

    test('create calls dataSource.create and returns id', () async {
      when(mockDataSource.create(any)).thenAnswer((_) async => 'new-id');

      final result = await repository.create(testOffer);

      expect(result, 'new-id');
      verify(mockDataSource.create(any)).called(1);
    });

    test('getById returns mapped entity when found', () async {
      when(
        mockDataSource.getById(testOffer.id),
      ).thenAnswer((_) async => testModel);

      final result = await repository.getById(testOffer.id);

      expect(result, isNotNull);
      expect(result!.id, testOffer.id);
      verify(mockDataSource.getById(testOffer.id)).called(1);
    });

    test('acceptOffer updates offer status and creates order', () async {
      // Arrange
      // We need an offer that can be accepted (pending)
      final pendingOffer = testOffer.copyWith(
        status: OfferStatus.pending,
        waitingFor: UserRole.fisher,
      );
      final pendingModel = createModelFromEntity(pendingOffer);

      when(
        mockDataSource.getById(pendingOffer.id),
      ).thenAnswer((_) async => pendingModel);
      when(mockDataSource.update(any)).thenAnswer((_) async => {});
      when(mockOrderRepository.create(any)).thenAnswer((_) async => 'order-id');

      // Act
      await repository.acceptOffer(pendingOffer.id, UserRole.fisher);

      // Assert
      // 1. Verify offer status updated to accepted
      final capturedOffer =
          verify(mockDataSource.update(captureAny)).captured.first
              as OfferModel;
      expect(capturedOffer.status, OfferStatus.accepted.name);

      // 2. Verify order created
      verify(mockOrderRepository.create(any)).called(1);
    });

    test('rejectOffer updates offer status to rejected', () async {
      // Arrange
      final pendingOffer = testOffer.copyWith(
        status: OfferStatus.pending,
        waitingFor: UserRole.buyer,
      );
      final pendingModel = createModelFromEntity(pendingOffer);

      when(
        mockDataSource.getById(pendingOffer.id),
      ).thenAnswer((_) async => pendingModel);
      when(mockDataSource.update(any)).thenAnswer((_) async => {});

      // Act
      await repository.rejectOffer(pendingOffer.id, UserRole.buyer);

      // Assert
      final capturedOffer =
          verify(mockDataSource.update(captureAny)).captured.first
              as OfferModel;
      expect(capturedOffer.status, OfferStatus.rejected.name);
    });

    test('counterOffer updates offer terms and switches turn', () async {
      // Arrange
      final pendingOffer = testOffer.copyWith(
        status: OfferStatus.pending,
        waitingFor: UserRole.fisher,
      );
      final pendingModel = createModelFromEntity(pendingOffer);
      final newTerms = TestData.createOfferTerms(
        totalPrice: TestData.createPrice(amount: 60000),
      );

      when(
        mockDataSource.getById(pendingOffer.id),
      ).thenAnswer((_) async => pendingModel);
      when(mockDataSource.update(any)).thenAnswer((_) async => {});

      // Act
      await repository.counterOffer(pendingOffer.id, UserRole.fisher, newTerms);

      // Assert
      final capturedOffer =
          verify(mockDataSource.update(captureAny)).captured.first
              as OfferModel;
      expect(capturedOffer.currentPriceAmount, newTerms.totalPrice.amount);
      expect(
        capturedOffer.waitingFor,
        'buyer',
      ); // Switched from fisher to buyer
    });
  });
}
