// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer_api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OfferApiModelImpl _$$OfferApiModelImplFromJson(
  Map<String, dynamic> json,
) => _$OfferApiModelImpl(
  id: json['id'],
  product: json['product'] == null
      ? null
      : ProductApiModel.fromJson(json['product'] as Map<String, dynamic>),
  buyer: json['buyer'] == null
      ? null
      : AccountApiModel.fromJson(json['buyer'] as Map<String, dynamic>),
  currentPriceAmount: (json['currentPriceAmount'] as num?)?.toInt(),
  currentWeightGrams: (json['currentWeightGrams'] as num?)?.toInt(),
  currentPricePerKgAmount: (json['currentPricePerKgAmount'] as num?)?.toInt(),
  previousPriceAmount: (json['previousPriceAmount'] as num?)?.toInt(),
  previousWeightGrams: (json['previousWeightGrams'] as num?)?.toInt(),
  previousPricePerKgAmount: (json['previousPricePerKgAmount'] as num?)?.toInt(),
  saleOrder: json['saleOrder'] as Map<String, dynamic>?,
  status: json['status'] as String?,
  waitingFor: json['waiting_for'] as String?,
  hasUpdateForFisher: json['has_update_for_fisher'] as bool?,
  hasUpdateForBuyer: json['has_update_for_buyer'] as bool?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$$OfferApiModelImplToJson(_$OfferApiModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product': instance.product?.toJson(),
      'buyer': instance.buyer?.toJson(),
      'currentPriceAmount': instance.currentPriceAmount,
      'currentWeightGrams': instance.currentWeightGrams,
      'currentPricePerKgAmount': instance.currentPricePerKgAmount,
      'previousPriceAmount': instance.previousPriceAmount,
      'previousWeightGrams': instance.previousWeightGrams,
      'previousPricePerKgAmount': instance.previousPricePerKgAmount,
      'saleOrder': instance.saleOrder,
      'status': instance.status,
      'waiting_for': instance.waitingFor,
      'has_update_for_fisher': instance.hasUpdateForFisher,
      'has_update_for_buyer': instance.hasUpdateForBuyer,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_$CreateOfferRequestImpl _$$CreateOfferRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateOfferRequestImpl(
  product: json['product'],
  weightInGrams: (json['weight_in_grams'] as num).toDouble(),
  price: (json['price'] as num).toDouble(),
  pricePerKg: (json['price_per_kg'] as num).toDouble(),
);

Map<String, dynamic> _$$CreateOfferRequestImplToJson(
  _$CreateOfferRequestImpl instance,
) => <String, dynamic>{
  'product': instance.product,
  'weight_in_grams': instance.weightInGrams,
  'price': instance.price,
  'price_per_kg': instance.pricePerKg,
};

_$CounterOfferRequestImpl _$$CounterOfferRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CounterOfferRequestImpl(
  weightInGrams: (json['weight_in_grams'] as num).toDouble(),
  price: (json['price'] as num).toDouble(),
  pricePerKg: (json['price_per_kg'] as num).toDouble(),
);

Map<String, dynamic> _$$CounterOfferRequestImplToJson(
  _$CounterOfferRequestImpl instance,
) => <String, dynamic>{
  'weight_in_grams': instance.weightInGrams,
  'price': instance.price,
  'price_per_kg': instance.pricePerKg,
};

_$OfferResponseRequestImpl _$$OfferResponseRequestImplFromJson(
  Map<String, dynamic> json,
) => _$OfferResponseRequestImpl(
  action: json['action'] as String,
  message: json['message'] as String,
);

Map<String, dynamic> _$$OfferResponseRequestImplToJson(
  _$OfferResponseRequestImpl instance,
) => <String, dynamic>{'action': instance.action, 'message': instance.message};
