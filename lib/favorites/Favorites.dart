import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:mbus/interfaces/BootlegNotifier.dart';
import 'package:mbus/GlobalConstants.dart';
import 'package:mbus/constants.dart';
import 'package:mbus/map/Animations.dart';
import 'package:mbus/map/DataTypes.dart';
import 'package:mbus/map/FavoriteButton.dart';
import 'package:mbus/mbus_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carousel_slider/carousel_slider.dart';


import '../map/MainMap.dart';

class SavedFavorite extends Equatable{
  final String stopId;
  final String stopName;

  SavedFavorite(this.stopId, this.stopName);

  SavedFavorite.fromJson(Map<String, dynamic> json) :
      stopId = json['stopId'],
      stopName = json['stopName'];

  Map<String, String> toJson() => {
    'stopId': stopId,
    'stopName': stopName
  };

  List<Object> get props => [stopId, stopName];

}

class FavoritesHeader extends StatelessWidget {
  final DateTime prevLoad;

  FavoritesHeader(this.prevLoad);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Favorites", style: TextStyle(color: MICHIGAN_BLUE, fontSize: 48, fontWeight: FontWeight.w900),),
        SizedBox(height: 8,),
        Center(child: Text("Last updated at ${DateFormat('jms').format(prevLoad).toString()}", style: TextStyle(color: Colors.grey),)),
        SizedBox(height: 32,)
      ],
    );
  }
}

class Favorites extends StatefulWidget {
  BootlegNotifier onSwitchedTo;
  Favorites(this.onSwitchedTo);

  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  late DateTime lastRefresh;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  Set<SavedFavorite> prevFavorites = {};
  List<FavoriteCardInfo> cardInformation = [];
  bool makingRequest = false;
  GlobalConstants globalConstants = GlobalConstants();


  Future<void> _getFavorites({overrideRefreshChecks: false}) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<SavedFavorite> favorites = prefs.getStringList("favorites")?.map((e) => SavedFavorite.fromJson(jsonDecode(e))).toSet() ?? {};
    List<FavoriteCardInfo> receivedInfo = [];
    bool setsEqual = setEquals(prevFavorites, favorites);
    prevFavorites = favorites;
    if (setsEqual && DateTime.now().difference(lastRefresh) < Duration(minutes: 1) && cardInformation.length > 0 && !overrideRefreshChecks) {
      return;
    }
    setState(() {
      makingRequest = true;
    });
    await Future.forEach<SavedFavorite>(favorites, (element) async {
      final arrivalsRes = await NetworkUtils.getWithErrorHandling(context, "getStopPredictions/${element.stopId}");
      final arrivalsResJson = jsonDecode(arrivalsRes)['bustime-response'];
      final List<IncomingBus> busses = [];
      if (arrivalsResJson['prd'] != null) {
        arrivalsResJson['prd'].forEach((e) {
          busses.add(new IncomingBus(e['vid'], e['des'], e['prdctdn'], GlobalConstants().ROUTE_ID_TO_ROUTE_NAME[e['rt']] ?? "Unknown Route"));
        });
      }
      receivedInfo.add(FavoriteCardInfo(element.stopId, element.stopName, busses));
    });
    lastRefresh = DateTime.now();
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
    lastRefresh = DateTime.now();
    _getFavorites();
    widget.onSwitchedTo.onNotify = () {
        _getFavorites();
    };
  }

  @override
  Widget build(BuildContext context) {
    return
    SafeArea(
      child: makingRequest ?
          Container(
            padding: EdgeInsets.symmetric(vertical: 32, horizontal: 8),
            child: Center(
              child: ListView(
                children: [
                  FavoritesHeader(lastRefresh),
                  _FavoriteCardSkeleton()
                ],
              )
            ),
          )
          :
          Container(
          child: (
            cardInformation.length > 0 ?
                SmartRefresher(
                  enablePullDown: true,
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  header: CustomHeader(
                    builder: (context, status) {
                      if (status == RefreshStatus.canRefresh) {
                        Vibrate.canVibrate.then((value) {
                          if (value) {
                            Vibrate.feedback(FeedbackType.impact);
                          }
                        });
                      }
                      return Container(
                        child: Center(
                            child: Text(status == RefreshStatus.canRefresh ? "Release to Update" : "Pull Down to Update",
                            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 18),)
                        ),
                      );
                    },
                  ),
                  child: ListView.builder(
                    addAutomaticKeepAlives: true,
                    padding: EdgeInsets.symmetric(vertical: 32, horizontal: 8),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                      if (index == 0) {
                        return FavoritesHeader(lastRefresh);
                      }
                      else if (index == 2) {
                        return Center(child: Text("Things have changed!\nSwipe horizontally to see your new favorites!", style: TextStyle(color: Colors.grey), textAlign: TextAlign.center,));
                      }
                      else {
                          return Container(
                            child: CarouselSlider(
                              options: CarouselOptions(
                                // make height max height of each child
                                height: 800,
                                viewportFraction: 0.9,
                                enlargeFactor: 0,
                                enableInfiniteScroll: false,
                                enlargeCenterPage: true,
                                autoPlay: false,
                                autoPlayInterval: Duration(seconds: 5),
                                autoPlayAnimationDuration: Duration(milliseconds: 800),
                                autoPlayCurve: Curves.fastOutSlowIn,
                                scrollDirection: Axis.horizontal,
                              ),
                              items: cardInformation.map((card) => FavoriteStopCard(card)).toList(),
                            )
                          );
                      }
                      }),
                )
                :
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("You don't seem to have any favorite stops.", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 36, color: MICHIGAN_BLUE)),
                      SizedBox(height: 8,),
                      Text("To add favorite stops, tap on a bus stop and select \"Add to favorites.\"", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey))
                    ],
                  ),
                )
          ),
        )
    );
  }
}

class FavoriteCardInfo {
  final String stopId;
  final String stopName;
  final List<IncomingBus> incomingBusses;

  FavoriteCardInfo(this.stopId, this.stopName, this.incomingBusses);
}

class FavoriteStopCard extends StatefulWidget {
  FavoriteCardInfo cardInfo;

  FavoriteStopCard(this.cardInfo);


  _FavoriteStopCardState createState() => _FavoriteStopCardState();

}


class _FavoriteStopCardState extends State<FavoriteStopCard> with AutomaticKeepAliveClientMixin  {
  static const _STOP_NAME_STYLE = TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: MICHIGAN_BLUE);
  static const _STOP_ID_STYLE = TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.grey);



  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: (
        Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          margin: EdgeInsets.fromLTRB(16, 0, 16, 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFD9D9D9),
                spreadRadius: 0,
                blurRadius: 10,
                offset: Offset(4, 4)
              ),
              BoxShadow(
                color: Colors.white,
                spreadRadius: 0,
                blurRadius: 10,
                offset: Offset(-4, -4)
              )
            ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.cardInfo.stopName.replaceAll("  ", " "), style: _STOP_NAME_STYLE,),
              Text("Stop ${widget.cardInfo.stopId}", style: _STOP_ID_STYLE,),
              SizedBox(height: 16,),
              Text("Arrivals", style: TextStyle(color: MICHIGAN_MAIZE, fontSize: 24, fontWeight: FontWeight.w800),),
              Divider(),
              Column(
                children: widget.cardInfo.incomingBusses.length > 0 ? widget.cardInfo.incomingBusses.map((e) => _FavoriteStopArrivalsDisplay(e)).toList() : [Text("No service to this stop at this time.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)],
              ),
              SizedBox(height: 16,),
              BusStopCardFavoriteButton(widget.cardInfo.stopId, widget.cardInfo.stopName, small: true,)
            ],
          ),
        )
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _FavoriteStopArrivalsDisplay extends StatelessWidget {

  final IncomingBus bus;

  _FavoriteStopArrivalsDisplay(this.bus);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))
      ),
      child: (
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Container(child: Text(bus.route.length > 0 ? "${bus.route}" : "Unknown Bus", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14),)),
              Container(child: Text(bus.estTimeMin == "DUE" ? "Arriving within the next minute." : "In about ${bus.estTimeMin} minutes.", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)),
              Row(
                children: [
                  Flexible(child: Text("Towards ${bus.to} ", style: TextStyle(fontWeight: FontWeight.bold, color: MICHIGAN_BLUE),)),
                ],
              )
            ],
          )
      ),
    );
  }
}

class _FavoriteCardSkeleton extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return
      Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        margin: EdgeInsets.fromLTRB(16, 0, 16, 32),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Color(0xFFD9D9D9),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: Offset(4, 4)
              ),
              BoxShadow(
                  color: Colors.white,
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: Offset(-4, -4)
              )
            ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardTextLoadingAnimation(1),
            Container(
              width: 64,
              child: CardTextLoadingAnimation(1),
            ),
            SizedBox(height: 16,),
            CardRectangleLoadingAnimation(3, height: 72.0,),
            SizedBox(height: 16,),
            CardRectangleLoadingAnimation(1, height: 56.0,)
          ],
        ),
      );
  }
}