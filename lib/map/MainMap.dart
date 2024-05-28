import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mbus/GlobalConstants.dart';
import 'package:mbus/map/BusTrackerCard/BusTrackerCard.dart';
import 'package:mbus/map/MarkerAnimator.dart';
import 'package:mbus/settings/Settings.dart';
import 'package:mbus/constants.dart';
import 'package:mbus/mbus_utils.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './DataTypes.dart';
import 'BusStopCard/BusStopCard.dart';

part 'MainMap.g.dart';

@swidget
Widget myLocationButton(void Function() onClick) {
  return Container(
    child: GestureDetector(
      onTap: onClick,
      child: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(64),
            boxShadow: [
              BoxShadow(
                  color: Color(0xAA222234),
                  offset: Offset(1, 1),
                  spreadRadius: 1.0,
                  blurRadius: 4.0)
            ],
            color: MICHIGAN_BLUE),
        child: Center(
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

Widget mapButtons(Function(Set<RouteData>) onRouteButtonClick, Function() onLocationClick) {
  return SafeArea(child: Container(
    padding: EdgeInsets.all(16),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: Container(),),
        RouteChooser(onRouteButtonClick),
        MyLocationButton(onLocationClick)
      ],
    ),
  ));
}

// iOS version of the map (iOS interpolates markers automatically)
@swidget
Widget mainGmap(
    Completer<GoogleMapController> mapController,
    Set<Marker> markers,
    Set<Polyline> polylines,
    bool showMyLocation,
    Function setMapRotation) {
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
      cameraTargetBounds: CameraTargetBounds(new LatLngBounds(
          southwest: LatLng(42.160243, -83.893041),
          northeast: LatLng(42.347612, -83.606753))),
      myLocationButtonEnabled: false,
      minMaxZoomPreference: new MinMaxZoomPreference(11, 100),
      myLocationEnabled: showMyLocation,
      polylines: polylines);
}

// Android version of the map (needs to use MarkerAnimator to animate markers)
@swidget
Widget mainAndroidMap(Completer<GoogleMapController> mapController,
    Set<Polyline> routeLines,
    Set<Marker> staticMarkers,
    Set<Marker> dynamicMarkers,
    bool showMyLocation,
    Function setMapRotation) {
  return MarkerAnimator(
    onCameraMove: (CameraPosition position) {
      setMapRotation(position.bearing);
    },
    cameraTargetBounds: CameraTargetBounds(new LatLngBounds(
        southwest: LatLng(42.160243, -83.893041),
        northeast: LatLng(42.347612, -83.606753))),
    myLocationButtonEnabled: showMyLocation,
    minMaxZoomPreference: const MinMaxZoomPreference(11, 100),
    polylines: routeLines,
    dynamicMarkers: dynamicMarkers,
    staticMarkers: staticMarkers
  );
}

// Button that lets the user choose which routes to show on the map
@swidget
Widget routeChooser(BuildContext context, Function(Set<RouteData>) setValues) {
  return Container(
    child: Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: GestureDetector(
        onTap: () {
          showBarModalBottomSheet(
              context: context,
              builder: (context) {
                return SettingsCard(setValues);
              });
        },
        child: Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(64),
              boxShadow: [
                BoxShadow(
                    color: Color(0xAA222234),
                    offset: Offset(1, 1),
                    spreadRadius: 1.0,
                    blurRadius: 4.0)
              ],
              color: MICHIGAN_BLUE),
          child: Icon(
            Icons.alt_route_rounded,
            color: MICHIGAN_MAIZE,
            size: 24,
          ),
        ),
      ),
    ),
  );
}

// Struct for storing map data received from the server
class MapData {
  final Set<RouteData> routes;
  final Set<BusRoute> routeLines;
  final Set<BusStop> routeStops;
  final Set<MBus> buses;

  MapData()
      : routes = new HashSet<RouteData>(),
        routeLines = new HashSet<BusRoute>(),
        routeStops = new HashSet<BusStop>(),
        buses = new HashSet<MBus>();

  void clear() {
    routes.clear();
    routeLines.clear();
    routeStops.clear();
    buses.clear();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapData &&
          runtimeType == other.runtimeType &&
          routes == other.routes &&
          routeLines == other.routeLines &&
          routeStops == other.routeStops &&
          buses == other.buses;
}

@hwidget
Widget mainMap(Set<RouteData> selectedRoutesIn) {
  BuildContext context = useContext();
  // Google Map Controller
  final mapController = useRef(Completer<GoogleMapController>());

  // Stores selected route IDs
  final selectedRoutes = useState(selectedRoutesIn);
  final selectedRouteIds =
      useState(selectedRoutesIn.map((e) => e.routeId).toSet());

  // Stores all map data received from the server
  final mapData = useRef(MapData());

  // Holds the currently displayed items
  final selectedRouteLines = useState(new Set<BusRoute>());
  final selectedRouteStops = useState(new Set<BusStop>());
  final selectedBuses = useState(new Set<MBus>());

  final staticMarkers = useState(new Set<Marker>());
  final dynamicMarkers = useState(new Set<Marker>());
  final polylines = useState(new Set<Polyline>());
  final busImages = GlobalConstants().marker_images;

  // Shows location button if user has location services enabled
  final showMyLocation = useState(false);

  double curMapRotation = 0;
  final setMapRotation = (double rotation) {
    curMapRotation = rotation;
  };

  BitmapDescriptor getBusImage(String routeId) {
    if (busImages.containsKey(routeId)) {
      return busImages[routeId] ??
          BitmapDescriptor
              .defaultMarker;
    } else {
      return BitmapDescriptor.defaultMarker;
    }
  }

  // Takes in some data with a routeId and returns the subset of that data that is selected
  Set<T> getSelectedData<T extends HasRouteId>(Set<T> data) {
    final filtered = data
        .where((element) => selectedRouteIds.value.contains(element.routeId))
        .toSet();

    return filtered;
  }

  // Shows the bus stop card (for when a bus stop is clicked on the map)
  void Function() showBusStopCard(stopId, stopName, routeId, stopLocation) {
    return () {
      showBarModalBottomSheet(
          expand: false,
          context: context,
          builder: (context) => Container(
                child: BusStopCard(
                    stopId,
                    stopName,
                    GlobalConstants().ROUTE_ID_TO_ROUTE_NAME[routeId] ??
                        "Unknown Route",
                    stopLocation),
              ));
    };
  }

  // Show the bus card (for when a bus is clicked on the map)
  void Function() showMBusCard(
      String busId, String busFullness, String routeId) {
    return () {
      showBarModalBottomSheet(
          expand: false,
          context: context,
          builder: (context) => Container(
                child: BusNextStopsCard(busId, busFullness, routeId),
              ));
    };
  }

  // Take one route from the API response and add its data to the map
  void addOneBusRoute(String routeId, List<dynamic> subroutes) {
    int subRouteCtr = 0;
    for (final Map<String, dynamic> subRoute in subroutes) {
      List<LatLng> points = [];
      for (final point in subRoute['pt']) {
        if (point['typ'] == 'S') {
          mapData.value.routeStops.add(BusStop(point['stpid'], point['stpnm'],
              new LatLng(point['lat'], point['lon']), routeId));
        }
        points.add(LatLng(point['lat'], point['lon']));
      }
      Polyline routeLine = new Polyline(
          polylineId: PolylineId(routeId + subRouteCtr.toString()),
          points: points,
          color: GlobalConstants().ROUTE_COLORS[routeId] ?? Colors.red,
          width: 3);
      mapData.value.routeLines.add(BusRoute(routeId, routeLine));
      subRouteCtr++;
      if (subRoute.containsKey('dtrpt')) {
        List<LatLng> detourPoints = [];
        for (final point in subRoute['dtrpt']) {
          if (point['typ'] == 'S') {
            mapData.value.routeStops.add(BusStop(point['stpid'], point['stpnm'],
                new LatLng(point['lat'], point['lon']), routeId));
          }
          detourPoints.add(LatLng(point['lat'], point['lon']));
        }

        Polyline detourRouteLine = new Polyline(
            polylineId: PolylineId(routeId + subRouteCtr.toString()),
            points: detourPoints,
            color: GlobalConstants().ROUTE_COLORS[routeId]?.withAlpha(175) ?? Colors.red,
            width: 3);

        mapData.value.routeLines.add(BusRoute(routeId, detourRouteLine));
        subRouteCtr++;
      }
    }
  }

  // Adds all route lines and bus stops to the map
  void getBusRoutes() async {
    final routeLineResponse =
        await NetworkUtils.getWithErrorHandling(context, 'getAllRoutes');
    // If there was an error or no routes were found
    if (routeLineResponse == "{}") return;

    final routeLineJson = jsonDecode(routeLineResponse)['routes'];

    for (final routeId in routeLineJson.keys) {
      addOneBusRoute(routeId, routeLineJson[routeId]);
    }

    // Possible performance optimization below (do we call the effect hook two times?)
    selectedRouteLines.value = getSelectedData(mapData.value.routeLines);
    selectedRouteStops.value = getSelectedData(mapData.value.routeStops);
  }

  // Filters all markers to only contain the selected routes
  void rebuildSelections() {
    final prevBuses = Set.from(selectedBuses.value);
    selectedRouteLines.value = getSelectedData(mapData.value.routeLines);
    selectedRouteStops.value = getSelectedData(mapData.value.routeStops);
    selectedBuses.value = getSelectedData(mapData.value.buses);
  }

  // Centers the map on the user's location
  void centerMapOnLocation() async {
    final GoogleMapController controller = await mapController.value.future;
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
          target: LatLng(currentLocation.latitude,
              currentLocation.longitude),
          zoom: 17.0,
        ),
      ));
    
  }

  Marker markerFromBusStop(BusStop stop) {
    return Marker(
        anchor: Offset(0.5, 0.5),
        markerId: MarkerId(stop.stopId),
        position: stop.location,
        icon: getBusImage("BUS_STOP"),
        consumeTapEvents: true,
        onTap: showBusStopCard(
            stop.stopId, stop.stopName, stop.routeId, stop.location));
  }

  // Updates buses on the map
  void updateBuses() async {
    final res =
        await NetworkUtils.getWithErrorHandling(context, "getVehiclePositions");
    if (res == "{}") return;
    mapData.value.buses.clear();

    // The API sometimes returns an empty response, so ignore it
    final json = jsonDecode(res)['buses'] ?? [];

    if (json.length == 0) return;

    for (final bus in json) {
      final busMarker = Marker(
          zIndex: 2,
          anchor: Offset(0.5, 0.5),
          markerId: MarkerId(bus['vid']),
          position: LatLng(double.parse(bus['lat']), double.parse(bus['lon'])),
          icon: getBusImage(bus['rt']),
          rotation: double.parse(bus['hdg']) - curMapRotation,
          onTap:
              showMBusCard(bus['vid'], bus['psgld'] ?? "HALF_EMPTY", bus['rt']),
          consumeTapEvents: true);

      mapData.value.buses.add(MBus(bus['rt'], busMarker));
    }

    selectedBuses.value = getSelectedData(mapData.value.buses);
  }

  final buildDynamicMarkers = () {
    dynamicMarkers.value = selectedBuses.value.map((bus) => bus.marker).toSet();
  };

  final buildStaticMarkers = () {
    staticMarkers.value =
        selectedRouteStops.value.map(markerFromBusStop).toSet();
  };

  final buildPolylines = () {
    polylines.value =
        selectedRouteLines.value.map((route) => route.polyline).toSet();
  };

  // Rebuilds selectedRouteIds when selectedRoutes changes
  final rebuildSelectedRouteIds = () {
    selectedRouteIds.value =
        selectedRoutes.value.map((route) => route.routeId).toSet();
  };

  // Rebuilds all markers and polylines
  final rebuildSelectedMapFeatures = () {
    rebuildSelections();
    buildDynamicMarkers();
    buildStaticMarkers();
    buildPolylines();
  };

  // Update buses every 5 seconds
  final setUpdateIntervals = () {
    updateBuses();
    getBusRoutes();

    final busTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      updateBuses();
    });

    final routeTimer = Timer.periodic(Duration(seconds: 60), (timer) {
      getBusRoutes();
    });

    return () {
      busTimer.cancel();
      routeTimer.cancel();
    };
  };

  // Checks if the user has granted location permissions and sets showMyLocation accordingly
  void checkLocationPermission() async {
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
      showMyLocation.value = true;
      return;
    }

    // Try and request location permissions, if the user allows, show the location button
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      prefs.setBool('noShowLocationWarning', false);
      showMyLocation.value = true;
      return;
    }
  };

  final checkLocationEffect = () {
    checkLocationPermission();
  };

  final routeChooserOnClick = (Set<RouteData> newRoutes) {
    selectedRoutes.value = newRoutes;
  };

  // build dynamic markers on mount and when selectedBuses changes
  useEffect(buildDynamicMarkers, [selectedBuses.value]);
  // build static markers on mount and when selectedRouteStops changes
  useEffect(buildStaticMarkers, [selectedRouteStops.value]);
  // build polylines on mount and when selectedRouteLines changes
  useEffect(buildPolylines, [selectedRouteLines.value]);
  // rebuild selectedRouteIds on mount and when selectedRouteLines changes
  useEffect(rebuildSelectedRouteIds, [selectedRoutes.value]);
  // set update intervals on mount
  useEffect(setUpdateIntervals, []);
  // rebuild selected map features on mount and when selectedRoutes changes
  useEffect(rebuildSelectedMapFeatures, [selectedRouteIds.value]);
  // check location permission on mount
  useEffect(checkLocationEffect, []);

  return AnnotatedRegion(
    value: SystemUiOverlayStyle.dark,
    child: (Container(
        child: Stack(
      children: [
        Platform.isIOS
            ? MainGmap(
                mapController.value,
                dynamicMarkers.value.union(staticMarkers.value),
                polylines.value,
                showMyLocation.value,
                setMapRotation)
            : MainAndroidMap(
                mapController.value,
                polylines.value,
                staticMarkers.value,
                dynamicMarkers.value,
                showMyLocation.value,
                setMapRotation),
        SafeArea(child: mapButtons(routeChooserOnClick, centerMapOnLocation))
      ],
    ))),
  );
}
