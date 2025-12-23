import 'package:flutter_test/flutter_test.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/value_objects/offer_terms.dart';
import 'package:siren_marketplace/core/domain/value_objects/price.dart';
import 'package:siren_marketplace/core/domain/value_objects/weight.dart';
import '../../../helpers/test_data.dart';

void main() {
  group('Offer Entity', () {
    late Offer testOffer;
    const fisherId = 'fisher-123';
    const buyerId = 'buyer-456';

    setUp(() {
      testOffer = TestData.createOffer(
        fisherId: fisherId,
        buyerId: buyerId,
        status: OfferStatus.pending,
        waitingFor: UserRole.fisher,
      );
    });

    group('Business Logic - Status Checks', () {
      test('isPending returns true for pending status', () {
        final pendingOffer = testOffer.copyWith(status: OfferStatus.pending);

        expect(pendingOffer.isPending, true);
      });

      test('isAccepted returns true for accepted status', () {
        final acceptedOffer = testOffer.copyWith(status: OfferStatus.accepted);

        expect(acceptedOffer.isAccepted, true);
      });

      test('isRejected returns true for rejected status', () {
        final rejectedOffer = testOffer.copyWith(status: OfferStatus.rejected);

        expect(rejectedOffer.isRejected, true);
      });

      test('isFinal returns true for accepted status', () {
        final acceptedOffer = testOffer.copyWith(status: OfferStatus.accepted);

        expect(acceptedOffer.isFinal, true);
      });

      test('isFinal returns true for rejected status', () {
        final rejectedOffer = testOffer.copyWith(status: OfferStatus.rejected);

        expect(rejectedOffer.isFinal, true);
      });

      test('isFinal returns false for pending status', () {
        final pendingOffer = testOffer.copyWith(status: OfferStatus.pending);

        expect(pendingOffer.isFinal, false);
      });

      test('hasBeenCountered returns true when previousTerms exist', () {
        final newTerms = TestData.createOfferTerms();
        final counteredOffer = testOffer.copyWith(previousTerms: newTerms);

        expect(counteredOffer.hasBeenCountered, true);
      });

      test('hasBeenCountered returns false when no previousTerms', () {
        final newOffer = testOffer.copyWith(previousTerms: null);

        expect(newOffer.hasBeenCountered, false);
      });
    });

    group('Business Logic - Turn Management', () {
      test(
        'isUsersTurn returns true when fisher is waiting and user is fisher',
        () {
          final offer = testOffer.copyWith(waitingFor: UserRole.fisher);

          expect(offer.isUsersTurn(fisherId), true);
        },
      );

      test(
        'isUsersTurn returns false when fisher is waiting and user is buyer',
        () {
          final offer = testOffer.copyWith(waitingFor: UserRole.fisher);

          expect(offer.isUsersTurn(buyerId), false);
        },
      );

      test(
        'isUsersTurn returns true when buyer is waiting and user is buyer',
        () {
          final offer = testOffer.copyWith(waitingFor: UserRole.buyer);

          expect(offer.isUsersTurn(buyerId), true);
        },
      );

      test(
        'isUsersTurn returns false when buyer is waiting and user is fisher',
        () {
          final offer = testOffer.copyWith(waitingFor: UserRole.buyer);

          expect(offer.isUsersTurn(fisherId), false);
        },
      );

      test('isUsersTurn returns false when waitingFor is null', () {
        final offer = testOffer.copyWith(
          waitingFor: null,
          clearWaitingFor: true,
        );

        expect(offer.isUsersTurn(fisherId), false);
        expect(offer.isUsersTurn(buyerId), false);
      });
    });

    group('Business Logic - Action Permissions', () {
      test('canBeCounteredBy returns true when pending and user turn', () {
        final offer = testOffer.copyWith(
          status: OfferStatus.pending,
          waitingFor: UserRole.fisher,
        );

        expect(offer.canBeCounteredBy(fisherId), true);
      });

      test('canBeCounteredBy returns false when not pending', () {
        final offer = testOffer.copyWith(
          status: OfferStatus.accepted,
          waitingFor: UserRole.fisher,
        );

        expect(offer.canBeCounteredBy(fisherId), false);
      });

      test('canBeCounteredBy returns false when not user turn', () {
        final offer = testOffer.copyWith(
          status: OfferStatus.pending,
          waitingFor: UserRole.buyer,
        );

        expect(offer.canBeCounteredBy(fisherId), false);
      });

      test('canBeAcceptedBy returns true when pending and user turn', () {
        final offer = testOffer.copyWith(
          status: OfferStatus.pending,
          waitingFor: UserRole.fisher,
        );

        expect(offer.canBeAcceptedBy(fisherId), true);
      });

      test('canBeAcceptedBy returns false when not pending', () {
        final offer = testOffer.copyWith(
          status: OfferStatus.rejected,
          waitingFor: UserRole.fisher,
        );

        expect(offer.canBeAcceptedBy(fisherId), false);
      });

      test('canBeRejectedBy returns true when pending and user turn', () {
        final offer = testOffer.copyWith(
          status: OfferStatus.pending,
          waitingFor: UserRole.buyer,
        );

        expect(offer.canBeRejectedBy(buyerId), true);
      });

      test('canBeRejectedBy returns false when not user turn', () {
        final offer = testOffer.copyWith(
          status: OfferStatus.pending,
          waitingFor: UserRole.fisher,
        );

        expect(offer.canBeRejectedBy(buyerId), false);
      });
    });

    group('Business Logic - Update Flags', () {
      test('hasUpdateFor returns correct value for fisher', () {
        final offer = testOffer.copyWith(
          hasUpdateForFisher: true,
          hasUpdateForBuyer: false,
        );

        expect(offer.hasUpdateFor(UserRole.fisher), true);
        expect(offer.hasUpdateFor(UserRole.buyer), false);
      });

      test('hasUpdateFor returns correct value for buyer', () {
        final offer = testOffer.copyWith(
          hasUpdateForFisher: false,
          hasUpdateForBuyer: true,
        );

        expect(offer.hasUpdateFor(UserRole.fisher), false);
        expect(offer.hasUpdateFor(UserRole.buyer), true);
      });
    });

    group('Domain Actions - Accept', () {
      test('accept changes status to accepted', () {
        final pendingOffer = testOffer.copyWith(
          status: OfferStatus.pending,
          waitingFor: UserRole.fisher,
        );

        final result = pendingOffer.accept();

        expect(result.status, OfferStatus.accepted);
      });

      test('accept updates dateUpdated', () {
        final pendingOffer = testOffer.copyWith(
          status: OfferStatus.pending,
          dateUpdated: DateTime(2025, 1, 1),
        );

        final result = pendingOffer.accept();

        expect(result.dateUpdated.isAfter(pendingOffer.dateUpdated), true);
      });

      test('accept throws when status is not pending', () {
        final acceptedOffer = testOffer.copyWith(status: OfferStatus.accepted);

        expect(() => acceptedOffer.accept(), throwsA(isA<StateError>()));
      });

      test('accept preserves other properties', () {
        final pendingOffer = testOffer.copyWith(status: OfferStatus.pending);

        final result = pendingOffer.accept();

        expect(result.id, pendingOffer.id);
        expect(result.productId, pendingOffer.productId);
        expect(result.fisherId, pendingOffer.fisherId);
        expect(result.buyerId, pendingOffer.buyerId);
        expect(result.currentTerms, pendingOffer.currentTerms);
      });
    });

    group('Domain Actions - Reject', () {
      test('reject changes status to rejected', () {
        final pendingOffer = testOffer.copyWith(
          status: OfferStatus.pending,
          waitingFor: UserRole.buyer,
        );

        final result = pendingOffer.reject();

        expect(result.status, OfferStatus.rejected);
      });

      test('reject updates dateUpdated', () {
        final pendingOffer = testOffer.copyWith(
          status: OfferStatus.pending,
          dateUpdated: DateTime(2025, 1, 1),
        );

        final result = pendingOffer.reject();

        expect(result.dateUpdated.isAfter(pendingOffer.dateUpdated), true);
      });

      test('reject throws when status is not pending', () {
        final rejectedOffer = testOffer.copyWith(status: OfferStatus.rejected);

        expect(() => rejectedOffer.reject(), throwsA(isA<StateError>()));
      });
    });

    group('Domain Actions - Counter', () {
      test('counter updates currentTerms and saves previous', () {
        final originalTerms = TestData.createOfferTerms();
        final newTerms = OfferTerms.create(
          weight: Weight.fromKg(8),
          totalPrice: Price.fromAmount(40000),
        );

        final pendingOffer = testOffer.copyWith(
          status: OfferStatus.pending,
          currentTerms: originalTerms,
          waitingFor: UserRole.fisher,
        );

        final result = pendingOffer.counter(
          newTerms: newTerms,
          byUserId: fisherId,
        );

        expect(result.currentTerms, equals(newTerms));
        expect(result.previousTerms, equals(originalTerms));
      });

      test('counter switches waitingFor to other party (fisher to buyer)', () {
        final newTerms = TestData.createOfferTerms();
        final pendingOffer = testOffer.copyWith(
          status: OfferStatus.pending,
          waitingFor: UserRole.fisher,
        );

        final result = pendingOffer.counter(
          newTerms: newTerms,
          byUserId: fisherId,
        );

        expect(result.waitingFor, UserRole.buyer);
      });

      test('counter switches waitingFor to other party (buyer to fisher)', () {
        final newTerms = TestData.createOfferTerms();
        final pendingOffer = testOffer.copyWith(
          status: OfferStatus.pending,
          waitingFor: UserRole.buyer,
        );

        final result = pendingOffer.counter(
          newTerms: newTerms,
          byUserId: buyerId,
        );

        expect(result.waitingFor, UserRole.fisher);
      });

      test('counter keeps status as pending', () {
        final newTerms = TestData.createOfferTerms();
        final pendingOffer = testOffer.copyWith(
          status: OfferStatus.pending,
          waitingFor: UserRole.fisher,
        );

        final result = pendingOffer.counter(
          newTerms: newTerms,
          byUserId: fisherId,
        );

        expect(result.status, OfferStatus.pending);
      });

      test('counter updates dateUpdated', () {
        final newTerms = TestData.createOfferTerms();
        final pendingOffer = testOffer.copyWith(
          status: OfferStatus.pending,
          waitingFor: UserRole.fisher,
          dateUpdated: DateTime(2025, 1, 1),
        );

        final result = pendingOffer.counter(
          newTerms: newTerms,
          byUserId: fisherId,
        );

        expect(result.dateUpdated.isAfter(pendingOffer.dateUpdated), true);
      });

      test('counter throws when status is not pending', () {
        final newTerms = TestData.createOfferTerms();
        final acceptedOffer = testOffer.copyWith(status: OfferStatus.accepted);

        expect(
          () => acceptedOffer.counter(newTerms: newTerms, byUserId: fisherId),
          throwsA(isA<StateError>()),
        );
      });

      test('counter throws when not user turn', () {
        final newTerms = TestData.createOfferTerms();
        final pendingOffer = testOffer.copyWith(
          status: OfferStatus.pending,
          waitingFor: UserRole.fisher,
        );

        // Buyer tries to counter when it's fisher's turn
        expect(
          () => pendingOffer.counter(newTerms: newTerms, byUserId: buyerId),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('Equality', () {
      test('two offers with same values are equal', () {
        final fixedDate = DateTime(2025, 1, 1, 12, 0);
        final offer1 = TestData.createOffer(
          id: 'same-id',
        ).copyWith(dateCreated: fixedDate, dateUpdated: fixedDate);
        final offer2 = TestData.createOffer(
          id: 'same-id',
        ).copyWith(dateCreated: fixedDate, dateUpdated: fixedDate);

        expect(offer1, equals(offer2));
        expect(offer1.hashCode, equals(offer2.hashCode));
      });

      test('two offers with different ids are not equal', () {
        final offer1 = TestData.createOffer(id: 'id-1');
        final offer2 = TestData.createOffer(id: 'id-2');

        expect(offer1, isNot(equals(offer2)));
      });

      test('two offers with different status are not equal', () {
        final fixedDate = DateTime(2025, 1, 1);
        final offer1 = TestData.createOffer(id: 'same').copyWith(
          status: OfferStatus.pending,
          dateCreated: fixedDate,
          dateUpdated: fixedDate,
        );
        final offer2 = TestData.createOffer(id: 'same').copyWith(
          status: OfferStatus.accepted,
          dateCreated: fixedDate,
          dateUpdated: fixedDate,
        );

        expect(offer1, isNot(equals(offer2)));
      });
    });

    group('CopyWith', () {
      test('copyWith creates new instance with updated values', () {
        final original = testOffer;
        final newTerms = OfferTerms.create(
          weight: Weight.fromKg(10),
          totalPrice: Price.fromAmount(50000),
        );

        final updated = original.copyWith(
          status: OfferStatus.accepted,
          currentTerms: newTerms,
        );

        expect(updated.status, OfferStatus.accepted);
        expect(updated.currentTerms, equals(newTerms));
        expect(updated.id, original.id);
      });

      test('copyWith preserves unchanged values', () {
        final original = testOffer;
        final updated = original.copyWith(status: OfferStatus.rejected);

        expect(updated.productId, original.productId);
        expect(updated.fisherId, original.fisherId);
        expect(updated.buyerId, original.buyerId);
        expect(updated.currentTerms, original.currentTerms);
      });

      test('copyWith can clear waitingFor with clearWaitingFor flag', () {
        final original = testOffer.copyWith(waitingFor: UserRole.fisher);
        final updated = original.copyWith(clearWaitingFor: true);

        expect(updated.waitingFor, null);
      });
    });
  });
}
