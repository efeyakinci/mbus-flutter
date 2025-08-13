import 'package:flutter/material.dart';
import 'package:mbus/theme/app_theme.dart';
import 'package:mbus/map/widgets/outlined_pill_button.dart';

class BusStopCardHeader extends StatelessWidget {
  final String busStopName;
  final void Function() onLaunchDirections;

  const BusStopCardHeader(
      {super.key, required this.busStopName, required this.onLaunchDirections});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Flexible(
              child: Text(
            busStopName.replaceAll('  ', ' '),
            style: AppTextStyles.headerStopName
                .copyWith(color: Theme.of(context).colorScheme.primary),
          )),
        ]),
        SizedBox(
          height: 8,
        ),
        OutlinedPillButton(
            icon: Icons.directions_walk,
            label: "Directions",
            onPressed: onLaunchDirections),
      ],
    );
  }
}
