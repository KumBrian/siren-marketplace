import '../../api/models/offer_api_models.dart';
import '../../../domain/enums/offer_status.dart';
import '../../models/offer_model.dart';
import '../../../domain/enums/user_role.dart';

abstract class IOfferDataSource {
  Future<String> create(OfferModel offer);

  Future<String> counterOffer(String offerId, CounterOfferRequest request);

  Future<OfferModel> respond(String offerId, OfferResponseRequest request);

  Future<List<OfferModel>> getAllOffers();

  Future<OfferModel?> getById(String offerId);

  Future<List<OfferModel>> getByProductId(String productId, {UserRole? role});

  Future<List<OfferModel>> getByBuyerId(String buyerId);

  Future<List<OfferModel>> getByFisherId(String fisherId);

  Future<List<OfferModel>> getByCatchIds(List<String> catchIds);

  Future<List<OfferModel>> getByStatus(OfferStatus status);

  Future<void> update(OfferModel offer);

  Future<void> delete(String offerId);

  // Transaction support
  Future<T> transaction<T>(Future<T> Function() action);

  /// Update local cache only (no API call)
  void updateLocalCache(OfferModel offer);

  Future<void> saveBatch(List<OfferModel> offers);
}
