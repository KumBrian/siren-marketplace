import '../../domain/entities/offer.dart';
import '../../domain/entities/order.dart';
import '../../domain/enums/offer_status.dart';
import '../../domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/repositories/i_offer_repository.dart';
import 'package:siren_marketplace/core/domain/value_objects/offer_terms.dart';
import '../datasources/interfaces/i_offer_datasource.dart';
import '../mappers/offer_mapper.dart';
import '../api/models/offer_api_models.dart';

class OfferRepositoryImpl implements IOfferRepository {
  final IOfferDataSource dataSource;

  OfferRepositoryImpl({required this.dataSource});

  @override
  Future<String> create(Offer offer) async {
    final model = OfferMapper.toModel(offer);
    return await dataSource.create(model);
  }

  @override
  Future<List<Offer>> getAllOffers() async {
    final models = await dataSource.getAllOffers();
    return models.map((m) => OfferMapper.toEntity(m)).toList();
  }

  @override
  Future<Offer?> getById(String offerId) async {
    final model = await dataSource.getById(offerId);
    return model != null ? OfferMapper.toEntity(model) : null;
  }

  @override
  Future<List<Offer>> getByProductId(String productId, {UserRole? role}) async {
    final models = await dataSource.getByProductId(productId, role: role);
    return models.map((m) => OfferMapper.toEntity(m)).toList();
  }

  @override
  Future<List<Offer>> getByBuyerId(String buyerId) async {
    final models = await dataSource.getByBuyerId(buyerId);
    return models.map((m) => OfferMapper.toEntity(m)).toList();
  }

  @override
  Future<List<Offer>> getByFisherId(String fisherId) async {
    final models = await dataSource.getByFisherId(fisherId);
    return models.map((m) => OfferMapper.toEntity(m)).toList();
  }

  @override
  Future<List<Offer>> getByCatchIds(List<String> catchIds) async {
    final models = await dataSource.getByCatchIds(catchIds);
    return models.map((m) => OfferMapper.toEntity(m)).toList();
  }

  @override
  Future<List<Offer>> getByStatus(OfferStatus status) async {
    final models = await dataSource.getByStatus(status);
    return models.map((m) => OfferMapper.toEntity(m)).toList();
  }

  @override
  Future<List<Offer>> getPendingForUser(String userId) async {
    final pending = await getByStatus(OfferStatus.pending);
    return pending.where((o) => o.isUsersTurn(userId)).toList();
  }

  @override
  Future<void> update(Offer offer) async {
    final model = OfferMapper.toModel(offer);
    await dataSource.update(model);
  }

  @override
  Future<void> delete(String offerId) async {
    await dataSource.delete(offerId);
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) async {
    return await dataSource.transaction(action);
  }

  @override
  Future<Order?> acceptOffer(
    String offerId,
    UserRole role, {
    String? message,
  }) async {
    final request = OfferResponseRequest(
      action: 'accept',
      message: message ?? 'Offer accepted',
    );

    // Get the raw OfferModel which has access to saleOrder via OfferApiModel
    // Get the raw OfferModel which has access to saleOrder via OfferApiModel
    await dataSource.respond(offerId, request);

    // The saleOrder is embedded in the API response
    // We need to get it from the original API model
    // For now, try to fetch the order separately as a workaround
    // TODO: Better solution would be to return OrderApiModel from dataSource

    return null; // Will be fetched in service layer
  }

  @override
  Future<void> rejectOffer(
    String offerId,
    UserRole role, {
    String? message,
  }) async {
    final request = OfferResponseRequest(
      action: 'reject',
      message: message ?? 'Offer rejected',
    );
    await dataSource.respond(offerId, request);
  }

  @override
  Future<void> counterOffer(
    String offerId,
    UserRole role,
    OfferTerms terms,
  ) async {
    // We don't strictly need to fetch the offer if we just trust the ID and terms,
    // but fetching confirms existence and allows us to verify logic if needed.
    // However, for the API call, we just need the terms.

    final request = CounterOfferRequest(
      weightInGrams: terms.weight.grams.toDouble(),
      price: terms.totalPrice.amount.toDouble(),
      pricePerKg: terms.pricePerKg.amountPerKg.toDouble(),
    );

    await dataSource.counterOffer(offerId, request);
  }

  @override
  Future<void> markAsViewed(String offerId, UserRole role) async {
    final offerModel = await dataSource.getById(offerId);
    if (offerModel == null) return;

    final offer = OfferMapper.toEntity(offerModel);
    Offer updatedOffer;

    if (role == UserRole.fisher) {
      updatedOffer = offer.copyWith(hasUpdateForFisher: false);
    } else {
      updatedOffer = offer.copyWith(hasUpdateForBuyer: false);
    }

    // Use local cache update instead of API update for view status
    // This avoids failing PATCH calls while updating the UI state
    dataSource.updateLocalCache(OfferMapper.toModel(updatedOffer));
  }
}
