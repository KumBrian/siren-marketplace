// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_statistics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AccountStatisticsModelImpl _$$AccountStatisticsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AccountStatisticsModelImpl(
      turnover: (json['turnover'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'CFA',
      totalSales: (json['totalSales'] as num?)?.toInt() ?? 0,
      activeProducts: (json['activeProducts'] as num?)?.toInt() ?? 0,
      completedOrders: (json['completedOrders'] as num?)?.toInt() ?? 0,
      totalCatches: (json['totalCatches'] as num?)?.toInt() ?? 0,
      period: json['period'] as String? ?? 'monthly',
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      ratingDistribution:
          (json['ratingDistribution'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, (e as num).toInt()),
              ) ??
              const {},
    );

Map<String, dynamic> _$$AccountStatisticsModelImplToJson(
        _$AccountStatisticsModelImpl instance) =>
    <String, dynamic>{
      'turnover': instance.turnover,
      'currency': instance.currency,
      'totalSales': instance.totalSales,
      'activeProducts': instance.activeProducts,
      'completedOrders': instance.completedOrders,
      'totalCatches': instance.totalCatches,
      'period': instance.period,
      'averageRating': instance.averageRating,
      'totalReviews': instance.totalReviews,
      'ratingDistribution': instance.ratingDistribution,
    };
