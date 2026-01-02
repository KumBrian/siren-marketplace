// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_api_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReviewApiRequest _$ReviewApiRequestFromJson(Map<String, dynamic> json) {
  return _ReviewApiRequest.fromJson(json);
}

/// @nodoc
mixin _$ReviewApiRequest {
  int get saleOrder => throw _privateConstructorUsedError;
  double get rate => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  bool get published => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReviewApiRequestCopyWith<ReviewApiRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewApiRequestCopyWith<$Res> {
  factory $ReviewApiRequestCopyWith(
          ReviewApiRequest value, $Res Function(ReviewApiRequest) then) =
      _$ReviewApiRequestCopyWithImpl<$Res, ReviewApiRequest>;
  @useResult
  $Res call({int saleOrder, double rate, String message, bool published});
}

/// @nodoc
class _$ReviewApiRequestCopyWithImpl<$Res, $Val extends ReviewApiRequest>
    implements $ReviewApiRequestCopyWith<$Res> {
  _$ReviewApiRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? saleOrder = null,
    Object? rate = null,
    Object? message = null,
    Object? published = null,
  }) {
    return _then(_value.copyWith(
      saleOrder: null == saleOrder
          ? _value.saleOrder
          : saleOrder // ignore: cast_nullable_to_non_nullable
              as int,
      rate: null == rate
          ? _value.rate
          : rate // ignore: cast_nullable_to_non_nullable
              as double,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      published: null == published
          ? _value.published
          : published // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReviewApiRequestImplCopyWith<$Res>
    implements $ReviewApiRequestCopyWith<$Res> {
  factory _$$ReviewApiRequestImplCopyWith(_$ReviewApiRequestImpl value,
          $Res Function(_$ReviewApiRequestImpl) then) =
      __$$ReviewApiRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int saleOrder, double rate, String message, bool published});
}

/// @nodoc
class __$$ReviewApiRequestImplCopyWithImpl<$Res>
    extends _$ReviewApiRequestCopyWithImpl<$Res, _$ReviewApiRequestImpl>
    implements _$$ReviewApiRequestImplCopyWith<$Res> {
  __$$ReviewApiRequestImplCopyWithImpl(_$ReviewApiRequestImpl _value,
      $Res Function(_$ReviewApiRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? saleOrder = null,
    Object? rate = null,
    Object? message = null,
    Object? published = null,
  }) {
    return _then(_$ReviewApiRequestImpl(
      saleOrder: null == saleOrder
          ? _value.saleOrder
          : saleOrder // ignore: cast_nullable_to_non_nullable
              as int,
      rate: null == rate
          ? _value.rate
          : rate // ignore: cast_nullable_to_non_nullable
              as double,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      published: null == published
          ? _value.published
          : published // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewApiRequestImpl implements _ReviewApiRequest {
  const _$ReviewApiRequestImpl(
      {required this.saleOrder,
      required this.rate,
      required this.message,
      required this.published});

  factory _$ReviewApiRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewApiRequestImplFromJson(json);

  @override
  final int saleOrder;
  @override
  final double rate;
  @override
  final String message;
  @override
  final bool published;

  @override
  String toString() {
    return 'ReviewApiRequest(saleOrder: $saleOrder, rate: $rate, message: $message, published: $published)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewApiRequestImpl &&
            (identical(other.saleOrder, saleOrder) ||
                other.saleOrder == saleOrder) &&
            (identical(other.rate, rate) || other.rate == rate) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.published, published) ||
                other.published == published));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, saleOrder, rate, message, published);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewApiRequestImplCopyWith<_$ReviewApiRequestImpl> get copyWith =>
      __$$ReviewApiRequestImplCopyWithImpl<_$ReviewApiRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewApiRequestImplToJson(
      this,
    );
  }
}

abstract class _ReviewApiRequest implements ReviewApiRequest {
  const factory _ReviewApiRequest(
      {required final int saleOrder,
      required final double rate,
      required final String message,
      required final bool published}) = _$ReviewApiRequestImpl;

  factory _ReviewApiRequest.fromJson(Map<String, dynamic> json) =
      _$ReviewApiRequestImpl.fromJson;

  @override
  int get saleOrder;
  @override
  double get rate;
  @override
  String get message;
  @override
  bool get published;
  @override
  @JsonKey(ignore: true)
  _$$ReviewApiRequestImplCopyWith<_$ReviewApiRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReviewApiResponse _$ReviewApiResponseFromJson(Map<String, dynamic> json) {
  return _ReviewApiResponse.fromJson(json);
}

/// @nodoc
mixin _$ReviewApiResponse {
  dynamic get id => throw _privateConstructorUsedError;
  double get rate => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  bool get published => throw _privateConstructorUsedError;
  @JsonKey(name: 'sale_order')
  dynamic get saleOrder => throw _privateConstructorUsedError; // User details
  AccountApiModel? get reviewer => throw _privateConstructorUsedError;
  AccountApiModel? get reviewedAccount =>
      throw _privateConstructorUsedError; // Timestamps
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'deleted_at')
  String? get deletedAt => throw _privateConstructorUsedError;
  String? get uid => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReviewApiResponseCopyWith<ReviewApiResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewApiResponseCopyWith<$Res> {
  factory $ReviewApiResponseCopyWith(
          ReviewApiResponse value, $Res Function(ReviewApiResponse) then) =
      _$ReviewApiResponseCopyWithImpl<$Res, ReviewApiResponse>;
  @useResult
  $Res call(
      {dynamic id,
      double rate,
      String message,
      bool published,
      @JsonKey(name: 'sale_order') dynamic saleOrder,
      AccountApiModel? reviewer,
      AccountApiModel? reviewedAccount,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt,
      @JsonKey(name: 'deleted_at') String? deletedAt,
      String? uid});

  $AccountApiModelCopyWith<$Res>? get reviewer;
  $AccountApiModelCopyWith<$Res>? get reviewedAccount;
}

/// @nodoc
class _$ReviewApiResponseCopyWithImpl<$Res, $Val extends ReviewApiResponse>
    implements $ReviewApiResponseCopyWith<$Res> {
  _$ReviewApiResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? rate = null,
    Object? message = null,
    Object? published = null,
    Object? saleOrder = freezed,
    Object? reviewer = freezed,
    Object? reviewedAccount = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
    Object? uid = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as dynamic,
      rate: null == rate
          ? _value.rate
          : rate // ignore: cast_nullable_to_non_nullable
              as double,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      published: null == published
          ? _value.published
          : published // ignore: cast_nullable_to_non_nullable
              as bool,
      saleOrder: freezed == saleOrder
          ? _value.saleOrder
          : saleOrder // ignore: cast_nullable_to_non_nullable
              as dynamic,
      reviewer: freezed == reviewer
          ? _value.reviewer
          : reviewer // ignore: cast_nullable_to_non_nullable
              as AccountApiModel?,
      reviewedAccount: freezed == reviewedAccount
          ? _value.reviewedAccount
          : reviewedAccount // ignore: cast_nullable_to_non_nullable
              as AccountApiModel?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      uid: freezed == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AccountApiModelCopyWith<$Res>? get reviewer {
    if (_value.reviewer == null) {
      return null;
    }

    return $AccountApiModelCopyWith<$Res>(_value.reviewer!, (value) {
      return _then(_value.copyWith(reviewer: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AccountApiModelCopyWith<$Res>? get reviewedAccount {
    if (_value.reviewedAccount == null) {
      return null;
    }

    return $AccountApiModelCopyWith<$Res>(_value.reviewedAccount!, (value) {
      return _then(_value.copyWith(reviewedAccount: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReviewApiResponseImplCopyWith<$Res>
    implements $ReviewApiResponseCopyWith<$Res> {
  factory _$$ReviewApiResponseImplCopyWith(_$ReviewApiResponseImpl value,
          $Res Function(_$ReviewApiResponseImpl) then) =
      __$$ReviewApiResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {dynamic id,
      double rate,
      String message,
      bool published,
      @JsonKey(name: 'sale_order') dynamic saleOrder,
      AccountApiModel? reviewer,
      AccountApiModel? reviewedAccount,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'updated_at') String? updatedAt,
      @JsonKey(name: 'deleted_at') String? deletedAt,
      String? uid});

  @override
  $AccountApiModelCopyWith<$Res>? get reviewer;
  @override
  $AccountApiModelCopyWith<$Res>? get reviewedAccount;
}

/// @nodoc
class __$$ReviewApiResponseImplCopyWithImpl<$Res>
    extends _$ReviewApiResponseCopyWithImpl<$Res, _$ReviewApiResponseImpl>
    implements _$$ReviewApiResponseImplCopyWith<$Res> {
  __$$ReviewApiResponseImplCopyWithImpl(_$ReviewApiResponseImpl _value,
      $Res Function(_$ReviewApiResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? rate = null,
    Object? message = null,
    Object? published = null,
    Object? saleOrder = freezed,
    Object? reviewer = freezed,
    Object? reviewedAccount = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
    Object? uid = freezed,
  }) {
    return _then(_$ReviewApiResponseImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as dynamic,
      rate: null == rate
          ? _value.rate
          : rate // ignore: cast_nullable_to_non_nullable
              as double,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      published: null == published
          ? _value.published
          : published // ignore: cast_nullable_to_non_nullable
              as bool,
      saleOrder: freezed == saleOrder
          ? _value.saleOrder
          : saleOrder // ignore: cast_nullable_to_non_nullable
              as dynamic,
      reviewer: freezed == reviewer
          ? _value.reviewer
          : reviewer // ignore: cast_nullable_to_non_nullable
              as AccountApiModel?,
      reviewedAccount: freezed == reviewedAccount
          ? _value.reviewedAccount
          : reviewedAccount // ignore: cast_nullable_to_non_nullable
              as AccountApiModel?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      uid: freezed == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewApiResponseImpl implements _ReviewApiResponse {
  const _$ReviewApiResponseImpl(
      {required this.id,
      required this.rate,
      required this.message,
      required this.published,
      @JsonKey(name: 'sale_order') this.saleOrder,
      this.reviewer,
      this.reviewedAccount,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      @JsonKey(name: 'deleted_at') this.deletedAt,
      this.uid});

  factory _$ReviewApiResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewApiResponseImplFromJson(json);

  @override
  final dynamic id;
  @override
  final double rate;
  @override
  final String message;
  @override
  final bool published;
  @override
  @JsonKey(name: 'sale_order')
  final dynamic saleOrder;
// User details
  @override
  final AccountApiModel? reviewer;
  @override
  final AccountApiModel? reviewedAccount;
// Timestamps
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @override
  @JsonKey(name: 'deleted_at')
  final String? deletedAt;
  @override
  final String? uid;

  @override
  String toString() {
    return 'ReviewApiResponse(id: $id, rate: $rate, message: $message, published: $published, saleOrder: $saleOrder, reviewer: $reviewer, reviewedAccount: $reviewedAccount, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, uid: $uid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewApiResponseImpl &&
            const DeepCollectionEquality().equals(other.id, id) &&
            (identical(other.rate, rate) || other.rate == rate) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.published, published) ||
                other.published == published) &&
            const DeepCollectionEquality().equals(other.saleOrder, saleOrder) &&
            (identical(other.reviewer, reviewer) ||
                other.reviewer == reviewer) &&
            (identical(other.reviewedAccount, reviewedAccount) ||
                other.reviewedAccount == reviewedAccount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.uid, uid) || other.uid == uid));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      rate,
      message,
      published,
      const DeepCollectionEquality().hash(saleOrder),
      reviewer,
      reviewedAccount,
      createdAt,
      updatedAt,
      deletedAt,
      uid);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewApiResponseImplCopyWith<_$ReviewApiResponseImpl> get copyWith =>
      __$$ReviewApiResponseImplCopyWithImpl<_$ReviewApiResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewApiResponseImplToJson(
      this,
    );
  }
}

abstract class _ReviewApiResponse implements ReviewApiResponse {
  const factory _ReviewApiResponse(
      {required final dynamic id,
      required final double rate,
      required final String message,
      required final bool published,
      @JsonKey(name: 'sale_order') final dynamic saleOrder,
      final AccountApiModel? reviewer,
      final AccountApiModel? reviewedAccount,
      @JsonKey(name: 'created_at') final String? createdAt,
      @JsonKey(name: 'updated_at') final String? updatedAt,
      @JsonKey(name: 'deleted_at') final String? deletedAt,
      final String? uid}) = _$ReviewApiResponseImpl;

  factory _ReviewApiResponse.fromJson(Map<String, dynamic> json) =
      _$ReviewApiResponseImpl.fromJson;

  @override
  dynamic get id;
  @override
  double get rate;
  @override
  String get message;
  @override
  bool get published;
  @override
  @JsonKey(name: 'sale_order')
  dynamic get saleOrder;
  @override // User details
  AccountApiModel? get reviewer;
  @override
  AccountApiModel? get reviewedAccount;
  @override // Timestamps
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;
  @override
  @JsonKey(name: 'deleted_at')
  String? get deletedAt;
  @override
  String? get uid;
  @override
  @JsonKey(ignore: true)
  _$$ReviewApiResponseImplCopyWith<_$ReviewApiResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
