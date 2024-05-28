import 'package:flutter/material.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:mbus/constants.dart';
import 'package:mbus/map/Animations.dart';
import 'package:mbus/map/BusTrackerCard/NextStop.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mbus/map/DataTypes.dart';

part 'BusStopCardBody.g.dart';



@hwidget
Widget busStopCardBody(BuildContext context, {future}) {
  return FutureBuilder(future: future,
      builder: (context, AsyncSnapshot<List<IncomingBus>> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return CardTextLoadingAnimation(5);
        } else {
          if (snapshot.hasData && snapshot.data != null) {
            if (snapshot.data!.length == 0) {
              return Container(child: Text("No bus service to the stop at this time", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),), margin: EdgeInsets.only(bottom: 16),);
            }
            return Container(
              child: Column(
                children: snapshot.data!.map((e) => BusArrivalDisplay(e)).toList(),
              ),
            );
          } else {
            return Text("Error.");
          }
        }
      });
}

// Data display item for a bus stop card for arriving busses.
@swidget
Widget busArrivalDisplay(BuildContext context, IncomingBus bus) {
  String getArrivalText(String arrivalTime) {
    if (arrivalTime == "DUE") {
      return "Arriving within the next minute";
    } else {
      return "In about ${arrivalTime} minutes";
    }
  }

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
            Container(child: Text(bus.route, style: TextStyle(color: MICHIGAN_BLUE, fontWeight: FontWeight.w800, fontSize: 16),)),
            Container(child: Text(getArrivalText(bus.estTimeMin), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)),
            Row(
              children: [
                Flexible(child: Text("Towards ${bus.to} ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),)),
              ],
            )
          ],
        )
    ),
  );
}