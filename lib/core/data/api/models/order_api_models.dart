import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_api_models.freezed.dart';
part 'order_api_models.g.dart';

@freezed
class OrderApiModel with _$OrderApiModel {
  const factory OrderApiModel({
    required dynamic id, // ID can be int in JSON
    @JsonKey(name: 'review') dynamic review, // Can be object or string URI
    String? orderNumber,
    String? cancellationReason,
    String? status,
    bool? completed,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    String? uid,
  }) = _OrderApiModel;

  factory OrderApiModel.fromJson(Map<String, dynamic> json) =>
      _$OrderApiModelFromJson(json);
}
