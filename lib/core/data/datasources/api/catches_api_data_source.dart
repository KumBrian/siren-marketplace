import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/data/api/api_client.dart';
import '../../../../core/data/api/api_config.dart';
import '../../../../core/data/api/models/catch_api_models.dart';
import '../../../../core/data/mappers/catch_api_mapper.dart';
import '../../models/catch_model.dart';
import '../../../domain/enums/catch_status.dart';
import '../interfaces/i_catch_datasource.dart';
import 'media_api_data_source.dart';
import 'subgroups_api_data_source.dart';
import '../../mappers/subgroup_mapper.dart';

import '../../../domain/entities/species.dart';

class CatchesApiDataSource implements ICatchDataSource {
  @override
  Future<void> saveBatch(List<CatchModel> catches) async =>
      throw UnimplementedError();

  final ApiClient _client;
  final MediaApiDataSource _mediaDataSource;
  final SubgroupsApiDataSource _subgroupsDataSource;

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
    required SubgroupsApiDataSource subgroupsDataSource,
  }) : _client = client,
       _mediaDataSource = mediaDataSource,
       _subgroupsDataSource = subgroupsDataSource;

  /// Fetch and cache species list from subgroups
  Future<List<Species>> _getSpecies() async {
    if (_cachedSpecies != null) {
      return _cachedSpecies!;
    }

    try {
      // Fetching species from subgroups for catch mapping...

      final subgroupModels = await _subgroupsDataSource.getMarketSubgroups(1);
      final subgroups = SubgroupMapper.toDomainList(subgroupModels);

      // Flatten all species from all subgroups
      _cachedSpecies = subgroups
          .expand((subgroup) => subgroup.species)
          .map(
            (subgroupSpecies) => Species(
              id: subgroupSpecies.id.toString(),
              uid: subgroupSpecies.id.toString(),
              name: subgroupSpecies.name,
              image: subgroupSpecies.imageUrl,
              scientificName: '',
            ),
          )
          .toList();
      // Cached species for mapping

      return _cachedSpecies!;
    } catch (e) {
      print('WARNING: Failed to fetch species from subgroups: $e');
      return [];
    }
  }

  @override
  Future<String> create(CatchModel catchItem) async {
    try {
      List<String> imageUrls = [];

      // Step 1: Upload images to Pulsebox if any
      if (catchItem.images.isNotEmpty) {
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

            // Extract storageFilePath from each upload result
            imageUrls = uploadResults
                .map((result) => result.storageFilePath)
                .whereType<String>() // Filter out nulls
                .toList();
          } catch (e) {
            print('ERROR: Image upload failed: $e');
            throw Exception('Failed to upload images: $e');
          }
        } else {}
      }

      // Step 2: Create catch with image URLs

      final request = CatchApiMapper.toCreateRequest(
        catchItem,
        imageUrls: imageUrls,
      );

      final response = await _client.post(
        ApiConfig.fishCatchesCreate,
        data: request.toJson(),
      );

      // Extract ID from response
      final data = response.data['data'] ?? response.data;
      final id = data['id'].toString();

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
      // Cache HIT for catch

      return _catchCache[catchId];
    }

    // Cache MISS for catch, fetching from API

    try {
      final url = ApiConfig.fishCatch(catchId);

      final response = await _client.get(url);

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

    // Fetched catches from my-fish-catches

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
      // Cached catch
    }
    // Cache now has catches

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

  // Callback for invalidating providers after update
  Function()? _onCatchPublished;

  /// Set callback to be called when a catch is published to marketplace
  /// This should invalidate both catch and product providers
  void setOnCatchPublishedCallback(Function() callback) {
    _onCatchPublished = callback;
  }

  @override
  Future<void> update(CatchModel catchItem) async {
    try {
      // Handle images similar to create: upload new files if any
      // Note: For update, we might have mixed URLs and File paths.
      // EXISTING URLs should be preserved.
      // NEW Files should be uploaded and replaced with URLs.

      List<String> finalImageUrls = [];
      List<File> newImagesToUpload = [];

      // Identify existing URLs vs new Files
      for (final path in catchItem.images) {
        if (path.startsWith('http')) {
          finalImageUrls.add(path);
        } else if (!path.startsWith('assets/')) {
          // It's a file path
          newImagesToUpload.add(File(path));
        }
      }

      // Upload new images
      if (newImagesToUpload.isNotEmpty) {
        try {
          final uploadResults = await _mediaDataSource.uploadImages(
            newImagesToUpload,
          );
          final newUrls = uploadResults
              .map((result) => result.storageFilePath)
              .whereType<String>()
              .toList();
          finalImageUrls.addAll(newUrls);
        } catch (e) {
          print('ERROR: Image upload failed during update: $e');
          // We might want to abort or continue? Abort safe.
          throw Exception('Failed to upload new images: $e');
        }
      }

      // Use Full Update request body
      final requestBody = CatchApiMapper.toUpdateRequest(
        catchItem,
        imageUrls: finalImageUrls,
      );

      final url = ApiConfig.fishCatchUpdate(catchItem.id);

      final response = await _client.patch(
        url,
        data: requestBody,
        options: Options(contentType: 'application/merge-patch+json'),
      );

      // Check if response contains both fishCatch and product (publish to marketplace)
      final responseData = response.data['data'] ?? response.data;

      if (responseData is Map && responseData.containsKey('product')) {
        // Catch published to marketplace! Product created.

        // Parse the update response
        try {
          UpdateCatchResponse.fromJson(Map<String, dynamic>.from(responseData));

          // Trigger the callback to invalidate both catch and product providers
          if (_onCatchPublished != null) {
            // Triggering provider invalidation callback

            _onCatchPublished!();
          } else {
            print('WARNING: No callback set for catch published event');
          }
        } catch (e) {
          print('ERROR: Failed to parse UpdateCatchResponse: $e');
        }
      }

      // Invalidate cache
      _catchCache.remove(catchItem.id);
    } catch (e) {
      print('ERROR: Failed to update catch: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String catchId) async {
    await _client.delete(ApiConfig.fishCatchDelete(catchId));

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
    // Cache cleared
  }
}
