import 'package:siren_marketplace/core/domain/value_objects/rating.dart';

import '../../domain/entities/offer.dart';
import '../../domain/entities/order.dart';
import '../../domain/enums/offer_status.dart';
import '../../domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/repositories/i_offer_repository.dart';
import 'package:siren_marketplace/core/domain/value_objects/offer_terms.dart';
import '../datasources/interfaces/i_offer_datasource.dart';
import '../mappers/offer_mapper.dart';
import '../api/models/offer_api_models.dart';
import '../../services/connectivity_service.dart';

import 'package:siren_marketplace/core/domain/repositories/i_user_repository.dart';
import '../../domain/entities/user.dart'; // Ensure User is imported
import 'package:siren_marketplace/core/data/models/offer_model.dart';
import 'package:siren_marketplace/core/data/api/models/auth_api_models.dart';

class OfferRepositoryImpl implements IOfferRepository {
  final IOfferDataSource remoteDataSource;
  final IOfferDataSource localDataSource;
  final ConnectivityService connectivityService;
  final IUserRepository userRepository;

  OfferRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
    required this.userRepository,
  });

  Future<void> _cacheUsers(List<OfferModel> models) async {
    Future<void> _cacheUsers(List<OfferModel> models) async {
      for (final model in models) {
        if (model.buyer != null) {
          try {
            final buyer = model.buyer!;
            final user = User(
              id: buyer.id.toString(),
              name:
                  '${buyer.firstName ?? ''} ${buyer.lastName ?? ''}'
                      .trim()
                      .isEmpty
                  ? (buyer.username ?? 'Unknown')
                  : '${buyer.firstName ?? ''} ${buyer.lastName ?? ''}'.trim(),
              rating: Rating.fromValue(buyer.rating ?? 0.0),
              reviewCount: buyer.totalReviews ?? 0,
              avatarUrl: buyer.avatar,
              currentRole: UserRole.buyer,
            );
            await userRepository.update(user);
          } catch (_) {}
        }

        // Also cache Fisher if available (e.g. via product)
        if (model.product?.fisher != null) {
          try {
            await userRepository.update(model.product!.fisher!);
          } catch (_) {}
        }
      }
    }
  }

  Future<bool> get _isOffline async {
    final status = await connectivityService.checkConnectivity();
    return status == NetworkStatus.offline;
  }

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
    if (await _isOffline) {
      final models = await localDataSource.getAllOffers();
      return await _mapModelsToEntitiesWithUsers(models);
    }

    try {
      final models = await remoteDataSource.getAllOffers();
      await localDataSource.saveBatch(models);

      // Cache associated users
      try {
        final usersToCache = <AccountApiModel>[];
        for (final m in models) {
          if (m.buyer != null) usersToCache.add(m.buyer!);
          // Fisher is often inside Product, need to check deeper or if fisher_id is sufficient?
          // OfferModel doesn't have a direct 'fisher' object field in the same way,
          // but let's check parsing. It falls back to ids.
          // IF the API returns the user objects, we should save them.
          // OfferModel has 'buyer' (AccountApiModel).
          // And 'product' which might have 'fisher' inside? ProductApiModel usually has fisherId or fisher object.
          if (m.product?.fisher != null) {
            // We need to map Product's fisher to AccountApiModel or User and save it.
            // But ProductApiModel fisher is 'AccountApiModel' usually.
            // Let's assume we can rely on what we have.
            // For now, at least cache the buyer.
          }
        }

        // We generally need a way to save UserModels.
        // OfferRepository shouldn't depend on UserRepository directly for logical purity?
        // But for pragmatism in offline-first, injecting UserRepository is fine.
        // Or we rely on the fact that if we use the app, we likely fetched these users elsewhere.
        // But the user says "only the offer i viewed while online".
        // SO we MUST save them here.

        // I will implement a private helper _cacheUsers(List<OfferModel> models)
        await _cacheUsers(models);
      } catch (e) {
        print('Warning: Failed to cache users from offers: $e');
      }

      return await _mapModelsToEntitiesWithUsers(models);
    } catch (e) {
      final models = await localDataSource.getAllOffers();
      return await _mapModelsToEntitiesWithUsers(models);
    }
  }

  Future<List<Offer>> _mapModelsToEntitiesWithUsers(
    List<OfferModel> models,
  ) async {
    final entities = <Offer>[];
    for (final model in models) {
      var entity = OfferMapper.toEntity(model);

      // 1. Hydrate Buyer if missing
      if (entity.buyer == null) {
        try {
          print(
            'DEBUG: Hydrating buyer for offer ${entity.id}, buyerId: ${entity.buyerId}',
          );
          final buyerUser = await userRepository.getById(entity.buyerId);
          if (buyerUser != null) {
            print('DEBUG: Found buyer: ${buyerUser.name}');
            entity = entity.copyWith(buyer: buyerUser);
          } else {
            print('DEBUG: Buyer not found in repository');
          }
        } catch (e) {
          print('DEBUG: Error hydrating buyer: $e');
        }
      }

      // 2. Hydrate Fisher if missing (usually via product or direct id)
      if (entity.fisher == null) {
        try {
          print(
            'DEBUG: Hydrating fisher for offer ${entity.id}, fisherId: ${entity.fisherId}',
          );
          final fisherUser = await userRepository.getById(entity.fisherId);
          if (fisherUser != null) {
            print('DEBUG: Found fisher: ${fisherUser.name}');
            entity = entity.copyWith(fisher: fisherUser);
          } else {
            print('DEBUG: Fisher not found in repository');
          }
        } catch (e) {
          print('DEBUG: Error hydrating fisher: $e');
        }
      }

      entities.add(entity);
    }
    return entities;
  }

  @override
  Future<Offer?> getById(String offerId) async {
    if (await _isOffline) {
      final localModel = await localDataSource.getById(offerId);
      return localModel != null ? OfferMapper.toEntity(localModel) : null;
    }

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
    if (await _isOffline) {
      final models = await localDataSource.getByProductId(
        productId,
        role: role,
      );
      return await _mapModelsToEntitiesWithUsers(models);
    }

    try {
      final models = await remoteDataSource.getByProductId(
        productId,
        role: role,
      );
      await localDataSource.saveBatch(models);
      await _cacheUsers(models);
      return await _mapModelsToEntitiesWithUsers(models);
    } catch (e) {
      final models = await localDataSource.getByProductId(
        productId,
        role: role,
      );
      return await _mapModelsToEntitiesWithUsers(models);
    }
  }

  @override
  Future<List<Offer>> getByBuyerId(String buyerId) async {
    if (await _isOffline) {
      final models = await localDataSource.getByBuyerId(buyerId);
      return await _mapModelsToEntitiesWithUsers(models);
    }

    try {
      final models = await remoteDataSource.getByBuyerId(buyerId);
      await localDataSource.saveBatch(models);
      return await _mapModelsToEntitiesWithUsers(models);
    } catch (e) {
      final models = await localDataSource.getByBuyerId(buyerId);
      return await _mapModelsToEntitiesWithUsers(models);
    }
  }

  @override
  Future<List<Offer>> getByFisherId(String fisherId) async {
    if (await _isOffline) {
      final models = await localDataSource.getByFisherId(fisherId);
      return await _mapModelsToEntitiesWithUsers(models);
    }

    try {
      final models = await remoteDataSource.getByFisherId(fisherId);
      await localDataSource.saveBatch(models);
      return await _mapModelsToEntitiesWithUsers(models);
    } catch (e) {
      final models = await localDataSource.getByFisherId(fisherId);
      return await _mapModelsToEntitiesWithUsers(models);
    }
  }

  @override
  Future<List<Offer>> getByCatchIds(List<String> catchIds) async {
    if (await _isOffline) {
      final models = await localDataSource.getByCatchIds(catchIds);
      return await _mapModelsToEntitiesWithUsers(models);
    }

    try {
      final models = await remoteDataSource.getByCatchIds(catchIds);
      await localDataSource.saveBatch(models);
      return await _mapModelsToEntitiesWithUsers(models);
    } catch (e) {
      final models = await localDataSource.getByCatchIds(catchIds);
      return await _mapModelsToEntitiesWithUsers(models);
    }
  }

  @override
  Future<List<Offer>> getByStatus(OfferStatus status) async {
    if (await _isOffline) {
      final models = await localDataSource.getByStatus(status);
      return await _mapModelsToEntitiesWithUsers(models);
    }

    try {
      final models = await remoteDataSource.getByStatus(status);
      await localDataSource.saveBatch(models);
      return await _mapModelsToEntitiesWithUsers(models);
    } catch (e) {
      final models = await localDataSource.getByStatus(status);
      return await _mapModelsToEntitiesWithUsers(models);
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
