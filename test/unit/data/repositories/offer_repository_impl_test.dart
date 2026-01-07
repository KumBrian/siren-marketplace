import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:siren_marketplace/core/data/models/offer_model.dart';
import 'package:siren_marketplace/core/services/connectivity_service.dart';
import 'package:siren_marketplace/core/data/repositories/offer_repository_impl.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/repositories/i_order_repository.dart';
import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_data.dart';

void main() {
  late OfferRepositoryImpl repository;
  late MockIOfferDataSource mockRemoteDataSource;
  late MockIOfferDataSource mockLocalDataSource;
  late MockIOrderRepository mockOrderRepository;
  late MockConnectivityService mockConnectivityService;
  final sl = GetIt.instance;

  setUp(() {
    mockRemoteDataSource = MockIOfferDataSource();
    mockLocalDataSource = MockIOfferDataSource();
    mockOrderRepository = MockIOrderRepository();
    mockConnectivityService = MockConnectivityService();

    // Default to online
    when(
      mockConnectivityService.checkConnectivity(),
    ).thenAnswer((_) async => NetworkStatus.online);

    // Register mock dependencies
    if (sl.isRegistered<IOrderRepository>()) {
      sl.unregister<IOrderRepository>();
    }
    sl.registerSingleton<IOrderRepository>(mockOrderRepository);

    repository = OfferRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      connectivityService: mockConnectivityService,
      userRepository:
          MockIUserRepository(), // We can use a simple mock here since it's not the SUT
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
      when(mockRemoteDataSource.create(any)).thenAnswer((_) async => 'new-id');

      final result = await repository.create(testOffer);

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
      expect(result, isNotNull);
      expect(result!.id, testModel.id);
      verify(mockConnectivityService.checkConnectivity()).called(1);
      verify(mockLocalDataSource.getById(testModel.id)).called(1);
      verifyNever(mockRemoteDataSource.getById(any));
    });

    test('getById returns mapped entity when found', () async {
      when(
        mockRemoteDataSource.getById(testOffer.id),
      ).thenAnswer((_) async => testModel);
      when(mockLocalDataSource.saveBatch([testModel])).thenAnswer((_) async {});

      final result = await repository.getById(testOffer.id);

      expect(result, isNotNull);
      expect(result!.id, testOffer.id);
      verify(mockRemoteDataSource.getById(testOffer.id)).called(1);
      verify(mockLocalDataSource.saveBatch([testModel])).called(1);
    });

    test('acceptOffer updates offer status and creates order', () async {
      // Arrange
      final pendingOffer = testOffer.copyWith(
        status: OfferStatus.pending,
        waitingFor: UserRole.fisher,
      );
      final pendingModel = createModelFromEntity(pendingOffer);
      final acceptedModel = pendingModel.copyWith(
        status: OfferStatus.accepted.name,
      );

      when(
        mockRemoteDataSource.getById(pendingOffer.id),
      ).thenAnswer((_) async => acceptedModel);
      when(
        mockRemoteDataSource.respond(any, any),
      ).thenAnswer((_) async => acceptedModel);
      when(mockLocalDataSource.saveBatch(any)).thenAnswer((_) async => {});
      when(mockOrderRepository.create(any)).thenAnswer((_) async => 'order-id');

      // Act
      await repository.acceptOffer(pendingOffer.id, UserRole.fisher);

      // Assert
      // Verify remote update via respond
      verify(mockRemoteDataSource.respond(pendingOffer.id, any)).called(1);
      // Verify local update
      verify(mockLocalDataSource.saveBatch(any)).called(1);
    });

    test('rejectOffer updates offer status to rejected', () async {
      // Arrange
      final pendingOffer = testOffer.copyWith(
        status: OfferStatus.pending,
        waitingFor: UserRole.buyer,
      );
      final pendingModel = createModelFromEntity(pendingOffer);
      final rejectedModel = pendingModel.copyWith(
        status: OfferStatus.rejected.name,
      );

      when(
        mockRemoteDataSource.getById(pendingOffer.id),
      ).thenAnswer((_) async => rejectedModel);
      when(
        mockRemoteDataSource.respond(any, any),
      ).thenAnswer((_) async => rejectedModel);
      when(mockLocalDataSource.saveBatch(any)).thenAnswer((_) async => {});

      // Act
      await repository.rejectOffer(pendingOffer.id, UserRole.buyer);

      // Assert
      verify(mockRemoteDataSource.respond(pendingOffer.id, any)).called(1);
      verify(mockLocalDataSource.saveBatch(any)).called(1);
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
      final updatedModel = pendingModel.copyWith(
        currentPriceAmount: 60000,
        currentPricePerKgAmount: 12000,
        waitingFor: 'buyer',
      );

      when(
        mockRemoteDataSource.getById(pendingOffer.id),
      ).thenAnswer((_) async => updatedModel);
      when(
        mockRemoteDataSource.counterOffer(any, any),
      ).thenAnswer((_) async => 'offer-id');
      when(mockLocalDataSource.saveBatch(any)).thenAnswer((_) async => {});

      // Act
      await repository.counterOffer(pendingOffer.id, UserRole.fisher, newTerms);

      // Assert
      verify(mockRemoteDataSource.counterOffer(pendingOffer.id, any)).called(1);
      verify(mockLocalDataSource.saveBatch(any)).called(1);
    });
  });
}
