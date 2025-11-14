import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/models/order.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/utils/transaction_notifier.dart';
import 'package:siren_marketplace/features/fisher/data/models/fisher.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import 'order_repository.dart';

/// Repository responsible for CRUD operations and domain logic
/// related to [`Offer`] entities.
///
/// This layer currently operates on top of the local SQLite database
/// via [`DatabaseHelper`]. The abstractions are intentionally structured
/// so that transitioning to remote API calls requires minimal upstream
/// changes.
///
/// **Future API Migration Path**
/// - Replace direct DB access with HTTP calls or a network service layer.
/// - Maintain public method signatures for backward compatibility.
/// - The service/assembly logic should remain in this repository.
class OfferRepository {
  /// Underlying local database service.
  final DatabaseHelper dbHelper;

  /// Global notifier used to signal offer-related state or activity changes.
  final TransactionNotifier notifier;

  /// Creates a new [OfferRepository] bound to the given
  /// database and notification service.
  OfferRepository({required this.dbHelper, required this.notifier});

  /// Inserts a full [`Offer`] into the database.
  ///
  /// This is a low-level write operation that places the complete
  /// offer map into the `offers` table. Existing entries with the same
  /// ID will be overwritten.
  Future<void> insertOffer(Offer offer) async {
    final db = await dbHelper.database;
    await db.insert(
      'offers',
      offer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Creates and persists a new offer using referenced domain entities.
  ///
  /// This method resolves:
  /// - the Fisher who owns the catch
  /// - the Buyer initiating the offer
  /// - the Catch being negotiated
  ///
  /// It produces a complete [`Offer`] that is immediately written to the DB.
  ///
  /// **API Forward Compatibility**
  /// - Resolve user and catch data via remote endpoints instead of DB.
  /// - Maintain the creation semantics for upstream service layers.
  Future<Offer> createOffer({
    required String catchId,
    required String buyerId,
    required String fisherId,
    required double price,
    required double weight,
    required double pricePerKg,
  }) async {
    final db = await dbHelper.database;

    final fisher = await dbHelper.getUserMapById(fisherId);
    final fisherData = Fisher.fromMap(fisher!);

    final buyer = await dbHelper.getUserMapById(buyerId);
    final buyerData = Fisher.fromMap(buyer!);

    final catchItem = await dbHelper.getCatchMapById(catchId);
    final catchData = Catch.fromMap(catchItem!);

    final newOffer = Offer(
      id: const Uuid().v4(),
      catchId: catchId,
      fisherId: fisherData.id,
      fisherName: fisherData.name,
      fisherRating: fisherData.rating,
      fisherAvatarUrl: fisherData.avatarUrl,
      buyerId: buyerData.id,
      buyerName: buyerData.name,
      buyerRating: buyerData.rating,
      buyerAvatarUrl: buyerData.avatarUrl,
      catchName: catchData.name,
      catchImageUrl: catchData.images.first,
      price: price,
      weight: weight,
      pricePerKg: pricePerKg,
      status: OfferStatus.pending,
      hasUpdateForFisher: true,
      hasUpdateForBuyer: false,
      dateCreated: DateTime.now().toIso8601String(),
      waitingFor: Role.fisher,
    );

    await db.insert(
      'offers',
      newOffer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    notifier.notify();
    return newOffer;
  }

  /// Retrieves raw offer maps for a given buyer, ordered by most recent.
  ///
  /// These raw maps are intended for consumption by the service layer,
  /// which assembles full [`Offer`] models with related entities.
  Future<List<Map<String, dynamic>>> getOfferMapsByBuyerId(
    String buyerId,
  ) async {
    final db = await dbHelper.database;
    return await db.query(
      'offers',
      where: 'buyer_id = ?',
      whereArgs: [buyerId],
      orderBy: 'date_created DESC',
    );
  }

  /// Retrieves all raw offer maps associated with a single Catch.
  ///
  /// Does not assemble domain objects. Intended for service layer use.
  Future<List<Map<String, dynamic>>> getOfferMapsByCatch(String catchId) async {
    final db = await dbHelper.database;
    return await db.query(
      'offers',
      where: 'catch_id = ?',
      whereArgs: [catchId],
      orderBy: 'date_created DESC',
    );
  }

  /// Retrieves raw offer maps for a list of Catch IDs.
  ///
  /// Useful for bulk queries when populating marketplace data.
  Future<List<Map<String, dynamic>>> getOfferMapsByCatchIds(
    List<String> catchIds,
  ) async {
    if (catchIds.isEmpty) return [];

    final db = await dbHelper.database;
    final placeholders = List.filled(catchIds.length, '?').join(',');

    return await db.query(
      'offers',
      where: 'catch_id IN ($placeholders)',
      whereArgs: catchIds,
      orderBy: 'date_created DESC',
    );
  }

  /// Retrieves a raw offer map using the offer’s unique identifier.
  Future<Map<String, dynamic>?> getOfferMapById(String id) async {
    final db = await dbHelper.database;

    final data = await db.query(
      'offers',
      where: 'offer_id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (data.isEmpty) return null;
    return data.first;
  }

  /// Retrieves raw offer maps belonging to a specific Fisher.
  ///
  /// Used for the Fisher-facing offers dashboard.
  Future<List<Map<String, dynamic>>> getOfferMapsByFisherId(
    String fisherId,
  ) async {
    final db = await dbHelper.database;
    return await db.query(
      'offers',
      where: 'fisher_id = ?',
      whereArgs: [fisherId],
      orderBy: 'date_created DESC',
    );
  }

  /// Retrieves every offer map in the database.
  ///
  /// Primarily used by the seeder or batch processors.
  Future<List<Map<String, dynamic>>> getAllOfferMaps() async {
    final db = await dbHelper.database;
    return await db.query('offers', orderBy: 'date_created DESC');
  }

  /// Retrieves offer maps filtered by their current status.
  Future<List<Map<String, dynamic>>> getOfferMapsByStatus(
    OfferStatus status,
  ) async {
    final db = await dbHelper.database;
    return await db.query(
      'offers',
      where: 'status = ?',
      whereArgs: [status.name],
      orderBy: 'date_created DESC',
    );
  }

  /// Retrieves a fully assembled [`Offer`] model by ID.
  ///
  /// This is a domain-level return, not just a raw map.
  Future<Offer?> getOfferById(String id) async {
    final map = await getOfferMapById(id);
    if (map == null) return null;

    return Offer.fromMap(map);
  }

  /// Updates an existing offer by writing its full map back to the DB.
  ///
  /// Notifies listeners through the shared [TransactionNotifier].
  Future<void> updateOffer(Offer offer) async {
    final db = await dbHelper.database;
    await db.update(
      'offers',
      offer.toMap(),
      where: 'offer_id = ?',
      whereArgs: [offer.id],
    );
    notifier.notify();
  }

  /// Retrieves all domain-level offers linked to a particular Catch.
  Future<List<Offer>> getOffersByCatchId(String catchId) async {
    final maps = await dbHelper.getOfferMapsByCatchId(catchId);
    return maps.map((m) => Offer.fromMap(m)).toList();
  }

  /// Deletes an offer from the database using its unique ID.
  Future<void> deleteOffer(String id) async {
    final db = await dbHelper.database;
    await db.delete('offers', where: 'offer_id = ?', whereArgs: [id]);
  }
}

/// Extended domain actions for negotiation and offer lifecycle management.
///
/// These workflows combine multiple repository operations and
/// interact with related domain entities such as [`Catch`],
/// [`Fisher`], and [`Order`].
extension OfferRepositoryActions on OfferRepository {
  /// Accepts an offer and generates a corresponding [`Order`].
  ///
  /// Returns a tuple containing:
  /// - the updated accepted [`Offer`]
  /// - the ID of the newly created [`Order`]
  ///
  /// This operation performs:
  /// 1. Status mutation → `accepted`
  /// 2. Offer update
  /// 3. Order creation via [`OrderRepository`]
  Future<(Offer, String)> acceptOffer({
    required Offer offer,
    required Catch catchItem,
    required Fisher fisher,
    required OrderRepository orderRepo,
  }) async {
    final accepted = offer.copyWith(
      status: OfferStatus.accepted,
      hasUpdateForBuyer: true,
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

  /// Rejects an offer with no additional side effects.
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

  /// Generates a counter-offer based on a previous offer.
  ///
  /// Mutates:
  /// - price
  /// - weight
  /// - price-per-kg
  /// - negotiation metadata
  ///
  /// Used when either party proposes new terms.
  Future<Offer> counterOffer({
    required Offer previous,
    required double newPrice,
    required double newWeight,
    required Role role,
  }) async {
    final newPricePerKg = newPrice / newWeight;
    final now = DateTime.now().toIso8601String();

    final updatedOffer = previous.copyWith(
      pricePerKg: newPricePerKg,
      price: newPrice,
      weight: newWeight,
      status: OfferStatus.pending,
      hasUpdateForBuyer: role == Role.buyer ? false : true,
      hasUpdateForFisher: role == Role.buyer ? true : false,
      dateCreated: now,
      previousPricePerKg: previous.pricePerKg,
      previousPrice: previous.price,
      previousWeight: previous.weight,
      waitingFor: role == Role.buyer ? Role.fisher : Role.buyer,
    );

    await updateOffer(updatedOffer);
    notifier.notify();

    return updatedOffer;
  }
}
