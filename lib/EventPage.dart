// Card for bus stop information e.g. arrivals, route name.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:mbus/map/BusStopCard/BusStopCardBody.dart';
import 'package:mbus/map/BusStopCard/BusStopCardHeader.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '/../GlobalConstants.dart';
import '/../constants.dart';
import '/../mbus_utils.dart';
import '/map/Animations.dart';
import '/map/CardScrollBehavior.dart';
import '/map/DataTypes.dart';
import '/map/FavoriteButton.dart';

part 'EventPage.g.dart';

@swidget
Widget eventPage(BuildContext context) {
  /*
  Future<List<IncomingBus>> getBusInfo() async {
    final res = await NetworkUtils.getWithErrorHandling(context, "getStopPredictions/${busStopId}");
    final resJson = jsonDecode(res)['bustime-response'];
    final GlobalConstants globalConstants = GlobalConstants();
    if (resJson == null) {
      return [];
    }
    List<IncomingBus> _busses = [];
    if (resJson['prd'] != null) {
      resJson['prd'].forEach((e) {
        _busses.add(new IncomingBus(e['vid'], e['des'], e['prdctdn'], globalConstants.ROUTE_ID_TO_ROUTE_NAME[e['rt']] ?? "Unknown Route"));
      });
    }
    return _busses;
  }
  */

  return ScrollConfiguration(
    behavior: CardScrollBehavior(),
    child: (
        ListView(
          shrinkWrap: true,
          controller: ModalScrollController.of(context),
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "YOU'RE INVITED", 
                    style: TextStyle(
                      fontWeight: FontWeight.w800, 
                      fontSize: 38, 
                      color: MICHIGAN_BLUE
                    ),
                  ),
                  Text(
                    "to the mBus 2.0 launch event", 
                    style: TextStyle(
                      fontWeight: FontWeight.w500, 
                      fontSize: 20, 
                      color: Colors.black
                    ),
                  ),
                  SizedBox(height: 10,),
                  Image.asset("assets/auditorium.png"),
                  SizedBox(height: 10,),
                  RichText(
                    text: TextSpan(
                      text: 'A ',
                      style: TextStyle(
                        fontWeight: FontWeight.w400, 
                        fontSize: 20, 
                        color: Colors.black
                      ),
                      children: <TextSpan>[
                        TextSpan(text: '30 minute', style: TextStyle(fontWeight: FontWeight.w800)),
                        TextSpan(text: " long event where we will launch the"),
                        TextSpan(text: ' biggest mBus update', style: TextStyle(fontWeight: FontWeight.w800)),
                        TextSpan(text: ' yet, as well as talk briefly about how'),
                        TextSpan(text: ' you', style: TextStyle(fontWeight: FontWeight.w800)),
                        TextSpan(text: " can join the mBus development team"),
                      ],
                    ),
                  ),
                  SizedBox(height: 20,),
                  Text(
                    "Details:", 
                    style: TextStyle(
                      fontWeight: FontWeight.w800, 
                      fontSize: 30, 
                      color: MICHIGAN_BLUE
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'Building: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w800, 
                        fontSize: 18, 
                        color: Colors.black
                      ),
                      children: <TextSpan>[
                        TextSpan(text: 'Central Campus Classroom Building (CCCB)', style: TextStyle(fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  SizedBox(height: 5,),
                  RichText(
                    text: TextSpan(
                      text: 'Room: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w800, 
                        fontSize: 18, 
                        color: Colors.black
                      ),
                      children: <TextSpan>[
                        TextSpan(text: 'Auditorium (Room 1420)', style: TextStyle(fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  SizedBox(height: 5,),
                  RichText(
                    text: TextSpan(
                      text: 'Date and Time: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w800, 
                        fontSize: 18, 
                        color: Colors.black
                      ),
                      children: <TextSpan>[
                        TextSpan(text: 'Thursday May 26th, 7:00pm - 7:30pm', style: TextStyle(fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  SizedBox(height: 25,),
                  GestureDetector(
                    onTap: () {print("yurr");},
                    child: (
                        AnimatedContainer(
                          duration: Duration(milliseconds: 250),
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                              color: MICHIGAN_BLUE,
                              borderRadius: BorderRadius.circular(16)
                          ),
                          child: Center(child: Text("Add to Calendar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18))),)
                    ),
                  )
                ],
              ),
            )],
        )
    ),
  );
}