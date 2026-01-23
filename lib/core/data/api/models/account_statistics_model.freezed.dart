// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_statistics_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AccountStatisticsModel _$AccountStatisticsModelFromJson(
    Map<String, dynamic> json) {
  return _AccountStatisticsModel.fromJson(json);
}

/// @nodoc
mixin _$AccountStatisticsModel {
  /// Total turnover amount
  int get turnover => throw _privateConstructorUsedError;

  /// Currency code (e.g., "CFA")
  String get currency => throw _privateConstructorUsedError;

  /// Total number of sales
  int get totalSales => throw _privateConstructorUsedError;

  /// Number of active products in marketplace
  int get activeProducts => throw _privateConstructorUsedError;

  /// Number of completed orders
  int get completedOrders => throw _privateConstructorUsedError;

  /// Total number of catches
  int get totalCatches => throw _privateConstructorUsedError;

  /// Statistics period (e.g., "monthly")
  String get period => throw _privateConstructorUsedError;

  /// Average rating score
  double get averageRating => throw _privateConstructorUsedError;

  /// Total number of reviews
  int get totalReviews => throw _privateConstructorUsedError;

  /// Distribution of ratings by star count
  /// Keys are "1", "2", "3", "4", "5"; values are counts
  Map<String, int> get ratingDistribution => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AccountStatisticsModelCopyWith<AccountStatisticsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccountStatisticsModelCopyWith<$Res> {
  factory $AccountStatisticsModelCopyWith(AccountStatisticsModel value,
          $Res Function(AccountStatisticsModel) then) =
      _$AccountStatisticsModelCopyWithImpl<$Res, AccountStatisticsModel>;
  @useResult
  $Res call(
      {int turnover,
      String currency,
      int totalSales,
      int activeProducts,
      int completedOrders,
      int totalCatches,
      String period,
      double averageRating,
      int totalReviews,
      Map<String, int> ratingDistribution});
}

/// @nodoc
class _$AccountStatisticsModelCopyWithImpl<$Res,
        $Val extends AccountStatisticsModel>
    implements $AccountStatisticsModelCopyWith<$Res> {
  _$AccountStatisticsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? turnover = null,
    Object? currency = null,
    Object? totalSales = null,
    Object? activeProducts = null,
    Object? completedOrders = null,
    Object? totalCatches = null,
    Object? period = null,
    Object? averageRating = null,
    Object? totalReviews = null,
    Object? ratingDistribution = null,
  }) {
    return _then(_value.copyWith(
      turnover: null == turnover
          ? _value.turnover
          : turnover // ignore: cast_nullable_to_non_nullable
              as int,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      totalSales: null == totalSales
          ? _value.totalSales
          : totalSales // ignore: cast_nullable_to_non_nullable
              as int,
      activeProducts: null == activeProducts
          ? _value.activeProducts
          : activeProducts // ignore: cast_nullable_to_non_nullable
              as int,
      completedOrders: null == completedOrders
          ? _value.completedOrders
          : completedOrders // ignore: cast_nullable_to_non_nullable
              as int,
      totalCatches: null == totalCatches
          ? _value.totalCatches
          : totalCatches // ignore: cast_nullable_to_non_nullable
              as int,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      totalReviews: null == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int,
      ratingDistribution: null == ratingDistribution
          ? _value.ratingDistribution
          : ratingDistribution // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AccountStatisticsModelImplCopyWith<$Res>
    implements $AccountStatisticsModelCopyWith<$Res> {
  factory _$$AccountStatisticsModelImplCopyWith(
          _$AccountStatisticsModelImpl value,
          $Res Function(_$AccountStatisticsModelImpl) then) =
      __$$AccountStatisticsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int turnover,
      String currency,
      int totalSales,
      int activeProducts,
      int completedOrders,
      int totalCatches,
      String period,
      double averageRating,
      int totalReviews,
      Map<String, int> ratingDistribution});
}

/// @nodoc
class __$$AccountStatisticsModelImplCopyWithImpl<$Res>
    extends _$AccountStatisticsModelCopyWithImpl<$Res,
        _$AccountStatisticsModelImpl>
    implements _$$AccountStatisticsModelImplCopyWith<$Res> {
  __$$AccountStatisticsModelImplCopyWithImpl(
      _$AccountStatisticsModelImpl _value,
      $Res Function(_$AccountStatisticsModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? turnover = null,
    Object? currency = null,
    Object? totalSales = null,
    Object? activeProducts = null,
    Object? completedOrders = null,
    Object? totalCatches = null,
    Object? period = null,
    Object? averageRating = null,
    Object? totalReviews = null,
    Object? ratingDistribution = null,
  }) {
    return _then(_$AccountStatisticsModelImpl(
      turnover: null == turnover
          ? _value.turnover
          : turnover // ignore: cast_nullable_to_non_nullable
              as int,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      totalSales: null == totalSales
          ? _value.totalSales
          : totalSales // ignore: cast_nullable_to_non_nullable
              as int,
      activeProducts: null == activeProducts
          ? _value.activeProducts
          : activeProducts // ignore: cast_nullable_to_non_nullable
              as int,
      completedOrders: null == completedOrders
          ? _value.completedOrders
          : completedOrders // ignore: cast_nullable_to_non_nullable
              as int,
      totalCatches: null == totalCatches
          ? _value.totalCatches
          : totalCatches // ignore: cast_nullable_to_non_nullable
              as int,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      totalReviews: null == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int,
      ratingDistribution: null == ratingDistribution
          ? _value._ratingDistribution
          : ratingDistribution // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AccountStatisticsModelImpl implements _AccountStatisticsModel {
  const _$AccountStatisticsModelImpl(
      {this.turnover = 0,
      this.currency = 'CFA',
      this.totalSales = 0,
      this.activeProducts = 0,
      this.completedOrders = 0,
      this.totalCatches = 0,
      this.period = 'monthly',
      this.averageRating = 0.0,
      this.totalReviews = 0,
      final Map<String, int> ratingDistribution = const {}})
      : _ratingDistribution = ratingDistribution;

  factory _$AccountStatisticsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AccountStatisticsModelImplFromJson(json);

  /// Total turnover amount
  @override
  @JsonKey()
  final int turnover;

  /// Currency code (e.g., "CFA")
  @override
  @JsonKey()
  final String currency;

  /// Total number of sales
  @override
  @JsonKey()
  final int totalSales;

  /// Number of active products in marketplace
  @override
  @JsonKey()
  final int activeProducts;

  /// Number of completed orders
  @override
  @JsonKey()
  final int completedOrders;

  /// Total number of catches
  @override
  @JsonKey()
  final int totalCatches;

  /// Statistics period (e.g., "monthly")
  @override
  @JsonKey()
  final String period;

  /// Average rating score
  @override
  @JsonKey()
  final double averageRating;

  /// Total number of reviews
  @override
  @JsonKey()
  final int totalReviews;

  /// Distribution of ratings by star count
  /// Keys are "1", "2", "3", "4", "5"; values are counts
  final Map<String, int> _ratingDistribution;

  /// Distribution of ratings by star count
  /// Keys are "1", "2", "3", "4", "5"; values are counts
  @override
  @JsonKey()
  Map<String, int> get ratingDistribution {
    if (_ratingDistribution is EqualUnmodifiableMapView)
      return _ratingDistribution;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_ratingDistribution);
  }

  @override
  String toString() {
    return 'AccountStatisticsModel(turnover: $turnover, currency: $currency, totalSales: $totalSales, activeProducts: $activeProducts, completedOrders: $completedOrders, totalCatches: $totalCatches, period: $period, averageRating: $averageRating, totalReviews: $totalReviews, ratingDistribution: $ratingDistribution)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountStatisticsModelImpl &&
            (identical(other.turnover, turnover) ||
                other.turnover == turnover) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.totalSales, totalSales) ||
                other.totalSales == totalSales) &&
            (identical(other.activeProducts, activeProducts) ||
                other.activeProducts == activeProducts) &&
            (identical(other.completedOrders, completedOrders) ||
                other.completedOrders == completedOrders) &&
            (identical(other.totalCatches, totalCatches) ||
                other.totalCatches == totalCatches) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.totalReviews, totalReviews) ||
                other.totalReviews == totalReviews) &&
            const DeepCollectionEquality()
                .equals(other._ratingDistribution, _ratingDistribution));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      turnover,
      currency,
      totalSales,
      activeProducts,
      completedOrders,
      totalCatches,
      period,
      averageRating,
      totalReviews,
      const DeepCollectionEquality().hash(_ratingDistribution));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AccountStatisticsModelImplCopyWith<_$AccountStatisticsModelImpl>
      get copyWith => __$$AccountStatisticsModelImplCopyWithImpl<
          _$AccountStatisticsModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AccountStatisticsModelImplToJson(
      this,
    );
  }
}

abstract class _AccountStatisticsModel implements AccountStatisticsModel {
  const factory _AccountStatisticsModel(
          {final int turnover,
          final String currency,
          final int totalSales,
          final int activeProducts,
          final int completedOrders,
          final int totalCatches,
          final String period,
          final double averageRating,
          final int totalReviews,
          final Map<String, int> ratingDistribution}) =
      _$AccountStatisticsModelImpl;

  factory _AccountStatisticsModel.fromJson(Map<String, dynamic> json) =
      _$AccountStatisticsModelImpl.fromJson;

  @override

  /// Total turnover amount
  int get turnover;
  @override

  /// Currency code (e.g., "CFA")
  String get currency;
  @override

  /// Total number of sales
  int get totalSales;
  @override

  /// Number of active products in marketplace
  int get activeProducts;
  @override

  /// Number of completed orders
  int get completedOrders;
  @override

  /// Total number of catches
  int get totalCatches;
  @override

  /// Statistics period (e.g., "monthly")
  String get period;
  @override

  /// Average rating score
  double get averageRating;
  @override

  /// Total number of reviews
  int get totalReviews;
  @override

  /// Distribution of ratings by star count
  /// Keys are "1", "2", "3", "4", "5"; values are counts
  Map<String, int> get ratingDistribution;
  @override
  @JsonKey(ignore: true)
  _$$AccountStatisticsModelImplCopyWith<_$AccountStatisticsModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
