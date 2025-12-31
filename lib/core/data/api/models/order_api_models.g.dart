// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderApiModelImpl _$$OrderApiModelImplFromJson(Map<String, dynamic> json) =>
    _$OrderApiModelImpl(
      id: json['id'],
      orderNumber: json['orderNumber'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      status: json['status'] as String?,
      completed: json['completed'] as bool?,
      termsPrice: (json['terms_price'] as num?)?.toInt(),
      termsWeight: (json['terms_weight'] as num?)?.toInt(),
      termsPricePerKg: (json['terms_price_per_kg'] as num?)?.toInt(),
      hasReviewFromFisher: json['has_review_from_fisher'] as bool? ?? false,
      hasReviewFromBuyer: json['has_review_from_buyer'] as bool? ?? false,
      buyerReview: json['buyerReview'],
      fisherReview: json['fisherReview'],
      product: json['product'] == null
          ? null
          : ProductApiModel.fromJson(json['product'] as Map<String, dynamic>),
      buyer: json['buyer'],
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      uid: json['uid'] as String?,
    );

Map<String, dynamic> _$$OrderApiModelImplToJson(_$OrderApiModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'cancellationReason': instance.cancellationReason,
      'status': instance.status,
      'completed': instance.completed,
      'terms_price': instance.termsPrice,
      'terms_weight': instance.termsWeight,
      'terms_price_per_kg': instance.termsPricePerKg,
      'has_review_from_fisher': instance.hasReviewFromFisher,
      'has_review_from_buyer': instance.hasReviewFromBuyer,
      'buyerReview': instance.buyerReview,
      'fisherReview': instance.fisherReview,
      'product': instance.product?.toJson(),
      'buyer': instance.buyer,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'uid': instance.uid,
    };
