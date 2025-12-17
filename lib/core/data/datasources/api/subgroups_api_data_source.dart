import 'package:siren_marketplace/core/data/api/api_client.dart';
import 'package:siren_marketplace/core/data/api/models/subgroup_api_models.dart';

/// Data source for fetching market subgroups
class SubgroupsApiDataSource {
  final ApiClient _client;

  SubgroupsApiDataSource(this._client);

  /// Fetch subgroups for a specific market
  Future<List<SubgroupModel>> getMarketSubgroups(int marketId) async {
    final response = await _client.get('/markets/$marketId/subgroups');

    if (response.statusCode == 200) {
      final responseModel = SubgroupsResponseModel.fromJson(response.data);
      return responseModel.data.subgroups;
    } else {
      throw Exception('Failed to load subgroups: ${response.statusCode}');
    }
  }
}
