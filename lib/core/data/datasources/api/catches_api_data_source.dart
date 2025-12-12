import 'dart:io';
import '../../../../core/data/api/api_client.dart';
import '../../../../core/data/api/api_config.dart';
import '../../../../core/data/api/models/catch_api_models.dart';
import '../../../../core/data/mappers/catch_api_mapper.dart';
import '../../models/catch_model.dart';
import '../../../domain/enums/catch_status.dart';
import '../interfaces/i_catch_datasource.dart';
import 'media_api_data_source.dart';
import 'species_api_data_source.dart';

import '../../../domain/entities/species.dart';

class CatchesApiDataSource implements ICatchDataSource {
  final ApiClient _client;
  final MediaApiDataSource _mediaDataSource;
  final SpeciesApiDataSource _speciesDataSource;

  // Cache species in memory
  List<Species>? _cachedSpecies;

  // In-memory cache for catches
  final Map<String, CatchModel> _catchCache = {};

  // Media server base URL for image prefixes
  static const String _mediaBaseUrl =
      'https://api.pulsebox.dev.siren.dhi-cm.com';

  CatchesApiDataSource({
    required ApiClient client,
    required MediaApiDataSource mediaDataSource,
    required SpeciesApiDataSource speciesDataSource,
  }) : _client = client,
       _mediaDataSource = mediaDataSource,
       _speciesDataSource = speciesDataSource;

  /// Fetch and cache species list
  Future<List<Species>> _getSpecies() async {
    if (_cachedSpecies != null) {
      return _cachedSpecies!;
    }

    try {
      print('DEBUG: Fetching species for catch mapping...');
      final apiSpecies = await _speciesDataSource.fetchSpecies(
        itemsPerPage: 100,
      );
      _cachedSpecies = apiSpecies.map((api) {
        return Species(
          id: api.uid,
          uid: api.uid,
          name: api.name,
          image: api.mediaReference ?? '',
          scientificName: '',
        );
      }).toList();
      print('DEBUG: Cached ${_cachedSpecies!.length} species for mapping');
      return _cachedSpecies!;
    } catch (e) {
      print('WARNING: Failed to fetch species: $e');
      return [];
    }
  }

  @override
  Future<String> create(CatchModel catchItem) async {
    try {
      List<String> imageUrls = [];

      // Step 1: Upload images to Pulsebox if any
      if (catchItem.images.isNotEmpty) {
        print(
          'DEBUG: Step 1 - Uploading ${catchItem.images.length} images to Pulsebox',
        );

        // Filter out asset images (placeholders) and convert paths to Files
        final realImagePaths = catchItem.images
            .where((path) => !path.startsWith('assets/'))
            .toList();

        if (realImagePaths.isNotEmpty) {
          final imageFiles = realImagePaths.map((path) => File(path)).toList();

          try {
            final uploadResults = await _mediaDataSource.uploadImages(
              imageFiles,
            );
            print(
              'DEBUG: Successfully uploaded ${uploadResults.length} images',
            );

            // Extract storageFilePath from each upload result
            imageUrls = uploadResults
                .map((result) => result.storageFilePath)
                .whereType<String>() // Filter out nulls
                .toList();

            print('DEBUG: Extracted image URLs: $imageUrls');
          } catch (e) {
            print('ERROR: Image upload failed: $e');
            throw Exception('Failed to upload images: $e');
          }
        } else {
          print('DEBUG: No real images to upload (only placeholders)');
        }
      }

      // Step 2: Create catch with image URLs
      print('DEBUG: Step 2 - Creating catch on Marketplace API');

      final request = CatchApiMapper.toCreateRequest(
        catchItem,
        imageUrls: imageUrls,
      );

      print('DEBUG: Catch request: ${request.toJson()}');

      final response = await _client.post(
        ApiConfig.fishCatchesCreate,
        data: request.toJson(),
      );

      print('DEBUG: Catch creation response status: ${response.statusCode}');

      // Extract ID from response
      final data = response.data['data'] ?? response.data;
      final id = data['id'].toString();

      print('DEBUG: Catch created successfully with ID: $id');

      // Invalidate cache since we created a new catch
      _clearCache();

      return id;
    } catch (e) {
      print('ERROR: Failed to create catch: $e');
      rethrow;
    }
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
      final species = await _getSpecies();
      final catchModel = CatchApiMapper.toDomain(
        apiModel,
        speciesList: species,
      );

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

    final species = await _getSpecies();
    final catches = data.map((json) {
      final prefixedJson = _prefixImageUrls(json);
      return CatchApiMapper.toDomain(
        CatchApiModel.fromJson(prefixedJson),
        speciesList: species,
      );
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

    final species = await _getSpecies();
    final catches = data.map((json) {
      final prefixedJson = _prefixImageUrls(json);
      return CatchApiMapper.toDomain(
        CatchApiModel.fromJson(prefixedJson),
        speciesList: species,
      );
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

    final species = await _getSpecies();
    final catches = data.map((json) {
      final prefixedJson = _prefixImageUrls(json);
      return CatchApiMapper.toDomain(
        CatchApiModel.fromJson(prefixedJson),
        speciesList: species,
      );
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
