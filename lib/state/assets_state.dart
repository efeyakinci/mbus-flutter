import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'assets_state.freezed.dart';

@freezed
abstract class AssetsState with _$AssetsState {
  const factory AssetsState({
    @Default(<String, Color>{}) Map<String, Color> routeColors,
    @Default(<String, dynamic>{}) Map<String, dynamic> routeIdToRouteName,
    @Default(<String, BitmapDescriptor>{})
    Map<String, BitmapDescriptor> markerImages,
  }) = _AssetsState;

  factory AssetsState.initial() => const AssetsState();
}
