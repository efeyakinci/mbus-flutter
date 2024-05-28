import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GlobalConstants extends ChangeNotifier{

  GlobalConstants._privateConstructor();

  static final GlobalConstants _instance = GlobalConstants._privateConstructor();

  factory GlobalConstants(){
    return _instance;
  }

  Map<String, Color> ROUTE_COLORS = {

  };

  Map<String, dynamic> ROUTE_ID_TO_ROUTE_NAME = {

  };

  Map<String, dynamic> ROUTE_TO_IMAGE = {

  };

  Map<String, BitmapDescriptor> marker_images = {

  };

  static const LatLng ANN_ARBOR = LatLng(42.278235, -83.738118);

  static const BUILD_VERSION = 11;

  void updateRouteInformation(Map<String, dynamic> information) {
    if (information['routeImages'] != null) {
      ROUTE_TO_IMAGE = information['routeImages'];
    }
    if (information['routeIdToName'] != null) {
      ROUTE_ID_TO_ROUTE_NAME = information['routeIdToName'];
    }
    if (information['routeColors'] != null) {
      ROUTE_COLORS = Map.fromIterable(information['routeColors'].keys, key: (k) => k, value: (k) => Color(int.tryParse(information['routeColors']?[k]) ?? 0xFFFF0000));
    }
    notifyListeners();
  }
}