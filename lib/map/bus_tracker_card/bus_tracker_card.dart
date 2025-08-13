// Data holder class for busses' next stops.

import 'package:flutter/material.dart';
import 'package:mbus/constants.dart';
import 'package:mbus/map/presentation/card_scroll_behavior.dart';
import 'package:mbus/data/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:mbus/map/bus_tracker_card/bus_tracker_card_body.dart';
import 'package:mbus/map/bus_tracker_card/bus_tracker_card_header.dart';
import 'package:mbus/map/bus_tracker_card/next_stop.dart';

// Card for information on busses e.g. next stops, route information.
class BusNextStopsCard extends StatelessWidget {
  final String busId;
  final String busFullness;
  final String routeId;

  const BusNextStopsCard(
      {Key? key,
      required this.busId,
      required this.busFullness,
      required this.routeId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<List<NextStop>> getBusInfo() async {
      final api = ProviderScope.containerOf(context, listen: false).read(apiClientProvider);
      final resJson = await api.getBusPredictions(busId);
      if (resJson.isEmpty) {
        return [];
      }
      List<NextStop> _busses = [];
      if (resJson['prd'] != null) {
        resJson['prd'].forEach((e) {
          _busses.add(new NextStop(e['stpnm'], e['des'], e['prdctdn']));
        });
      }
      return _busses;
    }

    return ScrollConfiguration(
      behavior: CardScrollBehavior(),
      child: (ListView(
        shrinkWrap: true,
        controller: ModalScrollController.of(context),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                BusNextStopsCardHeader(
                    busId: busId, busFullness: busFullness, routeId: routeId),
                const SizedBox(
                  height: 32,
                ),
                const Text(
                  "Next Stops",
                  style: TextStyle(
                      color: MICHIGAN_MAIZE,
                      fontSize: 32,
                      fontWeight: FontWeight.w800),
                ),
                const Divider(),
                const SizedBox(
                  height: 8,
                ),
                BusTrackerCardBody(future: getBusInfo()),
                const SizedBox(
                  height: 16,
                ),
              ],
            ),
          )
        ],
      )),
    );
  }
}