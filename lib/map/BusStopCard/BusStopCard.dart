// Card for bus stop information e.g. arrivals, route name.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:mbus/map/BusStopCard/BusStopCardBody.dart';
import 'package:mbus/map/BusStopCard/BusStopCardHeader.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../GlobalConstants.dart';
import '../../constants.dart';
import '../../mbus_utils.dart';
import '../Animations.dart';
import '../CardScrollBehavior.dart';
import '../DataTypes.dart';
import '../FavoriteButton.dart';

part 'BusStopCard.g.dart';

@swidget
Widget busStopCard(BuildContext context, String busStopId, String busStopName, String? busStopRouteName, LatLng busStopLocation) {
  Future<List<IncomingBus>> getBusInfo() async {
    final res = await NetworkUtils.getWithErrorHandling(context, "getStopPredictions/${busStopId}");
    final resJson = jsonDecode(res)['bustime-response'];
    final GlobalConstants globalConstants = GlobalConstants();
    if (resJson == null) {
      return [];
    }
    List<IncomingBus> _busses = [];
    if (resJson['prd'] != null) {
      resJson['prd'].forEach((e) {
        _busses.add(new IncomingBus(e['vid'], e['des'], e['prdctdn'], globalConstants.ROUTE_ID_TO_ROUTE_NAME[e['rt']] ?? "Unknown Route"));
      });
    }
    return _busses;
  }

  void launchDirectionsSelectionScreen() async {
    final coords = Coords(busStopLocation.latitude, busStopLocation.longitude);
    final availableMaps = await MapLauncher.installedMaps;

    showModalBottomSheet(context: context, builder: (context) {
      return SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Wrap(
              children: <Widget>[
                for (var map in availableMaps)
                  ListTile(
                    onTap: () => map.showDirections(
                      destination: coords,
                      destinationTitle: busStopName,
                    ),
                    title: Text(map.mapName),
                    leading: SvgPicture.asset(
                      map.icon,
                      height: 30.0,
                      width: 30.0,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  return ScrollConfiguration(
    behavior: CardScrollBehavior(),
    child: (
        ListView(
          shrinkWrap: true,
          controller: ModalScrollController.of(context),
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  BusStopCardHeader(busStopName, launchDirectionsSelectionScreen),
                  SizedBox(height: 32,),
                  Text("Arrivals", style: TextStyle(color: MICHIGAN_MAIZE, fontSize: 32, fontWeight: FontWeight.w800),),
                  Divider(),
                  SizedBox(height: 8,),
                  BusStopCardBody(future: getBusInfo()),
                  SizedBox(height: 16),
                  Container(
                      width: double.infinity,
                      child: BusStopCardFavoriteButton(busStopId, busStopName)
                  ),
                ],
              ),
            )],
        )
    ),
  );
}