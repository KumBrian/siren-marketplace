// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subgroup_api_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SubgroupsResponseModel _$SubgroupsResponseModelFromJson(
    Map<String, dynamic> json) {
  return _SubgroupsResponseModel.fromJson(json);
}

/// @nodoc
mixin _$SubgroupsResponseModel {
  SubgroupDataModel get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SubgroupsResponseModelCopyWith<SubgroupsResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubgroupsResponseModelCopyWith<$Res> {
  factory $SubgroupsResponseModelCopyWith(SubgroupsResponseModel value,
          $Res Function(SubgroupsResponseModel) then) =
      _$SubgroupsResponseModelCopyWithImpl<$Res, SubgroupsResponseModel>;
  @useResult
  $Res call({SubgroupDataModel data});

  $SubgroupDataModelCopyWith<$Res> get data;
}

/// @nodoc
class _$SubgroupsResponseModelCopyWithImpl<$Res,
        $Val extends SubgroupsResponseModel>
    implements $SubgroupsResponseModelCopyWith<$Res> {
  _$SubgroupsResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as SubgroupDataModel,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $SubgroupDataModelCopyWith<$Res> get data {
    return $SubgroupDataModelCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SubgroupsResponseModelImplCopyWith<$Res>
    implements $SubgroupsResponseModelCopyWith<$Res> {
  factory _$$SubgroupsResponseModelImplCopyWith(
          _$SubgroupsResponseModelImpl value,
          $Res Function(_$SubgroupsResponseModelImpl) then) =
      __$$SubgroupsResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({SubgroupDataModel data});

  @override
  $SubgroupDataModelCopyWith<$Res> get data;
}

/// @nodoc
class __$$SubgroupsResponseModelImplCopyWithImpl<$Res>
    extends _$SubgroupsResponseModelCopyWithImpl<$Res,
        _$SubgroupsResponseModelImpl>
    implements _$$SubgroupsResponseModelImplCopyWith<$Res> {
  __$$SubgroupsResponseModelImplCopyWithImpl(
      _$SubgroupsResponseModelImpl _value,
      $Res Function(_$SubgroupsResponseModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$SubgroupsResponseModelImpl(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as SubgroupDataModel,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubgroupsResponseModelImpl implements _SubgroupsResponseModel {
  const _$SubgroupsResponseModelImpl({required this.data});

  factory _$SubgroupsResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubgroupsResponseModelImplFromJson(json);

  @override
  final SubgroupDataModel data;

  @override
  String toString() {
    return 'SubgroupsResponseModel(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubgroupsResponseModelImpl &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SubgroupsResponseModelImplCopyWith<_$SubgroupsResponseModelImpl>
      get copyWith => __$$SubgroupsResponseModelImplCopyWithImpl<
          _$SubgroupsResponseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubgroupsResponseModelImplToJson(
      this,
    );
  }
}

abstract class _SubgroupsResponseModel implements SubgroupsResponseModel {
  const factory _SubgroupsResponseModel(
      {required final SubgroupDataModel data}) = _$SubgroupsResponseModelImpl;

  factory _SubgroupsResponseModel.fromJson(Map<String, dynamic> json) =
      _$SubgroupsResponseModelImpl.fromJson;

  @override
  SubgroupDataModel get data;
  @override
  @JsonKey(ignore: true)
  _$$SubgroupsResponseModelImplCopyWith<_$SubgroupsResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SubgroupDataModel _$SubgroupDataModelFromJson(Map<String, dynamic> json) {
  return _SubgroupDataModel.fromJson(json);
}

/// @nodoc
mixin _$SubgroupDataModel {
  List<SubgroupModel> get subgroups => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SubgroupDataModelCopyWith<SubgroupDataModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubgroupDataModelCopyWith<$Res> {
  factory $SubgroupDataModelCopyWith(
          SubgroupDataModel value, $Res Function(SubgroupDataModel) then) =
      _$SubgroupDataModelCopyWithImpl<$Res, SubgroupDataModel>;
  @useResult
  $Res call({List<SubgroupModel> subgroups});
}

/// @nodoc
class _$SubgroupDataModelCopyWithImpl<$Res, $Val extends SubgroupDataModel>
    implements $SubgroupDataModelCopyWith<$Res> {
  _$SubgroupDataModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subgroups = null,
  }) {
    return _then(_value.copyWith(
      subgroups: null == subgroups
          ? _value.subgroups
          : subgroups // ignore: cast_nullable_to_non_nullable
              as List<SubgroupModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubgroupDataModelImplCopyWith<$Res>
    implements $SubgroupDataModelCopyWith<$Res> {
  factory _$$SubgroupDataModelImplCopyWith(_$SubgroupDataModelImpl value,
          $Res Function(_$SubgroupDataModelImpl) then) =
      __$$SubgroupDataModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<SubgroupModel> subgroups});
}

/// @nodoc
class __$$SubgroupDataModelImplCopyWithImpl<$Res>
    extends _$SubgroupDataModelCopyWithImpl<$Res, _$SubgroupDataModelImpl>
    implements _$$SubgroupDataModelImplCopyWith<$Res> {
  __$$SubgroupDataModelImplCopyWithImpl(_$SubgroupDataModelImpl _value,
      $Res Function(_$SubgroupDataModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subgroups = null,
  }) {
    return _then(_$SubgroupDataModelImpl(
      subgroups: null == subgroups
          ? _value._subgroups
          : subgroups // ignore: cast_nullable_to_non_nullable
              as List<SubgroupModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubgroupDataModelImpl implements _SubgroupDataModel {
  const _$SubgroupDataModelImpl({required final List<SubgroupModel> subgroups})
      : _subgroups = subgroups;

  factory _$SubgroupDataModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubgroupDataModelImplFromJson(json);

  final List<SubgroupModel> _subgroups;
  @override
  List<SubgroupModel> get subgroups {
    if (_subgroups is EqualUnmodifiableListView) return _subgroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subgroups);
  }

  @override
  String toString() {
    return 'SubgroupDataModel(subgroups: $subgroups)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubgroupDataModelImpl &&
            const DeepCollectionEquality()
                .equals(other._subgroups, _subgroups));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_subgroups));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SubgroupDataModelImplCopyWith<_$SubgroupDataModelImpl> get copyWith =>
      __$$SubgroupDataModelImplCopyWithImpl<_$SubgroupDataModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubgroupDataModelImplToJson(
      this,
    );
  }
}

abstract class _SubgroupDataModel implements SubgroupDataModel {
  const factory _SubgroupDataModel(
      {required final List<SubgroupModel> subgroups}) = _$SubgroupDataModelImpl;

  factory _SubgroupDataModel.fromJson(Map<String, dynamic> json) =
      _$SubgroupDataModelImpl.fromJson;

  @override
  List<SubgroupModel> get subgroups;
  @override
  @JsonKey(ignore: true)
  _$$SubgroupDataModelImplCopyWith<_$SubgroupDataModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubgroupModel _$SubgroupModelFromJson(Map<String, dynamic> json) {
  return _SubgroupModel.fromJson(json);
}

/// @nodoc
mixin _$SubgroupModel {
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<SubgroupSpeciesModel> get species => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SubgroupModelCopyWith<SubgroupModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubgroupModelCopyWith<$Res> {
  factory $SubgroupModelCopyWith(
          SubgroupModel value, $Res Function(SubgroupModel) then) =
      _$SubgroupModelCopyWithImpl<$Res, SubgroupModel>;
  @useResult
  $Res call(
      {String name, String description, List<SubgroupSpeciesModel> species});
}

/// @nodoc
class _$SubgroupModelCopyWithImpl<$Res, $Val extends SubgroupModel>
    implements $SubgroupModelCopyWith<$Res> {
  _$SubgroupModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? species = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      species: null == species
          ? _value.species
          : species // ignore: cast_nullable_to_non_nullable
              as List<SubgroupSpeciesModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubgroupModelImplCopyWith<$Res>
    implements $SubgroupModelCopyWith<$Res> {
  factory _$$SubgroupModelImplCopyWith(
          _$SubgroupModelImpl value, $Res Function(_$SubgroupModelImpl) then) =
      __$$SubgroupModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name, String description, List<SubgroupSpeciesModel> species});
}

/// @nodoc
class __$$SubgroupModelImplCopyWithImpl<$Res>
    extends _$SubgroupModelCopyWithImpl<$Res, _$SubgroupModelImpl>
    implements _$$SubgroupModelImplCopyWith<$Res> {
  __$$SubgroupModelImplCopyWithImpl(
      _$SubgroupModelImpl _value, $Res Function(_$SubgroupModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? species = null,
  }) {
    return _then(_$SubgroupModelImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      species: null == species
          ? _value._species
          : species // ignore: cast_nullable_to_non_nullable
              as List<SubgroupSpeciesModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubgroupModelImpl implements _SubgroupModel {
  const _$SubgroupModelImpl(
      {required this.name,
      required this.description,
      required final List<SubgroupSpeciesModel> species})
      : _species = species;

  factory _$SubgroupModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubgroupModelImplFromJson(json);

  @override
  final String name;
  @override
  final String description;
  final List<SubgroupSpeciesModel> _species;
  @override
  List<SubgroupSpeciesModel> get species {
    if (_species is EqualUnmodifiableListView) return _species;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_species);
  }

  @override
  String toString() {
    return 'SubgroupModel(name: $name, description: $description, species: $species)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubgroupModelImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._species, _species));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, name, description,
      const DeepCollectionEquality().hash(_species));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SubgroupModelImplCopyWith<_$SubgroupModelImpl> get copyWith =>
      __$$SubgroupModelImplCopyWithImpl<_$SubgroupModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubgroupModelImplToJson(
      this,
    );
  }
}

abstract class _SubgroupModel implements SubgroupModel {
  const factory _SubgroupModel(
      {required final String name,
      required final String description,
      required final List<SubgroupSpeciesModel> species}) = _$SubgroupModelImpl;

  factory _SubgroupModel.fromJson(Map<String, dynamic> json) =
      _$SubgroupModelImpl.fromJson;

  @override
  String get name;
  @override
  String get description;
  @override
  List<SubgroupSpeciesModel> get species;
  @override
  @JsonKey(ignore: true)
  _$$SubgroupModelImplCopyWith<_$SubgroupModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubgroupSpeciesModel _$SubgroupSpeciesModelFromJson(Map<String, dynamic> json) {
  return _SubgroupSpeciesModel.fromJson(json);
}

/// @nodoc
mixin _$SubgroupSpeciesModel {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SubgroupSpeciesModelCopyWith<SubgroupSpeciesModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubgroupSpeciesModelCopyWith<$Res> {
  factory $SubgroupSpeciesModelCopyWith(SubgroupSpeciesModel value,
          $Res Function(SubgroupSpeciesModel) then) =
      _$SubgroupSpeciesModelCopyWithImpl<$Res, SubgroupSpeciesModel>;
  @useResult
  $Res call({int id, String name, String imageUrl});
}

/// @nodoc
class _$SubgroupSpeciesModelCopyWithImpl<$Res,
        $Val extends SubgroupSpeciesModel>
    implements $SubgroupSpeciesModelCopyWith<$Res> {
  _$SubgroupSpeciesModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? imageUrl = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubgroupSpeciesModelImplCopyWith<$Res>
    implements $SubgroupSpeciesModelCopyWith<$Res> {
  factory _$$SubgroupSpeciesModelImplCopyWith(_$SubgroupSpeciesModelImpl value,
          $Res Function(_$SubgroupSpeciesModelImpl) then) =
      __$$SubgroupSpeciesModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name, String imageUrl});
}

/// @nodoc
class __$$SubgroupSpeciesModelImplCopyWithImpl<$Res>
    extends _$SubgroupSpeciesModelCopyWithImpl<$Res, _$SubgroupSpeciesModelImpl>
    implements _$$SubgroupSpeciesModelImplCopyWith<$Res> {
  __$$SubgroupSpeciesModelImplCopyWithImpl(_$SubgroupSpeciesModelImpl _value,
      $Res Function(_$SubgroupSpeciesModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? imageUrl = null,
  }) {
    return _then(_$SubgroupSpeciesModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubgroupSpeciesModelImpl implements _SubgroupSpeciesModel {
  const _$SubgroupSpeciesModelImpl(
      {required this.id, required this.name, required this.imageUrl});

  factory _$SubgroupSpeciesModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubgroupSpeciesModelImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String imageUrl;

  @override
  String toString() {
    return 'SubgroupSpeciesModel(id: $id, name: $name, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubgroupSpeciesModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, imageUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SubgroupSpeciesModelImplCopyWith<_$SubgroupSpeciesModelImpl>
      get copyWith =>
          __$$SubgroupSpeciesModelImplCopyWithImpl<_$SubgroupSpeciesModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubgroupSpeciesModelImplToJson(
      this,
    );
  }
}

abstract class _SubgroupSpeciesModel implements SubgroupSpeciesModel {
  const factory _SubgroupSpeciesModel(
      {required final int id,
      required final String name,
      required final String imageUrl}) = _$SubgroupSpeciesModelImpl;

  factory _SubgroupSpeciesModel.fromJson(Map<String, dynamic> json) =
      _$SubgroupSpeciesModelImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get imageUrl;
  @override
  @JsonKey(ignore: true)
  _$$SubgroupSpeciesModelImplCopyWith<_$SubgroupSpeciesModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
