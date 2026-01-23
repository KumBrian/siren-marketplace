import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_statistics_model.freezed.dart';
part 'account_statistics_model.g.dart';

/// Model for account statistics from /accounts/my-statistics endpoint
@freezed
class AccountStatisticsModel with _$AccountStatisticsModel {
  const factory AccountStatisticsModel({
    /// Total turnover amount
    @Default(0) int turnover,

    /// Currency code (e.g., "CFA")
    @Default('CFA') String currency,

    /// Total number of sales
    @Default(0) int totalSales,

    /// Number of active products in marketplace
    @Default(0) int activeProducts,

    /// Number of completed orders
    @Default(0) int completedOrders,

    /// Total number of catches
    @Default(0) int totalCatches,

    /// Statistics period (e.g., "monthly")
    @Default('monthly') String period,

    /// Average rating score
    @Default(0.0) double averageRating,

    /// Total number of reviews
    @Default(0) int totalReviews,

    /// Distribution of ratings by star count
    /// Keys are "1", "2", "3", "4", "5"; values are counts
    @Default({}) Map<String, int> ratingDistribution,
  }) = _AccountStatisticsModel;

  factory AccountStatisticsModel.fromJson(Map<String, dynamic> json) =>
      _$AccountStatisticsModelFromJson(json);
}
