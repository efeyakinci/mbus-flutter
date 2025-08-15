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
  Map<MarkerId, Marker> _startMarkers = {};
  Map<MarkerId, Marker> _targetMarkers = {};
  bool _hasPending = false;
  Set<Marker>? _pendingDynamicMarkers;
  int? mapId;
  GoogleMapController? _gController;
  bool? _lastIsDark;
  static const int _targetFps = 15;
  late final Duration _minFrameGap =
      Duration(milliseconds: (1000 / _targetFps).floor());
  Duration _lastPaint = Duration.zero;
  static const CameraPosition _annArbor = CameraPosition(
    target: ANN_ARBOR,
    zoom: 14.4746,
  );

  double _shortestAngleDelta(double fromDeg, double toDeg) {
    double delta = (toDeg - fromDeg + 540) % 360 - 180;
    return delta;
  }

  void _startAnimation(Set<Marker> newDynamicMarkers) {
    _targetMarkers = {
      for (final m in newDynamicMarkers) m.markerId: m,
    };

    if (_startMarkers.isEmpty) {
      curMarkers = newDynamicMarkers;
      _startMarkers = Map.of(_targetMarkers);
      setState(() {});
      return;
    }

    _lastPaint = Duration.zero;
    _controller.forward(from: 0);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    curved.addListener(() {
      final now = _controller.lastElapsedDuration ?? Duration.zero;
      if (now - _lastPaint < _minFrameGap) return;
      _lastPaint = now;
      _paintInterpolated(curved.value);
    });
    _controller.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _paintInterpolated(1.0);
        _onAnimationDone();
      }
    });
  }

  void _paintInterpolated(double t) {
    final interpolated = <Marker>{};
    for (final entry in _targetMarkers.entries) {
      final MarkerId id = entry.key;
      final Marker target = entry.value;
      final Marker start = _startMarkers[id] ?? target;
      final double lat = start.position.latitude +
          (target.position.latitude - start.position.latitude) * t;
      final double lng =
          _lerpLng(start.position.longitude, target.position.longitude, t);
      final double rot = start.rotation +
          _shortestAngleDelta(start.rotation, target.rotation) * t;
      interpolated.add(Marker(
        markerId: id,
        anchor: target.anchor,
        onTap: target.onTap,
        icon: target.icon,
        position: LatLng(lat, lng),
        rotation: rot,
        zIndex: target.zIndex,
        consumeTapEvents: target.consumeTapEvents,
      ));
    }
    setState(() {
      curMarkers = interpolated;
    });
  }

  void _onAnimationDone() {
    _startMarkers = Map.of(_targetMarkers);
    if (_hasPending && _pendingDynamicMarkers != null) {
      _hasPending = false;
      final pending = _pendingDynamicMarkers!;
      _pendingDynamicMarkers = null;
      _lastPaint = Duration.zero;
      _startAnimation(pending);
    }
  }

  double _lerpLng(double startLng, double endLng, double t) {
    double s = startLng;
    double e = endLng;
    double delta = e - s;
    if (delta > 180) s += 360;
    if (delta < -180) e += 360;
    double value = s + (e - s) * t;
    if (value > 180) value -= 360;
    if (value < -180) value += 360;
    return value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MarkerAnimator oldWidget) {
    final incoming = widget.dynamicMarkers;
    if (_controller.isAnimating) {
      _hasPending = true;
      _pendingDynamicMarkers = incoming;
    } else {
      _startMarkers = {
        for (final m in oldWidget.dynamicMarkers) m.markerId: m,
      };
      _startAnimation(incoming);
    }
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
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
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
