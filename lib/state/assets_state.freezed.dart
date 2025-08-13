// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assets_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AssetsState {
  Map<String, Color> get routeColors;
  Map<String, dynamic> get routeIdToRouteName;
  Map<String, BitmapDescriptor> get markerImages;

  /// Create a copy of AssetsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AssetsStateCopyWith<AssetsState> get copyWith =>
      _$AssetsStateCopyWithImpl<AssetsState>(this as AssetsState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AssetsState &&
            const DeepCollectionEquality()
                .equals(other.routeColors, routeColors) &&
            const DeepCollectionEquality()
                .equals(other.routeIdToRouteName, routeIdToRouteName) &&
            const DeepCollectionEquality()
                .equals(other.markerImages, markerImages));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(routeColors),
      const DeepCollectionEquality().hash(routeIdToRouteName),
      const DeepCollectionEquality().hash(markerImages));

  @override
  String toString() {
    return 'AssetsState(routeColors: $routeColors, routeIdToRouteName: $routeIdToRouteName, markerImages: $markerImages)';
  }
}

/// @nodoc
abstract mixin class $AssetsStateCopyWith<$Res> {
  factory $AssetsStateCopyWith(
          AssetsState value, $Res Function(AssetsState) _then) =
      _$AssetsStateCopyWithImpl;
  @useResult
  $Res call(
      {Map<String, Color> routeColors,
      Map<String, dynamic> routeIdToRouteName,
      Map<String, BitmapDescriptor> markerImages});
}

/// @nodoc
class _$AssetsStateCopyWithImpl<$Res> implements $AssetsStateCopyWith<$Res> {
  _$AssetsStateCopyWithImpl(this._self, this._then);

  final AssetsState _self;
  final $Res Function(AssetsState) _then;

  /// Create a copy of AssetsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? routeColors = null,
    Object? routeIdToRouteName = null,
    Object? markerImages = null,
  }) {
    return _then(_self.copyWith(
      routeColors: null == routeColors
          ? _self.routeColors
          : routeColors // ignore: cast_nullable_to_non_nullable
              as Map<String, Color>,
      routeIdToRouteName: null == routeIdToRouteName
          ? _self.routeIdToRouteName
          : routeIdToRouteName // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      markerImages: null == markerImages
          ? _self.markerImages
          : markerImages // ignore: cast_nullable_to_non_nullable
              as Map<String, BitmapDescriptor>,
    ));
  }
}

/// @nodoc

class _AssetsState implements AssetsState {
  const _AssetsState(
      {final Map<String, Color> routeColors = const <String, Color>{},
      final Map<String, dynamic> routeIdToRouteName = const <String, dynamic>{},
      final Map<String, BitmapDescriptor> markerImages =
          const <String, BitmapDescriptor>{}})
      : _routeColors = routeColors,
        _routeIdToRouteName = routeIdToRouteName,
        _markerImages = markerImages;

  final Map<String, Color> _routeColors;
  @override
  @JsonKey()
  Map<String, Color> get routeColors {
    if (_routeColors is EqualUnmodifiableMapView) return _routeColors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_routeColors);
  }

  final Map<String, dynamic> _routeIdToRouteName;
  @override
  @JsonKey()
  Map<String, dynamic> get routeIdToRouteName {
    if (_routeIdToRouteName is EqualUnmodifiableMapView)
      return _routeIdToRouteName;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_routeIdToRouteName);
  }

  final Map<String, BitmapDescriptor> _markerImages;
  @override
  @JsonKey()
  Map<String, BitmapDescriptor> get markerImages {
    if (_markerImages is EqualUnmodifiableMapView) return _markerImages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_markerImages);
  }

  /// Create a copy of AssetsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AssetsStateCopyWith<_AssetsState> get copyWith =>
      __$AssetsStateCopyWithImpl<_AssetsState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AssetsState &&
            const DeepCollectionEquality()
                .equals(other._routeColors, _routeColors) &&
            const DeepCollectionEquality()
                .equals(other._routeIdToRouteName, _routeIdToRouteName) &&
            const DeepCollectionEquality()
                .equals(other._markerImages, _markerImages));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_routeColors),
      const DeepCollectionEquality().hash(_routeIdToRouteName),
      const DeepCollectionEquality().hash(_markerImages));

  @override
  String toString() {
    return 'AssetsState(routeColors: $routeColors, routeIdToRouteName: $routeIdToRouteName, markerImages: $markerImages)';
  }
}

/// @nodoc
abstract mixin class _$AssetsStateCopyWith<$Res>
    implements $AssetsStateCopyWith<$Res> {
  factory _$AssetsStateCopyWith(
          _AssetsState value, $Res Function(_AssetsState) _then) =
      __$AssetsStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Map<String, Color> routeColors,
      Map<String, dynamic> routeIdToRouteName,
      Map<String, BitmapDescriptor> markerImages});
}

/// @nodoc
class __$AssetsStateCopyWithImpl<$Res> implements _$AssetsStateCopyWith<$Res> {
  __$AssetsStateCopyWithImpl(this._self, this._then);

  final _AssetsState _self;
  final $Res Function(_AssetsState) _then;

  /// Create a copy of AssetsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? routeColors = null,
    Object? routeIdToRouteName = null,
    Object? markerImages = null,
  }) {
    return _then(_AssetsState(
      routeColors: null == routeColors
          ? _self._routeColors
          : routeColors // ignore: cast_nullable_to_non_nullable
              as Map<String, Color>,
      routeIdToRouteName: null == routeIdToRouteName
          ? _self._routeIdToRouteName
          : routeIdToRouteName // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      markerImages: null == markerImages
          ? _self._markerImages
          : markerImages // ignore: cast_nullable_to_non_nullable
              as Map<String, BitmapDescriptor>,
    ));
  }
}

// dart format on
