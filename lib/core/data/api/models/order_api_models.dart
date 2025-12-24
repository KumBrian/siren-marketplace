import 'package:freezed_annotation/freezed_annotation.dart';
import 'product_api_models.dart';

part 'order_api_models.freezed.dart';
part 'order_api_models.g.dart';

@freezed
class OrderApiModel with _$OrderApiModel {
  const factory OrderApiModel({
    required dynamic id, // ID can be int in JSON
    @JsonKey(name: 'review') dynamic review, // Can be object or null
    @JsonKey(name: 'orderNumber') String? orderNumber,
    @JsonKey(name: 'cancellationReason') String? cancellationReason,
    String? status,
    bool? completed,

    // Order terms
    @JsonKey(name: 'terms_price') int? termsPrice,
    @JsonKey(name: 'terms_weight') int? termsWeight,
    @JsonKey(name: 'terms_price_per_kg') int? termsPricePerKg,

    // Review tracking
    @JsonKey(name: 'has_review_from_fisher')
    @Default(false)
    bool hasReviewFromFisher,
    @JsonKey(name: 'has_review_from_buyer')
    @Default(false)
    bool hasReviewFromBuyer,

    // Embedded product data
    ProductApiModel? product,

    // Embedded buyer data (will be mapped manually in mapper)
    dynamic buyer,

    // Timestamps
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    String? uid,
  }) = _OrderApiModel;

  factory OrderApiModel.fromJson(Map<String, dynamic> json) =>
      _$OrderApiModelFromJson(json);
}
