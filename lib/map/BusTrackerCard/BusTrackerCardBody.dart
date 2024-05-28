import 'package:flutter/material.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:mbus/constants.dart';
import 'package:mbus/map/Animations.dart';
import 'package:mbus/map/BusTrackerCard/NextStop.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

part 'BusTrackerCardBody.g.dart';

// Data display item for a single upcoming stop for a bus information card.
@swidget
Widget busNextStopsDisplay(BuildContext context, NextStop bus) {
  return Container(
    margin: EdgeInsets.only(bottom: 16),
    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))
    ),
    child: (
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(child: Text(bus.stopName.replaceAll('  ', ' '), style: TextStyle(color: MICHIGAN_BLUE, fontWeight: FontWeight.w800, fontSize: 20),)),
            Container(child: Text(bus.estTimeMin == "DUE" ? "Arriving within the next minute" : "In about ${bus.estTimeMin} minutes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),)),
            Row(
              children: [
                Flexible(child: Text("Towards ${bus.destination} ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),)),
              ],
            )
          ],
        )
    ),
  );
}

@hwidget
Widget busTrackerCardBody(BuildContext context, {future}) {
  return FutureBuilder(future: future, builder: (context, AsyncSnapshot<List<NextStop>> snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return CardTextLoadingAnimation(5);
    } else {
      if (snapshot.hasData && snapshot.data != null) {
        if (snapshot.data!.length == 0) {
          return Text("This bus does not currently have any stops scheduled.", style: TextStyle(fontSize: 18),);
        }
        return Container(
          child: Column(
            children: snapshot.data!.map((e) => BusNextStopsDisplay(e)).toList(),
          ),
        );
      } else {
        return Text("Error. Please try again. If the issue persists, please let me know through the feedback form under the \"More\" tab on the bottom of the screen.");
      }
    }
  });
}