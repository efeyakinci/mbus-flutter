import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bitmap/bitmap.dart';
import 'package:mbus/data/api_client.dart';
import 'package:mbus/preferences_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mbus/constants.dart';

class AssetsRepository {
  final MBusApiClient api;
  AssetsRepository(this.api);

  Future<void> checkNewAssets({bool forceRouteInfoRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final curInfoVersion = prefs.getInt('curInfoVersion') ?? -1;
    final prevCheck = DateTime.parse(
        prefs.getString('lastCheckedAssets') ?? '1969-07-20 20:18:04Z');

    final serverInfoVersion = await api.getRouteInfoVersion();

    final storedInfo = prefs.getString(PrefKeys.routeInformation) ?? '';
    final storedJson = storedInfo.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(storedInfo) as Map<String, dynamic>;

    if (forceRouteInfoRefresh ||
        curInfoVersion < serverInfoVersion ||
        storedJson.isEmpty ||
        DateTime.now().difference(prevCheck).inDays > 5) {
      final isColorBlind = prefs.getBool(PrefKeys.colorBlindEnabled) ?? false;
      final routeInfo = await api.getRouteInformation(colorblind: isColorBlind);
      final metadata = routeInfo.json['metadata'];
      if (metadata is Map && metadata['version'] is int) {
        await DefaultCacheManager().emptyCache();
        await prefs.setString('lastCheckedAssets', DateTime.now().toString());
        await prefs.setInt('curInfoVersion', metadata['version'] as int);
        await prefs.setString(
            PrefKeys.routeInformation, jsonEncode(routeInfo.json));
      }
    }
  }

  Future<BitmapDescriptor> _bitmapFromAsset(String assetPath, {required int width}) async {
    final image = await Bitmap.fromProvider(AssetImage(assetPath));
    return BitmapDescriptor.fromBytes(image.apply(BitmapResize.to(width: width)).buildHeaded());
  }

  Future<Map<String, BitmapDescriptor>> loadBusImages({
    required int busWidth,
    required int stopWidth,
    required Map<String, dynamic> routeIdToRouteName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final isColorblind = prefs.getBool(PrefKeys.colorBlindEnabled) ?? false;

    final images = <String, BitmapDescriptor>{};
    images['BUS_STOP'] =
        await _bitmapFromAsset('assets/bus_stop.png', width: stopWidth);

    for (final routeIdentifier in routeIdToRouteName.keys) {
      ImageProvider provider;
      provider = CachedNetworkImageProvider(
        "$BACKEND_URL/getVehicleImage/$routeIdentifier?colorblind=${isColorblind ? 'Y' : 'N'}",
        errorListener: (_) {},
      );
      try {
        final bmp = await Bitmap.fromProvider(provider);
        images[routeIdentifier] = BitmapDescriptor.fromBytes(
            bmp.apply(BitmapResize.to(width: busWidth)).buildHeaded());
      } catch (_) {
        images[routeIdentifier] = await _bitmapFromAsset('assets/bus_blue.png', width: busWidth);
      }
    }

    return images;
  }
}


