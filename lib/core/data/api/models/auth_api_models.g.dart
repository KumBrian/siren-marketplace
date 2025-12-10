// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthorizeRequestImpl _$$AuthorizeRequestImplFromJson(
  Map<String, dynamic> json,
) => _$AuthorizeRequestImpl(
  login: json['login'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$$AuthorizeRequestImplToJson(
  _$AuthorizeRequestImpl instance,
) => <String, dynamic>{'login': instance.login, 'password': instance.password};

_$AuthorizeResponseImpl _$$AuthorizeResponseImplFromJson(
  Map<String, dynamic> json,
) => _$AuthorizeResponseImpl(
  token: json['token'] as String,
  tokenExpireAt: json['tokenExpireAt'] == null
      ? null
      : DateTime.parse(json['tokenExpireAt'] as String),
  id: json['id'],
  email: json['email'] as String,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  username: json['username'] as String?,
  phone: json['phone'] as String?,
  city: json['city'] as String?,
  roles: (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$$AuthorizeResponseImplToJson(
  _$AuthorizeResponseImpl instance,
) => <String, dynamic>{
  'token': instance.token,
  'tokenExpireAt': instance.tokenExpireAt?.toIso8601String(),
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
  Map<String, dynamic> json,
) => _$AccountApiModelImpl(
  id: json['id'],
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  username: json['username'] as String?,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  roles: (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
  rating: (json['rating'] as num?)?.toDouble(),
  avatar: json['avatar'] as String?,
);

Map<String, dynamic> _$$AccountApiModelImplToJson(
  _$AccountApiModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'username': instance.username,
  'email': instance.email,
  'phone': instance.phone,
  'roles': instance.roles,
  'rating': instance.rating,
  'avatar': instance.avatar,
};
