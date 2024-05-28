import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mbus/settings/Settings.dart';

import '../GlobalConstants.dart';

abstract class HasRouteId {
  String get routeId;
}

class BusStop implements HasRouteId{
  final String stopId;
  final String stopName;
  final LatLng location;
  final String routeId;

  BusStop(this.stopId, this.stopName, this.location, this.routeId);
}

class MBus implements HasRouteId{
  final String routeId;
  final Marker marker;

  MBus(this.routeId, this.marker);

  String toString() {
    return "Route ID: $routeId";
  }
}

class BusStopMarker implements HasRouteId{
  final String stopId;
  final String stopName;
  final String routeId;
  final Marker marker;

  BusStopMarker(this.stopId, this.stopName, this.routeId, this.marker);
}

class BusRoute implements HasRouteId{
  Polyline polyline;
  String routeId;

  BusRoute(this.routeId, this.polyline);

  // string method
  String toString() {
    return "Route ID: $routeId, Polyline ID: ${polyline.polylineId}";
  }
}

// Data holder class for arrivals on bus stop cards.
class IncomingBus {
  final String busNumber;
  final String to;
  final String estTimeMin;
  final String route;

  IncomingBus(this.busNumber, this.to, this.estTimeMin, this.route);
}