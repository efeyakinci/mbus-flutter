import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logging/logging.dart';
import 'package:mbus/dialogs/message_dialog.dart';
import 'package:mbus/favorites/favorites.dart';
import 'package:mbus/map/main_map.dart';
import 'package:mbus/onboarding/onboarding.dart';
import 'package:bitmap/bitmap.dart';
import 'package:mbus/settings/settings.dart';
import 'package:mbus/constants.dart';
import 'package:mbus/mbus_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:mbus/map/data_types.dart';
import 'package:mbus/services/asset_loader.dart';
import 'package:mbus/services/notification_service.dart';
import 'package:mbus/state/app_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbus/state/assets_controller.dart';
import 'package:mbus/state/settings_state.dart';
import 'package:mbus/preferences_keys.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('[${record.level.name}] ${record.time}: ${record.message}');
  });

  final navKey = GlobalKey<NavigatorState>();

  runApp(ProviderScope(
    overrides: [navigatorKeyProvider.overrideWithValue(navKey)],
    child: MyApp(navigatorKey: navKey),
  ));
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const MyApp({Key? key, required this.navigatorKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Phoenix(
        child: MaterialApp(
      title: 'MBus',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
          primaryColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(
              color: Colors.black, //change your color here
            ),
          )),
      home: const DefaultTabController(length: 3, child: OnBoardingSwitcher()),
    ));
  }
}

class OnBoardingSwitcher extends StatefulWidget {
  const OnBoardingSwitcher({Key? key}) : super(key: key);
  @override
  createState() => _OnBoardingSwitcherState();
}

class _OnBoardingSwitcherState extends State<OnBoardingSwitcher>
    with WidgetsBindingObserver {
  bool _hasBeenOnboarded = false;
  bool _isLoaded = false;
  Set<RouteData> selectedRoutes = <RouteData>{};

  final log = Logger("main.dart");
  final AssetLoader _assetLoader = AssetLoader();
  final NotificationService _notificationService = NotificationService();

  Future<void> _checkIfOnboarded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasBeenOnboarded = prefs.getBool(PrefKeys.onboarded) ?? false;
    });
    if (_hasBeenOnboarded) {
      _notificationService.checkMessages(context);
    }
  }

  Future<void> _onBoardingComplete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    LocationPermission permission;
    if (await Geolocator.isLocationServiceEnabled()) {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
    }
    await prefs.setBool(PrefKeys.onboarded, true);
    setState(() {
      _hasBeenOnboarded = true;
    });
  }

  Future<void> getSelectedRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedSelections = prefs.getString(PrefKeys.selectedRoutes);

    if (storedSelections == null || storedSelections.isEmpty) {
      return;
    }

    setState(() {
      jsonDecode(storedSelections).forEach((e) {
        selectedRoutes.add(RouteData(e['routeId'], e['routeName']));
      });
    });

    log.info("Got selected routes");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _assetLoader.checkNewAssets(context);
      _notificationService.checkMessages(context);
    }
  }

  void loadData() async {
    await Future.wait([
      getSelectedRoutes(),
      _assetLoader.checkNewAssets(context),
      _checkIfOnboarded(),
      _notificationService.checkUpdateNotes(context),
    ]);
    // depends on _checkNewAssets
    await _assetLoader.loadBusImages(context);
    setState(() {
      _isLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    log.info("Loading initialization data...");
    loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: const AssetImage('assets/mbus_logo.png'),
                width: MediaQuery.of(context).size.width * 0.75,
              ),
              const SizedBox(height: 60),
              const CircularProgressIndicator(color: MICHIGAN_MAIZE),
              const SizedBox(height: 10),
              const Text("Loading funny bus pictures",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const SelectableText(
                  "If assets do not load, check www.efeakinci.com/mbus for updates.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey))
            ],
          ),
        ),
      );
    } else {
      if (_hasBeenOnboarded) {
        return NavigationContainer(selectedRoutes);
      } else {
        return OnBoardingScreen(_onBoardingComplete);
      }
    }
  }
}

class NavigationContainer extends StatefulWidget {
  final Set<RouteData> _selectedRoutes;

  const NavigationContainer(this._selectedRoutes, {Key? key}) : super(key: key);

  @override
  _NavigationContainerState createState() => _NavigationContainerState();
}

class _NavigationContainerState extends State<NavigationContainer> {
  int _currentIndex = 0;
  final ChangeNotifier favoritesNotifier = ChangeNotifier();
  late Set<RouteData> selectedRoutes;

  @override
  void initState() {
    super.initState();
    selectedRoutes = widget._selectedRoutes;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void _onItemSelected(int index) {
    setState(() {
      _currentIndex = index;
      if (_currentIndex == 1) {
        favoritesNotifier.notifyListeners();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      body: IndexedStack(
        children: [
          MainMap(selectedRoutes),
          Favorites(favoritesNotifier),
          Settings((Set<RouteData> newRoutes) {
            setState(() {
              selectedRoutes = newRoutes;
            });
          }),
        ],
        index: _currentIndex,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Live Map"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Favorites"),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.doc_plaintext), label: "More")
        ],
        onTap: _onItemSelected,
        currentIndex: _currentIndex,
        selectedItemColor: MICHIGAN_BLUE,
      ),
    ));
  }
}
