import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_api_models.freezed.dart';
part 'auth_api_models.g.dart';

/// Request model for authorization endpoint
@freezed
class AuthorizeRequest with _$AuthorizeRequest {
  const factory AuthorizeRequest({
    required String login,
    required String password,
  }) = _AuthorizeRequest;

  factory AuthorizeRequest.fromJson(Map<String, dynamic> json) =>
      _$AuthorizeRequestFromJson(json);
}

/// Response model from authorization endpoint
@freezed
class AuthorizeResponse with _$AuthorizeResponse {
  const AuthorizeResponse._(); // Added private constructor for getter

  const factory AuthorizeResponse({
    required String token,
    DateTime? tokenExpireAt,
    required dynamic id, // ID can be int
    required String email,
    String? firstName,
    String? lastName,
    String? username,
    String? phone,
    String? city,
    List<String>? roles,
  }) = _AuthorizeResponse;

  factory AuthorizeResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthorizeResponseFromJson(json);

  // Helper to extract account part
  AccountApiModel get account => AccountApiModel(
    id: id,
    email: email,
    firstName: firstName,
    lastName: lastName,
    username: username,
    phone: phone,
    roles: roles,
  );
}

/// Account model from API
@freezed
class AccountApiModel with _$AccountApiModel {
  const factory AccountApiModel({
    required dynamic id, // ID can be int
    String? firstName,
    String? lastName,
    String? username,
    required String email,
    String? phone,
    List<String>? roles, // Roles as list of strings
    double? rating,
    String? avatar,
  }) = _AccountApiModel;

  factory AccountApiModel.fromJson(Map<String, dynamic> json) =>
      _$AccountApiModelFromJson(json);
}
