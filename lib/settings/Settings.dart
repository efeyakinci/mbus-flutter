import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:vibration/vibration.dart';
import 'package:mbus/about/about_screen.dart';
import 'package:mbus/dialogs/message_dialog.dart';
import 'package:mbus/feedback/Feedback.dart';
import 'package:mbus/map/card_scroll_behavior.dart';
import 'package:mbus/constants.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:mbus/mbus_utils.dart';
import 'package:mbus/state/app_state.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:equatable/equatable.dart';
import 'package:mbus/preferences_keys.dart';

const SETTINGS_TITLE_STYLE =
    TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: MICHIGAN_BLUE);
const ABOUT_TEXT =
    "M-Bus is an application created using the U-M Magic Bus API to provide an unofficial application to track University of Michigan buses. "
    "\n\nThis is not an official U-M application and is not affiliated with U-M in any way."
    "\n\nIf you have any questions or concerns, please do not hesitate to let me know through the feedback form with an email I can contact.";

class RouteData extends Equatable {
  final String routeId;
  final String routeName;

  RouteData(this.routeId, this.routeName);

  RouteData.fromJson(Map<String, dynamic> json)
      : routeId = json['routeId'],
        routeName = json['routeName'];

  @override
  List<Object> get props => [routeId];

  Map<String, String> toJson() {
    return {'routeId': routeId, 'routeName': routeName};
  }

  @override
  String toString() {
    return "[RouteData] Route ID: $routeId, Route Name: $routeName";
  }
}

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
  final AppState appState = AppState();
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
        final routeNames = appState.routeToImage;

        for (final routeName in routeNames.keys) {
          await CachedNetworkImage.evictFromCache("$BACKEND_URL/getVehicleImage/${routeName}?colorblind=Y");
          await CachedNetworkImage.evictFromCache("$BACKEND_URL/getVehicleImage/${routeName}?colorblind=N");
        }

        DefaultCacheManager().emptyCache().then((_) => Phoenix.rebirth(context));
      },
    ),
  ];

  final dialogData = DialogData("Clear Assets",
      "Are you sure you want to clear all assets from the cache?", actions);

  return getMessageDialog(dialogData);
}

class SwitchOptions extends StatelessWidget {
  List<SwitchOption> options = [];

  SwitchOptions(this.options);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.grey.shade300),
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

  SwitchOption(this.title, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                  color: MICHIGAN_BLUE,
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

class Settings extends StatefulWidget {
  final Function(Set<RouteData>) setSelectedRoutes;

  Settings(this.setSelectedRoutes);

  _SettingsState createState() => _SettingsState();
}

class SettingsSection extends StatelessWidget {
  final String title;

  SettingsSection(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        title,
        style: TextStyle(
            color: MICHIGAN_BLUE, fontWeight: FontWeight.w800, fontSize: 18),
        textAlign: TextAlign.center,
      ),
      padding: EdgeInsets.only(bottom: 8, top: 24),
    );
  }
}

class _SettingsState extends State<Settings> {
  bool colorblindModeIsEnabled = false;

  void _checkIfColorblindModeIsEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      colorblindModeIsEnabled = prefs.getBool(PrefKeys.colorBlindEnabled) ?? false;
    });
  }

  void setColorblindMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefKeys.colorBlindEnabled, value);
    setState(() {
      colorblindModeIsEnabled = value;
    });
    DialogAction action = DialogAction("OK", () {
      DefaultCacheManager().emptyCache().then((_) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(PrefKeys.routeInformation, "{}");
        Phoenix.rebirth(context);
        });
    });
    DialogData data = DialogData(
        "Colorblind Mode",
        "Colorblind mode has been ${value ? "enabled" : "disabled"}.\n\nThe app will now reload to apply the changes.",
        [action]);
    showDialog(context: context, builder: getMessageDialog(data), barrierDismissible: false);
  }

  @override
  void initState() {
    super.initState();
    _checkIfColorblindModeIsEnabled();
  }

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
            "Build: ${BUILD_VERSION}",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey,
                fontSize: 12),
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
          SwitchOptions(
            [
              //SwitchOption("Dark Mode", false, (p0) => null),
              SwitchOption("Colorblind Friendly", colorblindModeIsEnabled,
                  setColorblindMode),
            ]
          ),
          SettingsSection("Questions or Feedback?"),
          ElevatedButton(
              child: Text("Send Feedback", style: TextStyle(color: Colors.white)),
              // set color of button
              style: ElevatedButton.styleFrom(
                backgroundColor: MICHIGAN_BLUE,
              ),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => FeedbackScreen()));
              }),
          SettingsSection("Troubleshooting"),
          ElevatedButton(
              child: Text("Clear Asset Cache and Restart", style: TextStyle(color: Colors.white)),
              // set color of button
              style: ElevatedButton.styleFrom(
                backgroundColor: MICHIGAN_BLUE,
              ),
              onPressed: () {
                showDialog(
                    context: context, builder: getClearAssetsDialog(context));
              }),
          ElevatedButton(
              child: Text("Reset to Factory Settings", style: TextStyle(color: Colors.white)),
              // set color of button
              style: ElevatedButton.styleFrom(
                backgroundColor: MICHIGAN_BLUE,
              ),
              onPressed: () {
                showDialog(
                    context: context, builder: getFactoryResetDialog(context));
              }),
          SizedBox(
            height: 16,
          ),
          SettingsSection("More"),
          CupertinoButton(
              child: Text(
                "Privacy Policy and Terms & Conditions",
                style: TextStyle(fontSize: 14),
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
  String name;
  Color routeColor;
  bool selected;
  VoidCallback onClick;
  VoidCallback onLongClick;

  SelectableBusRoute(this.name, this.selected, this.onClick, this.onLongClick,
      this.routeColor);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      onLongPress: () async {
        onLongClick();
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(duration: 50);
        }
      },
      child: (Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(0, 0, 0, 16),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
            color: selected ? Color(0xFFffdf63) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.white,
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: Offset(-2, -2)),
              BoxShadow(
                  color: selected
                      ? Color(0xFFD9B83C)
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

class SettingsCard extends StatefulWidget {
  final Function(Set<RouteData>) setSelectedRoutes;

  SettingsCard(this.setSelectedRoutes);
  @override
  _SettingsCardState createState() => _SettingsCardState();
}

class _SettingsCardState extends State<SettingsCard> {
  List<RouteData> _routes = [];
  Set<RouteData> selectedRoutes = Set();
  late SharedPreferences prefs;

  void _toggleRoute(RouteData route) {
    setState(() {
      if (selectedRoutes.contains(route)) {
        selectedRoutes.remove(route);
      } else {
        selectedRoutes.add(route);
      }
      widget.setSelectedRoutes(Set.from(selectedRoutes));
      prefs.setString(PrefKeys.selectedRoutes, jsonEncode(selectedRoutes.toList()));
    });
  }

  void _onlySelectRoute(RouteData route) {
    setState(() {
      selectedRoutes.clear();
      selectedRoutes.add(route);
      widget.setSelectedRoutes(Set.from(selectedRoutes));
      prefs.setString(PrefKeys.selectedRoutes, jsonEncode(selectedRoutes.toList()));
    });
  }

  void _getRouteNames() async {
    if (!mounted) {
      return;
    }
    prefs = await SharedPreferences.getInstance();
    final String? storedSelections = prefs.getString('selectedRoutes');
    if (storedSelections != null) {
      jsonDecode(storedSelections).forEach((e) {
        selectedRoutes.add(RouteData.fromJson(e));
      });
    }
    List<String>? cachedSelections = prefs.getStringList('cachedSelections');
    List? routesJson = [];
    if (cachedSelections != null &&
        cachedSelections[1] != null &&
        DateTime.now()
                .difference(DateTime.parse(cachedSelections[1]))
                .inMinutes < 1) {
      routesJson =
          jsonDecode(cachedSelections[0])['bustime-response']['routes'];
    } else {
      final res = await NetworkUtils.getWithErrorHandling(
          context, "getSelectableRoutes");
      routesJson = jsonDecode(res)?['bustime-response']?['routes'] ?? null;
      if (routesJson == null) {
        return;
      }
      prefs.setStringList('cachedSelections', [res, DateTime.now().toString()]);
    }
    setState(() {
      _routes =
          routesJson!.map((e) => new RouteData(e['rt'], e['rtnm'])).toList();
    });
  }

  @override
  void initState() {
    _getRouteNames();
    NetworkUtils.addListener(() {
      if (!NetworkUtils.hasNetworkError) {
        _getRouteNames();
      }
    });
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
                style: SETTINGS_TITLE_STYLE,
              ),
              SizedBox(height: 4),
              Text(
                "Tip: Long press a route to only show that route",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Divider(),
              SizedBox(height: 16),
              if (_routes.isEmpty) CupertinoActivityIndicator(),
              ..._routes.map((e) => SelectableBusRoute(
                      e.routeName, selectedRoutes.contains(e), () {
                    _toggleRoute(e);
                  }, () {
                    _onlySelectRoute(e);
                  },
                      AppState().routeColors[e.routeId] ??
                          Color(0x00000000))),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ActionChip(
                    onPressed: Navigator.of(context).pop,
                    avatar: Icon(
                      Icons.map,
                      color: MICHIGAN_BLUE,
                    ),
                    label: Text(
                      "Back to Map",
                      style: TextStyle(
                          color: MICHIGAN_BLUE, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.transparent,
                    shape: StadiumBorder(
                        side: BorderSide(color: Colors.grey.shade400)),
                  )
                ],
              )
            ])),
      ),
    );
  }
}
