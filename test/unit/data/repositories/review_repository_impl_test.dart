import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:siren_marketplace/core/data/models/review_model.dart';
import 'package:siren_marketplace/core/data/repositories/review_repository_impl.dart';
import 'package:siren_marketplace/core/domain/entities/review.dart';
import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_data.dart';

void main() {
  late ReviewRepositoryImpl repository;
  late MockIReviewDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockIReviewDataSource();
    repository = ReviewRepositoryImpl(dataSource: mockDataSource);
  });

  group('ReviewRepositoryImpl', () {
    final testReview = TestData.createReview();

    ReviewModel createModelFromEntity(Review entity) {
      return ReviewModel(
        id: entity.id,
        orderId: entity.orderId,
        reviewerId: entity.reviewerId,
        reviewedUserId: entity.reviewedUserId,
        ratingValue: entity.rating.value,
        comment: entity.comment,
        timestamp: entity.timestamp.toIso8601String(),
      );
    }

    final testModel = createModelFromEntity(testReview);

    test('create calls dataSource.create and returns id', () async {
      when(mockDataSource.create(any)).thenAnswer((_) async => 'new-id');

      final result = await repository.create(testReview);

      expect(result, 'new-id');
      verify(mockDataSource.create(any)).called(1);
    });

    test('getById returns mapped entity when found', () async {
      when(
        mockDataSource.getById(testReview.id),
      ).thenAnswer((_) async => testModel);

      final result = await repository.getById(testReview.id);

      expect(result, isNotNull);
      expect(result!.id, testReview.id);
      verify(mockDataSource.getById(testReview.id)).called(1);
    });

    test('getReviewsForUser returns list of mapped entities', () async {
      when(
        mockDataSource.getReviewsForUser(testReview.reviewedUserId),
      ).thenAnswer((_) async => [testModel]);

      final result = await repository.getReviewsForUser(
        testReview.reviewedUserId,
      );

      expect(result.length, 1);
      expect(result.first.id, testReview.id);
      verify(
        mockDataSource.getReviewsForUser(testReview.reviewedUserId),
      ).called(1);
    });

    test('getReviewsByUser returns list of mapped entities', () async {
      when(
        mockDataSource.getReviewsByUser(testReview.reviewerId),
      ).thenAnswer((_) async => [testModel]);

      final result = await repository.getReviewsByUser(testReview.reviewerId);

      expect(result.length, 1);
      expect(result.first.id, testReview.id);
      verify(mockDataSource.getReviewsByUser(testReview.reviewerId)).called(1);
    });

    test('getReviewsForOrder returns list of mapped entities', () async {
      when(
        mockDataSource.getReviewsForOrder(testReview.orderId),
      ).thenAnswer((_) async => [testModel]);

      final result = await repository.getReviewsForOrder(testReview.orderId);

      expect(result.length, 1);
      expect(result.first.id, testReview.id);
      verify(mockDataSource.getReviewsForOrder(testReview.orderId)).called(1);
    });

    test('hasReview calls dataSource.hasReview', () async {
      when(
        mockDataSource.hasReview(
          orderId: anyNamed('orderId'),
          reviewerId: anyNamed('reviewerId'),
          reviewedUserId: anyNamed('reviewedUserId'),
        ),
      ).thenAnswer((_) async => true);

      final result = await repository.hasReview(
        orderId: testReview.orderId,
        reviewerId: testReview.reviewerId,
        reviewedUserId: testReview.reviewedUserId,
      );

      expect(result, true);
      verify(
        mockDataSource.hasReview(
          orderId: testReview.orderId,
          reviewerId: testReview.reviewerId,
          reviewedUserId: testReview.reviewedUserId,
        ),
      ).called(1);
    });

    test('delete calls dataSource.delete', () async {
      when(mockDataSource.delete(testReview.id)).thenAnswer((_) async => {});

      await repository.delete(testReview.id);

      verify(mockDataSource.delete(testReview.id)).called(1);
    });
  });
}
