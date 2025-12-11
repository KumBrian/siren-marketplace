import 'dart:io';
import 'package:dio/dio.dart';

/// Standalone script to seed species data to the Marketplace API
/// Run with: dart run scripts/seed_species.dart
///
/// This script:
/// 1. Reads species data (name, scientific name, image path)
/// 2. Creates each species via POST /api/v1/species/create
/// 3. Prints the returned UUIDs for each species
///
/// You'll need to update the Species model with the returned UUIDs

void main() async {
  print('=== Species Seeding Script ===\n');

  // API Configuration
  const apiBaseUrl = 'https://api.marketplace.dev.siren.dhi-cm.com/api/v1';
  const token =
      'YOUR_JWT_TOKEN_HERE'; // Replace with actual JWT token from login

  // Create Dio client
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Species data to seed
  final speciesData = [
    {
      'name': 'Prawn',
      'scientificName': 'Panaeus Monodon',
      'slug': 'prawn',
      'imagePath': 'assets/shrimp-species/prawn.png',
      'mediaReference':
          'assets/shrimp-species/prawn.png', // Can use asset path as reference
    },
    {
      'name': 'Grey Shrimp',
      'scientificName': 'Crevette Grise',
      'slug': 'grey-shrimp',
      'imagePath': 'assets/shrimp-species/grey-shrimp.png',
      'mediaReference': 'assets/shrimp-species/grey-shrimp.png',
    },
    {
      'name': 'Pink Shrimp',
      'scientificName': 'Crevette Rose',
      'slug': 'pink-shrimp',
      'imagePath': 'assets/shrimp-species/pink-shrimp.png',
      'mediaReference': 'assets/shrimp-species/pink-shrimp.png',
    },
    {
      'name': 'Tiger Shrimp',
      'scientificName': 'Crevette Tiger',
      'slug': 'tiger-shrimp',
      'imagePath': 'assets/shrimp-species/tiger-shrimp.png',
      'mediaReference': 'assets/shrimp-species/tiger-shrimp.png',
    },
  ];

  final createdSpecies = <Map<String, dynamic>>[];

  // Create each species
  for (final species in speciesData) {
    try {
      print('Creating species: ${species['name']}...');

      // Build request body based on API spec
      // Adjust fields based on actual API requirements
      final requestBody = {
        'name': species['name'],
        'scientificName': species['scientificName'],
        'mediaReference': species['mediaReference'],
        // Add other required fields here based on API spec
      };

      final response = await dio.post('/species/create', data: requestBody);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        final uuid = data['uid'] ?? data['id'] ?? data['uuid'];

        print('✅ Created: ${species['name']}');
        print('   UUID: $uuid');
        print('   Slug: ${species['slug']}\n');

        createdSpecies.add({
          'name': species['name'],
          'slug': species['slug'],
          'uuid': uuid,
          'data': data,
        });
      } else {
        print('❌ Failed: ${species['name']} - Status: ${response.statusCode}');
        print('   Response: ${response.data}\n');
      }
    } catch (e) {
      print('❌ Error creating ${species['name']}: $e\n');
      if (e is DioException) {
        print('   Response: ${e.response?.data}');
        print('   Status: ${e.response?.statusCode}\n');
      }
    }

    // Small delay to avoid rate limiting
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Print summary
  print('\n=== Summary ===');
  print(
    'Created ${createdSpecies.length} out of ${speciesData.length} species\n',
  );

  if (createdSpecies.isNotEmpty) {
    print('Species UUID Mapping (add to Species model):');
    print('=' * 60);
    for (final species in createdSpecies) {
      print('${species['slug']}: ${species['uuid']}');
    }
    print('=' * 60);

    print('\nUpdate SeederData.speciesList with these UUIDs:');
    print('const SpeciesModel(');
    print('  id: "SLUG",  // Keep for backward compatibility');
    print('  uid: "UUID", // Add this field');
    print('  name: "...",');
    print('  ...');
    print(')');
  }

  exit(0);
}
