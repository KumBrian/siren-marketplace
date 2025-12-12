import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../di/injector.dart';
import '../data/api/api_client.dart';
import '../data/datasources/api/species_api_data_source.dart';
import '../domain/entities/species.dart';
import '../data/models/species_model.dart';

/// Cache key for species data
const String _speciesCacheKey = 'cached_species_list';
const String _speciesTimestampKey = 'species_cache_timestamp';

/// Cache duration (2 days)
const Duration _cacheDuration = Duration(days: 2);

/// Provider for species API data source
final speciesApiDataSourceProvider = Provider<SpeciesApiDataSource>((ref) {
  final apiClient = sl<ApiClient>();
  return SpeciesApiDataSource(client: apiClient);
});

/// Provider that fetches and caches species from API
final speciesProvider = FutureProvider<List<Species>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final apiDataSource = ref.read(speciesApiDataSourceProvider);

  // Check cache first
  final cachedJson = prefs.getString(_speciesCacheKey);
  final timestampMs = prefs.getInt(_speciesTimestampKey);

  if (cachedJson != null && timestampMs != null) {
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final now = DateTime.now();

    // Check if cache is still valid (less than 2 days old)
    if (now.difference(cacheTime) < _cacheDuration) {
      print(
        'DEBUG: Using cached species data (age: ${now.difference(cacheTime).inHours}h)',
      );

      try {
        final List<dynamic> jsonList = json.decode(cachedJson);
        final species = jsonList
            .map((json) => SpeciesModel.fromJson(json as Map<String, dynamic>))
            .toList()
            .cast<Species>();

        print('DEBUG: Loaded ${species.length} species from cache');
        return species;
      } catch (e) {
        print('ERROR: Failed to decode cached species: $e');
        // Continue to fetch from API
      }
    } else {
      print(
        'DEBUG: Cache expired (age: ${now.difference(cacheTime).inHours}h), fetching fresh data',
      );
    }
  }

  // Fetch from API
  try {
    print('DEBUG: Fetching species from API');
    final apiSpecies = await apiDataSource.fetchSpecies(itemsPerPage: 100);

    // Convert to Species entities
    final species = apiSpecies.map((api) {
      return Species(
        id: api.uid, // Use uid as id
        uid: api.uid,
        name: api.name,
        image: api.mediaReference ?? '', // Asset path from backend
        scientificName: '', // Not provided by API yet
      );
    }).toList();

    print('DEBUG: Fetched ${species.length} species from API');

    // Cache the data
    try {
      final jsonList = species.map((s) {
        return {
          'id': s.id,
          'uid': s.uid,
          'name': s.name,
          'image': s.image,
          'scientific_name': s.scientificName,
        };
      }).toList();

      await prefs.setString(_speciesCacheKey, json.encode(jsonList));
      await prefs.setInt(
        _speciesTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      print('DEBUG: Cached ${species.length} species for 2 days');
    } catch (e) {
      print('ERROR: Failed to cache species: $e');
      // Continue anyway, we have the data
    }

    return species;
  } catch (e) {
    print('ERROR: Failed to fetch species from API: $e');

    // Try to return cached data even if expired as fallback
    if (cachedJson != null) {
      print('DEBUG: API failed, using expired cache as fallback');
      try {
        final List<dynamic> jsonList = json.decode(cachedJson);
        return jsonList
            .map((json) => SpeciesModel.fromJson(json as Map<String, dynamic>))
            .toList()
            .cast<Species>();
      } catch (cacheError) {
        print('ERROR: Failed to use cached fallback: $cacheError');
      }
    }

    // Return empty list if all fails
    return [];
  }
});

/// Helper to get species by uid
Species? getSpeciesByUid(List<Species> species, String uid) {
  try {
    return species.firstWhere((s) => s.uid == uid);
  } catch (e) {
    return null;
  }
}
