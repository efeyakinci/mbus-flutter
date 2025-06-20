import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppState extends ChangeNotifier{

  AppState._privateConstructor();

  static final AppState _instance = AppState._privateConstructor();

  factory AppState(){
    return _instance;
  }

  Map<String, Color> routeColors = {
    "CC": Colors.red,
    "GNW": Colors.blue,
    "MX": Colors.green,
    "NWL": Colors.orange,
    "OXM": Colors.purple,
    "SD": const Color(0xFFd633b5),
    "WS": const Color(0xFF39BD95),
    "WX": Colors.cyan
  };

  Map<String, dynamic> routeIdToRouteName = {
    "CC": "Campus Connector",
    "GNW": "Green Road - Northwood V Loop",
    "MX": "Med Express",
    "NWL": "Northwood Loop",
    "OXM": "Oxford - Markley Loop",
    "SD": "Stadium - Diag Loop",
    "WS": "Wall Street - NIB",
    "WX": "Wall Street Express"
  };

  Map<String, dynamic> routeToImage = {

  };

  Map<String, BitmapDescriptor> markerImages = {

  };

  void updateRouteInformation(Map<String, dynamic> information) {
    if (information['routeImages'] != null) {
      routeToImage = information['routeImages'];
    }
    if (information['routeIdToName'] != null) {
      routeIdToRouteName = information['routeIdToName'];
    }
    if (information['routeColors'] != null) {
      routeColors = { for (var k in information['routeColors'].keys) k : Color(int.tryParse(information['routeColors']?[k]) ?? 0xFFFF0000) };
    }
    notifyListeners();
  }
} 