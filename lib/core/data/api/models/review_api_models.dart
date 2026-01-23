import 'package:freezed_annotation/freezed_annotation.dart';
import 'auth_api_models.dart';

part 'review_api_models.freezed.dart';
part 'review_api_models.g.dart';

@freezed
class ReviewApiRequest with _$ReviewApiRequest {
  const factory ReviewApiRequest({
    required int saleOrder,
    required double rate,
    required String message,
    required bool published,
  }) = _ReviewApiRequest;

  factory ReviewApiRequest.fromJson(Map<String, dynamic> json) =>
      _$ReviewApiRequestFromJson(json);
}

@freezed
class ReviewApiResponse with _$ReviewApiResponse {
  const factory ReviewApiResponse({
    required dynamic id,
    required num rate,
    required String message,
    required bool published,
    @JsonKey(name: 'sale_order') dynamic? saleOrder,

    // User details
    AccountApiModel? reviewer,
    AccountApiModel? reviewedAccount,

    // Timestamps
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'deleted_at') String? deletedAt,
    String? uid,
  }) = _ReviewApiResponse;

  factory ReviewApiResponse.fromJson(Map<String, dynamic> json) =>
      _$ReviewApiResponseFromJson(json);
}
