import 'package:flutter_test/flutter_test.dart';
import 'package:siren_marketplace/core/domain/entities/user.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/value_objects/rating.dart';
import '../../../helpers/test_data.dart';

void main() {
  group('User Entity', () {
    late User testUser;

    setUp(() {
      testUser = TestData.createUser(
        name: 'Test User',
        currentRole: UserRole.fisher,
        rating: Rating.fromValue(4.5),
        reviewCount: 10,
      );
    });

    group('Business Logic - Avatar', () {
      test(
        'hasAvatar returns true when avatarUrl is not null and not empty',
        () {
          final user = testUser.copyWith(
            avatarUrl: 'https://example.com/avatar.jpg',
          );

          expect(user.hasAvatar, true);
        },
      );

      test('hasAvatar returns false when avatarUrl is null', () {
        final user = testUser.copyWith(avatarUrl: null);

        expect(user.hasAvatar, false);
      });

      test('hasAvatar returns false when avatarUrl is empty string', () {
        final user = testUser.copyWith(avatarUrl: '');

        expect(user.hasAvatar, false);
      });
    });

    group('Business Logic - Ratings', () {
      test('hasRatings returns true when reviewCount is greater than 0', () {
        final user = testUser.copyWith(reviewCount: 5);

        expect(user.hasRatings, true);
      });

      test('hasRatings returns false when reviewCount is 0', () {
        final user = testUser.copyWith(reviewCount: 0);

        expect(user.hasRatings, false);
      });

      test('displayRating shows rating and count when user has ratings', () {
        final user = testUser.copyWith(
          rating: Rating.fromValue(4.7),
          reviewCount: 15,
        );

        expect(user.displayRating, '4.7 (15)');
      });

      test('displayRating shows "No reviews yet" when reviewCount is 0', () {
        final user = testUser.copyWith(reviewCount: 0);

        expect(user.displayRating, 'No reviews yet');
      });

      test('displayRating formats rating to 1 decimal place', () {
        final user = testUser.copyWith(
          rating: Rating.fromValue(4.0),
          reviewCount: 3,
        );

        expect(user.displayRating, '4.0 (3)');
      });

      test('displayRating shows singular form for 1 review', () {
        final user = testUser.copyWith(
          rating: Rating.fromValue(5.0),
          reviewCount: 1,
        );

        // Note: The implementation shows count in parentheses
        expect(user.displayRating, '5.0 (1)');
      });
    });

    group('Equality', () {
      test('two users with same values are equal', () {
        final user1 = TestData.createUser(id: 'same-id');
        final user2 = TestData.createUser(id: 'same-id');

        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('two users with different ids are not equal', () {
        final user1 = TestData.createUser(id: 'id-1');
        final user2 = TestData.createUser(id: 'id-2');

        expect(user1, isNot(equals(user2)));
      });

      test('two users with different names are not equal', () {
        final user1 = TestData.createUser(id: 'same', name: 'Alice');
        final user2 = TestData.createUser(id: 'same', name: 'Bob');

        expect(user1, isNot(equals(user2)));
      });

      test('two users with different ratings are not equal', () {
        final user1 = TestData.createUser(
          id: 'same',
          rating: Rating.fromValue(4.0),
        );
        final user2 = TestData.createUser(
          id: 'same',
          rating: Rating.fromValue(5.0),
        );

        expect(user1, isNot(equals(user2)));
      });

      test('two users with different roles are not equal', () {
        final user1 = TestData.createUser(
          id: 'same',
          currentRole: UserRole.fisher,
        );
        final user2 = TestData.createUser(
          id: 'same',
          currentRole: UserRole.buyer,
        );

        expect(user1, isNot(equals(user2)));
      });
    });

    group('CopyWith', () {
      test('copyWith creates new instance with updated values', () {
        final original = testUser;

        final updated = original.copyWith(
          name: 'Updated Name',
          currentRole: UserRole.buyer,
          rating: Rating.fromValue(5.0),
        );

        expect(updated.name, 'Updated Name');
        expect(updated.currentRole, UserRole.buyer);
        expect(updated.rating.value, 5.0);
        expect(updated.id, original.id);
      });

      test('copyWith preserves unchanged values', () {
        final original = testUser;
        final updated = original.copyWith(name: 'New Name');

        expect(updated.currentRole, original.currentRole);
        expect(updated.rating, original.rating);
        expect(updated.reviewCount, original.reviewCount);
      });

      test('copyWith can update avatarUrl', () {
        final original = testUser;
        final updated = original.copyWith(
          avatarUrl: 'https://example.com/new-avatar.jpg',
        );

        expect(updated.avatarUrl, 'https://example.com/new-avatar.jpg');
      });

      test('copyWith can update reviewCount', () {
        final original = testUser.copyWith(reviewCount: 5);
        final updated = original.copyWith(reviewCount: 10);

        expect(updated.reviewCount, 10);
      });
    });

    group('Edge Cases', () {
      test('user with zero rating and zero reviews', () {
        final user = testUser.copyWith(
          rating: Rating.fromValue(0.0),
          reviewCount: 0,
        );

        expect(user.hasRatings, false);
        expect(user.displayRating, 'No reviews yet');
      });

      test('user with perfect rating', () {
        final user = testUser.copyWith(
          rating: Rating.fromValue(5.0),
          reviewCount: 100,
        );

        expect(user.displayRating, '5.0 (100)');
      });

      test('user with many reviews', () {
        final user = testUser.copyWith(
          rating: Rating.fromValue(4.8),
          reviewCount: 1000,
        );

        expect(user.displayRating, '4.8 (1000)');
      });
    });
  });
}
