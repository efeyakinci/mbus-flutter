// Weird wrapper class for the favorite button because calling setState() in BusStopCard causes unnecessary rebuilds with FutureBuilder, and still causes rebuild artifacts when a Memoizer is used.
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:mbus/favorites/Favorites.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../constants.dart';
import 'Animations.dart';

part 'FavoriteButton.g.dart';

@hwidget
Widget busStopCardFavoriteButton(BuildContext context, String busStopId, String busStopName, {bool small = false}) {
  final isFavorited = useState(false);
  final isSettingFavorited = useState(false);
  final hasFetchedFavorites = useState(false);

  bool doesFavoriesContain(List<SavedFavorite> favorites, String busStopId) {
    return favorites.any((element) => element.stopId == busStopId);
  }

  Future getFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoritesStr = prefs.getStringList("favorites");
    List<SavedFavorite> favorites = favoritesStr?.map((e) => SavedFavorite.fromJson(jsonDecode(e))).toList() ?? [];

    isFavorited.value = doesFavoriesContain(favorites, busStopId);
    hasFetchedFavorites.value = true;

    return favorites;
  }

  void showTooManyFavoritesDialog() {
    showDialog(context: context, builder: (context) {
      return CupertinoAlertDialog(
        title: Text("Woah There!"),
        content: Text("There is a 5 favorite limit on adding favorites due to performance reasons. Try removing a favorite before adding this one."),
        actions: [
          CupertinoButton(child: Text("Ok"), onPressed: () {
            Navigator.of(context).pop();
          })
        ],
      );
    },
    barrierDismissible: true);
  }

  void setFavorited(bool favorited) async {
    if (isSettingFavorited.value) {
      return;
    }
    isSettingFavorited.value = true;

    final favorites = await getFavorites();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (favorited) {
      if (favorites.length >= 5) {
        showTooManyFavoritesDialog();
        isSettingFavorited.value = false;
        return;
      }
      favorites.add(SavedFavorite(busStopId, busStopName));
    } else {
      favorites.removeWhere((element) => element.stopId == busStopId);
    }
    prefs.setStringList("favorites", favorites.map<String>((e) => jsonEncode(e)).toList());

    isFavorited.value = favorited;
    isSettingFavorited.value = false;
  }

  useEffect(() {
    getFavorites();
    return;
  }, []);

  if (!hasFetchedFavorites.value) {
    return CardRectangleLoadingAnimation(1);
  }

  return GestureDetector(
      onTap: () {setFavorited(!isFavorited.value);},
      child: (
          AnimatedContainer(
            duration: Duration(milliseconds: 250),
            padding: !small ? EdgeInsets.symmetric(vertical: 16, horizontal: 24) : EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
                color: isFavorited.value ? MICHIGAN_MAIZE : MICHIGAN_BLUE,
                borderRadius: BorderRadius.circular(16)
            ),
            child: Center(child: Text(isFavorited.value ? "Remove from Favorites" : "Add to Favorites", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18))),)
      ),
    );
}