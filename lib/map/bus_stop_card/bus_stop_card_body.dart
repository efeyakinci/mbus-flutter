import 'package:flutter/material.dart';
import 'package:mbus/map/presentation/animations.dart';
import 'package:mbus/map/domain/data_types.dart';
import 'package:mbus/theme/app_theme.dart';
import 'package:mbus/map/widgets/three_line_list_item.dart';

class BusStopCardBody extends StatelessWidget {
  final Future<List<IncomingBus>> future;

  const BusStopCardBody({super.key, required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, AsyncSnapshot<List<IncomingBus>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return CardTextLoadingAnimation(5);
          } else {
            if (snapshot.hasData && snapshot.data != null) {
              if (snapshot.data!.isEmpty) {
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Text(
                    "No bus service to the stop at this time",
                    style: AppTextStyles.bodyStrong,
                  ),
                );
              }
              return Container(
                child: Column(
                  children: snapshot.data!
                      .map((e) => BusArrivalDisplay(bus: e))
                      .toList(),
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

  const BusArrivalDisplay({super.key, required this.bus});

  String getArrivalText(String arrivalTime) {
    if (arrivalTime == "DUE") {
      return "Arriving within the next minute";
    } else {
      return "In about $arrivalTime minutes";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThreeLineListItem(
      titleText: bus.route,
      primaryText: getArrivalText(bus.estTimeMin),
      metaText: "Towards ${bus.to} ",
    );
  }
}
