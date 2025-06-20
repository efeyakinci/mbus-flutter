import 'package:flutter/material.dart';
import 'package:mbus/state/app_state.dart';
import 'package:mbus/constants.dart';

import '../data_types.dart';

class BusNextStopsCardHeader extends StatelessWidget {
  final String busId;
  final String busFullness;
  final String routeId;

  const BusNextStopsCardHeader(
      {Key? key,
      required this.busId,
      required this.busFullness,
      required this.routeId})
      : super(key: key);

  IconData getFullnessIcon(String fullness) {
    switch (fullness) {
      case "EMPTY":
        return Icons.person;
      case "HALF_EMPTY":
        return Icons.group;
      case "FULL":
        return Icons.groups;
      default:
        return Icons.error;
    }
  }

  String getFullnessText(String fullness) {
    switch (fullness) {
      case "EMPTY":
        return "Not crowded";
      case "HALF_EMPTY":
        return "Moderately crowded";
      case "FULL":
        return "Very crowded";
      default:
        return "Error";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Michigan API sometimes serves names with double spaces.
            Flexible(
              child: Text(
                "Bus ${busId}",
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 46,
                    color: MICHIGAN_BLUE),
              ),
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        Container(
          child: Text(
            AppState().routeIdToRouteName[routeId] ?? "Unknown Route",
            style: TextStyle(
                color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          margin: EdgeInsets.fromLTRB(0, 4, 0, 0),
        ),
        SizedBox(height: 8),
        Chip(
            avatar: Icon(
              getFullnessIcon(busFullness),
              color: MICHIGAN_BLUE,
            ),
            label: Text(
              getFullnessText(busFullness),
              style:
                  TextStyle(color: MICHIGAN_BLUE, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            shape:
                StadiumBorder(side: BorderSide(color: Colors.grey.shade400))),
      ],
    );
  }
}
