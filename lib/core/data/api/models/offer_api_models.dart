import 'package:freezed_annotation/freezed_annotation.dart';
import 'auth_api_models.dart';
import 'catch_api_models.dart';

part 'offer_api_models.freezed.dart';
part 'offer_api_models.g.dart';

@freezed
class OfferApiModel with _$OfferApiModel {
  const factory OfferApiModel({
    required dynamic id,
    @JsonKey(name: 'catch_id')
    dynamic catchId, // ID or object? Assume object if expanded
    @JsonKey(name: 'fisher_id') dynamic fisherId,
    @JsonKey(name: 'buyer_id') dynamic buyerId,

    // Or full objects if API returns them
    CatchApiModel? catchDetails,
    AccountApiModel? fisher,
    AccountApiModel? buyer,

    @JsonKey(name: 'current_price_amount') int? currentPriceAmount,
    @JsonKey(name: 'current_weight_grams') int? currentWeightGrams,
    @JsonKey(name: 'current_price_per_kg_amount') int? currentPricePerKgAmount,

    @JsonKey(name: 'previous_price_amount') int? previousPriceAmount,
    @JsonKey(name: 'previous_weight_grams') int? previousWeightGrams,
    @JsonKey(name: 'previous_price_per_kg_amount')
    int? previousPricePerKgAmount,

    String? status,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _OfferApiModel;

  factory OfferApiModel.fromJson(Map<String, dynamic> json) =>
      _$OfferApiModelFromJson(json);
}

@freezed
class CreateOfferRequest with _$CreateOfferRequest {
  const factory CreateOfferRequest({
    @JsonKey(name: 'catch_id') required String catchId,
    @JsonKey(name: 'price_amount') required int priceAmount,
    @JsonKey(name: 'weight_grams') required int weightGrams,
    @JsonKey(name: 'price_per_kg_amount') required int pricePerKgAmount,
  }) = _CreateOfferRequest;

  factory CreateOfferRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateOfferRequestFromJson(json);
}
