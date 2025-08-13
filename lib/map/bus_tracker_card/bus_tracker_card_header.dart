import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbus/state/assets_controller.dart';
import 'package:mbus/theme/app_theme.dart';
import 'package:mbus/map/widgets/outlined_info_chip.dart';


class BusNextStopsCardHeader extends ConsumerWidget {
  final String busId;
  final String busFullness;
  final String routeId;

  const BusNextStopsCardHeader(
      {super.key,
      required this.busId,
      required this.busFullness,
      required this.routeId});

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
      case "N/A":
        return "No data";
      default:
        return "Error";
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Michigan API sometimes serves names with double spaces.
            Flexible(
              child: Text(
                "Bus ${busId}",
                style: AppTextStyles.headerBusTitle
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 4, 0, 0),
          child: Text(
            ref.read(routeMetaProvider).routeIdToName[routeId] ?? "Unknown Route",
            style: AppTextStyles.body.copyWith(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 8),
          OutlinedInfoChip(icon: getFullnessIcon(busFullness), label: getFullnessText(busFullness)),
      ],
    );
  }
}
