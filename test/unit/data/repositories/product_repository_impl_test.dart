import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:siren_marketplace/core/data/api/models/product_api_models.dart';
import 'package:siren_marketplace/core/data/models/product_model.dart';
import 'package:siren_marketplace/core/data/repositories/product_repository_impl.dart';
import 'package:siren_marketplace/core/services/connectivity_service.dart';
import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_data.dart'; // Assuming TestData exists

void main() {
  late ProductRepositoryImpl repository;
  late MockProductsApiDataSource mockRemoteDataSource;
  late MockLocalProductDataSource mockLocalDataSource;
  late MockConnectivityService mockConnectivityService;

  setUp(() {
    mockRemoteDataSource = MockProductsApiDataSource();
    mockLocalDataSource = MockLocalProductDataSource();
    mockConnectivityService = MockConnectivityService();

    when(
      mockConnectivityService.checkConnectivity(),
    ).thenAnswer((_) async => NetworkStatus.online);

    // Stub caching
    when(mockLocalDataSource.saveBatch(any)).thenAnswer((_) async {});

    repository = ProductRepositoryImpl(
      mockRemoteDataSource,
      mockLocalDataSource,
      mockConnectivityService,
    );
  });

  group('ProductRepositoryImpl', () {
    final testProduct = TestData.createProduct(id: '123');

    test('getProductById returns remote data when online', () async {
      // Arrange
      final testApiModel = ProductApiModel(
        id: 123,
        name: 'Test Product',
      ); // minimal
      when(
        mockRemoteDataSource.getProductById(any),
      ).thenAnswer((_) async => testApiModel);

      // Act
      final result = await repository.getProductById('123');

      // Assert
      expect(result.isRight, true);
      verify(mockRemoteDataSource.getProductById('123')).called(1);
      verify(mockLocalDataSource.saveBatch(any)).called(1);
      verifyNever(mockLocalDataSource.getProductById(any));
    });

    test('getProductById returns catch data when offline', () async {
      // Arrange
      when(
        mockConnectivityService.checkConnectivity(),
      ).thenAnswer((_) async => NetworkStatus.offline);
      when(
        mockLocalDataSource.getProductById('123'),
      ).thenAnswer((_) async => ProductModel.fromDomain(testProduct));

      // Act
      final result = await repository.getProductById('123');

      result.fold(
        ifLeft: (failure) =>
            fail('Expected Success but got Failure: ${failure.message}'),
        ifRight: (product) => expect(product?.id, testProduct.id),
      );
      verify(mockConnectivityService.checkConnectivity()).called(1);
      verify(mockLocalDataSource.getProductById('123')).called(1);
      verifyNever(mockRemoteDataSource.getProductById(any));
    });

    test('getAvailableProducts returns remote data when online', () async {
      // Arrange
      when(
        mockRemoteDataSource.getAvailableProducts(),
      ).thenAnswer((_) async => []);

      // Act
      final result = await repository.getAvailableProducts();

      // Assert
      expect(result.isRight, true);
      expect(result.isRight, true);
      verify(mockRemoteDataSource.getAvailableProducts()).called(1);
      verify(mockLocalDataSource.saveBatch(any)).called(1);
    });

    test('getAvailableProducts returns catch data when offline', () async {
      // Arrange
      when(
        mockConnectivityService.checkConnectivity(),
      ).thenAnswer((_) async => NetworkStatus.offline);
      when(
        mockLocalDataSource.getAllProducts(),
      ).thenAnswer((_) async => [ProductModel.fromDomain(testProduct)]);

      // Act
      final result = await repository.getAvailableProducts();

      result.fold(
        ifLeft: (failure) =>
            fail('Expected Success but got Failure: ${failure.message}'),
        ifRight: (products) {
          expect(products.first.id, testProduct.id);
        },
      );
      verify(mockLocalDataSource.getAllProducts()).called(1);
    });
  });
}
