// Card for bus stop information e.g. arrivals, route name.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:mbus/constants.dart';
import 'package:mbus/map/card_scroll_behavior.dart';
import 'package:mbus/mbus_utils.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:mbus/state/app_state.dart';

import 'package:mbus/map/bus_stop_card/bus_stop_card_body.dart';
import 'package:mbus/map/bus_stop_card/bus_stop_card_header.dart';
import 'package:mbus/map/data_types.dart';
import 'package:mbus/map/favorite_button.dart';

class BusStopCard extends StatelessWidget {
  final String busStopId;
  final String busStopName;
  final String? busStopRouteName;
  final LatLng busStopLocation;

  const BusStopCard({
    Key? key,
    required this.busStopId,
    required this.busStopName,
    this.busStopRouteName,
    required this.busStopLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<List<IncomingBus>> getBusInfo() async {
      final res = await NetworkUtils.getWithErrorHandling(
          context, "getStopPredictions/$busStopId");
      final resJson = jsonDecode(res)['bustime-response'];
      final AppState appState = AppState();
      if (resJson == null) {
        return [];
      }
      List<IncomingBus> _busses = [];
      if (resJson['prd'] != null) {
        resJson['prd'].forEach((e) {
          _busses.add(new IncomingBus(
              e['vid'],
              e['des'],
              e['prdctdn'],
              appState.routeIdToRouteName[e['rt']] ??
                  "Unknown Route"));
        });
      }
      return _busses;
    }

    void launchDirectionsSelectionScreen() async {
      final coords = Coords(busStopLocation.latitude, busStopLocation.longitude);
      final availableMaps = await MapLauncher.installedMaps;

      showModalBottomSheet(
          context: context,
          builder: (context) {
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
      child: (ListView(
        shrinkWrap: true,
        controller: ModalScrollController.of(context),
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                BusStopCardHeader(
                    busStopName: busStopName,
                    onLaunchDirections: launchDirectionsSelectionScreen),
                const SizedBox(
                  height: 32,
                ),
                const Text(
                  "Arrivals",
                  style: TextStyle(
                      color: MICHIGAN_MAIZE,
                      fontSize: 32,
                      fontWeight: FontWeight.w800),
                ),
                const Divider(),
                const SizedBox(
                  height: 8,
                ),
                BusStopCardBody(future: getBusInfo()),
                const SizedBox(height: 16),
                Container(
                    width: double.infinity,
                    child: BusStopCardFavoriteButton(
                        busStopId: busStopId, busStopName: busStopName)),
              ],
            ),
          )
        ],
      )),
    );
  }
}