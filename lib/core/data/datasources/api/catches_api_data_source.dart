import '../../../../core/data/api/api_client.dart';
import '../../../../core/data/api/api_config.dart';
import '../../../../core/data/api/models/catch_api_models.dart';
import '../../../../core/data/mappers/catch_api_mapper.dart';
import '../../models/catch_model.dart';
import '../../../domain/enums/catch_status.dart';
import '../interfaces/i_catch_datasource.dart';

class CatchesApiDataSource implements ICatchDataSource {
  final ApiClient _client;

  // In-memory cache for catches
  final Map<String, CatchModel> _catchCache = {};

  // Media server base URL for image prefixes
  static const String _mediaBaseUrl =
      'https://api.pulsebox.dev.siren.dhi-cm.com';

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
    final id = data['id'].toString();

    // Invalidate cache since we created a new catch
    _clearCache();

    return id;
  }

  @override
  Future<CatchModel?> getById(String catchId) async {
    // Check cache first
    if (_catchCache.containsKey(catchId)) {
      print('DEBUG: Cache HIT for catch $catchId');
      return _catchCache[catchId];
    }

    print('DEBUG: Cache MISS for catch $catchId, fetching from API');

    try {
      final url = ApiConfig.fishCatch(catchId);
      print('DEBUG: Fetching catch by ID: $catchId');
      print('DEBUG: URL: $url');

      final response = await _client.get(url);

      print('DEBUG: Response status: ${response.statusCode}');

      final data = response.data['data'] ?? response.data;

      // Prefix image URLs
      final prefixedData = _prefixImageUrls(data);

      final apiModel = CatchApiModel.fromJson(prefixedData);
      final catchModel = CatchApiMapper.toDomain(apiModel);

      // Store in cache
      _catchCache[catchId] = catchModel;

      return catchModel;
    } catch (e) {
      print('DEBUG: Error fetching catch $catchId: $e');
      return null;
    }
  }

  @override
  Future<List<CatchModel>> getAll() async {
    final response = await _client.get(ApiConfig.fishCatches);
    final List data = response.data['data'] ?? [];

    final catches = data.map((json) {
      final prefixedJson = _prefixImageUrls(json);
      return CatchApiMapper.toDomain(CatchApiModel.fromJson(prefixedJson));
    }).toList();

    // Update cache
    for (var catch_ in catches) {
      _catchCache[catch_.id] = catch_;
    }

    return catches;
  }

  @override
  Future<List<CatchModel>> getMyCatches(String fisherId) async {
    // API uses token, ignores fisherId but interface requires it
    final response = await _client.get(
      ApiConfig.myFishCatches,
      queryParameters: {
        'page': 1,
        'itemsPerPage': 100, // Increase to get all user's catches
      },
    );
    final List data = response.data['data']['member'] ?? [];

    print('DEBUG: Fetched ${data.length} catches from my-fish-catches');

    final catches = data.map((json) {
      final prefixedJson = _prefixImageUrls(json);
      return CatchApiMapper.toDomain(CatchApiModel.fromJson(prefixedJson));
    }).toList();

    // Populate cache with all fetched catches
    _clearCache(); // Clear old cache first
    for (var catch_ in catches) {
      _catchCache[catch_.id] = catch_;
      print('DEBUG: Cached catch ${catch_.id}');
    }
    print('DEBUG: Cache now has ${_catchCache.length} catches');

    return catches;
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

    final catches = data.map((json) {
      final prefixedJson = _prefixImageUrls(json);
      return CatchApiMapper.toDomain(CatchApiModel.fromJson(prefixedJson));
    }).toList();

    // Update cache
    for (var catch_ in catches) {
      _catchCache[catch_.id] = catch_;
    }

    return catches;
  }

  @override
  Future<void> update(CatchModel catchItem) async {
    // TODO: Implement update
    // PATCH /fish-catches/{id}

    // Invalidate cache for this catch
    _catchCache.remove(catchItem.id);

    throw UnimplementedError();
  }

  @override
  Future<void> delete(String catchId) async {
    await _client.delete(ApiConfig.fishCatch(catchId));

    // Remove from cache
    _catchCache.remove(catchId);
  }

  @override
  Future<void> updateBatch(List<CatchModel> catches) async {
    // Invalidate cache
    _clearCache();
    throw UnimplementedError();
  }

  @override
  Future<void> deleteBatch(List<String> catchIds) async {
    // Remove from cache
    for (var id in catchIds) {
      _catchCache.remove(id);
    }
    throw UnimplementedError();
  }

  /// Prefix image URLs with media server base URL
  Map<String, dynamic> _prefixImageUrls(Map<String, dynamic> data) {
    final newData = Map<String, dynamic>.from(data);

    // Handle fishCatchImages array
    if (newData['fishCatchImages'] is List) {
      final images = newData['fishCatchImages'] as List;
      newData['fishCatchImages'] = images.map((img) {
        if (img is Map<String, dynamic> && img['imageUrl'] is String) {
          final imageUrl = img['imageUrl'] as String;
          // Only prefix if it's a relative URL
          if (!imageUrl.startsWith('http')) {
            img['imageUrl'] = '$_mediaBaseUrl/$imageUrl';
          }
        }
        return img;
      }).toList();
    }

    return newData;
  }

  /// Clear all cache
  void _clearCache() {
    _catchCache.clear();
    print('DEBUG: Cache cleared');
  }
}
