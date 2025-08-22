import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbus/state/navigation.dart';
import 'package:mbus/map/presentation/animations.dart';
import 'package:mbus/map/domain/data_types.dart';
import 'package:mbus/map/favorite_button.dart';
import 'package:mbus/data/providers.dart';
import 'package:mbus/data/api_errors.dart';
import 'package:mbus/state/assets_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mbus/theme/app_theme.dart';

class SavedFavorite extends Equatable {
  final String stopId;
  final String stopName;

  const SavedFavorite(this.stopId, this.stopName);

  SavedFavorite.fromJson(Map<String, dynamic> json)
      : stopId = json['stopId'],
        stopName = json['stopName'];

  Map<String, String> toJson() => {'stopId': stopId, 'stopName': stopName};

  @override
  List<Object> get props => [stopId, stopName];
}

class FavoritesHeader extends StatelessWidget {
  final DateTime prevLoad;

  const FavoritesHeader(this.prevLoad, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Favorites",
            style: AppTextStyles.pageTitle
                .copyWith(color: Theme.of(context).colorScheme.primary)),
        SizedBox(
          height: 8,
        ),
        Center(
            child: Text(
          "Last updated at ${DateFormat('jms').format(prevLoad).toString()}",
          style: AppTextStyles.caption,
        )),
        SizedBox(
          height: 32,
        )
      ],
    );
  }
}

class Favorites extends ConsumerStatefulWidget {
  const Favorites({super.key});

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends ConsumerState<Favorites> {
  late DateTime lastRefresh;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  Set<SavedFavorite> prevFavorites = {};
  List<FavoriteCardInfo> cardInformation = [];
  bool makingRequest = false;
  ProviderSubscription<int>? _tabSubscription;

  Future<void> _getFavorites({overrideRefreshChecks = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<SavedFavorite> favorites = prefs
            .getStringList("favorites")
            ?.map((e) => SavedFavorite.fromJson(jsonDecode(e)))
            .toSet() ??
        {};
    List<FavoriteCardInfo> receivedInfo = [];
    bool setsEqual = setEquals(prevFavorites, favorites);
    prevFavorites = favorites;
    if (setsEqual &&
        DateTime.now().difference(lastRefresh) < const Duration(minutes: 1) &&
        cardInformation.isNotEmpty &&
        !overrideRefreshChecks) {
      return;
    }
    if (!mounted) return;
    setState(() {
      makingRequest = true;
    });
    final api = ProviderScope.containerOf(context, listen: false)
        .read(apiClientProvider);
    await Future.forEach<SavedFavorite>(favorites, (element) async {
      try {
        final arrivalsResJson = await api.getStopPredictions(element.stopId);
        final List<IncomingBus> busses = [];
        if (arrivalsResJson['prd'] != null) {
          arrivalsResJson['prd'].forEach((e) {
            final routeMeta = ref.read(routeMetaProvider);
            final routeIdToName = routeMeta.routeIdToName;
            final routeName = (routeIdToName[e['rt']] ?? e['rt']).toString();
            busses
                .add(IncomingBus(e['vid'], e['des'], e['prdctdn'], routeName));
          });
        }
        receivedInfo
            .add(FavoriteCardInfo(element.stopId, element.stopName, busses));
      } on RateLimitException {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Too many requests. Please try again later.')));
      } on ApiException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load favorites: ${e.message}')));
      }
    });
    lastRefresh = DateTime.now();
    if (!mounted) return;
    setState(() {
      cardInformation = receivedInfo;
      makingRequest = false;
    });
  }

  void _onRefresh() async {
    await _getFavorites(overrideRefreshChecks: true);
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();
    lastRefresh = DateTime.now();
    _getFavorites();
    _tabSubscription = ref.listenManual<int>(
      currentTabProvider,
      (prev, next) {
        if (next == 1) {
          _getFavorites(overrideRefreshChecks: true);
        }
      },
    );
  }

  @override
  void dispose() {
    _tabSubscription?.close();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: makingRequest
            ? Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
                child: Center(
                    child: ListView(
                  children: [
                    FavoritesHeader(lastRefresh),
                    _FavoriteCardSkeleton()
                  ],
                )),
              )
            : Container(
                child: (cardInformation.isNotEmpty
                    ? SmartRefresher(
                        enablePullDown: true,
                        controller: _refreshController,
                        onRefresh: _onRefresh,
                        header: CustomHeader(
                          builder: (context, status) {
                            if (status == RefreshStatus.canRefresh) {
                              Vibration.hasVibrator().then((hasVibrator) {
                                if (hasVibrator) {
                                  Vibration.vibrate(duration: 100);
                                }
                              });
                            }
                            return Container(
                              child: Center(
                                  child: Text(
                                status == RefreshStatus.canRefresh
                                    ? "Release to Update"
                                    : "Pull Down to Update",
                                style: AppTextStyles.body.copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              )),
                            );
                          },
                        ),
                        child: ListView.builder(
                            addAutomaticKeepAlives: true,
                            padding: const EdgeInsets.symmetric(
                                vertical: 32, horizontal: 8),
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return FavoritesHeader(lastRefresh);
                              } else if (index == 2) {
                                return const Center(
                                    child: Text(
                                  "Things have changed!\nSwipe horizontally to see your new favorites!",
                                  style: AppTextStyles.caption,
                                  textAlign: TextAlign.center,
                                ));
                              } else {
                                return CarouselSlider(
                                  options: CarouselOptions(
                                    height: 800,
                                    viewportFraction: 0.9,
                                    enlargeFactor: 0,
                                    enableInfiniteScroll: false,
                                    enlargeCenterPage: true,
                                    autoPlay: false,
                                    autoPlayInterval: Duration(seconds: 5),
                                    autoPlayAnimationDuration:
                                        Duration(milliseconds: 800),
                                    autoPlayCurve: Curves.fastOutSlowIn,
                                    scrollDirection: Axis.horizontal,
                                  ),
                                  items: cardInformation
                                      .map((card) => FavoriteStopCard(card))
                                      .toList(),
                                );
                              }
                            }),
                      )
                    : Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("You don't seem to have any favorite stops.",
                                style: AppTextStyles.pageTitle.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary)),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                                "To add favorite stops, tap on a bus stop and select \"Add to favorites.\"",
                                style: AppTextStyles.body.copyWith(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold))
                          ],
                        ),
                      )),
              ));
  }
}

class FavoriteCardInfo {
  final String stopId;
  final String stopName;
  final List<IncomingBus> incomingBusses;

  FavoriteCardInfo(this.stopId, this.stopName, this.incomingBusses);
}

class FavoriteStopCard extends StatefulWidget {
  final FavoriteCardInfo cardInfo;

  const FavoriteStopCard(this.cardInfo, {super.key});

  @override
  _FavoriteStopCardState createState() => _FavoriteStopCardState();
}

class _FavoriteStopCardState extends State<FavoriteStopCard>
    with AutomaticKeepAliveClientMixin {
  static const _STOP_NAME_STYLE = AppTextStyles.headerStopName;
  static const _STOP_ID_STYLE = AppTextStyles.routeMeta;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Align(
      alignment: Alignment.topCenter,
      child: (Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        margin: EdgeInsets.fromLTRB(16, 0, 16, 32),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Color(0xFFD9D9D9),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: Offset(4, 4)),
              BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white,
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: Offset(-4, -4))
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.cardInfo.stopName.replaceAll("  ", " "),
              style: _STOP_NAME_STYLE.copyWith(
                  color: Theme.of(context).colorScheme.primary),
            ),
            Text(
              "Stop ${widget.cardInfo.stopId}",
              style: _STOP_ID_STYLE,
            ),
            SizedBox(
              height: 16,
            ),
            Text("Arrivals",
                style: AppTextStyles.arrivalsSection
                    .copyWith(color: Theme.of(context).colorScheme.secondary)),
            Divider(),
            Column(
              children: widget.cardInfo.incomingBusses.isNotEmpty
                  ? widget.cardInfo.incomingBusses
                      .map((e) => _FavoriteStopArrivalsDisplay(e))
                      .toList()
                  : [
                      Text("No service to this stop at this time.",
                          style: AppTextStyles.bodyStrong)
                    ],
            ),
            SizedBox(
              height: 16,
            ),
            BusStopCardFavoriteButton(
              busStopId: widget.cardInfo.stopId,
              busStopName: widget.cardInfo.stopName,
              small: true,
            )
          ],
        ),
      )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _FavoriteStopArrivalsDisplay extends StatelessWidget {
  final IncomingBus bus;

  const _FavoriteStopArrivalsDisplay(this.bus);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor))),
      child: (Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              child: Text(
            bus.route.isNotEmpty ? bus.route : "Unknown Bus",
            style: AppTextStyles.routeMeta,
          )),
          Container(
              child: Text(
            bus.estTimeMin == "DUE"
                ? "Arriving within the next minute."
                : "In about ${bus.estTimeMin} minutes.",
            style: AppTextStyles.bodyStrong,
          )),
          Row(
            children: [
              Flexible(
                  child: Text(
                "Towards ${bus.to} ",
                style: AppTextStyles.routeMeta.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color ??
                        Colors.grey),
              )),
            ],
          )
        ],
      )),
    );
  }
}

class _FavoriteCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      margin: EdgeInsets.fromLTRB(16, 0, 16, 32),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Color(0xFFD9D9D9),
                spreadRadius: 0,
                blurRadius: 10,
                offset: Offset(4, 4)),
            BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white,
                spreadRadius: 0,
                blurRadius: 10,
                offset: Offset(-4, -4))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTextLoadingAnimation(1),
          SizedBox(
            width: 64,
            child: CardTextLoadingAnimation(1),
          ),
          SizedBox(
            height: 16,
          ),
          CardRectangleLoadingAnimation(
            3,
            height: 72.0,
          ),
          SizedBox(
            height: 16,
          ),
          CardRectangleLoadingAnimation(
            1,
            height: 56.0,
          )
        ],
      ),
    );
  }
}
