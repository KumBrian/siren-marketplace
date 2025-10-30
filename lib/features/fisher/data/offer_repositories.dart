import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/models/order.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/features/fisher/data/models/fisher.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import 'order_repository.dart';

class OfferRepository {
  final DatabaseHelper dbHelper;

  OfferRepository({required this.dbHelper});

  // 1. INSERT: Inserts a full Offer object map into the 'offers' table
  Future<void> insertOffer(Offer offer) async {
    final db = await dbHelper.database;
    await db.insert(
      'offers',
      offer.toMap(), // Assumes Offer.toMap() is up-to-date and correct
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 🆕 NEW: Creates a new offer
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

    final newOffer = Offer(
      id: const Uuid().v4(),
      catchId: catchId,
      fisherId: fisherData.id,
      fisherName: fisherData.name,
      fisherRating: fisherData.rating,
      fisherAvatarUrl: fisherData.avatarUrl,
      // This will be populated by the service layer or when fetching the catch
      buyerId: buyerData.id,
      buyerName: buyerData.name,
      buyerRating: buyerData.rating,
      buyerAvatarUrl: buyerData.avatarUrl,
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
    return newOffer;
  }

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

  // --- Retrieval Methods (Returning Raw Maps for Service Layer Assembly) ---

  // 2. QUERY BY CATCH ID (RAW MAPS): Retrieves all offer maps for a single Catch
  Future<List<Map<String, dynamic>>> getOfferMapsByCatch(String catchId) async {
    final db = await dbHelper.database;
    return await db.query(
      'offers',
      where: 'catch_id = ?',
      whereArgs: [catchId],
      orderBy: 'date_created DESC', // Assuming a date field for sorting
    );
  }

  // 3. QUERY BY CATCH IDS (RAW MAPS): Retrieves offer maps for a list of Catch IDs
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

  // 4. QUERY BY ID (RAW MAP): Retrieves a single offer map by its ID
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

  // 🆕 NEW: For Fisher side (Received Offers)
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

  // Retrieves all offer maps. Required by the seeder to filter for accepted offers.
  Future<List<Map<String, dynamic>>> getAllOfferMaps() async {
    final db = await dbHelper.database;
    return await db.query('offers', orderBy: 'date_created DESC');
  }

  // Retrieves all offer maps filtered by status.
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

  // Retrieves a single Offer model by ID. Useful for the service layer.
  Future<Offer?> getOfferById(String id) async {
    final map = await getOfferMapById(id);
    if (map == null) return null;

    return Offer.fromMap(map);
  }

  // --- Update/Delete Methods ---

  // 5. UPDATE: Updates an offer using its map representation
  Future<void> updateOffer(Offer offer) async {
    final db = await dbHelper.database;
    await db.update(
      'offers',
      offer.toMap(), // Assumes the entire map is written, including updates
      where: 'offer_id = ?',
      whereArgs: [offer.id],
    );
  }

  Future<List<Offer>> getOffersByCatchId(String catchId) async {
    final maps = await dbHelper.getOfferMapsByCatchId(catchId);
    return maps.map((m) => Offer.fromMap(m)).toList();
  }

  // 6. DELETE: Deletes an offer by ID
  Future<void> deleteOffer(String id) async {
    final db = await dbHelper.database;
    await db.delete('offers', where: 'offer_id = ?', whereArgs: [id]);
  }
}

extension OfferRepositoryActions on OfferRepository {
  /// Marks an offer as accepted and generates an Order
  Future<String> acceptOffer({
    required Offer offer,
    required Catch catchItem,
    required Fisher fisher,
    required OrderRepository orderRepo,
  }) async {
    // Update the offer’s status to accepted
    final accepted = offer.copyWith(
      status: OfferStatus.accepted,
      hasUpdateForBuyer: true,
      waitingFor: null,
    );
    await updateOffer(accepted);

    // Create a new Order instance from the accepted Offer and Catch
    final newOrder = Order.fromOfferAndCatch(
      offer: accepted,
      catchItem: catchItem,
      fisher: fisher,
    );

    // Insert the order through repository
    await orderRepo.insertOrder(newOrder);

    // CRITICAL CHANGE: Return the ID of the newly created order
    return newOrder.id;
  }

  /// Marks an offer as rejected (no further side effects)
  Future<void> rejectOffer(Offer offer) async {
    final rejected = offer.copyWith(
      status: OfferStatus.rejected,
      hasUpdateForBuyer: true,
      waitingFor: null,
    );
    await updateOffer(rejected);
  }

  /// Creates a new counter-offer linked to a previous one
  Future<Offer> counterOffer({
    required Offer previous,
    required double newPrice,
    required double newWeight,
    required Role role,
  }) async {
    // 1. Calculate new values
    final newPricePerKg = newPrice / newWeight;
    final now = DateTime.now().toIso8601String();

    // 2. Create the updated Offer object
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
    return updatedOffer;
  }
}
