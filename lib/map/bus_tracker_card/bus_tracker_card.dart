// Data holder class for busses' next stops.

import 'package:flutter/material.dart';
// ignore_for_file: unused_import
import 'package:mbus/constants.dart';
import 'package:mbus/theme/app_theme.dart';
import 'package:mbus/map/presentation/card_scroll_behavior.dart';
import 'package:mbus/data/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:mbus/map/bus_tracker_card/bus_tracker_card_body.dart';
import 'package:mbus/map/bus_tracker_card/bus_tracker_card_header.dart';
import 'package:mbus/map/bus_tracker_card/next_stop.dart';
import 'package:mbus/map/widgets/bottom_sheet_card.dart';

// Card for information on busses e.g. next stops, route information.
class BusNextStopsCard extends StatelessWidget {
  final String busId;
  final String busFullness;
  final String routeId;

  const BusNextStopsCard(
      {super.key,
      required this.busId,
      required this.busFullness,
      required this.routeId});

  @override
  Widget build(BuildContext context) {
    Future<List<NextStop>> getBusInfo() async {
      final api = ProviderScope.containerOf(context, listen: false).read(apiClientProvider);
      final resJson = await api.getBusPredictions(busId);
      if (resJson.isEmpty) {
        return [];
      }
      List<NextStop> busses = [];
      if (resJson['prd'] != null) {
        resJson['prd'].forEach((e) {
          busses.add(NextStop(e['stpnm'], e['des'], e['prdctdn']));
        });
      }
      return busses;
    }

    return BottomSheetCard(
      header: BusNextStopsCardHeader(busId: busId, busFullness: busFullness, routeId: routeId),
      sectionTitle: "Next Stops",
      body: BusTrackerCardBody(future: getBusInfo()),
    );
  }
}