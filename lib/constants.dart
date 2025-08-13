import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const Color MICHIGAN_BLUE = Color(0xFF00274C);
const Color MICHIGAN_MAIZE = Color(0xFFFFCB05);
const String BACKEND_URL = String.fromEnvironment("BACKEND_URL", defaultValue: "https://mbusa2.xyz/mbus/api/v3");

const LatLng ANN_ARBOR = LatLng(42.278235, -83.738118);

const BUILD_VERSION = 11;