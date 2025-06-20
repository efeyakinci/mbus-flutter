import 'package:flutter/material.dart';
import 'package:mbus/map/animations.dart';
import 'package:mbus/constants.dart';
import '../data_types.dart';

class BusStopCardBody extends StatelessWidget {
  final Future<List<IncomingBus>> future;

  const BusStopCardBody({Key? key, required this.future}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, AsyncSnapshot<List<IncomingBus>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return CardTextLoadingAnimation(5);
          } else {
            if (snapshot.hasData && snapshot.data != null) {
              if (snapshot.data!.length == 0) {
                return Container(
                  child: Text(
                    "No bus service to the stop at this time",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  margin: EdgeInsets.only(bottom: 16),
                );
              }
              return Container(
                child: Column(
                  children:
                      snapshot.data!.map((e) => BusArrivalDisplay(bus: e)).toList(),
                ),
              );
            } else {
              return Text("Error.");
            }
          }
        });
  }
}

// Data display item for a bus stop card for arriving busses.
class BusArrivalDisplay extends StatelessWidget {
  final IncomingBus bus;

  const BusArrivalDisplay({Key? key, required this.bus}) : super(key: key);

  String getArrivalText(String arrivalTime) {
    if (arrivalTime == "DUE") {
      return "Arriving within the next minute";
    } else {
      return "In about ${arrivalTime} minutes";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: Theme.of(context).dividerColor))),
      child: (Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              child: Text(
            bus.route,
            style: TextStyle(
                color: MICHIGAN_BLUE,
                fontWeight: FontWeight.w800,
                fontSize: 16),
          )),
          Container(
              child: Text(
            getArrivalText(bus.estTimeMin),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          )),
          Row(
            children: [
              Flexible(
                  child: Text(
                "Towards ${bus.to} ",
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