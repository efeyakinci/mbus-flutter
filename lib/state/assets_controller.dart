import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mbus/preferences_keys.dart';
import 'package:mbus/data/providers.dart';
import 'package:mbus/repositories/assets_repository.dart';
import 'package:mbus/state/settings_controller.dart';
import 'package:mbus/state/settings_state.dart';

import 'assets_state.dart';

final assetsProvider =
    AsyncNotifierProvider<AssetsController, AssetsState>(AssetsController.new);

final routeMetaProvider = Provider<
    ({
      Map<String, Color> routeColors,
      Map<String, dynamic> routeIdToName,
    })>((ref) {
  final assets = ref.watch(assetsProvider).valueOrNull ?? AssetsState.initial();
  return (
    routeColors: assets.routeColors,
    routeIdToName: assets.routeIdToRouteName,
  );
});

final markerImagesProvider = Provider<Map<String, BitmapDescriptor>>((ref) {
  final assets = ref.watch(assetsProvider).valueOrNull ?? AssetsState.initial();
  return assets.markerImages;
});

class AssetsController extends AsyncNotifier<AssetsState> {
  late final AssetsRepository _assetsRepository;
  double? _lastDpr;
  Timer? _debounce;
  int _token = 0;

  @override
  Future<AssetsState> build() async {
    _assetsRepository = ref.read(assetsRepositoryProvider);

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(PrefKeys.routeInformation);
    if (stored != null && stored.isNotEmpty) {
      final json = jsonDecode(stored) as Map<String, dynamic>;
      final colorsJson = (json['routeColors'] ?? {}) as Map<String, dynamic>;
      final routeIdToName =
          (json['routeIdToName'] ?? {}) as Map<String, dynamic>;
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

    ref.listen<SettingsState>(settingsProvider,
        (SettingsState? prev, SettingsState next) {
      if (_lastDpr == null) return;
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 120), () {
        _refreshInternal(
          devicePixelRatio: _lastDpr!,
          forceRouteInfo: true,
          settings: next,
        );
      });
    });

    return AssetsState.initial();
  }

  Future<void> refreshAssets({
    required double devicePixelRatio,
    bool forceRouteInfo = false,
    SettingsState? settings,
  }) async {
    _lastDpr = devicePixelRatio;
    final SettingsState effectiveSettings =
        settings ?? ref.read(settingsProvider);
    await _refreshInternal(
      devicePixelRatio: devicePixelRatio,
      forceRouteInfo: forceRouteInfo,
      settings: effectiveSettings,
    );
  }

  Future<void> _refreshInternal({
    required double devicePixelRatio,
    required bool forceRouteInfo,
    required SettingsState settings,
  }) async {
    final myToken = ++_token;
    await _assetsRepository.checkNewAssets(
      forceRouteInfoRefresh: forceRouteInfo,
      settings: settings,
    );

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
      settings: settings,
    );

    if (myToken == _token) {
      state = AsyncData(
        AssetsState(
          routeColors: colors,
          routeIdToRouteName: routeIdToName,
          markerImages: images,
        ),
      );
    }
  }
}

final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  throw UnimplementedError('Navigator key not set');
});
