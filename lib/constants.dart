//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const Color MICHIGAN_BLUE = Color(0xFF00274C);
const Color MICHIGAN_MAIZE = Color(0xFFFFCB05);
//const String BACKEND_URL = String.fromEnvironment("BACKEND_URL", defaultValue: "http://localhost:3000/mbus/api/v3/"); // < iphone testing
//const String BACKEND_URL = String.fromEnvironment("BACKEND_URL", defaultValue: "http://10.0.2.2:3000/mbus/api/v3/");  // < android testing
const String BACKEND_URL = String.fromEnvironment("BACKEND_URL", defaultValue: "https://www.efeakinci.host/mbus/api/v3");


const Map<String, Color> ROUTE_COLORS = {
  "CC": Colors.red,
  "GNW": Colors.blue,
  "MX": Colors.green,
  "NWL": Colors.orange,
  "OXM": Colors.purple,
  "SD": Color(0xFFd633b5),
  "WS": Color(0xFF39BD95),
  "WX": Colors.cyan
};
const Map<String, String> ROUTE_ID_TO_ROUTE_NAME = {
  "CC": "Campus Connector",
  "GNW": "Green Road - Northwood V Loop",
  "MX": "Med Express",
  "NWL": "Northwood Loop",
  "OXM": "Oxford - Markley Loop",
  "SD": "Stadium - Diag Loop",
  "WS": "Wall Street - NIB",
  "WX": "Wall Street Express"
};