// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_api_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AuthorizeRequest _$AuthorizeRequestFromJson(Map<String, dynamic> json) {
  return _AuthorizeRequest.fromJson(json);
}

/// @nodoc
mixin _$AuthorizeRequest {
  String get login => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AuthorizeRequestCopyWith<AuthorizeRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthorizeRequestCopyWith<$Res> {
  factory $AuthorizeRequestCopyWith(
          AuthorizeRequest value, $Res Function(AuthorizeRequest) then) =
      _$AuthorizeRequestCopyWithImpl<$Res, AuthorizeRequest>;
  @useResult
  $Res call({String login, String password});
}

/// @nodoc
class _$AuthorizeRequestCopyWithImpl<$Res, $Val extends AuthorizeRequest>
    implements $AuthorizeRequestCopyWith<$Res> {
  _$AuthorizeRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? login = null,
    Object? password = null,
  }) {
    return _then(_value.copyWith(
      login: null == login
          ? _value.login
          : login // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuthorizeRequestImplCopyWith<$Res>
    implements $AuthorizeRequestCopyWith<$Res> {
  factory _$$AuthorizeRequestImplCopyWith(_$AuthorizeRequestImpl value,
          $Res Function(_$AuthorizeRequestImpl) then) =
      __$$AuthorizeRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String login, String password});
}

/// @nodoc
class __$$AuthorizeRequestImplCopyWithImpl<$Res>
    extends _$AuthorizeRequestCopyWithImpl<$Res, _$AuthorizeRequestImpl>
    implements _$$AuthorizeRequestImplCopyWith<$Res> {
  __$$AuthorizeRequestImplCopyWithImpl(_$AuthorizeRequestImpl _value,
      $Res Function(_$AuthorizeRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? login = null,
    Object? password = null,
  }) {
    return _then(_$AuthorizeRequestImpl(
      login: null == login
          ? _value.login
          : login // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthorizeRequestImpl implements _AuthorizeRequest {
  const _$AuthorizeRequestImpl({required this.login, required this.password});

  factory _$AuthorizeRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthorizeRequestImplFromJson(json);

  @override
  final String login;
  @override
  final String password;

  @override
  String toString() {
    return 'AuthorizeRequest(login: $login, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthorizeRequestImpl &&
            (identical(other.login, login) || other.login == login) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, login, password);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthorizeRequestImplCopyWith<_$AuthorizeRequestImpl> get copyWith =>
      __$$AuthorizeRequestImplCopyWithImpl<_$AuthorizeRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthorizeRequestImplToJson(
      this,
    );
  }
}

abstract class _AuthorizeRequest implements AuthorizeRequest {
  const factory _AuthorizeRequest(
      {required final String login,
      required final String password}) = _$AuthorizeRequestImpl;

  factory _AuthorizeRequest.fromJson(Map<String, dynamic> json) =
      _$AuthorizeRequestImpl.fromJson;

  @override
  String get login;
  @override
  String get password;
  @override
  @JsonKey(ignore: true)
  _$$AuthorizeRequestImplCopyWith<_$AuthorizeRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuthorizeResponse _$AuthorizeResponseFromJson(Map<String, dynamic> json) {
  return _AuthorizeResponse.fromJson(json);
}

/// @nodoc
mixin _$AuthorizeResponse {
  String get token => throw _privateConstructorUsedError;

  /// Token expiration date
  @JsonKey(name: 'tokenExpireAt')
  DateTime? get tokenExpireAt => throw _privateConstructorUsedError;

  /// Token issuance date
  @JsonKey(name: 'tokenIssuedAt')
  DateTime? get tokenIssuedAt => throw _privateConstructorUsedError;
  dynamic get id => throw _privateConstructorUsedError; // ID can be int
  String? get email => throw _privateConstructorUsedError;
  String? get firstName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  List<String>? get roles => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AuthorizeResponseCopyWith<AuthorizeResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthorizeResponseCopyWith<$Res> {
  factory $AuthorizeResponseCopyWith(
          AuthorizeResponse value, $Res Function(AuthorizeResponse) then) =
      _$AuthorizeResponseCopyWithImpl<$Res, AuthorizeResponse>;
  @useResult
  $Res call(
      {String token,
      @JsonKey(name: 'tokenExpireAt') DateTime? tokenExpireAt,
      @JsonKey(name: 'tokenIssuedAt') DateTime? tokenIssuedAt,
      dynamic id,
      String? email,
      String? firstName,
      String? lastName,
      String? username,
      String? phone,
      String? city,
      List<String>? roles});
}

/// @nodoc
class _$AuthorizeResponseCopyWithImpl<$Res, $Val extends AuthorizeResponse>
    implements $AuthorizeResponseCopyWith<$Res> {
  _$AuthorizeResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? tokenExpireAt = freezed,
    Object? tokenIssuedAt = freezed,
    Object? id = freezed,
    Object? email = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? username = freezed,
    Object? phone = freezed,
    Object? city = freezed,
    Object? roles = freezed,
  }) {
    return _then(_value.copyWith(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      tokenExpireAt: freezed == tokenExpireAt
          ? _value.tokenExpireAt
          : tokenExpireAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tokenIssuedAt: freezed == tokenIssuedAt
          ? _value.tokenIssuedAt
          : tokenIssuedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as dynamic,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      roles: freezed == roles
          ? _value.roles
          : roles // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuthorizeResponseImplCopyWith<$Res>
    implements $AuthorizeResponseCopyWith<$Res> {
  factory _$$AuthorizeResponseImplCopyWith(_$AuthorizeResponseImpl value,
          $Res Function(_$AuthorizeResponseImpl) then) =
      __$$AuthorizeResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String token,
      @JsonKey(name: 'tokenExpireAt') DateTime? tokenExpireAt,
      @JsonKey(name: 'tokenIssuedAt') DateTime? tokenIssuedAt,
      dynamic id,
      String? email,
      String? firstName,
      String? lastName,
      String? username,
      String? phone,
      String? city,
      List<String>? roles});
}

/// @nodoc
class __$$AuthorizeResponseImplCopyWithImpl<$Res>
    extends _$AuthorizeResponseCopyWithImpl<$Res, _$AuthorizeResponseImpl>
    implements _$$AuthorizeResponseImplCopyWith<$Res> {
  __$$AuthorizeResponseImplCopyWithImpl(_$AuthorizeResponseImpl _value,
      $Res Function(_$AuthorizeResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? tokenExpireAt = freezed,
    Object? tokenIssuedAt = freezed,
    Object? id = freezed,
    Object? email = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? username = freezed,
    Object? phone = freezed,
    Object? city = freezed,
    Object? roles = freezed,
  }) {
    return _then(_$AuthorizeResponseImpl(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      tokenExpireAt: freezed == tokenExpireAt
          ? _value.tokenExpireAt
          : tokenExpireAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tokenIssuedAt: freezed == tokenIssuedAt
          ? _value.tokenIssuedAt
          : tokenIssuedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as dynamic,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      roles: freezed == roles
          ? _value._roles
          : roles // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthorizeResponseImpl extends _AuthorizeResponse {
  const _$AuthorizeResponseImpl(
      {required this.token,
      @JsonKey(name: 'tokenExpireAt') this.tokenExpireAt,
      @JsonKey(name: 'tokenIssuedAt') this.tokenIssuedAt,
      required this.id,
      this.email,
      this.firstName,
      this.lastName,
      this.username,
      this.phone,
      this.city,
      final List<String>? roles})
      : _roles = roles,
        super._();

  factory _$AuthorizeResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthorizeResponseImplFromJson(json);

  @override
  final String token;

  /// Token expiration date
  @override
  @JsonKey(name: 'tokenExpireAt')
  final DateTime? tokenExpireAt;

  /// Token issuance date
  @override
  @JsonKey(name: 'tokenIssuedAt')
  final DateTime? tokenIssuedAt;
  @override
  final dynamic id;
// ID can be int
  @override
  final String? email;
  @override
  final String? firstName;
  @override
  final String? lastName;
  @override
  final String? username;
  @override
  final String? phone;
  @override
  final String? city;
  final List<String>? _roles;
  @override
  List<String>? get roles {
    final value = _roles;
    if (value == null) return null;
    if (_roles is EqualUnmodifiableListView) return _roles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'AuthorizeResponse(token: $token, tokenExpireAt: $tokenExpireAt, tokenIssuedAt: $tokenIssuedAt, id: $id, email: $email, firstName: $firstName, lastName: $lastName, username: $username, phone: $phone, city: $city, roles: $roles)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthorizeResponseImpl &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.tokenExpireAt, tokenExpireAt) ||
                other.tokenExpireAt == tokenExpireAt) &&
            (identical(other.tokenIssuedAt, tokenIssuedAt) ||
                other.tokenIssuedAt == tokenIssuedAt) &&
            const DeepCollectionEquality().equals(other.id, id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.city, city) || other.city == city) &&
            const DeepCollectionEquality().equals(other._roles, _roles));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      token,
      tokenExpireAt,
      tokenIssuedAt,
      const DeepCollectionEquality().hash(id),
      email,
      firstName,
      lastName,
      username,
      phone,
      city,
      const DeepCollectionEquality().hash(_roles));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthorizeResponseImplCopyWith<_$AuthorizeResponseImpl> get copyWith =>
      __$$AuthorizeResponseImplCopyWithImpl<_$AuthorizeResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthorizeResponseImplToJson(
      this,
    );
  }
}

abstract class _AuthorizeResponse extends AuthorizeResponse {
  const factory _AuthorizeResponse(
      {required final String token,
      @JsonKey(name: 'tokenExpireAt') final DateTime? tokenExpireAt,
      @JsonKey(name: 'tokenIssuedAt') final DateTime? tokenIssuedAt,
      required final dynamic id,
      final String? email,
      final String? firstName,
      final String? lastName,
      final String? username,
      final String? phone,
      final String? city,
      final List<String>? roles}) = _$AuthorizeResponseImpl;
  const _AuthorizeResponse._() : super._();

  factory _AuthorizeResponse.fromJson(Map<String, dynamic> json) =
      _$AuthorizeResponseImpl.fromJson;

  @override
  String get token;
  @override

  /// Token expiration date
  @JsonKey(name: 'tokenExpireAt')
  DateTime? get tokenExpireAt;
  @override

  /// Token issuance date
  @JsonKey(name: 'tokenIssuedAt')
  DateTime? get tokenIssuedAt;
  @override
  dynamic get id;
  @override // ID can be int
  String? get email;
  @override
  String? get firstName;
  @override
  String? get lastName;
  @override
  String? get username;
  @override
  String? get phone;
  @override
  String? get city;
  @override
  List<String>? get roles;
  @override
  @JsonKey(ignore: true)
  _$$AuthorizeResponseImplCopyWith<_$AuthorizeResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AccountApiModel _$AccountApiModelFromJson(Map<String, dynamic> json) {
  return _AccountApiModel.fromJson(json);
}

/// @nodoc
mixin _$AccountApiModel {
  /// Unique identifier
  @JsonKey(readValue: _readId)
  dynamic get id =>
      throw _privateConstructorUsedError; // ID can be int or string (uid)
  /// First name
  @JsonKey(name: 'first_name', readValue: _readFirstName)
  String? get firstName => throw _privateConstructorUsedError;

  /// Last name
  @JsonKey(name: 'last_name', readValue: _readLastName)
  String? get lastName => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  List<String>? get roles =>
      throw _privateConstructorUsedError; // Roles as list of strings
  @JsonKey(name: 'averageRating')
  double? get rating => throw _privateConstructorUsedError;

  /// Total number of reviews
  @JsonKey(name: 'total_reviews', readValue: _readTotalReviews)
  int? get totalReviews => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;

  /// Phone number (from my-profile endpoint)
  String? get phoneNumber => throw _privateConstructorUsedError;

  /// Address (from my-profile endpoint)
  String? get address => throw _privateConstructorUsedError;

  /// Profile picture URL (from my-profile endpoint)
  String? get profilePictureUrl => throw _privateConstructorUsedError;

  /// Whether notifications are enabled
  bool get notificationEnabled => throw _privateConstructorUsedError;

  /// Account creation date
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;

  /// Account update date
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Unique identifier string
  String? get uid => throw _privateConstructorUsedError;

  /// Rating distribution (from my-profile endpoint)
  List<String>? get ratingDistribution => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AccountApiModelCopyWith<AccountApiModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccountApiModelCopyWith<$Res> {
  factory $AccountApiModelCopyWith(
          AccountApiModel value, $Res Function(AccountApiModel) then) =
      _$AccountApiModelCopyWithImpl<$Res, AccountApiModel>;
  @useResult
  $Res call(
      {@JsonKey(readValue: _readId) dynamic id,
      @JsonKey(name: 'first_name', readValue: _readFirstName) String? firstName,
      @JsonKey(name: 'last_name', readValue: _readLastName) String? lastName,
      String? username,
      String? email,
      String? phone,
      List<String>? roles,
      @JsonKey(name: 'averageRating') double? rating,
      @JsonKey(name: 'total_reviews', readValue: _readTotalReviews)
      int? totalReviews,
      String? avatar,
      String? phoneNumber,
      String? address,
      String? profilePictureUrl,
      bool notificationEnabled,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt,
      String? uid,
      List<String>? ratingDistribution});
}

/// @nodoc
class _$AccountApiModelCopyWithImpl<$Res, $Val extends AccountApiModel>
    implements $AccountApiModelCopyWith<$Res> {
  _$AccountApiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? username = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? roles = freezed,
    Object? rating = freezed,
    Object? totalReviews = freezed,
    Object? avatar = freezed,
    Object? phoneNumber = freezed,
    Object? address = freezed,
    Object? profilePictureUrl = freezed,
    Object? notificationEnabled = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? uid = freezed,
    Object? ratingDistribution = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as dynamic,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      roles: freezed == roles
          ? _value.roles
          : roles // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      totalReviews: freezed == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      profilePictureUrl: freezed == profilePictureUrl
          ? _value.profilePictureUrl
          : profilePictureUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      notificationEnabled: null == notificationEnabled
          ? _value.notificationEnabled
          : notificationEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      uid: freezed == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String?,
      ratingDistribution: freezed == ratingDistribution
          ? _value.ratingDistribution
          : ratingDistribution // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AccountApiModelImplCopyWith<$Res>
    implements $AccountApiModelCopyWith<$Res> {
  factory _$$AccountApiModelImplCopyWith(_$AccountApiModelImpl value,
          $Res Function(_$AccountApiModelImpl) then) =
      __$$AccountApiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(readValue: _readId) dynamic id,
      @JsonKey(name: 'first_name', readValue: _readFirstName) String? firstName,
      @JsonKey(name: 'last_name', readValue: _readLastName) String? lastName,
      String? username,
      String? email,
      String? phone,
      List<String>? roles,
      @JsonKey(name: 'averageRating') double? rating,
      @JsonKey(name: 'total_reviews', readValue: _readTotalReviews)
      int? totalReviews,
      String? avatar,
      String? phoneNumber,
      String? address,
      String? profilePictureUrl,
      bool notificationEnabled,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt,
      String? uid,
      List<String>? ratingDistribution});
}

/// @nodoc
class __$$AccountApiModelImplCopyWithImpl<$Res>
    extends _$AccountApiModelCopyWithImpl<$Res, _$AccountApiModelImpl>
    implements _$$AccountApiModelImplCopyWith<$Res> {
  __$$AccountApiModelImplCopyWithImpl(
      _$AccountApiModelImpl _value, $Res Function(_$AccountApiModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? username = freezed,
    Object? email = freezed,
    Object? phone = freezed,
    Object? roles = freezed,
    Object? rating = freezed,
    Object? totalReviews = freezed,
    Object? avatar = freezed,
    Object? phoneNumber = freezed,
    Object? address = freezed,
    Object? profilePictureUrl = freezed,
    Object? notificationEnabled = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? uid = freezed,
    Object? ratingDistribution = freezed,
  }) {
    return _then(_$AccountApiModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as dynamic,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      roles: freezed == roles
          ? _value._roles
          : roles // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      totalReviews: freezed == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      profilePictureUrl: freezed == profilePictureUrl
          ? _value.profilePictureUrl
          : profilePictureUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      notificationEnabled: null == notificationEnabled
          ? _value.notificationEnabled
          : notificationEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      uid: freezed == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String?,
      ratingDistribution: freezed == ratingDistribution
          ? _value._ratingDistribution
          : ratingDistribution // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AccountApiModelImpl implements _AccountApiModel {
  const _$AccountApiModelImpl(
      {@JsonKey(readValue: _readId) required this.id,
      @JsonKey(name: 'first_name', readValue: _readFirstName) this.firstName,
      @JsonKey(name: 'last_name', readValue: _readLastName) this.lastName,
      this.username,
      this.email,
      this.phone,
      final List<String>? roles,
      @JsonKey(name: 'averageRating') this.rating,
      @JsonKey(name: 'total_reviews', readValue: _readTotalReviews)
      this.totalReviews,
      this.avatar,
      this.phoneNumber,
      this.address,
      this.profilePictureUrl,
      this.notificationEnabled = false,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      this.uid,
      final List<String>? ratingDistribution})
      : _roles = roles,
        _ratingDistribution = ratingDistribution;

  factory _$AccountApiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AccountApiModelImplFromJson(json);

  /// Unique identifier
  @override
  @JsonKey(readValue: _readId)
  final dynamic id;
// ID can be int or string (uid)
  /// First name
  @override
  @JsonKey(name: 'first_name', readValue: _readFirstName)
  final String? firstName;

  /// Last name
  @override
  @JsonKey(name: 'last_name', readValue: _readLastName)
  final String? lastName;
  @override
  final String? username;
  @override
  final String? email;
  @override
  final String? phone;
  final List<String>? _roles;
  @override
  List<String>? get roles {
    final value = _roles;
    if (value == null) return null;
    if (_roles is EqualUnmodifiableListView) return _roles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

// Roles as list of strings
  @override
  @JsonKey(name: 'averageRating')
  final double? rating;

  /// Total number of reviews
  @override
  @JsonKey(name: 'total_reviews', readValue: _readTotalReviews)
  final int? totalReviews;
  @override
  final String? avatar;

  /// Phone number (from my-profile endpoint)
  @override
  final String? phoneNumber;

  /// Address (from my-profile endpoint)
  @override
  final String? address;

  /// Profile picture URL (from my-profile endpoint)
  @override
  final String? profilePictureUrl;

  /// Whether notifications are enabled
  @override
  @JsonKey()
  final bool notificationEnabled;

  /// Account creation date
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;

  /// Account update date
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  /// Unique identifier string
  @override
  final String? uid;

  /// Rating distribution (from my-profile endpoint)
  final List<String>? _ratingDistribution;

  /// Rating distribution (from my-profile endpoint)
  @override
  List<String>? get ratingDistribution {
    final value = _ratingDistribution;
    if (value == null) return null;
    if (_ratingDistribution is EqualUnmodifiableListView)
      return _ratingDistribution;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'AccountApiModel(id: $id, firstName: $firstName, lastName: $lastName, username: $username, email: $email, phone: $phone, roles: $roles, rating: $rating, totalReviews: $totalReviews, avatar: $avatar, phoneNumber: $phoneNumber, address: $address, profilePictureUrl: $profilePictureUrl, notificationEnabled: $notificationEnabled, createdAt: $createdAt, updatedAt: $updatedAt, uid: $uid, ratingDistribution: $ratingDistribution)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountApiModelImpl &&
            const DeepCollectionEquality().equals(other.id, id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            const DeepCollectionEquality().equals(other._roles, _roles) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.totalReviews, totalReviews) ||
                other.totalReviews == totalReviews) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.profilePictureUrl, profilePictureUrl) ||
                other.profilePictureUrl == profilePictureUrl) &&
            (identical(other.notificationEnabled, notificationEnabled) ||
                other.notificationEnabled == notificationEnabled) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            const DeepCollectionEquality()
                .equals(other._ratingDistribution, _ratingDistribution));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      firstName,
      lastName,
      username,
      email,
      phone,
      const DeepCollectionEquality().hash(_roles),
      rating,
      totalReviews,
      avatar,
      phoneNumber,
      address,
      profilePictureUrl,
      notificationEnabled,
      createdAt,
      updatedAt,
      uid,
      const DeepCollectionEquality().hash(_ratingDistribution));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AccountApiModelImplCopyWith<_$AccountApiModelImpl> get copyWith =>
      __$$AccountApiModelImplCopyWithImpl<_$AccountApiModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AccountApiModelImplToJson(
      this,
    );
  }
}

abstract class _AccountApiModel implements AccountApiModel {
  const factory _AccountApiModel(
      {@JsonKey(readValue: _readId) required final dynamic id,
      @JsonKey(name: 'first_name', readValue: _readFirstName)
      final String? firstName,
      @JsonKey(name: 'last_name', readValue: _readLastName)
      final String? lastName,
      final String? username,
      final String? email,
      final String? phone,
      final List<String>? roles,
      @JsonKey(name: 'averageRating') final double? rating,
      @JsonKey(name: 'total_reviews', readValue: _readTotalReviews)
      final int? totalReviews,
      final String? avatar,
      final String? phoneNumber,
      final String? address,
      final String? profilePictureUrl,
      final bool notificationEnabled,
      @JsonKey(name: 'created_at') final String? createdAt,
      @JsonKey(name: 'updated_at') final String? updatedAt,
      final String? uid,
      final List<String>? ratingDistribution}) = _$AccountApiModelImpl;

  factory _AccountApiModel.fromJson(Map<String, dynamic> json) =
      _$AccountApiModelImpl.fromJson;

  @override

  /// Unique identifier
  @JsonKey(readValue: _readId)
  dynamic get id;
  @override // ID can be int or string (uid)
  /// First name
  @JsonKey(name: 'first_name', readValue: _readFirstName)
  String? get firstName;
  @override

  /// Last name
  @JsonKey(name: 'last_name', readValue: _readLastName)
  String? get lastName;
  @override
  String? get username;
  @override
  String? get email;
  @override
  String? get phone;
  @override
  List<String>? get roles;
  @override // Roles as list of strings
  @JsonKey(name: 'averageRating')
  double? get rating;
  @override

  /// Total number of reviews
  @JsonKey(name: 'total_reviews', readValue: _readTotalReviews)
  int? get totalReviews;
  @override
  String? get avatar;
  @override

  /// Phone number (from my-profile endpoint)
  String? get phoneNumber;
  @override

  /// Address (from my-profile endpoint)
  String? get address;
  @override

  /// Profile picture URL (from my-profile endpoint)
  String? get profilePictureUrl;
  @override

  /// Whether notifications are enabled
  bool get notificationEnabled;
  @override

  /// Account creation date
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override

  /// Account update date
  @JsonKey(name: 'updated_at')
  String? get updatedAt;
  @override

  /// Unique identifier string
  String? get uid;
  @override

  /// Rating distribution (from my-profile endpoint)
  List<String>? get ratingDistribution;
  @override
  @JsonKey(ignore: true)
  _$$AccountApiModelImplCopyWith<_$AccountApiModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
