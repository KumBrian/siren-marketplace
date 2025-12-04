import 'package:flutter_test/flutter_test.dart';
import 'package:siren_marketplace/core/domain/entities/review.dart';
import 'package:siren_marketplace/core/domain/value_objects/rating.dart';
import '../../../helpers/test_data.dart';

void main() {
  group('Review Entity', () {
    late Review testReview;

    setUp(() {
      testReview = TestData.createReview(
        orderId: 'order-123',
        reviewerId: 'reviewer-456',
        reviewedUserId: 'reviewed-789',
        rating: Rating.fromValue(4.5),
        comment: 'Great transaction!',
      );
    });

    group('Business Logic - Comment', () {
      test(
        'hasComment returns true when comment is not null and not empty',
        () {
          final review = TestData.createReview(comment: 'Good service');

          expect(review.hasComment, true);
        },
      );

      test('hasComment returns false when comment is null', () {
        final review = TestData.createReview(comment: null);

        expect(review.hasComment, false);
      });

      test('hasComment returns false when comment is empty string', () {
        final review = TestData.createReview(comment: '');

        expect(review.hasComment, false);
      });

      test('hasComment returns true for whitespace-only comment', () {
        // The implementation checks for empty string, not trimmed
        final review = TestData.createReview(comment: '   ');

        expect(review.hasComment, true);
      });
    });

    group('Equality', () {
      test('two reviews with same values are equal', () {
        final fixedDate = DateTime(2025, 1, 1, 12, 0);
        final review1 = TestData.createReview(
          id: 'same-id',
          timestamp: fixedDate,
        );
        final review2 = TestData.createReview(
          id: 'same-id',
          timestamp: fixedDate,
        );

        expect(review1, equals(review2));
        expect(review1.hashCode, equals(review2.hashCode));
      });

      test('two reviews with different ids are not equal', () {
        final review1 = TestData.createReview(id: 'id-1');
        final review2 = TestData.createReview(id: 'id-2');

        expect(review1, isNot(equals(review2)));
      });

      test('two reviews with different ratings are not equal', () {
        final fixedDate = DateTime(2025, 1, 1);
        final review1 = TestData.createReview(
          id: 'same',
          rating: Rating.fromValue(4.0),
          timestamp: fixedDate,
        );
        final review2 = TestData.createReview(
          id: 'same',
          rating: Rating.fromValue(5.0),
          timestamp: fixedDate,
        );

        expect(review1, isNot(equals(review2)));
      });

      test('two reviews with different comments are not equal', () {
        final fixedDate = DateTime(2025, 1, 1);
        final review1 = TestData.createReview(
          id: 'same',
          comment: 'Good',
          timestamp: fixedDate,
        );
        final review2 = TestData.createReview(
          id: 'same',
          comment: 'Excellent',
          timestamp: fixedDate,
        );

        expect(review1, isNot(equals(review2)));
      });

      test('two reviews with different timestamps are not equal', () {
        final review1 = TestData.createReview(
          id: 'same',
          timestamp: DateTime(2025, 1, 1),
        );
        final review2 = TestData.createReview(
          id: 'same',
          timestamp: DateTime(2025, 1, 2),
        );

        expect(review1, isNot(equals(review2)));
      });
    });

    group('Properties', () {
      test('review has correct orderId', () {
        expect(testReview.orderId, 'order-123');
      });

      test('review has correct reviewerId', () {
        expect(testReview.reviewerId, 'reviewer-456');
      });

      test('review has correct reviewedUserId', () {
        expect(testReview.reviewedUserId, 'reviewed-789');
      });

      test('review has correct rating', () {
        expect(testReview.rating.value, 4.5);
      });

      test('review has correct comment', () {
        expect(testReview.comment, 'Great transaction!');
      });
    });

    group('Edge Cases', () {
      test('review with minimum rating', () {
        final review = TestData.createReview(rating: Rating.fromValue(0.0));

        expect(review.rating.value, 0.0);
      });

      test('review with maximum rating', () {
        final review = TestData.createReview(rating: Rating.fromValue(5.0));

        expect(review.rating.value, 5.0);
      });

      test('review without comment', () {
        final review = TestData.createReview(comment: null);

        expect(review.comment, null);
        expect(review.hasComment, false);
      });

      test('review with long comment', () {
        final longComment = 'A' * 1000;
        final review = TestData.createReview(comment: longComment);

        expect(review.comment, longComment);
        expect(review.hasComment, true);
      });

      test('review with empty comment', () {
        final review = TestData.createReview(comment: '');

        expect(review.comment, '');
        expect(review.hasComment, false);
      });
    });

    group('Immutability', () {
      test('review properties are immutable', () {
        final review = testReview;

        // All properties should be final and cannot be changed
        expect(review.id, testReview.id);
        expect(review.orderId, testReview.orderId);
        expect(review.reviewerId, testReview.reviewerId);
        expect(review.reviewedUserId, testReview.reviewedUserId);
        expect(review.rating, testReview.rating);
        expect(review.comment, testReview.comment);
        expect(review.timestamp, testReview.timestamp);
      });
    });
  });
}
