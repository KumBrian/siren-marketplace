import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../features/fisher/data/models/fisher.dart';
import '../domain/models/offer.dart';
import 'catch.dart';

class Order extends Equatable {
  final String id;

  // Transaction details
  final Offer offer;
  final Fisher fisher;
  final String fisherId;
  final String buyerId;
  final String catchSnapshotJson;
  final String dateUpdated;
  final Catch catchModel;

  // 🌟 NEW RATING FIELDS 🌟
  final bool hasRatedBuyer;
  final bool hasRatedFisher;
  final double? buyerRatingValue;
  final String? buyerRatingMessage;
  final double? fisherRatingValue;
  final String? fisherRatingMessage;

  // 🌟 END NEW FIELDS 🌟

  Order({
    required this.id,
    required this.offer,
    required this.fisher,
    required this.fisherId,
    required this.buyerId,
    required this.catchSnapshotJson,
    required this.dateUpdated,
    required this.catchModel,
    // 🌟 NEW REQUIRED RATING FIELDS (defaulted for existing orders) 🌟
    this.hasRatedBuyer = false,
    this.hasRatedFisher = false,
    this.buyerRatingValue,
    this.buyerRatingMessage,
    this.fisherRatingValue,
    this.fisherRatingMessage,
    // 🌟 END NEW REQUIRED FIELDS 🌟
  }) : assert(fisher.id == fisherId, 'Fisher ID mismatch in Order constructor');

  // --- Equatable Properties ---
  @override
  List<Object?> get props => [
    id,
    offer,
    fisher,
    dateUpdated,
    catchModel,
    // 🌟 Add new rating fields to props
    hasRatedBuyer,
    hasRatedFisher,
    buyerRatingValue,
    buyerRatingMessage,
    fisherRatingValue,
    fisherRatingMessage,
  ];

  // Factory used by TransactionService to create an Order from an accepted Offer/Catch
  factory Order.fromOfferAndCatch({
    required Offer offer,
    required Catch catchItem,
    required Fisher fisher,
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
      fisherId: offer.fisherId,
      buyerId: offer.buyerId,
      catchSnapshotJson: catchSnapshotJson,
      dateUpdated: DateTime.now().toIso8601String(),
      catchModel: computedCatchModel,
      // NOTE: New orders start with rating flags set to default (false/null)
      hasRatedBuyer: false,
      hasRatedFisher: false,
      buyerRatingValue: null,
      buyerRatingMessage: null,
      fisherRatingValue: null,
      fisherRatingMessage: null,
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
    // 🌟 Map new rating fields for DB insertion/update
    'hasRatedBuyer': hasRatedBuyer ? 1 : 0,
    'hasRatedFisher': hasRatedFisher ? 1 : 0,
    'buyer_rating_value': buyerRatingValue,
    'buyer_rating_message': buyerRatingMessage,
    'fisher_rating_value': fisherRatingValue,
    'fisher_rating_message': fisherRatingMessage,
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

    // Helper function to safely read a double or null
    double? safeParseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
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
      // 🌟 Map new rating fields from DB (INTEGER 0/1 to bool, REAL to double?) 🌟
      hasRatedBuyer: (m['hasRatedBuyer'] as int?) == 1,
      hasRatedFisher: (m['hasRatedFisher'] as int?) == 1,
      buyerRatingValue: safeParseDouble(m['buyer_rating_value']),
      buyerRatingMessage: m['buyer_rating_message'] as String?,
      fisherRatingValue: safeParseDouble(m['fisher_rating_value']),
      fisherRatingMessage: m['fisher_rating_message'] as String?,
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
    // 🌟 Update copyWith 🌟
    bool? hasRatedBuyer,
    bool? hasRatedFisher,
    double? buyerRatingValue,
    String? buyerRatingMessage,
    double? fisherRatingValue,
    String? fisherRatingMessage,
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
      // 🌟 Copy new rating fields 🌟
      hasRatedBuyer: hasRatedBuyer ?? this.hasRatedBuyer,
      hasRatedFisher: hasRatedFisher ?? this.hasRatedFisher,
      buyerRatingValue: buyerRatingValue ?? this.buyerRatingValue,
      buyerRatingMessage: buyerRatingMessage ?? this.buyerRatingMessage,
      fisherRatingValue: fisherRatingValue ?? this.fisherRatingValue,
      fisherRatingMessage: fisherRatingMessage ?? this.fisherRatingMessage,
    );
  }
}
