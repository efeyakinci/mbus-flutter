import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:bitmap/bitmap.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logging/logging.dart';
import 'package:mbus/state/app_state.dart';
import 'package:mbus/constants.dart';
import 'package:mbus/mbus_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mbus/preferences_keys.dart';

class AssetLoader {
  final AppState appState = AppState();
  final log = Logger("AssetLoader");

  Future<void> checkNewAssets(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int curInfoVersion = prefs.getInt('curInfoVersion') ?? -1;
    DateTime prevCheck = DateTime.parse(
        prefs.getString("lastCheckedAssets") ?? "1969-07-20 20:18:04Z");
    int serverInfoVersion = -1;

    try {
      final res = jsonDecode(await NetworkUtils.getWithErrorHandling(
          context, "getRouteInfoVersion"));

      serverInfoVersion = res['version'] ?? 0;
      final Map<String, dynamic> storedInfo =
          jsonDecode(prefs.getString(PrefKeys.routeInformation) ?? "{}");

      if (curInfoVersion < serverInfoVersion ||
          storedInfo.isEmpty ||
          DateTime.now().difference(prevCheck).inDays > 5) {
        bool isColorBlindMode = prefs.getBool(PrefKeys.colorBlindEnabled) ?? false;
        final res = jsonDecode(await NetworkUtils.getWithErrorHandling(context,
            'getRouteInformation?colorblind=${isColorBlindMode ? "Y" : "N"}'));

        if (res['metadata'] != null &&
            res['metadata']?['version'] != null &&
            res['metadata']['version'] is int) {
          await DefaultCacheManager().emptyCache();
          await prefs.setString('lastCheckedAssets', DateTime.now().toString());
          await prefs.setInt('curInfoVersion', res['metadata']['version']);
          await prefs.setString(PrefKeys.routeInformation, jsonEncode(res));
          appState.updateRouteInformation(res);
        }
      } else {
        appState.updateRouteInformation(storedInfo);
        log.info("Got new assets");
      }
    } catch (e, stacktrace) {
      log.severe("Error checking for new assets", e, stacktrace);
    }
  }

  Future<BitmapDescriptor> getBusBitmap(String pathToImage,
      {int width = 124}) async {
    final image_bmap = await Bitmap.fromProvider(AssetImage(pathToImage));
    final image = BitmapDescriptor.fromBytes(
        image_bmap.apply(BitmapResize.to(width: width)).buildHeaded());
    return image;
  }

  Future<void> loadBusImages(BuildContext context) async {
    final BUS_WIDTH = (MediaQuery.of(context).devicePixelRatio * 40).toInt();
    final STOP_WIDTH = (MediaQuery.of(context).devicePixelRatio * 22).toInt();

    final markerImages = appState.markerImages;
    markerImages["BUS_STOP"] =
        await getBusBitmap("assets/bus_stop.png", width: STOP_WIDTH);

    final prefs = await SharedPreferences.getInstance();
    final isColorblind = prefs.getBool(PrefKeys.colorBlindEnabled) ?? false;

    for (String routeIdentifier
        in appState.routeIdToRouteName.keys) {
      late ImageProvider _provider;

      _provider = await CachedNetworkImageProvider(
          "$BACKEND_URL/getVehicleImage/$routeIdentifier?colorblind=${isColorblind ? "Y" : "N"}",
          errorListener: (final error) {
        log.warning(
            "Error loading bus image for $routeIdentifier: $error | Request sent to: $BACKEND_URL/getVehicleImage/$routeIdentifier?colorblind=${isColorblind ? "Y" : "N"}");
        _provider = AssetImage('assets/bus_blue.png');
      });

      log.info("Loading bus image for $routeIdentifier");

      markerImages[routeIdentifier] = await BitmapDescriptor.fromBytes(
          (await Bitmap.fromProvider(_provider))
              .apply(BitmapResize.to(width: BUS_WIDTH))
              .buildHeaded());
    }
  }
} 