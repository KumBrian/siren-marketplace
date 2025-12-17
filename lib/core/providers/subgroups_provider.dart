import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../di/injector.dart';
import '../domain/entities/subgroup.dart';
import '../data/datasources/api/subgroups_api_data_source.dart';
import '../data/mappers/subgroup_mapper.dart';

/// Cache keys for subgroups data
const String _subgroupsCacheKey = 'cached_subgroups_list';
const String _subgroupsTimestampKey = 'subgroups_cache_timestamp';

/// Cache duration (2 days)
const Duration _cacheDuration = Duration(days: 2);

/// Provider for fetching market subgroups with caching
final subgroupsProvider = FutureProvider<List<Subgroup>>((ref) async {
  try {
    // Get SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final dataSource = sl<SubgroupsApiDataSource>();

    // Check cache first
    final cachedJson = prefs.getString(_subgroupsCacheKey);
    final timestampMs = prefs.getInt(_subgroupsTimestampKey);

    if (cachedJson != null && timestampMs != null) {
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestampMs);
      final now = DateTime.now();

      // Check if cache is still valid (less than 2 days old)
      if (now.difference(cacheTime) < _cacheDuration) {
        print(
          'DEBUG: Using cached subgroups data (age: ${now.difference(cacheTime).inHours}h)',
        );

        try {
          final Map<String, dynamic> cacheData = json.decode(cachedJson);
          final List<dynamic> subgroupsList = cacheData['subgroups'] ?? [];

          final subgroups = subgroupsList.map((subgroupJson) {
            final speciesList = (subgroupJson['species'] as List? ?? [])
                .map(
                  (speciesJson) => SubgroupSpecies(
                    id: speciesJson['id'] as int,
                    name: speciesJson['name'] as String,
                    imageUrl: speciesJson['imageUrl'] as String? ?? '',
                  ),
                )
                .toList();

            return Subgroup(
              name: subgroupJson['name'] as String,
              description: subgroupJson['description'] as String,
              species: speciesList,
            );
          }).toList();

          print('DEBUG: Loaded ${subgroups.length} subgroups from cache');
          return subgroups;
        } catch (e) {
          print('ERROR: Failed to decode cached subgroups: $e');
          // Continue to fetch from API
        }
      } else {
        print(
          'DEBUG: Cache expired (age: ${now.difference(cacheTime).inHours}h), fetching fresh data',
        );
      }
    } else {
      print('DEBUG: No cached subgroups found');
    }

    // Fetch from API
    print('DEBUG: Fetching subgroups from API...');
    final apiModels = await dataSource.getMarketSubgroups(1);
    final subgroups = SubgroupMapper.toDomainList(apiModels);
    print('DEBUG: Fetched ${subgroups.length} subgroups from API');

    // Cache the data
    try {
      final cacheData = {
        'subgroups': subgroups
            .map(
              (sg) => {
                'name': sg.name,
                'description': sg.description,
                'species': sg.species
                    .map(
                      (s) => {
                        'id': s.id,
                        'name': s.name,
                        'imageUrl': s.imageUrl,
                      },
                    )
                    .toList(),
              },
            )
            .toList(),
      };

      await prefs.setString(_subgroupsCacheKey, json.encode(cacheData));
      await prefs.setInt(
        _subgroupsTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      print('DEBUG: Cached ${subgroups.length} subgroups for 2 days');
    } catch (e) {
      print('ERROR: Failed to cache subgroups: $e');
      // Continue anyway, we have the data
    }

    return subgroups;
  } catch (e, stack) {
    print('ERROR: Failed to fetch subgroups: $e');
    print('STACK: $stack');

    // Try to return cached data even if expired as fallback
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(_subgroupsCacheKey);

    if (cachedJson != null) {
      print('DEBUG: API failed, using expired cache as fallback');
      try {
        final Map<String, dynamic> cacheData = json.decode(cachedJson);
        final List<dynamic> subgroupsList = cacheData['subgroups'] ?? [];

        final subgroups = subgroupsList.map((subgroupJson) {
          final speciesList = (subgroupJson['species'] as List? ?? [])
              .map(
                (speciesJson) => SubgroupSpecies(
                  id: speciesJson['id'] as int,
                  name: speciesJson['name'] as String,
                  imageUrl: speciesJson['imageUrl'] as String? ?? '',
                ),
              )
              .toList();

          return Subgroup(
            name: subgroupJson['name'] as String,
            description: subgroupJson['description'] as String,
            species: speciesList,
          );
        }).toList();

        return subgroups;
      } catch (cacheError) {
        print('ERROR: Failed to use cached fallback: $cacheError');
      }
    }

    // Return empty list if all fails
    print('ERROR: Returning empty list as final fallback');
    return [];
  }
});
