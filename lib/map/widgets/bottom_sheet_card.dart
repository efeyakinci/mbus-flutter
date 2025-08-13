import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:mbus/map/presentation/card_scroll_behavior.dart';
import 'package:mbus/theme/app_theme.dart';

class BottomSheetCard extends StatelessWidget {
  final Widget header;
  final String sectionTitle;
  final Widget body;
  final Widget? footer;

  const BottomSheetCard(
      {super.key,
      required this.header,
      required this.sectionTitle,
      required this.body,
      this.footer});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: CardScrollBehavior(),
      child: ListView(
        shrinkWrap: true,
        controller: ModalScrollController.of(context),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                header,
                const SizedBox(height: 32),
                Text(sectionTitle, style: AppTextStyles.arrivalsSection),
                const Divider(),
                const SizedBox(height: 8),
                body,
                if (footer != null) const SizedBox(height: 16),
                if (footer != null) footer!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
