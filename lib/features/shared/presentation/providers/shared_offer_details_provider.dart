import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/entities/user.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/exceptions/not_found_exception.dart';
import 'package:siren_marketplace/core/domain/repositories/i_catch_repository.dart';

import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/repositories/i_order_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_user_repository.dart';
import 'package:siren_marketplace/core/providers/offer_providers.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';

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

      // 3. Fetch Catch
      final catchRepo = sl<ICatchRepository>();
      final catchItem = await catchRepo.getById(offer.catchId);

      if (catchItem == null) {
        throw NotFoundException(
          'Catch not found',
          entityType: 'Catch',
          entityId: offer.catchId,
        );
      }

      // 4. Determine and Fetch Other Party
      final userRepo = sl<IUserRepository>();
      String otherPartyId;

      if (currentUser.currentRole == UserRole.buyer) {
        otherPartyId = offer.fisherId;
      } else {
        otherPartyId = offer.buyerId;
      }

      final otherParty = await userRepo.getById(otherPartyId);

      if (otherParty == null) {
        throw NotFoundException(
          'User not found',
          entityType: 'User',
          entityId: otherPartyId,
        );
      }

      // 5. Determine Turn
      final isUserTurn = offer.waitingFor == currentUser.currentRole;

      // 6. Fetch Order ID if accepted/completed
      String? orderId;
      if (offer.status == OfferStatus.accepted ||
          offer.status == OfferStatus.completed) {
        final orderRepo = sl<IOrderRepository>();
        final order = await orderRepo.getByOfferId(offerId);
        orderId = order?.id;
      }

      return SharedOfferDetailsState(
        offer: offer,
        catchItem: catchItem,
        otherParty: otherParty,
        isUserTurn: isUserTurn,
        currentUserRole: currentUser.currentRole,
        orderId: orderId,
      );
    });
