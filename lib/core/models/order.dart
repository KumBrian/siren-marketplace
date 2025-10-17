import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../features/fisher/data/models/fisher.dart';
import 'catch.dart';
import 'offer.dart';

class Order extends Equatable {
  final String id;

  // Store the full Offer object for direct access to status/price/weight
  final Offer offer;

  // Store the full Fisher object for direct access to profile details
  final Fisher fisher;

  // These IDs are primarily for DB/Repository access but kept for context
  final String fisherId;
  final String buyerId;

  // JSON snapshot of the Catch at the time of order (for DB)
  final String catchSnapshotJson;
  final String dateUpdated;

  // 💡 FIX: This must be a final field. We compute it during construction.
  final Catch catchModel;

  Order({
    required this.id,
    required this.offer,
    required this.fisher,
    required this.fisherId,
    required this.buyerId,
    required this.catchSnapshotJson,
    required this.dateUpdated,
    // 💡 FIX: Now required in the constructor
    required this.catchModel,
  }) : assert(fisher.id == fisherId, 'Fisher ID mismatch in Order constructor');

  // --- Equatable Properties ---
  // 💡 FIX: Include catchModel in props list
  @override
  List<Object?> get props => [id, offer, fisher, dateUpdated, catchModel];

  // 💡 FIX: Removed the lazy-loading getter `catchModel` and the private field `_catchSnapshot`.

  // Factory used by TransactionService to create an Order from an accepted Offer/Catch
  factory Order.fromOfferAndCatch({
    required Offer offer,
    required Catch catchItem,
    required Fisher fisher, // Requires the Fisher model to be passed
  }) {
    // 1. Ensure the snapshot includes the accepted transaction details
    final snapshotMap = catchItem.toMap()
      ..['accepted_weight'] = offer.weight
      ..['accepted_price_per_kg'] = offer.pricePerKg
      ..['accepted_price'] = offer.price;

    final catchSnapshotJson = jsonEncode(snapshotMap);

    // 2. Deserialize the snapshot immediately to satisfy the final field requirement
    final Catch computedCatchModel = Catch.fromMap(snapshotMap);

    return Order(
      id: offer.id,
      offer: offer,
      fisher: fisher,
      // Pass the assembled Fisher object
      fisherId: offer.fisherId,
      buyerId: offer.buyerId,
      catchSnapshotJson: catchSnapshotJson,
      dateUpdated: DateTime.now().toIso8601String(),
      // 💡 FIX: Pass the computed Catch model
      catchModel: computedCatchModel,
    );
  }

  // --- DB Mapping ---

  Map<String, dynamic> toMap() => {
    'order_id': id,
    'offer_id': offer.id,
    'fisher_id': fisherId,
    'buyer_id': buyerId,
    'catch_snapshot': catchSnapshotJson,
    'date_updated': dateUpdated,
  };

  // Factory used by the Repository/Cubit to assemble a full Order from DB data
  factory Order.fromMap({
    required Map<String, dynamic> m,
    required Offer linkedOffer,
    required Fisher linkedFisher,
  }) {
    final catchSnapshotJson = m['catch_snapshot'] as String;

    Catch computedCatchModel;
    try {
      final Map<String, dynamic> catchMap = jsonDecode(catchSnapshotJson);
      computedCatchModel = Catch.fromMap(catchMap);
    } catch (e) {
      debugPrint(
        'Error deserializing Catch snapshot for Order ${m['order_id']}: $e',
      );
      computedCatchModel = Catch.empty();
    }

    return Order(
      id: m['order_id'] as String,
      offer: linkedOffer,
      fisher: linkedFisher,
      fisherId: m['fisher_id'] as String,
      buyerId: m['buyer_id'] as String,
      catchSnapshotJson: catchSnapshotJson,
      dateUpdated: m['date_updated'] as String,
      catchModel: computedCatchModel,
    );
  }

  Order copyWith({
    String? id,
    Offer? offer,
    Fisher? fisher,
    String? fisherId,
    String? buyerId,
    String? catchSnapshotJson,
    String? dateUpdated,
    Catch? catchModel,
  }) {
    return Order(
      id: id ?? this.id,
      offer: offer ?? this.offer,
      fisher: fisher ?? this.fisher,
      fisherId: fisherId ?? this.fisherId,
      buyerId: buyerId ?? this.buyerId,
      catchSnapshotJson: catchSnapshotJson ?? this.catchSnapshotJson,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      catchModel: catchModel ?? this.catchModel,
    );
  }
}
