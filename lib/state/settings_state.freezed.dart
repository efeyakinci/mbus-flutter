// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SettingsState {
  bool get isColorBlind;
  bool get isDarkMode;
  bool get hasOnboarded;
  List<String> get selectedRouteIds;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SettingsStateCopyWith<SettingsState> get copyWith =>
      _$SettingsStateCopyWithImpl<SettingsState>(
          this as SettingsState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SettingsState &&
            (identical(other.isColorBlind, isColorBlind) ||
                other.isColorBlind == isColorBlind) &&
            (identical(other.hasOnboarded, hasOnboarded) ||
                other.hasOnboarded == hasOnboarded) &&
            const DeepCollectionEquality()
                .equals(other.selectedRouteIds, selectedRouteIds));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isColorBlind, hasOnboarded,
      const DeepCollectionEquality().hash(selectedRouteIds));

  @override
  String toString() {
    return 'SettingsState(isColorBlind: $isColorBlind, hasOnboarded: $hasOnboarded, selectedRouteIds: $selectedRouteIds)';
  }
}

/// @nodoc
abstract mixin class $SettingsStateCopyWith<$Res> {
  factory $SettingsStateCopyWith(
          SettingsState value, $Res Function(SettingsState) _then) =
      _$SettingsStateCopyWithImpl;
  @useResult
  $Res call(
      {bool isColorBlind,
      bool isDarkMode,
      bool hasOnboarded,
      List<String> selectedRouteIds});
}

/// @nodoc
class _$SettingsStateCopyWithImpl<$Res>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._self, this._then);

  final SettingsState _self;
  final $Res Function(SettingsState) _then;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isColorBlind = null,
    Object? isDarkMode = null,
    Object? hasOnboarded = null,
    Object? selectedRouteIds = null,
  }) {
    return _then(_self.copyWith(
      isColorBlind: null == isColorBlind
          ? _self.isColorBlind
          : isColorBlind // ignore: cast_nullable_to_non_nullable
              as bool,
      isDarkMode: null == isDarkMode
          ? _self.isDarkMode
          : isDarkMode // ignore: cast_nullable_to_non_nullable
              as bool,
      hasOnboarded: null == hasOnboarded
          ? _self.hasOnboarded
          : hasOnboarded // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedRouteIds: null == selectedRouteIds
          ? _self.selectedRouteIds
          : selectedRouteIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _SettingsState implements SettingsState {
  const _SettingsState(
      {this.isColorBlind = false,
      this.isDarkMode = false,
      this.hasOnboarded = false,
      final List<String> selectedRouteIds = const <String>[]})
      : _selectedRouteIds = selectedRouteIds;

  @override
  @JsonKey()
  final bool isColorBlind;
  @override
  @JsonKey()
  final bool isDarkMode;
  @override
  @JsonKey()
  final bool hasOnboarded;
  final List<String> _selectedRouteIds;
  @override
  @JsonKey()
  List<String> get selectedRouteIds {
    if (_selectedRouteIds is EqualUnmodifiableListView)
      return _selectedRouteIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedRouteIds);
  }

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SettingsStateCopyWith<_SettingsState> get copyWith =>
      __$SettingsStateCopyWithImpl<_SettingsState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SettingsState &&
            (identical(other.isColorBlind, isColorBlind) ||
                other.isColorBlind == isColorBlind) &&
            (identical(other.hasOnboarded, hasOnboarded) ||
                other.hasOnboarded == hasOnboarded) &&
            const DeepCollectionEquality()
                .equals(other._selectedRouteIds, _selectedRouteIds));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isColorBlind, hasOnboarded,
      const DeepCollectionEquality().hash(_selectedRouteIds));

  @override
  String toString() {
    return 'SettingsState(isColorBlind: $isColorBlind, isDarkMode: $isDarkMode, hasOnboarded: $hasOnboarded, selectedRouteIds: $selectedRouteIds)';
  }
}

/// @nodoc
abstract mixin class _$SettingsStateCopyWith<$Res>
    implements $SettingsStateCopyWith<$Res> {
  factory _$SettingsStateCopyWith(
          _SettingsState value, $Res Function(_SettingsState) _then) =
      __$SettingsStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool isColorBlind,
      bool isDarkMode,
      bool hasOnboarded,
      List<String> selectedRouteIds});
}

/// @nodoc
class __$SettingsStateCopyWithImpl<$Res>
    implements _$SettingsStateCopyWith<$Res> {
  __$SettingsStateCopyWithImpl(this._self, this._then);

  final _SettingsState _self;
  final $Res Function(_SettingsState) _then;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isColorBlind = null,
    Object? isDarkMode = null,
    Object? hasOnboarded = null,
    Object? selectedRouteIds = null,
  }) {
    return _then(_SettingsState(
      isColorBlind: null == isColorBlind
          ? _self.isColorBlind
          : isColorBlind // ignore: cast_nullable_to_non_nullable
              as bool,
      isDarkMode: null == isDarkMode
          ? _self.isDarkMode
          : isDarkMode // ignore: cast_nullable_to_non_nullable
              as bool,
      hasOnboarded: null == hasOnboarded
          ? _self.hasOnboarded
          : hasOnboarded // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedRouteIds: null == selectedRouteIds
          ? _self._selectedRouteIds
          : selectedRouteIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

// dart format on
