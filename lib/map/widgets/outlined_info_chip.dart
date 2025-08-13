import 'package:flutter/material.dart';
import 'package:mbus/theme/app_theme.dart';

class OutlinedInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const OutlinedInfoChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
        avatar: Icon(icon, color: Theme.of(context).colorScheme.primary),
        label: Text(label,
            style: AppTextStyles.routeDirectionBlue
                .copyWith(color: Theme.of(context).colorScheme.primary)),
        backgroundColor: Colors.transparent,
        shape: StadiumBorder(
            side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade700
                    : Colors.grey.shade400)));
  }
}
