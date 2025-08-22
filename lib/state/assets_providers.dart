import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mbus/constants.dart';
import 'package:mbus/data/providers.dart';
import 'package:mbus/preferences_keys.dart';
import 'package:mbus/state/settings_notifier.dart';

// Immutable snapshot type exposed to consumers
({
  Map<String, Color> routeColors,
  Map<String, dynamic> routeIdToName,
  Map<String, BitmapDescriptor> markerImages,
}) _snapshot({
  required Map<String, Color> colors,
  required Map<String, dynamic> idToName,
  required Map<String, BitmapDescriptor> images,
}) =>
    (
      routeColors: Map.unmodifiable(colors),
      routeIdToName: Map.unmodifiable(idToName),
      markerImages: Map.unmodifiable(images),
    );

// Device pixel ratio supplied from widgets with BuildContext
final devicePixelRatioProvider = StateProvider<double>((ref) => 2.0);

final assetsSnapshotProvider = FutureProvider<
    ({
      Map<String, Color> routeColors,
      Map<String, dynamic> routeIdToName,
      Map<String, BitmapDescriptor> markerImages,
    })>((ref) async {
  final api = ref.read(apiClientProvider);
  final prefs = await ref.read(sharedPreferencesProvider.future);
  final isColorBlind =
      ref.watch(settingsNotifierProvider.select((s) => s.isColorBlind));

  final curInfoVersion = prefs.getInt('curInfoVersion') ?? -1;
  final prevCheck = DateTime.parse(
      prefs.getString('lastCheckedAssets') ?? '1969-07-20 20:18:04Z');

  final serverInfoVersion = await api.getRouteInfoVersion();

  final storedInfo = prefs.getString(PrefKeys.routeInformation) ?? '';
  final storedJson = storedInfo.isEmpty
      ? <String, dynamic>{}
      : jsonDecode(storedInfo) as Map<String, dynamic>;

  final lastCb = prefs.getBool('lastColorBlind');
  final colorBlindChanged = (lastCb == null) || (lastCb != isColorBlind);

  if (colorBlindChanged ||
      curInfoVersion < serverInfoVersion ||
      storedJson.isEmpty ||
      DateTime.now().difference(prevCheck).inDays > 5) {
    final routeInfo = await api.getRouteInformation(colorblind: isColorBlind);
    final metadata = routeInfo.json['metadata'];
    if (metadata is! Map || metadata['version'] is! int) {
      throw const FormatException('Invalid route information metadata');
    }
    // Evict only relevant cached URLs to avoid nuking unrelated cache entries
    final routeIdsToEvict =
        (storedJson['routeIdToName'] as Map<String, dynamic>?)?.keys ??
            const Iterable.empty();
    for (final id in routeIdsToEvict) {
      final yUrl = "$BACKEND_URL/getVehicleImage/$id?colorblind=Y";
      final nUrl = "$BACKEND_URL/getVehicleImage/$id?colorblind=N";
      await DefaultCacheManager().removeFile(yUrl);
      await DefaultCacheManager().removeFile(nUrl);
    }
    await prefs.setString('lastCheckedAssets', DateTime.now().toString());
    await prefs.setInt('curInfoVersion', metadata['version'] as int);
    await prefs.setString(
        PrefKeys.routeInformation, jsonEncode(routeInfo.json));
    await prefs.setBool('lastColorBlind', isColorBlind);
  }

  // Read back persisted route metadata and project into cache
  final persisted = prefs.getString(PrefKeys.routeInformation);
  if (persisted == null || persisted.isEmpty) {
    return _snapshot(colors: const {}, idToName: const {}, images: const {});
  }
  final json = jsonDecode(persisted) as Map<String, dynamic>;
  final colorsJson = (json['routeColors'] ?? {}) as Map<String, dynamic>;
  final routeIdToName = (json['routeIdToName'] ?? {}) as Map<String, dynamic>;
  final colors = <String, Color>{
    for (final e in colorsJson.entries)
      e.key: Color(int.parse(e.value.toString()))
  };
  // Load bitmaps (BUS_STOP + per-route), prefer cached network files
  final images = <String, BitmapDescriptor>{};
  final busWidth = 40, stopWidth = 22;
  // Use device pixel ratio supplied by widget tree
  final dpr = ref.watch(devicePixelRatioProvider);
  final busPxWidth = (busWidth * dpr).round();
  final stopPxWidth = (stopWidth * dpr).round();
  // Load stop icon from asset via rootBundle and resize via codec
  final stop = await rootBundle.load('assets/bus_stop.png');
  images['BUS_STOP'] = BitmapDescriptor.bytes(
    await _resizePngBytes(stop.buffer.asUint8List(), stopPxWidth),
    width: stopWidth.toDouble(),
  );
  // Load favorite stop icon
  final stopFav = await rootBundle.load('assets/bus_stop_fav.png');
  images['BUS_STOP_FAV'] = BitmapDescriptor.bytes(
    await _resizePngBytes(stopFav.buffer.asUint8List(), stopPxWidth),
    width: stopWidth.toDouble(),
  );

  final imageLoadTasks = <Future<void>>[];
  for (final routeIdentifier in routeIdToName.keys) {
    final id = routeIdentifier.trim();
    imageLoadTasks.add(() async {
      try {
        final original = await api.getVehicleImageBytes(
          routeId: id,
          colorblind: isColorBlind,
        );
        images[id] = BitmapDescriptor.bytes(
          await _resizePngBytes(original, busPxWidth),
          width: busWidth.toDouble(),
        );
      } catch (_) {
        final fallback = await rootBundle.load('assets/bus_blue.png');
        images[id] = BitmapDescriptor.bytes(
          await _resizePngBytes(fallback.buffer.asUint8List(), busPxWidth),
          width: busWidth.toDouble(),
        );
      }
    }());
  }
  await Future.wait(imageLoadTasks);

  return _snapshot(colors: colors, idToName: routeIdToName, images: images);
});

// Resize arbitrary PNG bytes to a fixed width while preserving aspect ratio
Future<Uint8List> _resizePngBytes(Uint8List bytes, int targetWidth) async {
  final codec = await ui.instantiateImageCodec(bytes, targetWidth: targetWidth);
  final frame = await codec.getNextFrame();
  final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
  if (data == null) {
    throw StateError('Failed to transcode image');
  }
  return data.buffer.asUint8List();
}

final routeMetaProvider = Provider<
    ({
      Map<String, Color> routeColors,
      Map<String, dynamic> routeIdToName,
    })>((ref) {
  final asyncSnap = ref.watch(assetsSnapshotProvider);
  final snap = asyncSnap.maybeWhen(
    data: (s) => s,
    orElse: () => asyncSnap.asData?.value,
  );
  if (snap == null) return (routeColors: const {}, routeIdToName: const {});
  return (routeColors: snap.routeColors, routeIdToName: snap.routeIdToName);
});

final markerImagesProvider = Provider<Map<String, BitmapDescriptor>>((ref) {
  final asyncSnap = ref.watch(assetsSnapshotProvider);
  final snap = asyncSnap.maybeWhen(
    data: (s) => s,
    orElse: () => asyncSnap.asData?.value,
  );
  return snap?.markerImages ?? const {};
});
