import '../../../../core/data/api/api_client.dart';
import '../../../../core/data/api/api_config.dart';
import '../../../../core/data/api/models/catch_api_models.dart';
import '../../../../core/data/mappers/catch_api_mapper.dart';
import '../../models/catch_model.dart';
import '../../../domain/enums/catch_status.dart';
import '../interfaces/i_catch_datasource.dart';

class CatchesApiDataSource implements ICatchDataSource {
  final ApiClient _client;

  CatchesApiDataSource({required ApiClient client}) : _client = client;

  @override
  Future<String> create(CatchModel catchItem) async {
    final request = CatchApiMapper.toRequest(catchItem);
    final response = await _client.post(
      ApiConfig.fishCatches,
      data: request.toJson(),
    );
    // Assuming response returns the created object or ID
    // If wrapped in 'data'
    final data = response.data['data'] ?? response.data;
    return data['id'].toString();
  }

  @override
  Future<CatchModel?> getById(String catchId) async {
    try {
      final response = await _client.get(ApiConfig.fishCatch(catchId));
      final data = response.data['data'] ?? response.data;
      final apiModel = CatchApiModel.fromJson(data);
      return CatchApiMapper.toDomain(apiModel);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<CatchModel>> getAll() async {
    final response = await _client.get(ApiConfig.fishCatches);
    final List data = response.data['data'] ?? [];
    return data
        .map((json) => CatchApiMapper.toDomain(CatchApiModel.fromJson(json)))
        .toList();
  }

  @override
  Future<List<CatchModel>> getMyCatches(String fisherId) async {
    // API uses token, ignores fisherId but interface requires it
    final response = await _client.get(
      ApiConfig.myFishCatches,
      queryParameters: {
        'page': 1,
        'itemsPerPage': 20, // Default to sensible limit
      },
    );
    final List data = response.data['data']['member'] ?? [];
    return data
        .map((json) => CatchApiMapper.toDomain(CatchApiModel.fromJson(json)))
        .toList();
  }

  @override
  Future<List<CatchModel>> getByFisherId(String fisherId) async {
    // In API mode, use the authenticated my-fish-catches endpoint
    // The fisherId parameter is ignored since API uses the token
    return await getMyCatches(fisherId);
  }

  @override
  Future<List<CatchModel>> getByStatus(CatchStatus status) async {
    // API might expect string status
    final statusStr = status.name; // 'available', 'soldOut', etc.
    final response = await _client.get(
      ApiConfig.fishCatches,
      queryParameters: {'status': statusStr},
    );
    final List data = response.data['data'] ?? [];
    return data
        .map((json) => CatchApiMapper.toDomain(CatchApiModel.fromJson(json)))
        .toList();
  }

  @override
  Future<void> update(CatchModel catchItem) async {
    // TODO: Implement update
    // PATCH /fish_catches/{id}
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String catchId) async {
    await _client.delete(ApiConfig.fishCatch(catchId));
  }

  @override
  Future<void> updateBatch(List<CatchModel> catches) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteBatch(List<String> catchIds) async {
    throw UnimplementedError();
  }
}
