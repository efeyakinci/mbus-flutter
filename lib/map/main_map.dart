import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mbus/map/bus_tracker_card/bus_tracker_card.dart';
import 'package:mbus/map/marker_animator.dart';
import 'package:mbus/settings/settings.dart';
import 'package:mbus/constants.dart';
import 'package:mbus/mbus_utils.dart';
import 'package:mbus/state/app_state.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './data_types.dart';
import 'bus_stop_card/bus_stop_card.dart';

class MyLocationButton extends StatelessWidget {
  final void Function() onClick;

  const MyLocationButton({Key? key, required this.onClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              color: MICHIGAN_BLUE),
          child: const Center(
            child: Icon(
              Icons.my_location,
              color: MICHIGAN_MAIZE,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class MapButtons extends StatelessWidget {
  final Function(Set<RouteData>) onRouteButtonClick;
  final Function() onLocationClick;

  const MapButtons(
      {Key? key,
      required this.onRouteButtonClick,
      required this.onLocationClick})
      : super(key: key);

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

// iOS version of the map (iOS interpolates markers automatically)
class MainGmap extends StatelessWidget {
  final Completer<GoogleMapController> mapController;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final bool showMyLocation;
  final Function setMapRotation;

  const MainGmap(
      {Key? key,
      required this.mapController,
      required this.markers,
      required this.polylines,
      required this.showMyLocation,
      required this.setMapRotation})
      : super(key: key);

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
          mapController.complete(controller);
        },
        onCameraMove: (CameraPosition position) {
          setMapRotation(position.bearing);
        },
        markers: markers,
        cameraTargetBounds: CameraTargetBounds(LatLngBounds(
            southwest: const LatLng(42.160243, -83.893041),
            northeast: const LatLng(42.347612, -83.606753))),
        myLocationButtonEnabled: false,
        minMaxZoomPreference: const MinMaxZoomPreference(11, 100),
        myLocationEnabled: showMyLocation,
        polylines: polylines);
  }
}

// Android version of the map (needs to use MarkerAnimator to animate markers)
class MainAndroidMap extends StatelessWidget {
  final Completer<GoogleMapController> mapController;
  final Set<Polyline> routeLines;
  final Set<Marker> staticMarkers;
  final Set<Marker> dynamicMarkers;
  final bool showMyLocation;
  final Function setMapRotation;

  const MainAndroidMap(
      {Key? key,
      required this.mapController,
      required this.routeLines,
      required this.staticMarkers,
      required this.dynamicMarkers,
      required this.showMyLocation,
      required this.setMapRotation})
      : super(key: key);
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

// Button that lets the user choose which routes to show on the map
class RouteChooser extends StatelessWidget {
  final Function(Set<RouteData>) onRouteButtonClick;

  const RouteChooser({Key? key, required this.onRouteButtonClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: GestureDetector(
          onTap: () {
            showBarModalBottomSheet(
                context: context,
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
                color: MICHIGAN_BLUE),
            child: const Icon(
              Icons.alt_route_rounded,
              color: MICHIGAN_MAIZE,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class MainMap extends StatefulWidget {
  final Set<RouteData> selectedRoutes;

  const MainMap(this.selectedRoutes, {Key? key}) : super(key: key);

  @override
  _MainMapState createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  final AppState appState = AppState();
  // Google Map Controller
  final Completer<GoogleMapController> _mapController = Completer();

  // Stores selected route IDs
  late Set<RouteData> _selectedRoutes;
  late Set<String> _selectedRouteIds;

  // Stores all map data received from the server
  final MapData _mapData = MapData();

  // Holds the currently displayed items
  Set<BusRoute> _selectedRouteLines = {};
  Set<BusStop> _selectedRouteStops = {};
  Set<MBus> _selectedBuses = {};

  Set<Marker> _staticMarkers = {};
  Set<Marker> _dynamicMarkers = {};
  Set<Polyline> _polylines = {};
  late final Map<String, BitmapDescriptor> _busImages;

  // Shows location button if user has location services enabled
  bool _showMyLocation = false;

  double _curMapRotation = 0;

  Timer? _busTimer;
  Timer? _routeTimer;

  @override
  void initState() {
    super.initState();
    _selectedRoutes = widget.selectedRoutes;
    _selectedRouteIds = _selectedRoutes.map((e) => e.routeId).toSet();
    _busImages = appState.markerImages;

    _rebuildSelectedMapFeatures();
    _setUpdateIntervals();
    _checkLocationPermission();
  }

  @override
  void didUpdateWidget(MainMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedRoutes != widget.selectedRoutes) {
      setState(() {
        _selectedRoutes = widget.selectedRoutes;
        _selectedRouteIds = _selectedRoutes.map((e) => e.routeId).toSet();
        _rebuildSelectedMapFeatures();
      });
    }
  }

  @override
  void dispose() {
    _busTimer?.cancel();
    _routeTimer?.cancel();
    super.dispose();
  }

  void _setMapRotation(double rotation) {
    _curMapRotation = rotation;
  }

  BitmapDescriptor _getBusImage(String routeId) {
    return _busImages[routeId] ?? BitmapDescriptor.defaultMarker;
  }

  // Takes in some data with a routeId and returns the subset of that data that is selected
  Set<T> _getSelectedData<T extends HasRouteId>(Set<T> data) {
    final filtered = data
        .where((element) => _selectedRouteIds.contains(element.routeId))
        .toSet();

    return filtered;
  }

  // Shows the bus stop card (for when a bus stop is clicked on the map)
  void _showBusStopCard(String stopId, String stopName, String routeId, LatLng stopLocation) {
    showBarModalBottomSheet(
        expand: false,
        context: context,
        builder: (context) => Container(
              child: BusStopCard(
                  busStopId: stopId,
                  busStopName: stopName,
                  busStopRouteName:
                      appState.routeIdToRouteName[routeId] ??
                          "Unknown Route",
                  busStopLocation: stopLocation),
            ));
  }

  // Show the bus card (for when a bus is clicked on the map)
  void _showMBusCard(String busId, String busFullness, String routeId) {
    showBarModalBottomSheet(
        expand: false,
        context: context,
        builder: (context) => Container(
              child: BusNextStopsCard(
                  busId: busId, busFullness: busFullness, routeId: routeId),
            ));
  }

  // Take one route from the API response and add its data to the map
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
          color: appState.routeColors[routeId] ?? Colors.red,
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
            color:
                appState.routeColors[routeId]?.withAlpha(175) ??
                    Colors.red,
            width: 3);

        _mapData.routeLines.add(BusRoute(routeId, detourRouteLine));
        subRouteCtr++;
      }
    }
  }

  // Adds all route lines and bus stops to the map
  void _getBusRoutes() async {
    final routeLineResponse =
        await NetworkUtils.getWithErrorHandling(context, 'getAllRoutes');
    // If there was an error or no routes were found
    if (routeLineResponse == "{}") return;

    final routeLineJson = jsonDecode(routeLineResponse)['routes'];

    for (final routeId in routeLineJson.keys) {
      _addOneBusRoute(routeId, routeLineJson[routeId]);
    }
    setState(() {
      _rebuildSelectedMapFeatures();
    });
  }

  // Filters all markers to only contain the selected routes
  void _rebuildSelections() {
    _selectedRouteLines = _getSelectedData(_mapData.routeLines);
    _selectedRouteStops = _getSelectedData(_mapData.routeStops);
    _selectedBuses = _getSelectedData(_mapData.buses);
  }

  // Centers the map on the user's location
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

  // Updates buses on the map
  void _updateBuses() async {
    final res =
        await NetworkUtils.getWithErrorHandling(context, "getVehiclePositions");
    if (res == "{}") return;
    _mapData.buses.clear();

    // The API sometimes returns an empty response, so ignore it
    final json = jsonDecode(res)['buses'] ?? [];

    if (json.length == 0) return;

    for (final bus in json) {
      final busMarker = Marker(
          zIndex: 2,
          anchor: const Offset(0.5, 0.5),
          markerId: MarkerId(bus['vid']),
          position: LatLng(double.parse(bus['lat']), double.parse(bus['lon'])),
          icon: _getBusImage(bus['rt']),
          rotation: double.parse(bus['hdg']) - _curMapRotation,
          onTap: () =>
              _showMBusCard(bus['vid'], bus['psgld'] ?? "HALF_EMPTY", bus['rt']),
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

  // Rebuilds all markers and polylines
  void _rebuildSelectedMapFeatures() {
    _rebuildSelections();
    _buildDynamicMarkers();
    _buildStaticMarkers();
    _buildPolylines();
  }

  // Update buses every 5 seconds
  void _setUpdateIntervals() {
    _updateBuses();
    _getBusRoutes();

    _busTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateBuses();
    });

    _routeTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      _getBusRoutes();
    });
  }

  // Checks if the user has granted location permissions and sets showMyLocation accordingly
  void _checkLocationPermission() async {
    LocationPermission permission;

    if (!(await Geolocator.isLocationServiceEnabled())) {
      return;
    }

    permission = await Geolocator.checkPermission();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // If the user has already allowed location permissions, show the location button
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      prefs.setBool('noShowLocationWarning', false);
      setState(() {
        _showMyLocation = true;
      });
      return;
    }

    // Try and request location permissions, if the user allows, show the location button
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
      _selectedRoutes = newRoutes;
      _selectedRouteIds = _selectedRoutes.map((route) => route.routeId).toSet();
      _rebuildSelectedMapFeatures();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
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