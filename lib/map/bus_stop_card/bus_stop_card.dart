// Card for bus stop information e.g. arrivals, route name.

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// ignore_for_file: unused_import
import 'package:mbus/constants.dart';
import 'package:mbus/theme/app_theme.dart';
import 'package:mbus/map/presentation/card_scroll_behavior.dart';
import 'package:mbus/data/providers.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbus/state/assets_controller.dart';

import 'package:mbus/map/bus_stop_card/bus_stop_card_body.dart';
import 'package:mbus/map/bus_stop_card/bus_stop_card_header.dart';
import 'package:mbus/map/domain/data_types.dart';
import 'package:mbus/map/favorite_button.dart';
import 'package:mbus/map/widgets/bottom_sheet_card.dart';

class BusStopCard extends ConsumerWidget {
  final String busStopId;
  final String busStopName;
  final String? busStopRouteName;
  final LatLng busStopLocation;

  const BusStopCard({
    super.key,
    required this.busStopId,
    required this.busStopName,
    this.busStopRouteName,
    required this.busStopLocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<List<IncomingBus>> getBusInfo() async {
      final api = ProviderScope.containerOf(context, listen: false)
          .read(apiClientProvider);
      final resJson = await api.getStopPredictions(busStopId);
      if (resJson.isEmpty) {
        return [];
      }
      List<IncomingBus> busses = [];
      if (resJson['prd'] != null) {
        resJson['prd'].forEach((e) {
          busses.add(IncomingBus(
              e['vid'],
              e['des'],
              e['prdctdn'],
              ref.read(routeMetaProvider).routeIdToName[e['rt']] ??
                  "Unknown Route"));
        });
      }
      return busses;
    }

    void launchDirectionsSelectionScreen() async {
      final coords =
          Coords(busStopLocation.latitude, busStopLocation.longitude);
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

    return BottomSheetCard(
      header: BusStopCardHeader(
          busStopName: busStopName,
          onLaunchDirections: launchDirectionsSelectionScreen),
      sectionTitle: "Arrivals",
      body: BusStopCardBody(future: getBusInfo()),
      footer: SizedBox(
          width: double.infinity,
          child: BusStopCardFavoriteButton(
              busStopId: busStopId, busStopName: busStopName)),
    );
  }
}
