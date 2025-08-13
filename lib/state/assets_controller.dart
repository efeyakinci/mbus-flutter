import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:mbus/constants.dart';
import 'package:mbus/preferences_keys.dart';
import 'package:mbus/data/providers.dart';
import 'package:mbus/repositories/assets_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'assets_state.dart';

final assetsProvider =
    AsyncNotifierProvider<AssetsController, AssetsState>(AssetsController.new);

// Derived providers replacing AppState fields
final routeMetaProvider = Provider<({
  Map<String, Color> routeColors,
  Map<String, dynamic> routeIdToName,
})>((ref) {
  final assets = ref.watch(assetsProvider).valueOrNull ?? AssetsState.initial();
  return (routeColors: assets.routeColors, routeIdToName: assets.routeIdToRouteName);
});

final markerImagesProvider = Provider<Map<String, BitmapDescriptor>>((ref) {
  final assets = ref.watch(assetsProvider).valueOrNull ?? AssetsState.initial();
  return assets.markerImages;
});

class AssetsController extends AsyncNotifier<AssetsState> {
  late final AssetsRepository _assetsRepository;

  @override
  Future<AssetsState> build() async {
    _assetsRepository = ref.read(assetsRepositoryProvider);
    // Seed initial from stored route information if present
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(PrefKeys.routeInformation);
    if (stored != null && stored.isNotEmpty) {
      final json = jsonDecode(stored) as Map<String, dynamic>;
      final colorsJson = (json['routeColors'] ?? {}) as Map<String, dynamic>;
      final routeIdToName = (json['routeIdToName'] ?? {}) as Map<String, dynamic>;
      final colors = <String, Color>{
        for (final entry in colorsJson.entries)
          entry.key: Color(int.parse(entry.value.toString()))
      };
      return AssetsState(
        routeColors: colors,
        routeIdToRouteName: routeIdToName,
        markerImages: {},
      );
    }
    return AssetsState.initial();
  }

  // Refresh route info and marker images; forceRouteInfo skips version/time gating
  Future<void> refreshAssets({required double devicePixelRatio, bool forceRouteInfo = false}) async {
    await _assetsRepository.checkNewAssets(forceRouteInfoRefresh: forceRouteInfo);

    // Pull from the singleton AppLoader writes (updateRouteInformation previously notified)
    // But now read from SharedPreferences routeInformation to rebuild state consistently
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(PrefKeys.routeInformation);
    if (stored == null || stored.isEmpty) return;
    final json = jsonDecode(stored) as Map<String, dynamic>;
    final colorsJson = (json['routeColors'] ?? {}) as Map<String, dynamic>;
    final routeIdToName = (json['routeIdToName'] ?? {}) as Map<String, dynamic>;
    final colors = <String, Color>{
      for (final entry in colorsJson.entries)
        entry.key: Color(int.parse(entry.value.toString()))
    };

    final busWidth = (devicePixelRatio * 40).toInt();
    final stopWidth = (devicePixelRatio * 22).toInt();

    final images = await _assetsRepository.loadBusImages(
      busWidth: busWidth,
      stopWidth: stopWidth,
      routeIdToRouteName: routeIdToName,
    );

    // Marker images are loaded into AppState today; rebuild them here as an empty map.
    // They will be set by loadBusImages via AppState for now; we will migrate fully below.
    state = AsyncData(
      AssetsState(
        routeColors: colors,
        routeIdToRouteName: routeIdToName,
        markerImages: images,
      ),
    );
  }
}

// A global navigator key provider to access context while away from widgets.
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  throw UnimplementedError('Navigator key not set');
});