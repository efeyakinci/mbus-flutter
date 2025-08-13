import 'package:flutter/material.dart';
import 'package:mbus/map/presentation/animations.dart';

import 'next_stop.dart';
import 'package:mbus/theme/app_theme.dart';
import 'package:mbus/map/widgets/three_line_list_item.dart';

// Data display item for a single upcoming stop for a bus information card.
class BusNextStopsDisplay extends StatelessWidget {
  final NextStop bus;

  const BusNextStopsDisplay({super.key, required this.bus});

  @override
  Widget build(BuildContext context) {
    final bool isDue = bus.estTimeMin == "DUE";
    return ThreeLineListItem(
      titleText: bus.stopName.replaceAll('  ', ' '),
      primaryText: isDue
          ? "Arriving within the next minute"
          : "In about ${bus.estTimeMin} minutes",
      metaText: "Towards ${bus.destination} ",
      titleStyleOverride: AppTextStyles.routeName.copyWith(fontSize: 20),
      primaryStyleOverride:
          AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class BusTrackerCardBody extends StatelessWidget {
  final Future<List<NextStop>> future;

  const BusTrackerCardBody({super.key, required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (context, AsyncSnapshot<List<NextStop>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return CardTextLoadingAnimation(5);
          } else {
            if (snapshot.hasData && snapshot.data != null) {
              if (snapshot.data!.isEmpty) {
                return Text(
                  "This bus does not currently have any stops scheduled.",
                  style: AppTextStyles.body,
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
