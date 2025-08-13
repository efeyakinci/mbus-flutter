// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'route_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RouteData {
  String get routeId;
  String get routeName;

  /// Create a copy of RouteData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RouteDataCopyWith<RouteData> get copyWith =>
      _$RouteDataCopyWithImpl<RouteData>(this as RouteData, _$identity);

  /// Serializes this RouteData to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RouteData &&
            (identical(other.routeId, routeId) || other.routeId == routeId) &&
            (identical(other.routeName, routeName) ||
                other.routeName == routeName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, routeId, routeName);

  @override
  String toString() {
    return 'RouteData(routeId: $routeId, routeName: $routeName)';
  }
}

/// @nodoc
abstract mixin class $RouteDataCopyWith<$Res> {
  factory $RouteDataCopyWith(RouteData value, $Res Function(RouteData) _then) =
      _$RouteDataCopyWithImpl;
  @useResult
  $Res call({String routeId, String routeName});
}

/// @nodoc
class _$RouteDataCopyWithImpl<$Res> implements $RouteDataCopyWith<$Res> {
  _$RouteDataCopyWithImpl(this._self, this._then);

  final RouteData _self;
  final $Res Function(RouteData) _then;

  /// Create a copy of RouteData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? routeId = null,
    Object? routeName = null,
  }) {
    return _then(_self.copyWith(
      routeId: null == routeId
          ? _self.routeId
          : routeId // ignore: cast_nullable_to_non_nullable
              as String,
      routeName: null == routeName
          ? _self.routeName
          : routeName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _RouteData implements RouteData {
  const _RouteData({required this.routeId, required this.routeName});
  factory _RouteData.fromJson(Map<String, dynamic> json) =>
      _$RouteDataFromJson(json);

  @override
  final String routeId;
  @override
  final String routeName;

  /// Create a copy of RouteData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RouteDataCopyWith<_RouteData> get copyWith =>
      __$RouteDataCopyWithImpl<_RouteData>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$RouteDataToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RouteData &&
            (identical(other.routeId, routeId) || other.routeId == routeId) &&
            (identical(other.routeName, routeName) ||
                other.routeName == routeName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, routeId, routeName);

  @override
  String toString() {
    return 'RouteData(routeId: $routeId, routeName: $routeName)';
  }
}

/// @nodoc
abstract mixin class _$RouteDataCopyWith<$Res>
    implements $RouteDataCopyWith<$Res> {
  factory _$RouteDataCopyWith(
          _RouteData value, $Res Function(_RouteData) _then) =
      __$RouteDataCopyWithImpl;
  @override
  @useResult
  $Res call({String routeId, String routeName});
}

/// @nodoc
class __$RouteDataCopyWithImpl<$Res> implements _$RouteDataCopyWith<$Res> {
  __$RouteDataCopyWithImpl(this._self, this._then);

  final _RouteData _self;
  final $Res Function(_RouteData) _then;

  /// Create a copy of RouteData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? routeId = null,
    Object? routeName = null,
  }) {
    return _then(_RouteData(
      routeId: null == routeId
          ? _self.routeId
          : routeId // ignore: cast_nullable_to_non_nullable
              as String,
      routeName: null == routeName
          ? _self.routeName
          : routeName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
