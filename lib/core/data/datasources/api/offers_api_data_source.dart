import '../../../../core/data/api/api_client.dart';
import '../../../../core/data/api/api_config.dart';
import '../../../../core/data/api/models/offer_api_models.dart';
import '../../../../core/data/mappers/offer_api_mapper.dart';
import '../../models/offer_model.dart';
import '../../../domain/enums/offer_status.dart';
import '../../../domain/enums/user_role.dart';
import '../interfaces/i_offer_datasource.dart';

import '../../../domain/services/viewed_offers_service.dart';

class OffersApiDataSource implements IOfferDataSource {
  final ApiClient _client;
  final IViewedOffersService _viewedOffersService;

  // Time-based caching for offers (marketplace data changes frequently)
  static const Duration _cacheStaleTime = Duration(seconds: 30);

  // Separate caches for different offer types
  final Map<String, OfferModel> _offerByIdCache = {};
  final Map<String, DateTime> _offerByIdCacheTime = {};

  List<OfferModel>? _myOffersCache;
  DateTime? _myOffersCacheTime;

  List<OfferModel>? _receivedOffersCache;
  DateTime? _receivedOffersCacheTime;

  final Map<String, List<OfferModel>> _offersByProductCache = {};
  final Map<String, DateTime> _offersByProductCacheTime = {};

  OffersApiDataSource({
    required ApiClient client,
    required IViewedOffersService viewedOffersService,
  }) : _client = client,
       _viewedOffersService = viewedOffersService;

  @override
  Future<String> create(OfferModel offer) async {
    final request = OfferApiMapper.toRequest(offer);
    final response = await _client.post(
      ApiConfig.makeOffer,
      data: request.toJson(),
    );
    final data = response.data['data'] ?? response.data;

    // Invalidate all caches since a new offer was created
    _clearAllCaches();

    return data['id'].toString();
  }

  @override
  Future<List<OfferModel>> getAllOffers() async {
    final response = await _client.get(ApiConfig.offers);
    final List data = response.data['data'] ?? [];
    return data
        .map((json) => OfferApiMapper.toDomain(OfferApiModel.fromJson(json)))
        .map(_applyViewedState)
        .toList();
  }

  @override
  Future<String> counterOffer(
    String offerId,
    CounterOfferRequest request,
  ) async {
    final response = await _client.post(
      ApiConfig.counterOffer(offerId),
      data: request.toJson(),
    );
    final data = response.data['data'] ?? response.data;

    // Invalidate caches
    _offerByIdCache.remove(offerId);
    _offerByIdCacheTime.remove(offerId);
    _clearAllCaches();

    return data['id'].toString();
  }

  @override
  Future<OfferModel> respond(
    String offerId,
    OfferResponseRequest request,
  ) async {
    final response = await _client.post(
      ApiConfig.respondToOffer(offerId),
      data: request.toJson(),
    );
    final data = response.data['data'] ?? response.data;

    // Invalidate caches
    _offerByIdCache.remove(offerId);
    _offerByIdCacheTime.remove(offerId);
    _clearAllCaches();

    return OfferApiMapper.toDomain(OfferApiModel.fromJson(data));
  }

  @override
  Future<OfferModel?> getById(String offerId) async {
    // TEMPORARY: Force cache miss to pick up new ID format
    // TODO: Remove this after migration is complete
    if (_offerByIdCache.containsKey(offerId)) {
      print(
        'DEBUG: Force invalidating cached offer $offerId to pick up ID format changes',
      );
      _offerByIdCache.remove(offerId);
      _offerByIdCacheTime.remove(offerId);
    }

    // Check cache with stale time
    if (_offerByIdCache.containsKey(offerId)) {
      final cacheTime = _offerByIdCacheTime[offerId];
      if (cacheTime != null &&
          DateTime.now().difference(cacheTime) < _cacheStaleTime) {
        print(
          'DEBUG: Offer cache HIT for $offerId (${DateTime.now().difference(cacheTime).inSeconds}s old)',
        );
        return _offerByIdCache[offerId];
      }
    }

    print('DEBUG: Offer cache MISS for $offerId, fetching from API');

    try {
      final response = await _client.get(ApiConfig.offer(offerId));
      final data = response.data['data'] ?? response.data;
      final apiModel = OfferApiModel.fromJson(data);
      var offerModel = OfferApiMapper.toDomain(apiModel);

      // Apply local viewed state
      offerModel = _applyViewedState(offerModel);

      // Store in cache with timestamp
      _offerByIdCache[offerId] = offerModel;
      _offerByIdCacheTime[offerId] = DateTime.now();

      return offerModel;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<OfferModel>> getByProductId(
    String productId, {
    UserRole? role,
  }) async {
    // Check cache with stale time
    if (_offersByProductCache.containsKey(productId)) {
      final cacheTime = _offersByProductCacheTime[productId];
      if (cacheTime != null &&
          DateTime.now().difference(cacheTime) < _cacheStaleTime) {
        print('DEBUG: Offers by product cache HIT for product $productId');
        return _offersByProductCache[productId]!;
      }
    }

    print(
      'DEBUG: Offers by product cache MISS for product $productId (Role: $role)',
    );

    List<OfferModel> offers;

    if (role == UserRole.fisher) {
      // Fisher wants to see offers RECEIVED on their catch
      // Use received-offers endpoint
      try {
        final response = await _client.get(
          ApiConfig.receivedOffers,
          queryParameters: {
            'product': productId,
            'page': 1,
            'itemsPerPage': 100,
          },
        );
        final List data = response.data['data']['member'] ?? [];
        offers = data
            .map(
              (json) => OfferApiMapper.toDomain(OfferApiModel.fromJson(json)),
            )
            .map(_applyViewedState)
            .toList();
      } catch (e) {
        // Fallback: fetch all received offers and filter (if API doesn't support product filter on received-offers)
        print(
          "DEBUG: Fetching specific product failed, falling back to all received: $e",
        );
        final allReceived = await getReceivedOffers('me'); // 'me' is ignored
        offers = allReceived.where((o) => o.productId == productId).toList();
      }
    } else {
      // Buyer (or unknown) wants to see THEIR offers on this catch
      // Use my-offers endpoint with product filter
      final response = await _client.get(
        ApiConfig.myOffers,
        queryParameters: {'product': productId, 'page': 1, 'itemsPerPage': 100},
      );
      final List data = response.data['data']['member'] ?? [];
      offers = data
          .map((json) => OfferApiMapper.toDomain(OfferApiModel.fromJson(json)))
          .map(_applyViewedState)
          .toList();
    }

    // Cache with timestamp
    _offersByProductCache[productId] = offers;
    _offersByProductCacheTime[productId] = DateTime.now();

    return offers;
  }

  @override
  Future<List<OfferModel>> getByBuyerId(String buyerId) async {
    // In API mode, use the authenticated my-offers endpoint
    // (These are offers made by the buyer)
    // The buyerId parameter is ignored since API uses the token
    return await getMyOffers();
  }

  // NOTE: Removed @override as this is not in interface, but a public helper
  Future<List<OfferModel>> getReceivedOffers(String fisherId) async {
    // Check cache with stale time
    if (_receivedOffersCache != null && _receivedOffersCacheTime != null) {
      if (DateTime.now().difference(_receivedOffersCacheTime!) <
          _cacheStaleTime) {
        print('DEBUG: Received offers cache HIT');
        return _receivedOffersCache!;
      }
    }

    print('DEBUG: Received offers cache MISS');

    // API uses token for authentication
    final response = await _client.get(
      ApiConfig.receivedOffers,
      queryParameters: {'page': 1, 'itemsPerPage': 100},
    );
    final List data = response.data['data']['member'] ?? [];
    final offers = data
        .map((json) => OfferApiMapper.toDomain(OfferApiModel.fromJson(json)))
        .map(_applyViewedState)
        .toList();

    // Cache with timestamp
    _receivedOffersCache = offers;
    _receivedOffersCacheTime = DateTime.now();

    return offers;
  }

  @override
  Future<List<OfferModel>> getByFisherId(String fisherId) async {
    // In API mode, use the authenticated received-offers endpoint
    // (These are offers received by the fisher on their catches)
    // The fisherId parameter is ignored since API uses the token
    return await getReceivedOffers(fisherId);
  }

  /// Get authenticated user's offers (buyer's offers)
  Future<List<OfferModel>> getMyOffers() async {
    // Check cache with stale time
    if (_myOffersCache != null && _myOffersCacheTime != null) {
      if (DateTime.now().difference(_myOffersCacheTime!) < _cacheStaleTime) {
        print('DEBUG: My offers cache HIT');
        return _myOffersCache!;
      }
    }

    print('DEBUG: My offers cache MISS');

    final response = await _client.get(
      ApiConfig.myOffers,
      queryParameters: {'page': 1, 'itemsPerPage': 100},
    );
    final List data = response.data['data']['member'] ?? [];
    final offers = data
        .map((json) => OfferApiMapper.toDomain(OfferApiModel.fromJson(json)))
        .map(_applyViewedState)
        .toList();

    // Cache with timestamp
    _myOffersCache = offers;
    _myOffersCacheTime = DateTime.now();

    return offers;
  }

  @override
  Future<List<OfferModel>> getByCatchIds(List<String> catchIds) async {
    if (catchIds.isEmpty) return [];
    // Assuming API supports list filter or we loop
    // 'catch_id': catchIds.join(',') or similar?
    // Safety fallback: loop
    final futures = catchIds.map((id) => getByProductId(id));
    final results = await Future.wait(futures);
    return results.expand((element) => element).toList();
  }

  @override
  Future<List<OfferModel>> getByStatus(OfferStatus status) async {
    final response = await _client.get(
      ApiConfig.offers,
      queryParameters: {'status': status.name},
    );
    final List data = response.data['data'] ?? [];
    return data
        .map((json) => OfferApiMapper.toDomain(OfferApiModel.fromJson(json)))
        .map(_applyViewedState)
        .toList();
  }

  @override
  Future<void> update(OfferModel offer) async {
    // Partial update or full put? Assuming partial (PATCH) logic manually
    // But Mapper.toRequest creates a CREATE request (no id).
    // We might need specific simple map for updates for now.
    final data = {
      'price_amount': offer.currentPriceAmount,
      'weight_grams': offer.currentWeightGrams,
      'status': offer.status,
    };

    await _client.patch(ApiConfig.offer(offer.id), data: data);

    // Invalidate caches for this offer
    _offerByIdCache.remove(offer.id);
    _offerByIdCacheTime.remove(offer.id);
    _clearAllCaches(); // Also clear list caches
  }

  @override
  Future<void> delete(String offerId) async {
    await _client.delete(ApiConfig.offer(offerId));

    // Invalidate caches
    _offerByIdCache.remove(offerId);
    _offerByIdCacheTime.remove(offerId);
    _clearAllCaches();
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) async {
    // No explicit transaction support in API usually
    return await action();
  }

  @override
  void updateLocalCache(OfferModel offer) {
    // Persist viewed state
    try {
      _viewedOffersService.markAsViewed(
        offer.id,
        DateTime.parse(offer.dateUpdated),
      );
    } catch (e) {
      print('DEBUG: Failed to persist viewed state: $e');
    }

    // Update ID cache
    if (_offerByIdCache.containsKey(offer.id)) {
      _offerByIdCache[offer.id] = offer;
      _offerByIdCacheTime[offer.id] =
          DateTime.now(); // Refresh timestamp so it sticks
    }

    // Helper to update list
    bool updateList(List<OfferModel>? list) {
      if (list == null) return false;
      final index = list.indexWhere((o) => o.id == offer.id);
      if (index != -1) {
        list[index] = offer;
        return true;
      }
      return false;
    }

    // Update list caches
    if (updateList(_myOffersCache)) _myOffersCacheTime = DateTime.now();
    if (updateList(_receivedOffersCache))
      _receivedOffersCacheTime = DateTime.now();
    _offersByProductCache.values.forEach(updateList);
    // Note: Not updating product cache times individually as it complicates map iteration

    print('DEBUG: Updated local cache for offer ${offer.id}');
  }

  /// Apply local viewed state to override API flags
  OfferModel _applyViewedState(OfferModel offer) {
    try {
      final isViewed = _viewedOffersService.isViewed(
        offer.id,
        DateTime.parse(offer.dateUpdated),
      );

      if (isViewed) {
        // Force update flags to false locally
        return offer.copyWith(
          hasUpdateForFisher: false,
          hasUpdateForBuyer: false,
        );
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return offer;
  }

  /// Clear all list caches (called on mutations)
  void _clearAllCaches() {
    _myOffersCache = null;
    _myOffersCacheTime = null;
    _receivedOffersCache = null;
    _receivedOffersCacheTime = null;
    _offersByProductCache.clear();
    _offersByProductCacheTime.clear();
    print('DEBUG: All offer caches cleared');
  }
}
