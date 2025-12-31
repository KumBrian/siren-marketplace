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

    /// Token expiration date
    @JsonKey(name: 'tokenExpireAt') DateTime? tokenExpireAt,

    /// Token issuance date
    @JsonKey(name: 'tokenIssuedAt') DateTime? tokenIssuedAt,
    required dynamic id, // ID can be int
    String? email,
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
    /// Unique identifier
    @JsonKey(readValue: _readId)
    required dynamic id, // ID can be int or string (uid)
    /// First name
    @JsonKey(name: 'first_name', readValue: _readFirstName) String? firstName,

    /// Last name
    @JsonKey(name: 'last_name', readValue: _readLastName) String? lastName,
    String? username,
    String? email,
    String? phone,
    List<String>? roles, // Roles as list of strings
    double? rating,

    /// Total number of reviews
    @JsonKey(name: 'total_reviews', readValue: _readTotalReviews)
    int? totalReviews,
    String? avatar,
  }) = _AccountApiModel;

  factory AccountApiModel.fromJson(Map<String, dynamic> json) =>
      _$AccountApiModelFromJson(json);
}

// Helper to read ID from either 'id' or 'uid'
Object? _readId(Map json, String key) {
  if (json.containsKey('id')) return json['id'];
  if (json.containsKey('uid')) return json['uid'];
  return null;
}

Object? _readFirstName(Map json, String key) {
  return json['first_name'] ?? json['firstName'];
}

Object? _readLastName(Map json, String key) {
  return json['last_name'] ?? json['lastName'];
}

Object? _readTotalReviews(Map json, String key) {
  return json['total_reviews'] ?? json['totalReviews'];
}
