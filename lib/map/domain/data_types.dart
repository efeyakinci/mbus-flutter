import 'dart:collection';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mbus/models/route_data.dart';

abstract class HasRouteId {
  String get routeId;
}

class BusStop implements HasRouteId {
  final String stopId;
  final String stopName;
  final LatLng location;
  @override
  final String routeId;

  BusStop(this.stopId, this.stopName, this.location, this.routeId);
}

class MBus implements HasRouteId {
  @override
  final String routeId;
  final Marker marker;

  MBus(this.routeId, this.marker);

  @override
  String toString() {
    return "Route ID: $routeId";
  }
}

class BusStopMarker implements HasRouteId {
  final String stopId;
  final String stopName;
  @override
  final String routeId;
  final Marker marker;

  BusStopMarker(this.stopId, this.stopName, this.routeId, this.marker);
}

class BusRoute implements HasRouteId {
  Polyline polyline;
  @override
  String routeId;

  BusRoute(this.routeId, this.polyline);

  @override
  String toString() {
    return "Route ID: $routeId, Polyline ID: ${polyline.polylineId}";
  }
}

class IncomingBus {
  final String busNumber;
  final String to;
  final String estTimeMin;
  final String route;

  IncomingBus(this.busNumber, this.to, this.estTimeMin, this.route);
}

class MapData {
  final Set<RouteData> routes;
  final Set<BusRoute> routeLines;
  final Set<BusStop> routeStops;
  final Set<MBus> buses;

  MapData()
      : routes = HashSet<RouteData>(),
        routeLines = HashSet<BusRoute>(),
        routeStops = HashSet<BusStop>(),
        buses = HashSet<MBus>();

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
