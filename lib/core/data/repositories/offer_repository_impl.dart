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
  final IOfferDataSource remoteDataSource;
  final IOfferDataSource localDataSource;

  OfferRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<String> create(Offer offer) async {
    final model = OfferMapper.toModel(offer);
    // Create remotely
    final id = await remoteDataSource.create(model);
    // Cache locally (with the new ID returned from remote)
    // Note: The model passed to create() likely has a temporary or empty ID if new.
    // Ideally we fetch the created offer back or update our model with the new ID.
    // For now, let's assume we can fetch it or ignore local caching of "sent" items until refreshed.
    return id;
  }

  @override
  Future<List<Offer>> getAllOffers() async {
    try {
      final models = await remoteDataSource.getAllOffers();
      await localDataSource.saveBatch(models);
      return models.map((m) => OfferMapper.toEntity(m)).toList();
    } catch (e) {
      final models = await localDataSource.getAllOffers();
      return models.map((m) => OfferMapper.toEntity(m)).toList();
    }
  }

  @override
  Future<Offer?> getById(String offerId) async {
    try {
      final model = await remoteDataSource.getById(offerId);
      if (model != null) {
        await localDataSource.saveBatch([model]);
        return OfferMapper.toEntity(model);
      }
    } catch (e) {
      // Fallback
    }

    final localModel = await localDataSource.getById(offerId);
    return localModel != null ? OfferMapper.toEntity(localModel) : null;
  }

  @override
  Future<List<Offer>> getByProductId(String productId, {UserRole? role}) async {
    try {
      final models = await remoteDataSource.getByProductId(
        productId,
        role: role,
      );
      await localDataSource.saveBatch(models);
      return models.map((m) => OfferMapper.toEntity(m)).toList();
    } catch (e) {
      final models = await localDataSource.getByProductId(
        productId,
        role: role,
      );
      return models.map((m) => OfferMapper.toEntity(m)).toList();
    }
  }

  @override
  Future<List<Offer>> getByBuyerId(String buyerId) async {
    try {
      final models = await remoteDataSource.getByBuyerId(buyerId);
      await localDataSource.saveBatch(models);
      return models.map((m) => OfferMapper.toEntity(m)).toList();
    } catch (e) {
      final models = await localDataSource.getByBuyerId(buyerId);
      return models.map((m) => OfferMapper.toEntity(m)).toList();
    }
  }

  @override
  Future<List<Offer>> getByFisherId(String fisherId) async {
    try {
      final models = await remoteDataSource.getByFisherId(fisherId);
      await localDataSource.saveBatch(models);
      return models.map((m) => OfferMapper.toEntity(m)).toList();
    } catch (e) {
      final models = await localDataSource.getByFisherId(fisherId);
      return models.map((m) => OfferMapper.toEntity(m)).toList();
    }
  }

  @override
  Future<List<Offer>> getByCatchIds(List<String> catchIds) async {
    try {
      final models = await remoteDataSource.getByCatchIds(catchIds);
      await localDataSource.saveBatch(models);
      return models.map((m) => OfferMapper.toEntity(m)).toList();
    } catch (e) {
      final models = await localDataSource.getByCatchIds(catchIds);
      return models.map((m) => OfferMapper.toEntity(m)).toList();
    }
  }

  @override
  Future<List<Offer>> getByStatus(OfferStatus status) async {
    try {
      final models = await remoteDataSource.getByStatus(status);
      await localDataSource.saveBatch(models);
      return models.map((m) => OfferMapper.toEntity(m)).toList();
    } catch (e) {
      final models = await localDataSource.getByStatus(status);
      return models.map((m) => OfferMapper.toEntity(m)).toList();
    }
  }

  @override
  Future<List<Offer>> getPendingForUser(String userId) async {
    final pending = await getByStatus(OfferStatus.pending);
    return pending.where((o) => o.isUsersTurn(userId)).toList();
  }

  @override
  Future<void> update(Offer offer) async {
    final model = OfferMapper.toModel(offer);
    await remoteDataSource.update(model);
    await localDataSource.update(model); // Keep local in sync
  }

  @override
  Future<void> delete(String offerId) async {
    await remoteDataSource.delete(offerId);
    try {
      await localDataSource.delete(offerId);
    } catch (_) {}
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) async {
    // Transaction usually implies local DB transaction
    return await localDataSource.transaction(action);
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

    await remoteDataSource.respond(offerId, request);

    // Invalidate/Refresh needed?
    // We can fetch the updated offer and cache it
    try {
      final updatedModel = await remoteDataSource.getById(offerId);
      if (updatedModel != null) {
        await localDataSource.saveBatch([updatedModel]);
      }
    } catch (_) {}

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
    await remoteDataSource.respond(offerId, request);

    try {
      final updatedModel = await remoteDataSource.getById(offerId);
      if (updatedModel != null) {
        await localDataSource.saveBatch([updatedModel]);
      }
    } catch (_) {}
  }

  @override
  Future<void> counterOffer(
    String offerId,
    UserRole role,
    OfferTerms terms,
  ) async {
    final request = CounterOfferRequest(
      weightInGrams: terms.weight.grams.toDouble(),
      price: terms.totalPrice.amount.toDouble(),
      pricePerKg: terms.pricePerKg.amountPerKg.toDouble(),
    );

    await remoteDataSource.counterOffer(offerId, request);

    try {
      final updatedModel = await remoteDataSource.getById(offerId);
      if (updatedModel != null) {
        await localDataSource.saveBatch([updatedModel]);
      }
    } catch (_) {}
  }

  @override
  Future<void> markAsViewed(String offerId, UserRole role) async {
    // This logic was modifying local cache directly in API mode before
    // Now we can be more explicit: update local data source
    final offerModel = await localDataSource.getById(
      offerId,
    ); // Getting from local is fast
    if (offerModel == null) return; // If not in cache, ignore?

    final offer = OfferMapper.toEntity(offerModel);
    Offer updatedOffer;

    if (role == UserRole.fisher) {
      updatedOffer = offer.copyWith(hasUpdateForFisher: false);
    } else {
      updatedOffer = offer.copyWith(hasUpdateForBuyer: false);
    }

    final updatedModel = OfferMapper.toModel(updatedOffer);

    // Update local cache
    await localDataSource.update(updatedModel);

    // Also try to update remote if needed, but `markAsViewed` is often local-only state
    // unless backend stores 'viewed' flags. The previous code only updated local cache.
    // remoteDataSource.updateLocalCache(updatedModel); // This method existed on ApiDataSource
    // We should probably check if remoteDataSource has a method for this or just rely on local.
    // The previous implementation used `updateLocalCache` on the dataSource.
    // `IOfferDataSource` has `updateLocalCache`.
    remoteDataSource.updateLocalCache(updatedModel);
  }
}
