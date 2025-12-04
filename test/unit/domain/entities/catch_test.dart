import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/enums/catch_status.dart';
import 'package:siren_marketplace/core/domain/value_objects/weight.dart';
import '../../../helpers/test_data.dart';

void main() {
  group('Catch Entity', () {
    late Catch testCatch;

    setUp(() {
      testCatch = TestData.createCatch();
    });

    group('Business Logic - Expiration', () {
      test('isExpired returns false for new catch', () {
        final newCatch = testCatch.copyWith(datePosted: DateTime.now());

        expect(newCatch.isExpired, false);
      });

      test('isExpired returns true when past expiration date', () {
        fakeAsync((async) {
          final oldCatch = testCatch.copyWith(
            datePosted: DateTime.now().subtract(const Duration(days: 8)),
          );

          expect(oldCatch.isExpired, true);
        });
      });

      test('isExpired returns false when within expiration period', () {
        final recentCatch = testCatch.copyWith(
          datePosted: DateTime.now().subtract(const Duration(days: 3)),
        );

        expect(recentCatch.isExpired, false);
      });

      test('isExpired returns false for non-available status', () {
        final soldCatch = testCatch.copyWith(
          datePosted: DateTime.now().subtract(const Duration(days: 10)),
          status: CatchStatus.soldOut,
        );

        expect(soldCatch.isExpired, false);
      });

      test('daysLeft calculates correctly for new catch', () {
        final now = DateTime(2025, 1, 1, 12, 0);
        final newCatch = testCatch.copyWith(datePosted: now);

        // Mock current time to be same as posted time
        final daysLeft = newCatch.expirationDate.difference(now).inDays;
        expect(daysLeft, 7);
      });

      test('daysLeft calculates correctly for 3-day-old catch', () {
        final now = DateTime(2025, 1, 4, 12, 0);
        final postedDate = DateTime(2025, 1, 1, 12, 0);
        final oldCatch = testCatch.copyWith(datePosted: postedDate);

        // Expiration is 7 days from posted, so 4 days left
        final daysLeft = oldCatch.expirationDate.difference(now).inDays;
        expect(daysLeft, 4);
      });

      test('daysLeft returns 0 for expired catch', () {
        final expiredCatch = testCatch.copyWith(
          datePosted: DateTime.now().subtract(const Duration(days: 10)),
        );

        expect(expiredCatch.daysLeft, 0);
      });

      test('daysLeftLabel returns correct text for 1 day', () {
        final now = DateTime(2025, 1, 7, 12, 0);
        final postedDate = DateTime(2025, 1, 1, 12, 0);
        final catch1Day = testCatch.copyWith(datePosted: postedDate);

        // 6 days have passed, 1 day left until expiration
        final daysLeft = catch1Day.expirationDate.difference(now).inDays;
        expect(daysLeft, 1);
      });

      test('daysLeftLabel returns correct text for multiple days', () {
        final now = DateTime(2025, 1, 4, 12, 0);
        final postedDate = DateTime(2025, 1, 1, 12, 0);
        final catch3Days = testCatch.copyWith(datePosted: postedDate);

        // 3 days have passed, 4 days left until expiration
        final daysLeft = catch3Days.expirationDate.difference(now).inDays;
        expect(daysLeft, 4);
      });

      test('daysLeftLabel returns "Expired" for expired catch', () {
        final expiredCatch = testCatch.copyWith(
          datePosted: DateTime.now().subtract(const Duration(days: 10)),
        );

        expect(expiredCatch.daysLeftLabel, 'Expired');
      });
    });

    group('Business Logic - Status Checks', () {
      test('isSoldOut returns true for sold out status', () {
        final soldCatch = testCatch.copyWith(status: CatchStatus.soldOut);

        expect(soldCatch.isSoldOut, true);
      });

      test('isAvailable returns true for available status', () {
        final availableCatch = testCatch.copyWith(
          status: CatchStatus.available,
        );

        expect(availableCatch.isAvailable, true);
      });

      test('canReceiveOffers returns true for available non-expired catch', () {
        final goodCatch = testCatch.copyWith(
          status: CatchStatus.available,
          datePosted: DateTime.now(),
        );

        expect(goodCatch.canReceiveOffers, true);
      });

      test('canReceiveOffers returns false for expired catch', () {
        final expiredCatch = testCatch.copyWith(
          status: CatchStatus.available,
          datePosted: DateTime.now().subtract(const Duration(days: 10)),
        );

        expect(expiredCatch.canReceiveOffers, false);
      });

      test('canReceiveOffers returns false for sold out catch', () {
        final soldCatch = testCatch.copyWith(status: CatchStatus.soldOut);

        expect(soldCatch.canReceiveOffers, false);
      });
    });

    group('Domain Actions - Mark Status', () {
      test('markAsExpired changes status to expired', () {
        final availableCatch = testCatch.copyWith(
          status: CatchStatus.available,
        );

        final result = availableCatch.markAsExpired();

        expect(result.status, CatchStatus.expired);
        expect(result.id, availableCatch.id);
      });

      test('markAsExpired throws when not available', () {
        final soldCatch = testCatch.copyWith(status: CatchStatus.soldOut);

        expect(() => soldCatch.markAsExpired(), throwsA(isA<StateError>()));
      });

      test('markAsSoldOut changes status to sold out', () {
        final availableCatch = testCatch.copyWith(
          status: CatchStatus.available,
        );

        final result = availableCatch.markAsSoldOut();

        expect(result.status, CatchStatus.soldOut);
      });

      test('markAsSoldOut throws when not available', () {
        final expiredCatch = testCatch.copyWith(status: CatchStatus.expired);

        expect(() => expiredCatch.markAsSoldOut(), throwsA(isA<StateError>()));
      });

      test('markAsRemoved changes status to removed', () {
        final result = testCatch.markAsRemoved();

        expect(result.status, CatchStatus.removed);
      });
    });

    group('Domain Actions - Reduce Weight', () {
      test('reduceAvailableWeight updates weight correctly', () {
        final catchWith10Kg = testCatch.copyWith(
          availableWeight: Weight.fromKg(10),
        );
        final soldWeight = Weight.fromKg(3);

        final result = catchWith10Kg.reduceAvailableWeight(soldWeight);

        expect(result.availableWeight.kilograms, 7.0);
        expect(result.status, CatchStatus.available);
      });

      test(
        'reduceAvailableWeight marks as sold out when weight reaches zero',
        () {
          final catchWith5Kg = testCatch.copyWith(
            availableWeight: Weight.fromKg(5),
            status: CatchStatus.available,
          );
          final soldWeight = Weight.fromKg(5);

          final result = catchWith5Kg.reduceAvailableWeight(soldWeight);

          expect(result.availableWeight.isZero, true);
          expect(result.status, CatchStatus.soldOut);
        },
      );

      test('reduceAvailableWeight throws when exceeding available weight', () {
        final catchWith5Kg = testCatch.copyWith(
          availableWeight: Weight.fromKg(5),
        );
        final tooMuch = Weight.fromKg(6);

        expect(
          () => catchWith5Kg.reduceAvailableWeight(tooMuch),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('reduceAvailableWeight preserves other properties', () {
        final original = testCatch.copyWith(
          name: 'Test Catch',
          availableWeight: Weight.fromKg(10),
        );

        final result = original.reduceAvailableWeight(Weight.fromKg(2));

        expect(result.name, 'Test Catch');
        expect(result.fisherId, original.fisherId);
      });
    });

    group('Image Handling', () {
      test('hasImages returns true when images exist', () {
        final catchWithImages = testCatch.copyWith(
          images: ['image1.jpg', 'image2.jpg'],
        );

        expect(catchWithImages.hasImages, true);
      });

      test('hasImages returns false when no images', () {
        final catchNoImages = testCatch.copyWith(images: []);

        expect(catchNoImages.hasImages, false);
      });

      test('primaryImage returns first image when images exist', () {
        final catchWithImages = testCatch.copyWith(
          images: ['primary.jpg', 'secondary.jpg'],
        );

        expect(catchWithImages.primaryImage, 'primary.jpg');
      });

      test('primaryImage returns null when no images', () {
        final catchNoImages = testCatch.copyWith(images: []);

        expect(catchNoImages.primaryImage, null);
      });
    });

    group('Equality', () {
      test('two catches with same values are equal', () {
        final fixedDate = DateTime(2025, 1, 1, 12, 0);
        final catch1 = TestData.createCatch(
          id: 'same-id',
        ).copyWith(datePosted: fixedDate);
        final catch2 = TestData.createCatch(
          id: 'same-id',
        ).copyWith(datePosted: fixedDate);

        expect(catch1, equals(catch2));
        expect(catch1.hashCode, equals(catch2.hashCode));
      });

      test('two catches with different ids are not equal', () {
        final catch1 = TestData.createCatch(id: 'id-1');
        final catch2 = TestData.createCatch(id: 'id-2');

        expect(catch1, isNot(equals(catch2)));
      });

      test('two catches with different weights are not equal', () {
        final catch1 = TestData.createCatch(availableWeight: Weight.fromKg(10));
        final catch2 = TestData.createCatch(availableWeight: Weight.fromKg(5));

        expect(catch1, isNot(equals(catch2)));
      });
    });

    group('CopyWith', () {
      test('copyWith creates new instance with updated values', () {
        final original = testCatch;
        final updated = original.copyWith(
          name: 'Updated Name',
          status: CatchStatus.soldOut,
        );

        expect(updated.name, 'Updated Name');
        expect(updated.status, CatchStatus.soldOut);
        expect(updated.id, original.id);
      });

      test('copyWith preserves unchanged values', () {
        final original = testCatch;
        final updated = original.copyWith(name: 'New Name');

        expect(updated.fisherId, original.fisherId);
        expect(updated.species, original.species);
        expect(updated.market, original.market);
      });
    });
  });
}
