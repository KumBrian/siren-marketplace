import '../entities/offer.dart';
import '../enums/offer_status.dart';

abstract class IOfferRepository {
  /// Create a new offer
  Future<String> create(Offer offer);

  /// Get offer by ID
  Future<Offer?> getById(String offerId);

  /// Get all offers for a specific catch
  Future<List<Offer>> getByCatchId(String catchId);

  /// Get all offers made by a buyer
  Future<List<Offer>> getByBuyerId(String buyerId);

  /// Get all offers received by a fisher
  Future<List<Offer>> getByFisherId(String fisherId);

  /// Get offers by catch IDs (bulk query)
  Future<List<Offer>> getByCatchIds(List<String> catchIds);

  /// Get offers by status
  Future<List<Offer>> getByStatus(OfferStatus status);

  /// Get pending offers where user's action is needed
  Future<List<Offer>> getPendingForUser(String userId);

  /// Update offer
  Future<void> update(Offer offer);

  /// Delete offer
  Future<void> delete(String offerId);

  /// Execute multiple operations in a transaction
  Future<T> transaction<T>(Future<T> Function() action);
}
