import 'package:flutter/material.dart';
import 'package:mbus/theme/app_theme.dart';

class ThreeLineListItem extends StatelessWidget {
  final String titleText;
  final String primaryText;
  final String metaText;
  final TextStyle? titleStyleOverride;
  final TextStyle? primaryStyleOverride;

  const ThreeLineListItem(
      {super.key,
      required this.titleText,
      required this.primaryText,
      required this.metaText,
      this.titleStyleOverride,
      this.primaryStyleOverride});

  @override
  Widget build(BuildContext context) {
    final Color metaColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titleText,
              style: (titleStyleOverride ?? AppTextStyles.routeName)
                  .copyWith(color: Theme.of(context).colorScheme.primary)),
          Text(primaryText,
              style: primaryStyleOverride ?? AppTextStyles.bodyStrong),
          Row(children: [
            Flexible(
                child: Text(metaText,
                    style: AppTextStyles.routeMeta.copyWith(color: metaColor))),
          ])
        ],
      ),
    );
  }
}
