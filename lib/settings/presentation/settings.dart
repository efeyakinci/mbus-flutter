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
import 'package:mbus/state/assets_controller.dart';
import 'package:mbus/state/settings_controller.dart';
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
    final settings = ref.watch(settingsProvider);
    return _SettingsContent(
      colorblindModeIsEnabled: settings.isColorBlind,
      darkModeIsEnabled: settings.isDarkMode,
      onToggleColorblind: () {
        ref.read(settingsProvider.notifier).toggleColorBlind();
      },
      onToggleDarkMode: () {
        ref.read(settingsProvider.notifier).toggleDarkMode();
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

class SelectableBusRoute extends StatelessWidget {
  final String name;
  final Color routeColor;
  final bool selected;
  final VoidCallback onClick;
  final VoidCallback onLongClick;

  const SelectableBusRoute(
      this.name, this.selected, this.onClick, this.onLongClick, this.routeColor,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      onLongPress: () async {
        onLongClick();
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          Vibration.vibrate(duration: 50);
        }
      },
      child: (Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(0, 0, 0, 16),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
            color: selected
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
                  color: selected
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
                  name,
                  style: AppTextStyles.body
                      .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(selected ? Icons.check : Icons.add),
            ),
          ],
        ),
      )),
    );
  }
}

class SettingsCard extends ConsumerStatefulWidget {
  final Function(Set<RouteData>) setSelectedRoutes;

  const SettingsCard(this.setSelectedRoutes, {super.key});
  @override
  _SettingsCardState createState() => _SettingsCardState();
}

class _SettingsCardState extends ConsumerState<SettingsCard> {
  List<RouteData> _routes = [];
  Set<RouteData> selectedRoutes = {};
  late SharedPreferences prefs;

  void _toggleRoute(RouteData route) {
    setState(() {
      final hasId = selectedRoutes.any((r) => r.routeId == route.routeId);
      if (hasId) {
        selectedRoutes.removeWhere((r) => r.routeId == route.routeId);
      } else {
        selectedRoutes.add(route);
      }
      widget.setSelectedRoutes(Set.from(selectedRoutes));
      ref
          .read(settingsProvider.notifier)
          .setSelectedRoutes(selectedRoutes.map((e) => e.routeId).toSet());
    });
  }

  void _onlySelectRoute(RouteData route) {
    setState(() {
      selectedRoutes.clear();
      selectedRoutes.add(route);
      widget.setSelectedRoutes(Set.from(selectedRoutes));
      ref.read(settingsProvider.notifier).setSelectedRoutes({route.routeId});
    });
  }

  void _getRouteNames() async {
    if (!mounted) return;
    prefs = await SharedPreferences.getInstance();
    final selectedIds = ref.read(settingsProvider).selectedRouteIds;
    final idToName = ref.read(routeMetaProvider).routeIdToName;
    selectedRoutes = selectedIds
        .map((id) => RouteData(routeId: id, routeName: idToName[id] ?? id))
        .toSet();
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
      prefs.setStringList('cachedSelections', [
        jsonEncode({
          'bustime-response': {'routes': routesJson}
        }),
        DateTime.now().toString()
      ]);
    }
    if (routesJson != null) {
      setState(() {
        _routes = routesJson!
            .map((e) => RouteData(routeId: e['rt'], routeName: e['rtnm']))
            .toList()
            .cast<RouteData>();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getRouteNames();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ScrollConfiguration(
        behavior: CardScrollBehavior(),
        child: (ListView(
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
              if (_routes.isEmpty) CupertinoActivityIndicator(),
              ..._routes.map((e) => SelectableBusRoute(e.routeName,
                      selectedRoutes.any((r) => r.routeId == e.routeId), () {
                    _toggleRoute(e);
                  }, () {
                    _onlySelectRoute(e);
                  },
                      ref.read(routeMetaProvider).routeColors[e.routeId] ??
                          Color(0x00000000))),
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
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade400)),
                  )
                ],
              )
            ])),
      ),
    );
  }
}
