import 'package:flutter/material.dart';
import 'package:mbus/constants.dart';

class BusStopCardHeader extends StatelessWidget {
  final String busStopName;
  final void Function() onLaunchDirections;

  const BusStopCardHeader(
      {Key? key, required this.busStopName, required this.onLaunchDirections})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Flexible(
              child: Text(
            busStopName.replaceAll('  ', ' '),
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 38,
                color: MICHIGAN_BLUE),
          )),
        ]),
        SizedBox(
          height: 8,
        ),
        Container(
          child: ActionChip(
              onPressed: onLaunchDirections,
              avatar: Icon(
                Icons.directions_walk,
                color: MICHIGAN_BLUE,
              ),
              label: Text(
                "Directions",
                style:
                    TextStyle(color: MICHIGAN_BLUE, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.transparent,
              shape: StadiumBorder(side: BorderSide(color: Colors.grey.shade400))),
        ),
      ],
    );
  }
}
