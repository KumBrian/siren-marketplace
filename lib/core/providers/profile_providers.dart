import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/data/api/api_client.dart';
import 'package:siren_marketplace/core/data/api/api_config.dart';
import 'package:siren_marketplace/core/data/api/models/account_statistics_model.dart';
import 'package:siren_marketplace/core/data/api/models/auth_api_models.dart';
import 'package:siren_marketplace/core/di/injector.dart';

/// Provider for fetching the current user's full profile from /accounts/my-profile
/// Uses marketplace API client (not core API)
final myProfileProvider = FutureProvider.autoDispose<AccountApiModel>((
  ref,
) async {
  final client = sl<ApiClient>(instanceName: 'marketplaceApiClient');
  final response = await client.get(ApiConfig.myProfile);
  return AccountApiModel.fromJson(response.data['data']);
});

/// Provider for fetching the current user's statistics from /accounts/my-statistics
/// Uses marketplace API client (not core API)
final myStatisticsProvider = FutureProvider.autoDispose<AccountStatisticsModel>(
  (ref) async {
    final client = sl<ApiClient>(instanceName: 'marketplaceApiClient');
    final response = await client.get(ApiConfig.myStatistics);
    return AccountStatisticsModel.fromJson(response.data['data']);
  },
);
