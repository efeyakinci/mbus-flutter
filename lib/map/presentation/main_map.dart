import 'dart:async';

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mbus/map/bus_tracker_card/bus_tracker_card.dart';
import 'package:mbus/map/presentation/marker_animator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbus/models/route_data.dart';
import 'package:mbus/settings/presentation/settings.dart';
import 'package:mbus/constants.dart';
import 'package:mbus/data/providers.dart';
import 'package:mbus/map/infrastructure/route_repository.dart' as repos;
import 'package:mbus/state/assets_controller.dart';
import 'package:mbus/state/settings_controller.dart';
import 'package:mbus/state/settings_state.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mbus/map/presentation/map_styles.dart';

import 'package:mbus/map/domain/data_types.dart';
import 'package:mbus/map/bus_stop_card/bus_stop_card.dart';

class MyLocationButton extends StatelessWidget {
  final void Function() onClick;

  const MyLocationButton({super.key, required this.onClick});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      child: GestureDetector(
        onTap: onClick,
        child: Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(64),
              boxShadow: const [
                BoxShadow(
                    color: Color(0xAA222234),
                    offset: Offset(1, 1),
                    spreadRadius: 1.0,
                    blurRadius: 4.0)
              ],
              color: isDark
                  ? Theme.of(context).colorScheme.secondary
                  : MICHIGAN_BLUE),
          child: const Center(
            child: _MyLocationIcon(),
          ),
        ),
      ),
    );
  }
}

class _MyLocationIcon extends StatelessWidget {
  const _MyLocationIcon();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Icon(
      Icons.my_location,
      color: isDark ? MICHIGAN_BLUE : MICHIGAN_MAIZE,
      size: 24,
    );
  }
}

class MapButtons extends StatelessWidget {
  final Function(Set<RouteData>) onRouteButtonClick;
  final Function() onLocationClick;

  const MapButtons(
      {super.key,
      required this.onRouteButtonClick,
      required this.onLocationClick});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(),
          ),
          RouteChooser(onRouteButtonClick: onRouteButtonClick),
          MyLocationButton(onClick: onLocationClick)
        ],
      ),
    ));
  }
}

class MainGmap extends StatefulWidget {
  final Completer<GoogleMapController> mapController;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final bool showMyLocation;
  final Function setMapRotation;

  const MainGmap(
      {super.key,
      required this.mapController,
      required this.markers,
      required this.polylines,
      required this.showMyLocation,
      required this.setMapRotation});

  @override
  State<MainGmap> createState() => _MainGmapState();
}

class _MainGmapState extends State<MainGmap> {
  GoogleMapController? _controller;
  bool? _lastIsDark;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_controller != null && _lastIsDark != isDark) {
      _controller!.setMapStyle(isDark ? darkMapStyle : lightMapStyle);
      _lastIsDark = isDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    const CameraPosition annArbor = CameraPosition(
      target: LatLng(42.278235, -83.738118),
      zoom: 14.4746,
    );
    return GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: annArbor,
        onMapCreated: (controller) {
          widget.mapController.complete(controller);
          _controller = controller;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          controller.setMapStyle(isDark ? darkMapStyle : lightMapStyle);
          _lastIsDark = isDark;
        },
        onCameraMove: (CameraPosition position) {
          widget.setMapRotation(position.bearing);
        },
        markers: widget.markers,
        cameraTargetBounds: CameraTargetBounds(LatLngBounds(
            southwest: const LatLng(42.160243, -83.893041),
            northeast: const LatLng(42.347612, -83.606753))),
        myLocationButtonEnabled: false,
        minMaxZoomPreference: const MinMaxZoomPreference(11, 100),
        myLocationEnabled: widget.showMyLocation,
        polylines: widget.polylines);
  }
}

class MainAndroidMap extends StatelessWidget {
  final Completer<GoogleMapController> mapController;
  final Set<Polyline> routeLines;
  final Set<Marker> staticMarkers;
  final Set<Marker> dynamicMarkers;
  final bool showMyLocation;
  final Function setMapRotation;

  const MainAndroidMap(
      {super.key,
      required this.mapController,
      required this.routeLines,
      required this.staticMarkers,
      required this.dynamicMarkers,
      required this.showMyLocation,
      required this.setMapRotation});
  @override
  Widget build(BuildContext context) {
    return MarkerAnimator(
        onCameraMove: (CameraPosition position) {
          setMapRotation(position.bearing);
        },
        cameraTargetBounds: CameraTargetBounds(LatLngBounds(
            southwest: const LatLng(42.160243, -83.893041),
            northeast: const LatLng(42.347612, -83.606753))),
        myLocationButtonEnabled: showMyLocation,
        minMaxZoomPreference: const MinMaxZoomPreference(11, 100),
        polylines: routeLines,
        dynamicMarkers: dynamicMarkers,
        staticMarkers: staticMarkers);
  }
}

class RouteChooser extends StatelessWidget {
  final Function(Set<RouteData>) onRouteButtonClick;

  const RouteChooser({super.key, required this.onRouteButtonClick});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: GestureDetector(
          onTap: () {
            showBarModalBottomSheet(
                context: context,
                backgroundColor:
                    Theme.of(context).bottomSheetTheme.backgroundColor,
                builder: (context) {
                  return SettingsCard(onRouteButtonClick);
                });
          },
          child: Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(64),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0xAA222234),
                      offset: Offset(1, 1),
                      spreadRadius: 1.0,
                      blurRadius: 4.0)
                ],
                color: isDark
                    ? Theme.of(context).colorScheme.secondary
                    : MICHIGAN_BLUE),
            child: Icon(
              Icons.alt_route_rounded,
              color: isDark ? MICHIGAN_BLUE : MICHIGAN_MAIZE,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class MainMap extends ConsumerStatefulWidget {
  const MainMap({super.key});

  @override
  _MainMapState createState() => _MainMapState();
}

class _MainMapState extends ConsumerState<MainMap> {
  final Completer<GoogleMapController> _mapController = Completer();
  late Set<String> _selectedRouteIds;
  final MapData _mapData = MapData();
  Set<BusRoute> _selectedRouteLines = {};
  Set<BusStop> _selectedRouteStops = {};
  Set<MBus> _selectedBuses = {};

  Set<Marker> _staticMarkers = {};
  Set<Marker> _dynamicMarkers = {};
  Set<Polyline> _polylines = {};
  late Map<String, BitmapDescriptor> _busImages;
  bool _showMyLocation = false;
  double _curMapRotation = 0;

  StreamSubscription<repos.RouteSnapshot>? _routeSub;
  ProviderSubscription<SettingsState>? _settingsSubscription;
  // removed unused _lastSnapshot; map rebuilds from stream

  @override
  void initState() {
    super.initState();
    _selectedRouteIds = ref.read(settingsProvider).selectedRouteIds.toSet();
    _busImages = ref.read(markerImagesProvider);

    _rebuildSelectedMapFeatures();
    _setUpdateIntervals();
    _checkLocationPermission();

    _settingsSubscription = ref.listenManual<SettingsState>(
      settingsProvider,
      (prev, next) {
        setState(() {
          _selectedRouteIds = next.selectedRouteIds.toSet();
          _rebuildSelectedMapFeatures();
        });
      },
    );
  }

  @override
  void didUpdateWidget(MainMap oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _settingsSubscription?.close();
    _routeSub?.cancel();
    super.dispose();
  }

  void _setMapRotation(double rotation) {
    _curMapRotation = rotation;
  }

  BitmapDescriptor _getBusImage(String routeId) {
    final key = _busImages.containsKey(routeId) ? routeId : routeId.trim();
    return _busImages[key] ?? BitmapDescriptor.defaultMarker;
  }

  void _showBusStopCard(
      String stopId, String stopName, String routeId, LatLng stopLocation) {
    showBarModalBottomSheet(
        expand: false,
        context: context,
        backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
        builder: (context) => Container(
              child: BusStopCard(
                  busStopId: stopId,
                  busStopName: stopName,
                  busStopRouteName:
                      ref.read(routeMetaProvider).routeIdToName[routeId] ??
                          "Unknown Route",
                  busStopLocation: stopLocation),
            ));
  }

  void _showMBusCard(String busId, String busFullness, String routeId) {
    showBarModalBottomSheet(
        expand: false,
        context: context,
        backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
        builder: (context) => Container(
              child: BusNextStopsCard(
                  busId: busId, busFullness: busFullness, routeId: routeId),
            ));
  }

  void _addOneBusRoute(String routeId, List<dynamic> subroutes) {
    int subRouteCtr = 0;
    for (final Map<String, dynamic> subRoute in subroutes) {
      List<LatLng> points = [];
      for (final point in subRoute['pt']) {
        if (point['typ'] == 'S') {
          _mapData.routeStops.add(BusStop(point['stpid'], point['stpnm'],
              LatLng(point['lat'], point['lon']), routeId));
        }
        points.add(LatLng(point['lat'], point['lon']));
      }
      Polyline routeLine = Polyline(
          polylineId: PolylineId(routeId + subRouteCtr.toString()),
          points: points,
          color: ref.read(routeMetaProvider).routeColors[routeId] ?? Colors.red,
          width: 3);
      _mapData.routeLines.add(BusRoute(routeId, routeLine));
      subRouteCtr++;
      if (subRoute.containsKey('dtrpt')) {
        List<LatLng> detourPoints = [];
        for (final point in subRoute['dtrpt']) {
          if (point['typ'] == 'S') {
            _mapData.routeStops.add(BusStop(point['stpid'], point['stpnm'],
                LatLng(point['lat'], point['lon']), routeId));
          }
          detourPoints.add(LatLng(point['lat'], point['lon']));
        }

        Polyline detourRouteLine = Polyline(
            polylineId: PolylineId(routeId + subRouteCtr.toString()),
            points: detourPoints,
            color: ref
                    .read(routeMetaProvider)
                    .routeColors[routeId]
                    ?.withAlpha(175) ??
                Colors.red,
            width: 3);

        _mapData.routeLines.add(BusRoute(routeId, detourRouteLine));
        subRouteCtr++;
      }
    }
  }

  void _setRoutesFromRepo(Map<String, dynamic> routeLineJson) {
    for (final routeId in routeLineJson.keys) {
      _addOneBusRoute(routeId, routeLineJson[routeId]);
    }
  }

  void _rebuildSelections() {
    final selectedIds = _selectedRouteIds;
    _selectedRouteLines = _mapData.routeLines
        .where((e) => selectedIds.contains(e.routeId))
        .toSet();
    _selectedRouteStops = _mapData.routeStops
        .where((e) => selectedIds.contains(e.routeId))
        .toSet();
    _selectedBuses =
        _mapData.buses.where((e) => selectedIds.contains(e.routeId)).toSet();
  }

  void _centerMapOnLocation() async {
    final GoogleMapController controller = await _mapController.future;
    LocationPermission permission;

    if (!(await Geolocator.isLocationServiceEnabled())) {
      return;
    }

    permission = await Geolocator.checkPermission();

    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      return;
    }

    final currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
        zoom: 17.0,
      ),
    ));
  }

  Marker _markerFromBusStop(BusStop stop) {
    return Marker(
        anchor: const Offset(0.5, 0.5),
        markerId: MarkerId(stop.stopId),
        position: stop.location,
        icon: _getBusImage("BUS_STOP"),
        consumeTapEvents: true,
        onTap: () => _showBusStopCard(
            stop.stopId, stop.stopName, stop.routeId, stop.location));
  }

  void _setBusesFromRepo(List<dynamic> buses) {
    _mapData.buses.clear();
    if (buses.isEmpty) return;
    for (final bus in buses) {
      final busMarker = Marker(
          zIndex: 2,
          anchor: const Offset(0.5, 0.5),
          markerId: MarkerId(bus['vid']),
          position: LatLng(double.parse(bus['lat']), double.parse(bus['lon'])),
          icon: _getBusImage(bus['rt']),
          rotation: double.parse(bus['hdg']) - _curMapRotation,
          onTap: () => _showMBusCard(
              bus['vid'], bus['psgld'] ?? "HALF_EMPTY", bus['rt']),
          consumeTapEvents: true);

      _mapData.buses.add(MBus(bus['rt'], busMarker));
    }
    setState(() {
      _rebuildSelectedMapFeatures();
    });
  }

  void _buildDynamicMarkers() {
    _dynamicMarkers = _selectedBuses.map((bus) => bus.marker).toSet();
  }

  void _buildStaticMarkers() {
    _staticMarkers = _selectedRouteStops.map(_markerFromBusStop).toSet();
  }

  void _buildPolylines() {
    _polylines = _selectedRouteLines.map((route) => route.polyline).toSet();
  }

  void _rebuildSelectedMapFeatures() {
    _rebuildSelections();
    _buildDynamicMarkers();
    _buildStaticMarkers();
    _buildPolylines();
  }

  void _setUpdateIntervals() {
    final repo = ref.read(routeRepositoryProvider);
    _routeSub = repo.stream.listen((snapshot) {
      _mapData.routeLines.clear();
      _mapData.routeStops.clear();
      _setRoutesFromRepo(snapshot.allRoutes);
      _setBusesFromRepo(snapshot.buses);
    }, onError: (_) {
      // Fail fast: let UI continue showing last known state
    });
  }

  void _checkLocationPermission() async {
    LocationPermission permission;

    if (!(await Geolocator.isLocationServiceEnabled())) {
      return;
    }

    permission = await Geolocator.checkPermission();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      prefs.setBool('noShowLocationWarning', false);
      setState(() {
        _showMyLocation = true;
      });
      return;
    }

    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      prefs.setBool('noShowLocationWarning', false);
      setState(() {
        _showMyLocation = true;
      });
      return;
    }
  }

  void _onRouteChooserClick(Set<RouteData> newRoutes) {
    setState(() {
      _selectedRouteIds = newRoutes.map((route) => route.routeId).toSet();
      ref.read(settingsProvider.notifier).setSelectedRoutes(_selectedRouteIds);
      _rebuildSelectedMapFeatures();
    });
  }

  // Manual asset refresh removed; assets react to settings changes

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: (Container(
          child: Stack(
        children: [
          Platform.isIOS
              ? MainGmap(
                  mapController: _mapController,
                  markers: _dynamicMarkers.union(_staticMarkers),
                  polylines: _polylines,
                  showMyLocation: _showMyLocation,
                  setMapRotation: _setMapRotation)
              : MainAndroidMap(
                  mapController: _mapController,
                  routeLines: _polylines,
                  staticMarkers: _staticMarkers,
                  dynamicMarkers: _dynamicMarkers,
                  showMyLocation: _showMyLocation,
                  setMapRotation: _setMapRotation),
          SafeArea(
              child: MapButtons(
                  onRouteButtonClick: _onRouteChooserClick,
                  onLocationClick: _centerMapOnLocation))
        ],
      ))),
    );
  }
}
