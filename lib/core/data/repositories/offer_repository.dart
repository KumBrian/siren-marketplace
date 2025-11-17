import 'package:siren_marketplace/core/data/dto/offer_dto.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/order.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/utils/transaction_notifier.dart';
import 'package:siren_marketplace/features/fisher/data/models/fisher.dart';
import 'package:uuid/uuid.dart';

import '../../../features/fisher/data/catch_repository.dart';
import '../../../features/fisher/data/order_repository.dart';
import '../../domain/models/offer.dart';
import '../datasources/offer_datasource.dart';
import '../persistence/offer_entity.dart';

// NOTE: import paths above may need adjustments to match your project layout.

class OfferRepository {
  final OfferDataSource dataSource;
  final TransactionNotifier notifier;
  final UserRepository userRepo; // used to fetch buyer/fisher info
  final CatchRepository catchRepo; // used to fetch catch info
  final OrderRepository orderRepo; // used in acceptOffer
  final Uuid _uuid = const Uuid();

  OfferRepository({
    required this.dataSource,
    required this.notifier,
    required this.userRepo,
    required this.catchRepo,
    required this.orderRepo,
  });

  // Low-level insert (domain -> persistence)
  Future<void> insertOffer(Offer offer) async {
    final map = OfferDto.fromDomain(offer);
    await dataSource.insertOffer(OfferEntity.fromMap(map));
    notifier.notify();
  }

  // Create offer using IDs (mirrors original createOffer)
  Future<Offer> createOffer({
    required String catchId,
    required String buyerId,
    required String fisherId,
    required double price,
    required double weight,
    required double pricePerKg,
  }) async {
    // resolve domain user & catch data using injected repos (local or remote)
    final fisherUser = await userRepo.getUserById(fisherId);
    if (fisherUser == null) throw Exception('Fisher not found: $fisherId');

    final buyerUser = await userRepo.getUserById(buyerId);
    if (buyerUser == null) throw Exception('Buyer not found: $buyerId');

    final catchItem = await catchRepo.getCatchById(catchId);
    if (catchItem == null) throw Exception('Catch not found: $catchId');

    final newOffer = Offer(
      id: _uuid.v4(),
      catchId: catchId,
      fisherId: fisherUser.id,
      fisherName: fisherUser.name,
      fisherRating: fisherUser.rating,
      fisherAvatarUrl: fisherUser.avatarUrl,
      buyerId: buyerUser.id,
      buyerName: buyerUser.name,
      buyerRating: buyerUser.rating,
      buyerAvatarUrl: buyerUser.avatarUrl,
      catchName: catchItem.name,
      catchImageUrl: catchItem.images.isNotEmpty ? catchItem.images.first : '',
      price: price,
      weight: weight,
      pricePerKg: pricePerKg,
      status: OfferStatus.pending,
      hasUpdateForFisher: true,
      hasUpdateForBuyer: false,
      dateCreated: DateTime.now().toIso8601String(),
      waitingFor: Role.fisher,
      previousPrice: null,
      previousWeight: null,
      previousPricePerKg: null,
    );

    await insertOffer(newOffer);
    return newOffer;
  }

  // Queries & retrievals

  Future<Offer?> getOfferById(String id) async {
    final ent = await dataSource.getOfferById(id);
    if (ent == null) return null;
    return Offer.fromMap(ent.toMap());
  }

  Future<List<Offer>> getOffersByCatchId(String catchId) async {
    final ents = await dataSource.getOffersByCatchId(catchId);
    return ents.map((e) => Offer.fromMap(e.toMap())).toList();
  }

  Future<List<Offer>> getOffersByCatchIds(List<String> catchIds) async {
    final ents = await dataSource.getOffersByCatchIds(catchIds);
    return ents.map((e) => Offer.fromMap(e.toMap())).toList();
  }

  Future<List<Offer>> getOffersByBuyerId(String buyerId) async {
    final ents = await dataSource.getOffersByBuyerId(buyerId);
    return ents.map((e) => Offer.fromMap(e.toMap())).toList();
  }

  Future<List<Offer>> getOffersByFisherId(String fisherId) async {
    final ents = await dataSource.getOffersByFisherId(fisherId);
    return ents.map((e) => Offer.fromMap(e.toMap())).toList();
  }

  Future<List<Offer>> getAllOffers() async {
    final ents = await dataSource.getAllOffers();
    return ents.map((e) => Offer.fromMap(e.toMap())).toList();
  }

  Future<List<Offer>> getOffersByStatus(OfferStatus status) async {
    final ents = await dataSource.getOffersByStatus(status.name);
    return ents.map((e) => Offer.fromMap(e.toMap())).toList();
  }

  // Update
  Future<void> updateOffer(Offer offer) async {
    final map = OfferDto.fromDomain(offer);
    await dataSource.updateOffer(OfferEntity.fromMap(map));
    notifier.notify();
  }

  // Delete
  Future<void> deleteOffer(String id) async {
    await dataSource.deleteOffer(id);
    notifier.notify();
  }

  // --- Workflow helpers (accept/reject/counter) ---
  Future<(Offer, String)> acceptOffer({
    required Offer offer,
    required Catch catchItem,
    required Fisher fisher,
  }) async {
    // mutate offer status
    final accepted = offer.copyWith(
      status: OfferStatus.accepted,
      hasUpdateForBuyer: true,
      hasUpdateForFisher: true,
      waitingFor: null,
    );

    await updateOffer(accepted);

    final newOrder = Order.fromOfferAndCatch(
      offer: accepted,
      catchItem: catchItem,
      fisher: fisher,
    );

    await orderRepo.insertOrder(newOrder);

    return (accepted, newOrder.id);
  }

  Future<Offer> rejectOffer(Offer offer) async {
    final rejected = offer.copyWith(
      status: OfferStatus.rejected,
      hasUpdateForBuyer: true,
      hasUpdateForFisher: false,
      waitingFor: null,
    );

    await updateOffer(rejected);
    return rejected;
  }

  Future<Offer> counterOffer({
    required Offer previous,
    required double newPrice,
    required double newWeight,
    required Role role,
  }) async {
    final newPricePerKg = newPrice / newWeight;
    final now = DateTime.now().toIso8601String();

    final updatedOffer = previous.copyWith(
      price: newPrice,
      weight: newWeight,
      pricePerKg: newPricePerKg,
      status: OfferStatus.pending,
      hasUpdateForBuyer: role == Role.buyer ? false : true,
      hasUpdateForFisher: role == Role.buyer ? true : false,
      dateCreated: now,
      previousPrice: previous.price,
      previousWeight: previous.weight,
      previousPricePerKg: previous.pricePerKg,
      waitingFor: role == Role.buyer ? Role.fisher : Role.buyer,
    );

    await updateOffer(updatedOffer);
    notifier.notify();
    return updatedOffer;
  }
}
