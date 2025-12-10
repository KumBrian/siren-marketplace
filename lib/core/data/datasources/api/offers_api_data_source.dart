import '../../../../core/data/api/api_client.dart';
import '../../../../core/data/api/api_config.dart';
import '../../../../core/data/api/models/offer_api_models.dart';
import '../../../../core/data/mappers/offer_api_mapper.dart';
import '../../models/offer_model.dart';
import '../../../domain/enums/offer_status.dart';
import '../interfaces/i_offer_datasource.dart';

class OffersApiDataSource implements IOfferDataSource {
  final ApiClient _client;

  // Time-based caching for offers (marketplace data changes frequently)
  static const Duration _cacheStaleTime = Duration(seconds: 30);

  // Separate caches for different offer types
  final Map<String, OfferModel> _offerByIdCache = {};
  final Map<String, DateTime> _offerByIdCacheTime = {};

  List<OfferModel>? _myOffersCache;
  DateTime? _myOffersCacheTime;

  List<OfferModel>? _receivedOffersCache;
  DateTime? _receivedOffersCacheTime;

  final Map<String, List<OfferModel>> _offersByCatchCache = {};
  final Map<String, DateTime> _offersByCatchCacheTime = {};

  OffersApiDataSource({required ApiClient client}) : _client = client;

  @override
  Future<String> create(OfferModel offer) async {
    final request = OfferApiMapper.toRequest(offer);
    final response = await _client.post(
      ApiConfig.offers,
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
        .toList();
  }

  @override
  Future<OfferModel?> getById(String offerId) async {
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
      final offerModel = OfferApiMapper.toDomain(apiModel);

      // Store in cache with timestamp
      _offerByIdCache[offerId] = offerModel;
      _offerByIdCacheTime[offerId] = DateTime.now();

      return offerModel;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<OfferModel>> getByCatchId(String catchId) async {
    // Check cache with stale time
    if (_offersByCatchCache.containsKey(catchId)) {
      final cacheTime = _offersByCatchCacheTime[catchId];
      if (cacheTime != null &&
          DateTime.now().difference(cacheTime) < _cacheStaleTime) {
        print('DEBUG: Offers by catch cache HIT for catch $catchId');
        return _offersByCatchCache[catchId]!;
      }
    }

    print('DEBUG: Offers by catch cache MISS for catch $catchId');

    // Use my-offers endpoint with product filter
    // More efficient than filtering all offers
    final response = await _client.get(
      ApiConfig.myOffers,
      queryParameters: {'product': catchId, 'page': 1, 'itemsPerPage': 100},
    );
    final List data = response.data['data']['member'] ?? [];
    final offers = data
        .map((json) => OfferApiMapper.toDomain(OfferApiModel.fromJson(json)))
        .toList();

    // Cache with timestamp
    _offersByCatchCache[catchId] = offers;
    _offersByCatchCacheTime[catchId] = DateTime.now();

    return offers;
  }

  @override
  Future<List<OfferModel>> getByBuyerId(String buyerId) async {
    // In API mode, use the authenticated my-offers endpoint
    // (These are offers made by the buyer)
    // The buyerId parameter is ignored since API uses the token
    return await getMyOffers();
  }

  @override
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
    final futures = catchIds.map((id) => getByCatchId(id));
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

  /// Clear all list caches (called on mutations)
  void _clearAllCaches() {
    _myOffersCache = null;
    _myOffersCacheTime = null;
    _receivedOffersCache = null;
    _receivedOffersCacheTime = null;
    _offersByCatchCache.clear();
    _offersByCatchCacheTime.clear();
    print('DEBUG: All offer caches cleared');
  }
}
