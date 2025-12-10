import '../../../../core/data/api/api_client.dart';
import '../../../../core/data/api/api_config.dart';
import '../../../../core/data/api/models/offer_api_models.dart';
import '../../../../core/data/mappers/offer_api_mapper.dart';
import '../../models/offer_model.dart';
import '../../../domain/enums/offer_status.dart';
import '../interfaces/i_offer_datasource.dart';

class OffersApiDataSource implements IOfferDataSource {
  final ApiClient _client;

  OffersApiDataSource({required ApiClient client}) : _client = client;

  @override
  Future<String> create(OfferModel offer) async {
    final request = OfferApiMapper.toRequest(offer);
    final response = await _client.post(
      ApiConfig.offers,
      data: request.toJson(),
    );
    final data = response.data['data'] ?? response.data;
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
    try {
      final response = await _client.get(ApiConfig.offer(offerId));
      final data = response.data['data'] ?? response.data;
      final apiModel = OfferApiModel.fromJson(data);
      return OfferApiMapper.toDomain(apiModel);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<OfferModel>> getByCatchId(String catchId) async {
    final response = await _client.get(
      ApiConfig.offers,
      queryParameters: {'catch_id': catchId},
    );
    final List data = response.data['data'] ?? [];
    return data
        .map((json) => OfferApiMapper.toDomain(OfferApiModel.fromJson(json)))
        .toList();
  }

  @override
  Future<List<OfferModel>> getByBuyerId(String buyerId) async {
    final response = await _client.get(
      ApiConfig.offers,
      queryParameters: {'buyer_id': buyerId},
    );
    final List data = response.data['data'] ?? [];
    return data
        .map((json) => OfferApiMapper.toDomain(OfferApiModel.fromJson(json)))
        .toList();
  }

  @override
  Future<List<OfferModel>> getReceivedOffers(String fisherId) async {
    // API uses token for authentication
    final response = await _client.get(
      ApiConfig.receivedOffers,
      queryParameters: {'page': 1, 'itemsPerPage': 20},
    );
    final List data = response.data['data']['member'] ?? [];
    return data
        .map((json) => OfferApiMapper.toDomain(OfferApiModel.fromJson(json)))
        .toList();
  }

  @override
  Future<List<OfferModel>> getByFisherId(String fisherId) async {
    final response = await _client.get(
      ApiConfig.offers,
      queryParameters: {'fisher_id': fisherId},
    );
    final List data = response.data['data'] ?? [];
    return data
        .map((json) => OfferApiMapper.toDomain(OfferApiModel.fromJson(json)))
        .toList();
  }

  /// Get authenticated user's offers (buyer's offers)
  Future<List<OfferModel>> getMyOffers() async {
    final response = await _client.get(
      ApiConfig.myOffers,
      queryParameters: {'page': 1, 'itemsPerPage': 20},
    );
    final List data = response.data['data']['member'] ?? [];
    return data
        .map((json) => OfferApiMapper.toDomain(OfferApiModel.fromJson(json)))
        .toList();
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
  }

  @override
  Future<void> delete(String offerId) async {
    await _client.delete(ApiConfig.offer(offerId));
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) async {
    // No explicit transaction support in API usually
    return await action();
  }
}
