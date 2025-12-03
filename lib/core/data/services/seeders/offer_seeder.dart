import 'dart:math';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/entities/user.dart';
import 'package:siren_marketplace/core/domain/enums/catch_status.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/repositories/i_offer_repository.dart';
import 'package:siren_marketplace/core/domain/value_objects/offer_terms.dart';
import 'package:siren_marketplace/core/domain/value_objects/price.dart';
import 'package:siren_marketplace/core/domain/value_objects/rating.dart';
import 'package:siren_marketplace/core/domain/value_objects/weight.dart';
import 'package:uuid/uuid.dart';
import 'seeder_data.dart';

class OfferSeeder {
  final Uuid _uuid = const Uuid();
  final Random _rng = Random();

  Future<List<Offer>> seed(List<Catch> seededCatches) async {
    final offerRepository = sl<IOfferRepository>();
    final existing = await offerRepository.getAllOffers();
    if (existing.isNotEmpty) {
      print('Offers exist. Returning existing.');
      return existing;
    }

    final buyer1Map = SeederData.userMaps.firstWhere(
      (m) => m['id'] == 'buyer_id_1',
    );
    final buyer1 = User(
      id: buyer1Map['id'],
      name: buyer1Map['name'],
      avatarUrl: buyer1Map['avatar_url'],
      rating: Rating.fromValue(buyer1Map['rating']),
      reviewCount: buyer1Map['review_count'],
      currentRole: buyer1Map['role'],
    );

    final buyer2Map = SeederData.userMaps.firstWhere(
      (m) => m['id'] == 'buyer_id_2',
    );
    final buyer2 = User(
      id: buyer2Map['id'],
      name: buyer2Map['name'],
      avatarUrl: buyer2Map['avatar_url'],
      rating: Rating.fromValue(buyer2Map['rating']),
      reviewCount: buyer2Map['review_count'],
      currentRole: buyer2Map['role'],
    );

    final List<Offer> allOffers = [];
    final buyers = [buyer1, buyer2];

    for (int i = 0; i < seededCatches.length; i++) {
      final catchItem = seededCatches[i];
      final buyer = buyers[i % buyers.length];

      if (catchItem.status == CatchStatus.available ||
          catchItem.status == CatchStatus.expired) {
        // Pending offer — 50% of available weight
        final int pendingWeightGrams =
            ((catchItem.availableWeight.grams * 50) ~/ 100 / 100).floor() * 100;

        // discounted pricePerKg (integer) — apply 5% discount and round
        final int pendingPricePerKg =
            ((catchItem.pricePerKg.amountPerKg * 95) ~/ 100);

        final int pendingPrice =
            (pendingWeightGrams * pendingPricePerKg) ~/ 1000;

        final waitingFor = UserRole.values[_rng.nextInt(2)];

        // Logic for hasUpdate flags based on waitingFor
        // If waitingFor Fisher, it means Buyer sent it/updated it, so Fisher has update.
        // If waitingFor Buyer, it means Fisher sent it/updated it, so Buyer has update.
        final bool hasUpdateForFisher = waitingFor == UserRole.fisher;
        final bool hasUpdateForBuyer = waitingFor == UserRole.buyer;

        final pendingOffer = Offer(
          id: _uuid.v4(),
          catchId: catchItem.id,
          fisherId: catchItem.fisherId,
          buyerId: buyer.id,
          currentTerms: OfferTerms.create(
            totalPrice: Price.fromAmount(pendingPrice),
            weight: Weight.fromGrams(pendingWeightGrams),
          ),
          status: OfferStatus.pending,
          dateCreated: DateTime.now(),
          previousTerms: null,
          dateUpdated: DateTime.now(),
          waitingFor: waitingFor,
          hasUpdateForFisher: hasUpdateForFisher,
          hasUpdateForBuyer: hasUpdateForBuyer,
        );

        await offerRepository.create(pendingOffer);
        allOffers.add(pendingOffer);
      }
    }

    print('${allOffers.length} offers seeded.');
    return allOffers;
  }
}
