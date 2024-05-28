
// Data holder class for busses' next stops.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:mbus/constants.dart';
import 'package:mbus/map/Animations.dart';
import 'package:mbus/map/BusTrackerCard/NextStop.dart';
import 'package:mbus/map/CardScrollBehavior.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:mbus/mbus_utils.dart';

import 'BusTrackerCardHeader.dart';
import 'BusTrackerCardBody.dart';



part 'BusTrackerCard.g.dart';



// Card for information on busses e.g. next stops, route information.
@swidget
Widget busNextStopsCard(BuildContext context, String busId, String busFullness, String routeId) {

  Future<List<NextStop>> getBusInfo() async {
    final res = await NetworkUtils.getWithErrorHandling(context, "getBusPredictions/${busId}");
    final resJson = jsonDecode(res)['bustime-response'];
    if (resJson == null) {
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
                  BusNextStopsCardHeader(busId, busFullness, routeId),
                  SizedBox(height: 32,),
                  Text("Next Stops", style: TextStyle(color: MICHIGAN_MAIZE, fontSize: 32, fontWeight: FontWeight.w800),),
                  Divider(),
                  SizedBox(height: 8,),
                  BusTrackerCardBody(future: getBusInfo()),
                  SizedBox(height: 16,),
                ],
              ),
            )],
        )
    ),
  );
}