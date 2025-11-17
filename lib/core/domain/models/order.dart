import 'package:equatable/equatable.dart';
import 'package:siren_marketplace/core/domain/models/catch.dart';
import 'package:siren_marketplace/core/domain/models/offer.dart';

class Order extends Equatable {
  final String id;
  final Offer offer;
  final String fisherId;
  final String buyerId;
  final String catchSnapshotJson;
  final String dateUpdated;
  final Catch catchModel;
  final bool hasRatedBuyer;
  final bool hasRatedFisher;
  final double? buyerRatingValue;
  final String? buyerRatingMessage;
  final double? fisherRatingValue;
  final String? fisherRatingMessage;

  const Order({
    required this.id,
    required this.offer,
    required this.fisherId,
    required this.buyerId,
    required this.catchSnapshotJson,
    required this.dateUpdated,
    required this.catchModel,
    this.hasRatedBuyer = false,
    this.hasRatedFisher = false,
    this.buyerRatingValue,
    this.buyerRatingMessage,
    this.fisherRatingValue,
    this.fisherRatingMessage,
  });

  @override
  List<Object?> get props => [
    id,
    offer,
    fisherId,
    buyerId,
    catchSnapshotJson,
    dateUpdated,
    catchModel,
    hasRatedBuyer,
    hasRatedFisher,
    buyerRatingValue,
    buyerRatingMessage,
    fisherRatingValue,
    fisherRatingMessage,
  ];

  Order copyWith({
    String? id,
    Offer? offer,
    String? fisherId,
    String? buyerId,
    String? catchSnapshotJson,
    String? dateUpdated,
    Catch? catchModel,
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
      fisherId: fisherId ?? this.fisherId,
      buyerId: buyerId ?? this.buyerId,
      catchSnapshotJson: catchSnapshotJson ?? this.catchSnapshotJson,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      catchModel: catchModel ?? this.catchModel,
      hasRatedBuyer: hasRatedBuyer ?? this.hasRatedBuyer,
      hasRatedFisher: hasRatedFisher ?? this.hasRatedFisher,
      buyerRatingValue: buyerRatingValue ?? this.buyerRatingValue,
      buyerRatingMessage: buyerRatingMessage ?? this.buyerRatingMessage,
      fisherRatingValue: fisherRatingValue ?? this.fisherRatingValue,
      fisherRatingMessage: fisherRatingMessage ?? this.fisherRatingMessage,
    );
  }
}
