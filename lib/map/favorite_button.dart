// Weird wrapper class for the favorite button because calling setState() in BusStopCard causes unnecessary rebuilds with FutureBuilder, and still causes rebuild artifacts when a Memoizer is used.
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbus/data/providers.dart';
import 'package:mbus/favorites/presentation/favorites.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'presentation/animations.dart';
import 'package:mbus/theme/app_theme.dart';

class BusStopCardFavoriteButton extends StatefulWidget {
  final String busStopId;
  final String busStopName;
  final bool small;

  const BusStopCardFavoriteButton({
    super.key,
    required this.busStopId,
    required this.busStopName,
    this.small = false,
  });

  @override
  _BusStopCardFavoriteButtonState createState() =>
      _BusStopCardFavoriteButtonState();
}

class _BusStopCardFavoriteButtonState extends State<BusStopCardFavoriteButton> {
  bool isFavorited = false;
  bool isSettingFavorited = false;
  bool hasFetchedFavorites = false;

  @override
  void initState() {
    super.initState();
    getFavorites();
  }

  bool doesFavoritesContain(List<SavedFavorite> favorites, String busStopId) {
    return favorites.any((element) => element.stopId == busStopId);
  }

  Future<List<SavedFavorite>> getFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoritesStr = prefs.getStringList("favorites");
    List<SavedFavorite> favorites = favoritesStr
            ?.map((e) => SavedFavorite.fromJson(jsonDecode(e)))
            .toList() ??
        [];

    if (mounted) {
      setState(() {
        isFavorited = doesFavoritesContain(favorites, widget.busStopId);
        hasFetchedFavorites = true;
      });
    }

    return favorites;
  }

  void showTooManyFavoritesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("Woah There!"),
          content: Text(
              "There is a 5 favorite limit on adding favorites due to performance reasons. Try removing a favorite before adding this one."),
          actions: [
            CupertinoButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
      barrierDismissible: true,
    );
  }

  void setFavorited(bool favorited) async {
    if (isSettingFavorited) {
      return;
    }
    setState(() {
      isSettingFavorited = true;
    });

    final favorites = await getFavorites();
    if (favorited) {
      if (favorites.length >= 5) {
        showTooManyFavoritesDialog();
        if (mounted) {
          setState(() {
            isSettingFavorited = false;
          });
        }
        return;
      }
      await ProviderScope.containerOf(context, listen: false)
          .read(favoriteStopsProvider.notifier)
          .addFavorite(stopId: widget.busStopId, stopName: widget.busStopName);
    } else {
      await ProviderScope.containerOf(context, listen: false)
          .read(favoriteStopsProvider.notifier)
          .removeFavorite(widget.busStopId);
    }

    if (mounted) {
      setState(() {
        isFavorited = favorited;
        isSettingFavorited = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!hasFetchedFavorites) {
      return CardRectangleLoadingAnimation(1);
    }

    return GestureDetector(
      onTap: () {
        setFavorited(!isFavorited);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 250),
        padding: !widget.small
            ? EdgeInsets.symmetric(vertical: 16, horizontal: 24)
            : EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
            color: isFavorited
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16)),
        child: Center(
            child: Text(
                isFavorited ? "Remove from Favorites" : "Add to Favorites",
                style: AppTextStyles.buttonPrimary.copyWith(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onPrimary))),
      ),
    );
  }
}
