import 'package:flutter/material.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:mbus/GlobalConstants.dart';
import 'package:mbus/constants.dart';

part 'BusStopCardHeader.g.dart';


@swidget
Widget busStopCardHeader(BuildContext context, String busStopName, Function() launchDirectionsSelectionScreen) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Flexible(child: Text(busStopName.replaceAll('  ', ' '), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 38, color: MICHIGAN_BLUE),)),
        ]
      ),
      SizedBox(height: 8,),
      Container(
        child: ActionChip(
            onPressed: launchDirectionsSelectionScreen,
            avatar: Icon(Icons.directions_walk, color: MICHIGAN_BLUE,),
            label: Text("Directions", style: TextStyle(color: MICHIGAN_BLUE, fontWeight: FontWeight.bold),),
            backgroundColor: Colors.transparent,
            shape: StadiumBorder(side: BorderSide(color: Colors.grey.shade400))
        ),
      ),
    ],
  );
}
