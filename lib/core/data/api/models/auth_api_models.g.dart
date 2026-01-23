// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthorizeRequestImpl _$$AuthorizeRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$AuthorizeRequestImpl(
      login: json['login'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$$AuthorizeRequestImplToJson(
        _$AuthorizeRequestImpl instance) =>
    <String, dynamic>{
      'login': instance.login,
      'password': instance.password,
    };

_$AuthorizeResponseImpl _$$AuthorizeResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$AuthorizeResponseImpl(
      token: json['token'] as String,
      tokenExpireAt: json['tokenExpireAt'] == null
          ? null
          : DateTime.parse(json['tokenExpireAt'] as String),
      tokenIssuedAt: json['tokenIssuedAt'] == null
          ? null
          : DateTime.parse(json['tokenIssuedAt'] as String),
      id: json['id'],
      email: json['email'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      username: json['username'] as String?,
      phone: json['phone'] as String?,
      city: json['city'] as String?,
      roles:
          (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$AuthorizeResponseImplToJson(
        _$AuthorizeResponseImpl instance) =>
    <String, dynamic>{
      'token': instance.token,
      'tokenExpireAt': instance.tokenExpireAt?.toIso8601String(),
      'tokenIssuedAt': instance.tokenIssuedAt?.toIso8601String(),
      'id': instance.id,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'username': instance.username,
      'phone': instance.phone,
      'city': instance.city,
      'roles': instance.roles,
    };

_$AccountApiModelImpl _$$AccountApiModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AccountApiModelImpl(
      id: _readId(json, 'id'),
      firstName: _readFirstName(json, 'first_name') as String?,
      lastName: _readLastName(json, 'last_name') as String?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      roles:
          (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
      rating: (json['averageRating'] as num?)?.toDouble(),
      totalReviews: (_readTotalReviews(json, 'total_reviews') as num?)?.toInt(),
      avatar: json['avatar'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      notificationEnabled: json['notificationEnabled'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      uid: json['uid'] as String?,
      ratingDistribution: json['ratingDistribution'],
    );

Map<String, dynamic> _$$AccountApiModelImplToJson(
        _$AccountApiModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'username': instance.username,
      'email': instance.email,
      'phone': instance.phone,
      'roles': instance.roles,
      'averageRating': instance.rating,
      'total_reviews': instance.totalReviews,
      'avatar': instance.avatar,
      'phoneNumber': instance.phoneNumber,
      'address': instance.address,
      'profilePictureUrl': instance.profilePictureUrl,
      'notificationEnabled': instance.notificationEnabled,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'uid': instance.uid,
      'ratingDistribution': instance.ratingDistribution,
    };
