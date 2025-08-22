import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:vibration/vibration.dart';
import 'package:mbus/about/about_screen.dart';
import 'package:mbus/dialogs/message_dialog.dart';
import 'package:mbus/feedback/presentation/feedback_screen.dart';
import 'package:mbus/map/presentation/card_scroll_behavior.dart';
import 'package:mbus/constants.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:mbus/data/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbus/state/assets_providers.dart';
import 'package:mbus/state/settings_notifier.dart';
import 'package:mbus/models/route_data.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mbus/preferences_keys.dart';
import 'package:mbus/theme/app_theme.dart';

const SETTINGS_TITLE_STYLE = AppTextStyles.settingsTitle;
const ABOUT_TEXT =
    "M-Bus is an application created using the U-M Magic Bus API to provide an unofficial application to track University of Michigan buses. "
    "\n\nThis is not an official U-M application and is not affiliated with U-M in any way."
    "\n\nIf you have any questions or concerns, please do not hesitate to let me know through the feedback form with an email I can contact.";

WidgetBuilder getFactoryResetDialog(BuildContext context) {
  final actions = [
    DialogAction(
      "Cancel",
      () {},
    ),
    DialogAction(
      "Reset",
      () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Phoenix.rebirth(context);
      },
    ),
  ];

  final dialogData = DialogData("Factory Reset",
      "Are you sure you want to return the app to factory settings?", actions);

  return getMessageDialog(dialogData);
}

WidgetBuilder getClearAssetsDialog(BuildContext context) {
  final actions = [
    DialogAction(
      "Cancel",
      () {},
    ),
    DialogAction(
      "Clear",
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(PrefKeys.routeInformation, "{}");
        final routeIds = ProviderScope.containerOf(context, listen: false)
            .read(routeMetaProvider)
            .routeIdToName
            .keys;

        for (final routeId in routeIds) {
          await CachedNetworkImage.evictFromCache(
              "$BACKEND_URL/getVehicleImage/$routeId?colorblind=Y");
          await CachedNetworkImage.evictFromCache(
              "$BACKEND_URL/getVehicleImage/$routeId?colorblind=N");
        }

        DefaultCacheManager()
            .emptyCache()
            .then((_) => Phoenix.rebirth(context));
      },
    ),
  ];

  final dialogData = DialogData("Clear Assets",
      "Are you sure you want to clear all assets from the cache?", actions);

  return getMessageDialog(dialogData);
}

class SwitchOptions extends StatelessWidget {
  final List<SwitchOption> options;

  const SwitchOptions(this.options, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : Colors.grey.shade200,
        border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade800
                : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: options,
      ),
    );
  }
}

class SwitchOption extends StatelessWidget {
  final String title;
  final bool value;
  final Function(bool) onChanged;

  const SwitchOption(this.title, this.value, this.onChanged, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.body.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16),
            ),
          ),
          Switch(
            value: value,
            activeColor: MICHIGAN_MAIZE,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class Settings extends ConsumerWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    return _SettingsContent(
      colorblindModeIsEnabled: settings.isColorBlind,
      darkModeIsEnabled: settings.isDarkMode,
      onToggleColorblind: () async {
        await ref.read(settingsNotifierProvider.notifier).toggleColorBlind();
      },
      onToggleDarkMode: () async {
        await ref.read(settingsNotifierProvider.notifier).toggleDarkMode();
      },
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String title;

  const SettingsSection(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 8, top: 24),
      child: Text(
        title,
        style: AppTextStyles.sectionTitle
            .copyWith(color: Theme.of(context).colorScheme.primary),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  final bool colorblindModeIsEnabled;
  final bool darkModeIsEnabled;
  final VoidCallback onToggleColorblind;
  final VoidCallback onToggleDarkMode;

  const _SettingsContent({
    required this.colorblindModeIsEnabled,
    required this.darkModeIsEnabled,
    required this.onToggleColorblind,
    required this.onToggleDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: (ListView(padding: EdgeInsets.all(16), children: [
          SizedBox(height: 16),
          Center(
            child: Image.asset(
              "assets/mbus_logo.png",
              width: MediaQuery.of(context).size.width * 0.4,
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            "Build: $BUILD_VERSION",
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
          SizedBox(
            height: 32,
          ),
          Text(ABOUT_TEXT),
          SizedBox(
            height: 32,
          ),
          SizedBox(
            height: 16,
          ),
          Divider(),
          SettingsSection("Options"),
          SwitchOptions([
            SwitchOption(
                "Dark Mode", darkModeIsEnabled, (v) => onToggleDarkMode()),
            SwitchOption("Colorblind Friendly", colorblindModeIsEnabled,
                (v) => onToggleColorblind()),
          ]),
          SettingsSection("Questions or Feedback?"),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MICHIGAN_BLUE,
              ),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => FeedbackScreen()));
              },
              child: Text("Send Feedback", style: AppTextStyles.buttonPrimary)),
          SettingsSection("Troubleshooting"),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MICHIGAN_BLUE,
              ),
              onPressed: () {
                showDialog(
                    context: context, builder: getClearAssetsDialog(context));
              },
              child: Text("Clear Asset Cache and Restart",
                  style: AppTextStyles.buttonPrimary)),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MICHIGAN_BLUE,
              ),
              onPressed: () {
                showDialog(
                    context: context, builder: getFactoryResetDialog(context));
              },
              child: Text("Reset to Factory Settings",
                  style: AppTextStyles.buttonPrimary)),
          SizedBox(
            height: 16,
          ),
          SettingsSection("More"),
          CupertinoButton(
              child: Text(
                "Privacy Policy and Terms & Conditions",
                style: AppTextStyles.body.copyWith(fontSize: 14),
              ),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => TermsScreen()));
              }),
        ])),
      ),
    );
  }
}

class SelectableBusRoute extends ConsumerWidget {
  final RouteData route;

  const SelectableBusRoute({super.key, required this.route});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final isSelected = settings.selectedRouteIds.contains(route.routeId);
    final routeColor = ref.read(routeMetaProvider).routeColors[route.routeId] ??
        const Color(0x00000000);

    Future<void> handleTap() async {
      final notifier = ref.read(settingsNotifierProvider.notifier);
      if (isSelected) {
        await notifier.removeSelectedRouteId(route.routeId);
      } else {
        await notifier.addSelectedRouteId(route.routeId);
      }
    }

    Future<void> handleLongPress() async {
      final notifier = ref.read(settingsNotifierProvider.notifier);
      await notifier.setSelectedRouteIds({route.routeId});
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 50);
      }
    }

    return GestureDetector(
      onTap: handleTap,
      onLongPress: handleLongPress,
      child: (Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(0, 0, 0, 16),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
            color: isSelected
                ? (Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF3A3000)
                    : const Color(0xFFffdf63))
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white,
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: Offset(-2, -2)),
              BoxShadow(
                  color: isSelected
                      ? (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF5A4700)
                          : const Color(0xFFD9B83C))
                      : Colors.black.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: Offset(2, 2))
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: routeColor,
                      borderRadius: BorderRadius.circular(15.0)),
                  height: 15,
                  width: 15,
                  margin: EdgeInsets.only(right: 15),
                ),
                Text(
                  route.routeName,
                  style: AppTextStyles.body
                      .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(isSelected ? Icons.check : Icons.add),
            ),
          ],
        ),
      )),
    );
  }
}

class SettingsCard extends ConsumerWidget {
  const SettingsCard({super.key});

  Future<List<RouteData>> _loadRoutes(
      BuildContext context, WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedSelections = prefs.getStringList('cachedSelections');
    List? routesJson;
    if (cachedSelections != null &&
        cachedSelections.length > 1 &&
        DateTime.now()
                .difference(DateTime.parse(cachedSelections[1]))
                .inMinutes <
            1) {
      routesJson =
          jsonDecode(cachedSelections[0])['bustime-response']['routes'];
    } else {
      final api = ProviderScope.containerOf(context, listen: false)
          .read(apiClientProvider);
      routesJson = (await api.getSelectableRoutes()).routes;
      await prefs.setStringList('cachedSelections', [
        jsonEncode({
          'bustime-response': {'routes': routesJson}
        }),
        DateTime.now().toString()
      ]);
    }
    if (routesJson == null) return [];
    return routesJson
        .map((e) => RouteData(routeId: e['rt'], routeName: e['rtnm']))
        .toList()
        .cast<RouteData>();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      child: ScrollConfiguration(
        behavior: CardScrollBehavior(),
        child: FutureBuilder<List<RouteData>>(
          future: _loadRoutes(context, ref),
          builder: (context, snap) {
            final routes = snap.data ?? const <RouteData>[];
            return ListView(
              controller: ModalScrollController.of(context),
              padding: EdgeInsets.all(16),
              children: [
                Text(
                  "Select Routes",
                  style: SETTINGS_TITLE_STYLE.copyWith(
                      color: Theme.of(context).colorScheme.primary),
                ),
                SizedBox(height: 4),
                Text(
                  "Tip: Long press a route to only show that route",
                  style: AppTextStyles.body
                      .copyWith(color: Colors.grey, fontSize: 14),
                ),
                Divider(),
                SizedBox(height: 16),
                if (!snap.hasData) CupertinoActivityIndicator(),
                ...routes.map((e) => SelectableBusRoute(route: e)),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ActionChip(
                      onPressed: Navigator.of(context).pop,
                      avatar: Icon(
                        Icons.map,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      label: Text(
                        "Back to Map",
                        style: AppTextStyles.routeDirectionBlue.copyWith(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      backgroundColor: Colors.transparent,
                      shape: StadiumBorder(
                          side: BorderSide(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade400)),
                    )
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
