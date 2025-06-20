import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AssetsState extends Equatable {
  final Map<String, Color> routeColors;
  final Map<String, dynamic> routeIdToRouteName;
  final Map<String, BitmapDescriptor> markerImages;

  const AssetsState({
    required this.routeColors,
    required this.routeIdToRouteName,
    required this.markerImages,
  });

  factory AssetsState.initial() => const AssetsState(
        routeColors: {},
        routeIdToRouteName: {},
        markerImages: {},
      );

  AssetsState copyWith({
    Map<String, Color>? routeColors,
    Map<String, dynamic>? routeIdToRouteName,
    Map<String, BitmapDescriptor>? markerImages,
  }) {
    return AssetsState(
      routeColors: routeColors ?? this.routeColors,
      routeIdToRouteName: routeIdToRouteName ?? this.routeIdToRouteName,
      markerImages: markerImages ?? this.markerImages,
    );
  }

  @override
  List<Object?> get props => [routeColors, routeIdToRouteName, markerImages];
} 