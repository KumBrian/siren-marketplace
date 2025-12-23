import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/entities/user.dart';
import 'package:siren_marketplace/core/domain/exceptions/not_found_exception.dart';
import 'package:siren_marketplace/core/providers/data_providers.dart';

class OfferDetailsState {
  final Offer offer;
  final User fisher;
  final Catch catchItem;

  OfferDetailsState({
    required this.offer,
    required this.fisher,
    required this.catchItem,
  });
}

final offerDetailsProvider = FutureProvider.family<OfferDetailsState, String>((
  ref,
  offerId,
) async {
  // 1. Fetch the Offer
  final offer = await ref.watch(offerProvider(offerId).future);
  if (offer == null) {
    throw NotFoundException(
      'Offer not found',
      entityType: 'Offer',
      entityId: offerId,
    );
  }

  // 2. Fetch dependencies in parallel (optional optimization, but sequential is fine for now)
  // Using Future.wait would be faster if they don't depend on each other,
  // but here we need offer to get IDs.

  final fisherFuture = ref.watch(userProvider(offer.fisherId).future);
  final catchFuture = ref.watch(catchProvider(offer.productId).future);

  final results = await Future.wait([fisherFuture, catchFuture]);
  final fisher = results[0] as User?;
  final catchItem = results[1] as Catch?;

  if (fisher == null) {
    throw NotFoundException(
      'Fisher not found',
      entityType: 'User',
      entityId: offer.fisherId,
    );
  }
  if (catchItem == null) {
    throw NotFoundException(
      'Catch not found',
      entityType: 'Catch',
      entityId: offer.productId,
    );
  }

  return OfferDetailsState(offer: offer, fisher: fisher, catchItem: catchItem);
});
