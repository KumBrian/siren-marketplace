import '../../domain/models/offer.dart';

class OfferDto {
  final Map<String, dynamic> json;

  OfferDto(this.json);

  Offer toDomain() {
    return Offer.fromMap(json);
  }

  // convert domain -> API payload (keys for backend team; you may rename as needed)
  static Map<String, dynamic> fromDomain(Offer offer) {
    return {
      'offer_id': offer.id,
      'catch_id': offer.catchId,
      'fisher_id': offer.fisherId,
      'fisher_name': offer.fisherName,
      'fisher_rating': offer.fisherRating,
      'fisher_avatar': offer.fisherAvatarUrl,
      'buyer_id': offer.buyerId,
      'buyer_name': offer.buyerName,
      'buyer_rating': offer.buyerRating,
      'buyer_avatar': offer.buyerAvatarUrl,
      'catch_name': offer.catchName,
      'catch_image_url': offer.catchImageUrl,
      'price': offer.price,
      'weight': offer.weight,
      'price_per_kg': offer.pricePerKg,
      'status': offer.status.name,
      'has_update_for_buyer': offer.hasUpdateForBuyer ? 1 : 0,
      'has_update_for_fisher': offer.hasUpdateForFisher ? 1 : 0,
      'date_created': offer.dateCreated,
      'waiting_for': offer.waitingFor?.name,
      'previous_price': offer.previousPrice,
      'previous_weight': offer.previousWeight,
      'previous_price_per_kg': offer.previousPricePerKg,
    };
  }
}
