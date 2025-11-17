import '../persistence/offer_entity.dart';

abstract class OfferDataSource {
  Future<void> insertOffer(OfferEntity entity);

  Future<OfferEntity?> getOfferById(String offerId);

  Future<List<OfferEntity>> getOffersByCatchId(String catchId);

  Future<List<OfferEntity>> getOffersByCatchIds(List<String> catchIds);

  Future<List<OfferEntity>> getOffersByBuyerId(String buyerId);

  Future<List<OfferEntity>> getOffersByFisherId(String fisherId);

  Future<List<OfferEntity>> getAllOffers();

  Future<List<OfferEntity>> getOffersByStatus(String status); // status.name
  Future<void> updateOffer(OfferEntity entity);

  Future<void> deleteOffer(String offerId);
}
