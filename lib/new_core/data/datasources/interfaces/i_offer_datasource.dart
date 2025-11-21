import '../../../domain/enums/offer_status.dart';
import '../../models/offer_model.dart';

abstract class IOfferDataSource {
  Future<String> create(OfferModel offer);

  Future<OfferModel?> getById(String offerId);

  Future<List<OfferModel>> getByCatchId(String catchId);

  Future<List<OfferModel>> getByBuyerId(String buyerId);

  Future<List<OfferModel>> getByFisherId(String fisherId);

  Future<List<OfferModel>> getByCatchIds(List<String> catchIds);

  Future<List<OfferModel>> getByStatus(OfferStatus status);

  Future<void> update(OfferModel offer);

  Future<void> delete(String offerId);

  // Transaction support
  Future<T> transaction<T>(Future<T> Function() action);
}
