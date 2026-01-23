import '../../api/api_client.dart';
import '../../api/api_config.dart';
import '../../api/models/species_api_models.dart';

class SpeciesApiDataSource {
  final ApiClient _client;

  SpeciesApiDataSource({required ApiClient client}) : _client = client;

  /// Fetch all species from API
  Future<List<SpeciesApiModel>> fetchSpecies({
    int page = 1,
    int itemsPerPage = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiConfig.speciesList,
        queryParameters: {'page': page, 'itemsPerPage': itemsPerPage},
      );

      final speciesResponse = SpeciesListResponse.fromJson(response.data);
      final species = speciesResponse.data.member;

      return species;
    } catch (e) {
      print('ERROR: Failed to fetch species: $e');
      rethrow;
    }
  }
}
