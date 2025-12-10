// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_api_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OrderApiModel _$OrderApiModelFromJson(Map<String, dynamic> json) {
  return _OrderApiModel.fromJson(json);
}

/// @nodoc
mixin _$OrderApiModel {
  dynamic get id => throw _privateConstructorUsedError; // ID can be int in JSON
  @JsonKey(name: 'review')
  dynamic get review => throw _privateConstructorUsedError; // Can be object or string URI
  String? get orderNumber => throw _privateConstructorUsedError;
  String? get cancellationReason => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  bool? get completed => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;
  String? get uid => throw _privateConstructorUsedError;

  /// Serializes this OrderApiModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderApiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderApiModelCopyWith<OrderApiModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderApiModelCopyWith<$Res> {
  factory $OrderApiModelCopyWith(
    OrderApiModel value,
    $Res Function(OrderApiModel) then,
  ) = _$OrderApiModelCopyWithImpl<$Res, OrderApiModel>;
  @useResult
  $Res call({
    dynamic id,
    @JsonKey(name: 'review') dynamic review,
    String? orderNumber,
    String? cancellationReason,
    String? status,
    bool? completed,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    String? uid,
  });
}

/// @nodoc
class _$OrderApiModelCopyWithImpl<$Res, $Val extends OrderApiModel>
    implements $OrderApiModelCopyWith<$Res> {
  _$OrderApiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderApiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? review = freezed,
    Object? orderNumber = freezed,
    Object? cancellationReason = freezed,
    Object? status = freezed,
    Object? completed = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? uid = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            review: freezed == review
                ? _value.review
                : review // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            orderNumber: freezed == orderNumber
                ? _value.orderNumber
                : orderNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            cancellationReason: freezed == cancellationReason
                ? _value.cancellationReason
                : cancellationReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            completed: freezed == completed
                ? _value.completed
                : completed // ignore: cast_nullable_to_non_nullable
                      as bool?,
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderApiModelImplCopyWith<$Res>
    implements $OrderApiModelCopyWith<$Res> {
  factory _$$OrderApiModelImplCopyWith(
    _$OrderApiModelImpl value,
    $Res Function(_$OrderApiModelImpl) then,
  ) = __$$OrderApiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    dynamic id,
    @JsonKey(name: 'review') dynamic review,
    String? orderNumber,
    String? cancellationReason,
    String? status,
    bool? completed,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    String? uid,
  });
}

/// @nodoc
class __$$OrderApiModelImplCopyWithImpl<$Res>
    extends _$OrderApiModelCopyWithImpl<$Res, _$OrderApiModelImpl>
    implements _$$OrderApiModelImplCopyWith<$Res> {
  __$$OrderApiModelImplCopyWithImpl(
    _$OrderApiModelImpl _value,
    $Res Function(_$OrderApiModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderApiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? review = freezed,
    Object? orderNumber = freezed,
    Object? cancellationReason = freezed,
    Object? status = freezed,
    Object? completed = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? uid = freezed,
  }) {
    return _then(
      _$OrderApiModelImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        review: freezed == review
            ? _value.review
            : review // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        orderNumber: freezed == orderNumber
            ? _value.orderNumber
            : orderNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        cancellationReason: freezed == cancellationReason
            ? _value.cancellationReason
            : cancellationReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        completed: freezed == completed
            ? _value.completed
            : completed // ignore: cast_nullable_to_non_nullable
                  as bool?,
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderApiModelImpl implements _OrderApiModel {
  const _$OrderApiModelImpl({
    required this.id,
    @JsonKey(name: 'review') this.review,
    this.orderNumber,
    this.cancellationReason,
    this.status,
    this.completed,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
    this.uid,
  });

  factory _$OrderApiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderApiModelImplFromJson(json);

  @override
  final dynamic id;
  // ID can be int in JSON
  @override
  @JsonKey(name: 'review')
  final dynamic review;
  // Can be object or string URI
  @override
  final String? orderNumber;
  @override
  final String? cancellationReason;
  @override
  final String? status;
  @override
  final bool? completed;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @override
  final String? uid;

  @override
  String toString() {
    return 'OrderApiModel(id: $id, review: $review, orderNumber: $orderNumber, cancellationReason: $cancellationReason, status: $status, completed: $completed, createdAt: $createdAt, updatedAt: $updatedAt, uid: $uid)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderApiModelImpl &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.review, review) &&
            (identical(other.orderNumber, orderNumber) ||
                other.orderNumber == orderNumber) &&
            (identical(other.cancellationReason, cancellationReason) ||
                other.cancellationReason == cancellationReason) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.uid, uid) || other.uid == uid));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(id),
    const DeepCollectionEquality().hash(review),
    orderNumber,
    cancellationReason,
    status,
    completed,
    createdAt,
    updatedAt,
    uid,
  );

  /// Create a copy of OrderApiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderApiModelImplCopyWith<_$OrderApiModelImpl> get copyWith =>
      __$$OrderApiModelImplCopyWithImpl<_$OrderApiModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderApiModelImplToJson(this);
  }
}

abstract class _OrderApiModel implements OrderApiModel {
  const factory _OrderApiModel({
    required final dynamic id,
    @JsonKey(name: 'review') final dynamic review,
    final String? orderNumber,
    final String? cancellationReason,
    final String? status,
    final bool? completed,
    @JsonKey(name: 'created_at') final String? createdAt,
    @JsonKey(name: 'updated_at') final String? updatedAt,
    final String? uid,
  }) = _$OrderApiModelImpl;

  factory _OrderApiModel.fromJson(Map<String, dynamic> json) =
      _$OrderApiModelImpl.fromJson;

  @override
  dynamic get id; // ID can be int in JSON
  @override
  @JsonKey(name: 'review')
  dynamic get review; // Can be object or string URI
  @override
  String? get orderNumber;
  @override
  String? get cancellationReason;
  @override
  String? get status;
  @override
  bool? get completed;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;
  @override
  String? get uid;

  /// Create a copy of OrderApiModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderApiModelImplCopyWith<_$OrderApiModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
