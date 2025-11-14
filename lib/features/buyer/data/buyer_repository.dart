import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/models/order.dart';
import 'package:siren_marketplace/features/fisher/data/models/fisher.dart';

/// Repository responsible for fetching buyer-related data from the local
/// persistence layer.
///
/// This class currently relies on a local SQLite database provided by
/// [DatabaseHelper]. It is structured so that migrating to a remote API
/// (REST or GraphQL) will require internal refactoring only, without
/// breaking the method signatures used by the rest of the app.
///
/// When transitioning to network-backed operations, each method will map
/// naturally to future endpoints such as:
/// - `GET /buyers/{id}/orders`
/// - `GET /market/catches`
/// - `GET /orders/{id}`
///
/// The models returned (`Order`, `Catch`, `Offer`, `Fisher`) are fully
/// assembled objects with their related entities joined and hydrated.
class BuyerRepository {
  /// Creates a new buyer repository using the injected database helper.
  BuyerRepository({required this.dbHelper});

  /// Provides access to the SQLite helper used for data operations.
  final DatabaseHelper dbHelper;

  /// Retrieves all orders associated with a specific buyer.
  ///
  /// This method performs several lookups:
  /// - Fetches all order maps through the database helper.
  /// - Loads the linked `Offer` for each order.
  /// - Loads the linked `Fisher` representing the seller.
  /// - Constructs a fully hydrated [Order] instance.
  ///
  /// When migrated to an API layer, this will likely collapse into a single
  /// endpoint returning joined order, offer, and fisher data.
  Future<List<Order>> getOrdersByBuyerId(String buyerId) async {
    final orderMaps = await dbHelper.getOrdersByBuyerId(buyerId);

    final List<Order> orders = [];

    for (final oMap in orderMaps) {
      final offerId = oMap['offer_id'] as String;
      final offerMaps = await dbHelper.getOfferMapsByCatchId(offerId);
      if (offerMaps.isEmpty) continue;
      final offer = Offer.fromMap(offerMaps.first);

      final fisherId = oMap['fisher_id'] as String;
      final userMap = await dbHelper.getUserMapById(fisherId);
      if (userMap == null) continue;
      final fisher = Fisher.fromMap(userMap);

      final order = Order.fromMap(
        m: oMap,
        linkedOffer: offer,
        linkedFisher: fisher,
      );

      orders.add(order);
    }

    return orders;
  }

  /// Retrieves the list of all available catches currently on the market.
  ///
  /// The method:
  /// - Fetches raw catch maps from the database layer.
  /// - Converts them to [Catch] models.
  /// - Fetches all offers associated with the retrieved catches.
  /// - Groups offers by `catchId`.
  /// - Returns a list of catches where each one is enriched with its related
  ///   offers.
  ///
  /// A future API implementation may map to something like:
  /// `GET /market/catches?include=offers`.
  Future<List<Catch>> getMarketCatches() async {
    final catchMaps = await dbHelper.getCatchMapsForMarket();

    if (catchMaps.isEmpty) return [];

    final catches = catchMaps.map((m) => Catch.fromMap(m)).toList();

    final catchIds = catches.map((c) => c.id).toList();
    final offerMaps = await dbHelper.getOfferMapsByCatchIds(catchIds);

    final Map<String, List<Offer>> offersByCatch = {};
    for (final map in offerMaps) {
      final offer = Offer.fromMap(map);
      offersByCatch.putIfAbsent(offer.catchId, () => []).add(offer);
    }

    return catches
        .map((c) => c.copyWith(offers: offersByCatch[c.id] ?? []))
        .toList();
  }

  /// Retrieves a single order by its unique identifier.
  ///
  /// This includes loading the linked [Offer] and [Fisher] so that the
  /// returned [Order] is fully assembled. If any of the required components
  /// are missing, the method returns `null`.
  ///
  /// API-based version would typically hit:
  /// `GET /orders/{orderId}?include=offer,fisher`.
  Future<Order?> getOrderById(String orderId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'orders',
      where: 'order_id = ?',
      whereArgs: [orderId],
      limit: 1,
    );
    if (maps.isEmpty) return null;

    final oMap = maps.first;

    final offerId = oMap['offer_id'] as String;
    final offerMaps = await dbHelper.getOfferMapsByCatchId(offerId);
    if (offerMaps.isEmpty) return null;
    final offer = Offer.fromMap(offerMaps.first);

    final fisherId = oMap['fisher_id'] as String;
    final userMap = await dbHelper.getUserMapById(fisherId);
    if (userMap == null) return null;
    final fisher = Fisher.fromMap(userMap);

    return Order.fromMap(m: oMap, linkedOffer: offer, linkedFisher: fisher);
  }
}
