// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer_api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OfferApiModelImpl _$$OfferApiModelImplFromJson(Map<String, dynamic> json) =>
    _$OfferApiModelImpl(
      id: json['id'],
      catchId: json['catch_id'],
      fisherId: json['fisher_id'],
      buyerId: json['buyer_id'],
      catchDetails: json['catchDetails'] == null
          ? null
          : CatchApiModel.fromJson(
              json['catchDetails'] as Map<String, dynamic>,
            ),
      fisher: json['fisher'] == null
          ? null
          : AccountApiModel.fromJson(json['fisher'] as Map<String, dynamic>),
      buyer: json['buyer'] == null
          ? null
          : AccountApiModel.fromJson(json['buyer'] as Map<String, dynamic>),
      currentPriceAmount: (json['current_price_amount'] as num?)?.toInt(),
      currentWeightGrams: (json['current_weight_grams'] as num?)?.toInt(),
      currentPricePerKgAmount: (json['current_price_per_kg_amount'] as num?)
          ?.toInt(),
      previousPriceAmount: (json['previous_price_amount'] as num?)?.toInt(),
      previousWeightGrams: (json['previous_weight_grams'] as num?)?.toInt(),
      previousPricePerKgAmount: (json['previous_price_per_kg_amount'] as num?)
          ?.toInt(),
      status: json['status'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$OfferApiModelImplToJson(_$OfferApiModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'catch_id': instance.catchId,
      'fisher_id': instance.fisherId,
      'buyer_id': instance.buyerId,
      'catchDetails': instance.catchDetails,
      'fisher': instance.fisher,
      'buyer': instance.buyer,
      'current_price_amount': instance.currentPriceAmount,
      'current_weight_grams': instance.currentWeightGrams,
      'current_price_per_kg_amount': instance.currentPricePerKgAmount,
      'previous_price_amount': instance.previousPriceAmount,
      'previous_weight_grams': instance.previousWeightGrams,
      'previous_price_per_kg_amount': instance.previousPricePerKgAmount,
      'status': instance.status,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_$CreateOfferRequestImpl _$$CreateOfferRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateOfferRequestImpl(
  catchId: json['catch_id'] as String,
  priceAmount: (json['price_amount'] as num).toInt(),
  weightGrams: (json['weight_grams'] as num).toInt(),
  pricePerKgAmount: (json['price_per_kg_amount'] as num).toInt(),
);

Map<String, dynamic> _$$CreateOfferRequestImplToJson(
  _$CreateOfferRequestImpl instance,
) => <String, dynamic>{
  'catch_id': instance.catchId,
  'price_amount': instance.priceAmount,
  'weight_grams': instance.weightGrams,
  'price_per_kg_amount': instance.pricePerKgAmount,
};
