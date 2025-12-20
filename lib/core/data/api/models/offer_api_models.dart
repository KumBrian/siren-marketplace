import 'package:freezed_annotation/freezed_annotation.dart';
import 'auth_api_models.dart';
import 'catch_api_models.dart';
import 'product_api_models.dart';

part 'offer_api_models.freezed.dart';
part 'offer_api_models.g.dart';

@freezed
class OfferApiModel with _$OfferApiModel {
  const factory OfferApiModel({
    required dynamic id,
    // API returns 'product' object which contains 'specie', 'account' etc.
    // 'product' is the new catch
    ProductApiModel? product,

    // API returns 'buyer' object
    AccountApiModel? buyer,

    // Field from API JSON "currentPriceAmount": 7000
    // Using camelCase keys as per JSON response
    int? currentPriceAmount,
    int? currentWeightGrams,
    int? currentPricePerKgAmount,

    // Previous values seem to use snake_case or mixed?
    // JSON: "previous_price": 90, "previousPriceAmount": 7500
    // We'll use the specific amount fields if available (camelCase ones)
    int? previousPriceAmount,
    int? previousWeightGrams,
    int? previousPricePerKgAmount,

    String? status,
    @JsonKey(name: 'waiting_for') String? waitingFor,
    @JsonKey(name: 'has_update_for_fisher') bool? hasUpdateForFisher,
    @JsonKey(name: 'has_update_for_buyer') bool? hasUpdateForBuyer,

    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _OfferApiModel;

  factory OfferApiModel.fromJson(Map<String, dynamic> json) =>
      _$OfferApiModelFromJson(json);
}

@freezed
class CreateOfferRequest with _$CreateOfferRequest {
  const factory CreateOfferRequest({
    // Request: "product": 1
    required dynamic product,
    // Request: "weight_in_grams": 10.5
    @JsonKey(name: 'weight_in_grams') required double weightInGrams,
    // Request: "price": 100
    required double price,
    // Request: "price_per_kg": 9.52
    @JsonKey(name: 'price_per_kg') required double pricePerKg,
  }) = _CreateOfferRequest;

  factory CreateOfferRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateOfferRequestFromJson(json);
}
