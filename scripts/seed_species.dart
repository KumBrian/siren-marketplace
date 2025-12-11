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
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpYXQiOjE3NjU0NDY4MzEsImV4cCI6MTc2NTQ1MDQzMSwicm9sZXMiOlsiUk9MRV9VU0VSIl0sImVtYWlsIjoibmlyb3UwMDBAZ21haWwuY29tIiwidWlkIjoiYTNlOTUzOTUtMDE0MS00MGQ5LWIxMTgtOGU0MGVkZDE3MjEzIiwidXNlcm5hbWUiOm51bGwsInB1bHNlQm94QWNjZXNzVG9rZW4iOiI0NDE4ZDA0YS04YWI0LTQ1MzItYTIxMC0xNTE4YTBkYzkxM2QtMDYwNGY4N2ItMGIyYi00MTgzLWJjZTYtYmNhZmMzZWNhZmNkIiwibWFya2V0cGxhY2VBY2Nlc3NUb2tlbiI6ImExMjI2MTYzLTczMGEtNDk1MC1iYTM0LTdiODU2OTZhYzcwOS05NjNmMjZkMC0xYWQwLTRmZDUtOGUyNi01YzNiOWIwNzNhMmEiLCJ0b2tlbkV4cGlyZUF0IjoxNzY1NDUwNDI4fQ.cyvdaqyAoG8nooJrkwyY-9v7AliZx0T2PirNsvLP_d_00shdpsXf48D8xWSd84ZVbitEvILQ_yGxrmcJtx3wUhFInX7Xv_cG6VQiA2CC3WMdhnGtEzTnzSRTNgqSHEM3UfUuxX4dCFEXMV1QMwtL0w_Y-o2yKILqOK2VADYFxHrmNu0uK5Q4rPzFqFmw3c6bCdGxUcgUD_pqGcE8fQd43KnSAaCWeFiHYSfdfuCLcPn-MG9nuELwKJBRUpm2Vl-mKgEu0OtbjV1M8PvvLuXKCeiMN_QL71nI0rIou6-teJ9O1F5jiatyQbrGTMdOOxHvy-ymLfnLGmtOhm6-2ZkSSA'; // Replace with actual JWT token from login

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

      // Minimal request body - only required fields
      // Skip fishCatches and marketSpecies to avoid circular dependencies
      final requestBody = {
        'name': species['scientificName'], // Use scientific name as primary
        'mediaReference': species['mediaReference'],
        // Optional: add these if API allows them to be empty
        // 'fishCatches': [],
        // 'marketSpecies': [],
      };

      print('Request body: $requestBody');

      final response = await dio.post('/species/create', data: requestBody);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;
        // UUID is nested: {data: {uid: "...", ...}}
        final data = responseData['data'] as Map<String, dynamic>?;
        final uuid = data?['uid'] ?? data?['id'] ?? responseData['uid'];

        print('✅ Created: ${species['name']}');
        print('   UUID: $uuid');
        print('   Slug: ${species['slug']}');
        print('   Full response: $responseData\n');

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
        print('   Status: ${e.response?.statusCode}');
        print('   Response: ${e.response?.data}');
        print('   Message: ${e.message}\n');
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
