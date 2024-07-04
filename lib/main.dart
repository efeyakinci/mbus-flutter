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
import 'package:mbus/interfaces/BootlegNotifier.dart';
import 'package:mbus/favorites/Favorites.dart';
import 'package:mbus/GlobalConstants.dart';
import 'package:mbus/map/MainMap.dart';
import 'package:mbus/onboarding/Onboarding.dart';
import 'package:bitmap/bitmap.dart';
import 'package:mbus/settings/Settings.dart';
import 'package:mbus/constants.dart';
import 'package:mbus/mbus_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';



void main() {

  // start logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('[${record.level.name}] ${record.time}: ${record.message}');
  });

  runApp(MyApp());
}

WidgetBuilder getStartupMessageDialog(dynamic res) {
  final title = res['title'] ?? "Update Notes!";
  final message = res['message'] ?? "No message found";
  final id = res['id'] ?? "-1";
  final actions = [
    DialogAction("Dismiss", () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("dismissedMessageId", id);
    })
  ];

  return getMessageDialog(DialogData(title, message, actions));
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Phoenix(
      child: MaterialApp(
        title: 'MBus',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
          )
        ),
        home: DefaultTabController(
          length: 3, 
          child: OnBoardingSwitcher()
        ),
      )
    );
  }
}

class OnBoardingSwitcher extends StatefulWidget {
  createState() => _OnBoardingSwitcherState();
}

// "WidgetsBindingObserver" allows the app to reload when it is out of and back in focus
class _OnBoardingSwitcherState extends State<OnBoardingSwitcher> with WidgetsBindingObserver {
  // variable declarations
  bool _hasOnboardingStatusBeenChecked = false;
  bool _hasBeenOnboarded = false;
  bool _hasCheckedNewAssets = false;
  bool _currentlyCheckingAssets = false;
  bool _currentlyMessageShowing = false;
  bool _isLoaded = false;
  Set<RouteData> selectedRoutes = Set<RouteData>();
  GlobalConstants globalConstants = GlobalConstants();
  final log = new Logger("main.dart");

  // determines whether onboarding has occurred
  Future<void> _checkIfOnboarded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // update the state and determine whether onboarding has occurred
    setState(() {
      _hasBeenOnboarded = prefs.getBool("onboarded") ?? false;
      _hasOnboardingStatusBeenChecked = true;
    });

    if (_hasBeenOnboarded) {
      _checkMessages();
    }
  }

  // this runs after the onboarding sequence and mainly just requests location permission
  Future<void> _onBoardingComplete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    LocationPermission permission;

    // if location services exist on the device
    if (await Geolocator.isLocationServiceEnabled()) {
      permission = await Geolocator.checkPermission();

      // if the permission is denied
      if (permission == LocationPermission.denied) {
        // request permission (note: will only ask once)
        //                     > TODO: make it ask every time you hit the button
        permission = await Geolocator.requestPermission();
      }
    }
    await prefs.setBool("onboarded", true);
    setState(() {
      _hasBeenOnboarded = true;
    });
  }

  Future<void> _checkMessages() async {
    if (_currentlyMessageShowing) {
      return;
    }
    _currentlyMessageShowing = true;
    try {
      final res = jsonDecode(await NetworkUtils.getWithErrorHandling(
          context, "get-startup-messages"));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String dismissedMessageId =
          prefs.getString("dismissedMessageId") ?? "None";
      final String messageId = res['id'] ?? "-1";

      if (double.parse(res['buildVersion']) > GlobalConstants.BUILD_VERSION &&
          messageId != dismissedMessageId) {
        await showDialog(
            context: context, builder: getStartupMessageDialog(res));
        _currentlyMessageShowing = false;
      }

      log.info("Got startup messages");
    } catch (e) {
      _currentlyMessageShowing = false;
      NetworkUtils.createNetworkError();
      return;
    }
  }

  Future<void> _checkUpdateNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool updateNotesDismissed = prefs.getBool("updateNotesDismissed") ?? false;

    if (updateNotesDismissed) {
      return;
    }

    Map<String, dynamic> notes = jsonDecode(
        await NetworkUtils.getWithErrorHandling(context, 'getUpdateNotes'));

    log.info("Got update notes");

    if (notes['version'] != GlobalConstants.BUILD_VERSION.toString()) {
      return;
    }

    showDialog(
        context: context,
        builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Container(
                // set the minimum height of the dialog to 200
                constraints: BoxConstraints(maxHeight: 500.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                          child: Text(
                        "Update Notes!",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                      SizedBox(
                        height: 20,
                      ),
                      // Text container that scrolls if the text is too long and shrinks if the text is short
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SingleChildScrollView(
                            child: Text(
                              notes["message"] ?? "No message found",
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            child: Text("Dismiss"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ));
  }

  Future<void> getSelectedRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedSelections = prefs.getString('selectedRoutes');

    if (storedSelections == null || storedSelections.isEmpty) {
      return;
    }

    setState(() {
      jsonDecode(storedSelections!).forEach((e) {
        selectedRoutes.add(new RouteData(e['routeId'], e['routeName']));
      });
    });

    log.info("Got selected routes");
  }

  Future<void> _checkNewAssets() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int curInfoVersion = prefs.getInt('curInfoVersion') ?? -1;
    DateTime prevCheck = DateTime.parse(
        prefs.getString("lastCheckedAssets") ?? "1969-07-20 20:18:04Z");
    int serverInfoVersion = -1;

    if (_currentlyCheckingAssets) {
      return;
    }

    _currentlyCheckingAssets = true;
    try {
      final res = jsonDecode(await NetworkUtils.getWithErrorHandling(
          context, "getRouteInfoVersion"));

      serverInfoVersion = res['version'] ?? 0;
      final Map<String, dynamic> storedInfo =
          jsonDecode(prefs.getString("routeInformation") ?? "{}");

      if (curInfoVersion < serverInfoVersion ||
          storedInfo.isEmpty ||
          DateTime.now().difference(prevCheck).inDays > 5) {
        bool isColorBlindMode = prefs.getBool("isColorBlindEnabled") ?? false;
        final res = jsonDecode(await NetworkUtils.getWithErrorHandling(context,
            'getRouteInformation?colorblind=${isColorBlindMode ? "Y" : "N"}'));

        if (res['metadata'] != null &&
            res['metadata']?['version'] != null &&
            res['metadata']['version'] is int) {
          await DefaultCacheManager().emptyCache();
          await prefs.setString('lastCheckedAssets', DateTime.now().toString());
          await prefs.setInt('curInfoVersion', res['metadata']['version']);
          await prefs.setString('routeInformation', jsonEncode(res));
          setState(() {
            globalConstants.updateRouteInformation(res);
            _hasCheckedNewAssets = true;
          });
        }
      } else {
        setState(() {
          globalConstants.updateRouteInformation(storedInfo);
          _hasCheckedNewAssets = true;
        });
        log.info("Got new assets");
      }
    } catch (e, stacktrace) {
      setState(() {
        _hasCheckedNewAssets = true;
      });
      log.severe("Error checking for new assets", e, stacktrace);
    }
    _currentlyCheckingAssets = false;
  }

  // Loads and resizes bus images given a path to the image
  Future<BitmapDescriptor> getBusBitmap(String pathToImage,
      {width: 124}) async {
    final image_bmap = await Bitmap.fromProvider(AssetImage(pathToImage));
    final image = BitmapDescriptor.fromBytes(
        image_bmap.apply(BitmapResize.to(width: width)).buildHeaded());
    return image;
  }

  Future<void> _loadBusImages() async {
    final BUS_WIDTH = (MediaQuery.of(context).devicePixelRatio * 40).toInt();
    final STOP_WIDTH = (MediaQuery.of(context).devicePixelRatio * 22).toInt();

    final markerImages = GlobalConstants().marker_images;
    // Load bus stop image
    markerImages["BUS_STOP"] =
        await getBusBitmap("assets/bus_stop.png", width: STOP_WIDTH);

    final prefs = await SharedPreferences.getInstance();
    final isColorblind = prefs.getBool("isColorBlindEnabled") ?? false;

    for (String routeIdentifier
        in GlobalConstants().ROUTE_ID_TO_ROUTE_NAME.keys) {
      late ImageProvider _provider;

      // Load bus image (tries lookup in cache) or use default if it fails
      _provider = await CachedNetworkImageProvider(
          "$BACKEND_URL/getVehicleImage/${routeIdentifier}?colorblind=${isColorblind ? "Y" : "N"}",
          errorListener: (final error) {
            log.warning("Error loading bus image for $routeIdentifier: $error | Request sent to: $BACKEND_URL/getVehicleImage/${routeIdentifier}?colorblind=${isColorblind ? "Y" : "N"}");
            _provider = AssetImage('assets/bus_blue.png');
      });

      log.info("Loading bus image for $routeIdentifier");

      // Resize bus image and add to map
      markerImages[routeIdentifier] = await BitmapDescriptor.fromBytes(
          (await Bitmap.fromProvider(_provider))
              .apply(BitmapResize.to(width: BUS_WIDTH))
              .buildHeaded());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkNewAssets();
      _checkMessages();
    }
  }

  void loadData() async {
    await Future.wait([
      getSelectedRoutes(),
      _checkNewAssets(),
      _checkIfOnboarded(),
      _checkUpdateNotes(),
    ]);
    // depends on _checkNewAssets
    await _loadBusImages();
    setState(() {
      _isLoaded = true;
    });
  }

  // initialization of app
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
    // if we haven't checked for onboarding or the data isn't loaded, put up the loading screen
    if (!_hasOnboardingStatusBeenChecked || !_isLoaded) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage('assets/mbus_logo.png'),
                width: MediaQuery.of(context).size.width * 0.75,
              ),
              SizedBox(height: 60),
              CircularProgressIndicator(color: MICHIGAN_MAIZE),
              SizedBox(height: 10),
              Text("Loading funny bus pictures",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              SelectableText(
                "If assets do not load, check www.efeakinci.com/mbus for updates.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey))
            ],
          ),
        ),
      );
    } else if (_hasBeenOnboarded) {
      return NavigationContainer(selectedRoutes);
    } else {
      // run onboarding sequence, and _onBoardingComplete after
      return OnBoardingScreen(_onBoardingComplete);
    }
  }
}

class NavigationContainer extends StatefulWidget {
  Set<RouteData> _selectedRoutes;

  NavigationContainer(this._selectedRoutes);

  @override
  _NavigationContainerState createState() => _NavigationContainerState();
}

class _NavigationContainerState extends State<NavigationContainer> {
  int _currentIndex = 0;
  BootlegNotifier favoritesNotifier = BootlegNotifier();
  Set<RouteData> selectedRoutes = {};

  void _onItemSelected(int index) {
    setState(() {
      _currentIndex = index;
      if (_currentIndex == 1) {
        favoritesNotifier.notify();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  // main home screen 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        children: [
          MainMap(widget._selectedRoutes.toSet()),
          Favorites(favoritesNotifier),
          Settings((Set<RouteData> newRoutes) {
            setState(() {
              widget._selectedRoutes = newRoutes;
            });
          }),
        ],
        index: _currentIndex,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Live Map"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.doc_plaintext), label: "More")
        ],
        onTap: _onItemSelected,
        currentIndex: _currentIndex,
        selectedItemColor: MICHIGAN_BLUE,
      ),
    );
  }
}
