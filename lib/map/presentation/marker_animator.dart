import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:mbus/constants.dart';
import 'package:mbus/map/presentation/map_styles.dart';

class MarkerAnimator extends StatefulWidget {
  final Set<Marker> dynamicMarkers;
  final Set<Marker> staticMarkers;
  final Function(CameraPosition) onCameraMove;
  final Set<Polyline> polylines;
  final bool myLocationButtonEnabled;
  final CameraTargetBounds cameraTargetBounds;
  final MinMaxZoomPreference minMaxZoomPreference;
  MarkerAnimator(
      {super.key,
      required this.dynamicMarkers,
      required this.staticMarkers,
      required this.onCameraMove,
      this.polylines = const {},
      this.myLocationButtonEnabled = false,
      required this.cameraTargetBounds,
      required this.minMaxZoomPreference});

  @override
  _MarkerAnimatorState createState() => _MarkerAnimatorState();
}

class _MarkerAnimatorState extends State<MarkerAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Set<Marker> curMarkers = {};
  Map<MarkerId, Marker> prevMarkers = {};
  double tempDiff = 0;
  int? mapId; // unsure
  HashMap<MarkerId, List<double>> markerDeltas = HashMap();
  GoogleMapController? _gController;
  bool? _lastIsDark;
  static const CameraPosition _annArbor = CameraPosition(
    target: ANN_ARBOR,
    zoom: 14.4746,
  );

  void initialize() async {
    _controller.addListener(interpolateMarkers);
  }

  double _calculateRotationDelta(double d1, double d2) {
    tempDiff = (d2 - d1 + 180) % 360 - 180;
    return tempDiff < -180 ? tempDiff + 360 : tempDiff;
  }

  double _clampRotation(double d) {
    return d < 0 ? d + 360 : d;
  }

  void calculateDeltas() {
    Marker oldMarker;
    for (var marker in widget.dynamicMarkers) {
      oldMarker = prevMarkers[marker.markerId] ?? marker;
      markerDeltas[marker.markerId] = [
        oldMarker.position.latitude - marker.position.latitude,
        oldMarker.position.longitude - marker.position.longitude,
        _calculateRotationDelta(oldMarker.rotation, marker.rotation)
      ];
    }
  }

  void interpolateMarkers() {
    setState(() {
      curMarkers = widget.dynamicMarkers.map((Marker marker) {
        final List<double> markerDelta =
            markerDeltas[marker.markerId] ?? const [0, 0, 0];
        final latLng = LatLng(
            marker.position.latitude + markerDelta[0] * _controller.value,
            marker.position.longitude + markerDelta[1] * _controller.value);
        final rotation = _clampRotation(
            marker.rotation - markerDelta[2] * _controller.value);
        return Marker(
            markerId: marker.markerId,
            anchor: marker.anchor,
            onTap: marker.onTap,
            icon: marker.icon,
            position: latLng,
            rotation: rotation);
      }).toSet();
    });
  }

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MarkerAnimator oldWidget) {
    prevMarkers = {
      for (var marker in oldWidget.dynamicMarkers) marker.markerId: marker
    };
    calculateDeltas();
    if (_controller.isAnimating) {
      _controller.value = _controller.lowerBound;
    }
    _controller.value = _controller.upperBound;
    _controller.reverse();

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_gController != null && _lastIsDark != isDark) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _gController?.setMapStyle(isDark ? darkMapStyle : lightMapStyle);
        _lastIsDark = isDark;
      });
    }
    return GoogleMap(
      compassEnabled: false,
      myLocationEnabled: widget.myLocationButtonEnabled,
      onCameraMove: widget.onCameraMove,
      minMaxZoomPreference: widget.minMaxZoomPreference,
      cameraTargetBounds: widget.cameraTargetBounds,
      markers: curMarkers.union(widget.staticMarkers),
      initialCameraPosition: _annArbor,
      polylines: widget.polylines,
      onMapCreated: (gController) => setState(() {
        mapId = gController.mapId;
        _gController = gController;
        gController.setMapStyle(isDark ? darkMapStyle : lightMapStyle);
        _lastIsDark = isDark;
      }),
    );
  }
}
