import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/entities/user.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/exceptions/not_found_exception.dart';
import 'package:siren_marketplace/core/domain/repositories/i_product_repository.dart';
import 'package:siren_marketplace/core/domain/entities/product.dart';
import 'package:siren_marketplace/core/domain/enums/catch_status.dart';
import 'package:siren_marketplace/core/domain/repositories/i_user_repository.dart';

import 'package:siren_marketplace/core/providers/offer_providers.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';
import 'package:siren_marketplace/core/domain/value_objects/rating.dart';

class SharedOfferDetailsState {
  final Offer offer;
  final Catch catchItem;
  final User otherParty;
  final bool isUserTurn;
  final UserRole currentUserRole;
  final String? orderId;

  SharedOfferDetailsState({
    required this.offer,
    required this.catchItem,
    required this.otherParty,
    required this.isUserTurn,
    required this.currentUserRole,
    this.orderId,
  });
}

final sharedOfferDetailsProvider = FutureProvider.family
    .autoDispose<SharedOfferDetailsState, String>((ref, offerId) async {
      // 1. Get Current User
      final currentUser = await ref.watch(currentUserProvider.future);
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // 2. Fetch Offer
      final offer = await ref.watch(offerProvider(offerId).future);

      if (offer == null) {
        throw NotFoundException(
          'Offer not found',
          entityType: 'Offer',
          entityId: offerId,
        );
      }

      // 3. Get Catch (Use embedded product if available, else fetch)
      Catch? catchItem;
      if (offer.product != null) {
        try {
          catchItem = _mapProductToCatch(offer.product!);
        } catch (e) {}
      }

      if (catchItem == null) {
        final productRepo = sl<IProductRepository>();
        final result = await productRepo.getProductById(offer.productId);
        catchItem = result.fold(
          ifLeft: (failure) => null,
          ifRight: (product) =>
              product != null ? _mapProductToCatch(product) : null,
        );
      }

      if (catchItem == null) {
        throw NotFoundException(
          'Product not found',
          entityType: 'Product',
          entityId: offer.productId,
        );
      }

      // 4. Determine and Fetch Other Party
      final isBuyer = currentUser.currentRole == UserRole.buyer;
      User? otherParty;

      if (isBuyer && offer.fisher != null) {
        otherParty = offer.fisher;
      } else if (!isBuyer && offer.buyer != null) {
        otherParty = offer.buyer;
      }

      if (otherParty == null) {
        // Fallback: Try to fetch user from repository (offline cache or remote)
        final userRepo = sl<IUserRepository>();
        final otherPartyId = isBuyer ? offer.fisherId : offer.buyerId;

        try {
          otherParty = await userRepo.getById(otherPartyId);
        } catch (e) {}

        if (otherParty == null) {
          otherParty = User(
            id: otherPartyId,
            name: 'Unknown',
            rating: Rating.zero(),
            reviewCount: 0,
            currentRole: isBuyer ? UserRole.fisher : UserRole.buyer,
          );
        }
      }

      // 5. Determine Turn
      final isUserTurn = offer.waitingFor == currentUser.currentRole;

      // 6. Get Order ID from offer if available (set when offer is accepted)
      final orderId = offer.orderId;

      return SharedOfferDetailsState(
        offer: offer,
        catchItem: catchItem,
        otherParty: otherParty,
        isUserTurn: isUserTurn,
        currentUserRole: currentUser.currentRole,
        orderId: orderId,
      );
    });

// Helper to map Product (embedded) to Catch
Catch _mapProductToCatch(Product product) {
  // Map status string to CatchStatus
  CatchStatus status = CatchStatus.available;
  try {
    status = CatchStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == product.status.toLowerCase(),
      orElse: () => CatchStatus.available,
    );
  } catch (_) {}

  return Catch(
    id: product.id,
    name: product.name,
    datePosted: product.datePosted,
    initialWeight: product.initialWeight,
    availableWeight: product.availableWeight,
    pricePerKg: product.pricePerKg,
    totalPrice: product.totalPrice,
    size: product.size,
    market: product.marketName,
    images: product.images,
    species: product.species,
    fisherId: product.fisherId,
    status: status,
    observationId: '', // Not available in Product, safe to omit for display
    locationName: product.locationName,
    latitude: product.latitude,
    longitude: product.longitude,
    meshSize: product.meshSize,
    gearLength: product.gearLength,
    gearWidth: product.gearWidth,
    gearNature: product.gearNature,
  );
}
