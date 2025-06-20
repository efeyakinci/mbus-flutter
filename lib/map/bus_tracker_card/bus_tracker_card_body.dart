import 'package:flutter/material.dart';
import 'package:mbus/map/animations.dart';

import '../../constants.dart';
import '../data_types.dart';
import 'next_stop.dart';

// Data display item for a single upcoming stop for a bus information card.
class BusNextStopsDisplay extends StatelessWidget {
  final NextStop bus;

  const BusNextStopsDisplay({Key? key, required this.bus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor))),
      child: (Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              child: Text(
            bus.stopName.replaceAll('  ', ' '),
            style: TextStyle(
                color: MICHIGAN_BLUE,
                fontWeight: FontWeight.w800,
                fontSize: 20),
          )),
          Container(
              child: Text(
            bus.estTimeMin == "DUE"
                ? "Arriving within the next minute"
                : "In about ${bus.estTimeMin} minutes",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          )),
          Row(
            children: [
              Flexible(
                  child: Text(
                "Towards ${bus.destination} ",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              )),
            ],
          )
        ],
      )),
    );
  }
}

class BusTrackerCardBody extends StatelessWidget {
  final Future<List<NextStop>> future;

  const BusTrackerCardBody({Key? key, required this.future}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, AsyncSnapshot<List<NextStop>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return CardTextLoadingAnimation(5);
          } else {
            if (snapshot.hasData && snapshot.data != null) {
              if (snapshot.data!.length == 0) {
                return Text(
                  "This bus does not currently have any stops scheduled.",
                  style: TextStyle(fontSize: 18),
                );
              }
              return Container(
                child: Column(
                  children: snapshot.data!
                      .map((e) => BusNextStopsDisplay(bus: e))
                      .toList(),
                ),
              );
            } else {
              return Text(
                  "Error. Please try again. If the issue persists, please let me know through the feedback form under the \"More\" tab on the bottom of the screen.");
            }
          }
        });
  }
}