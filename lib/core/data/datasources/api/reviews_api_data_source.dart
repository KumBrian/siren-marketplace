import '../../api/api_client.dart';
import '../../api/models/review_api_models.dart';

import '../../api/api_config.dart';

class ReviewsApiDataSource {
  final ApiClient _client;

  ReviewsApiDataSource(this._client);

  Future<ReviewApiResponse> create(ReviewApiRequest request) async {
    final response = await _client.post(
      ApiConfig.reviewsCreate,
      data: request.toJson(),
    );

    final data = response.data['data'] ?? response.data;
    return ReviewApiResponse.fromJson(data);
  }

  Future<List<ReviewApiResponse>> getReviewsForAccount(int accountId) async {
    final response = await _client.get(ApiConfig.reviewsForAccount(accountId));

    final data = response.data['data']['member'] as List;
    return data
        .map((e) => ReviewApiResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
