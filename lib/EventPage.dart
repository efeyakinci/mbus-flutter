// The page that opens when the event button is tapped
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
import 'package:url_launcher/url_launcher_string.dart';

import '/../GlobalConstants.dart';
import '/../constants.dart';
import '/../mbus_utils.dart';
import '/map/Animations.dart';
import '/map/CardScrollBehavior.dart';
import '/map/DataTypes.dart';
import '/map/FavoriteButton.dart';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';

part 'EventPage.g.dart';

@swidget
Widget eventPage(BuildContext context) {

  Future<Widget> loadPageFromServer() async {

    final res = await NetworkUtils.getWithErrorHandling(context, "getEventMessage");
    final Map<String, dynamic> json = jsonDecode(res);
    final List<dynamic>? sections = json['sections'] as List<dynamic>?;

    if (sections == null || sections.isEmpty) {
      return Text("ERROR: server returned blank data");
    }

    final textParts = sections[0]['textParts'] as List<dynamic>;
    final details = sections[1]['textParts'] as List<dynamic>;
    final titles = sections[2]['textParts'] as List<dynamic>;

    // A TextSpan builder which turns the JSON data into a paragraph 
    // of text with some parts being bolded while others are normal. 
    List<TextSpan> spans = textParts.map((part) {
      final text = part['text'] as String;
      final isBold = part['bold'] as bool;
      return TextSpan(
        text: text,
        style: TextStyle(fontWeight: isBold ? FontWeight.w800 : FontWeight.w400),
      );
    }).toList();

    // column of widgets for the page - most loaded from server response
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [

        // Page Title
        Text(
          titles[0]["title"], 
          style: TextStyle(
            fontWeight: FontWeight.w800, 
            fontSize: 38, 
            color: MICHIGAN_BLUE
          ),
        ),

        // Page Subtitle
        Text(
          titles[1]["subtitle"], 
          style: TextStyle(
            fontWeight: FontWeight.w500, 
            fontSize: 20, 
            color: Colors.black
          ),
        ),

        SizedBox(height: 10,),
        
        // Image builder (tries to load image, on fail uses a fallback one)
        FutureBuilder<Uint8List?>(
          future: NetworkUtils.getImageWithErrorHandling(context,"getEventImage"),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || snapshot.data == null) {
              return Image.asset("assets/mbusFallbackImage.png");
            } else {
              return Image.memory(
                snapshot.data!,
                width: double.infinity,
                fit: BoxFit.cover,
              );
            }
          },
        ),

        SizedBox(height: 10,),    

        // Paragraph. Uses TextSpan builder from earlier   
        RichText(
          text: TextSpan(
            children: spans,
            style: TextStyle(
              fontWeight: FontWeight.w400, 
              fontSize: 20, 
              color: Colors.black
            ),
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

        // Sections of details. Descprition followed by text.
        RichText(
          text: TextSpan(
            text: details.first['detail'],
            style: TextStyle(
              fontWeight: FontWeight.w800, 
              fontSize: 18, 
              color: Colors.black
            ),
            children: <TextSpan>[
              TextSpan(text: details.first['text'], style: TextStyle(fontWeight: FontWeight.w400)),
            ],
          ),
        ),
        SizedBox(height: 5,),
        RichText(
          text: TextSpan(
            text: details[1]['detail'],
            style: TextStyle(
              fontWeight: FontWeight.w800, 
              fontSize: 18, 
              color: Colors.black
            ),
            children: <TextSpan>[
              TextSpan(text: details[1]['text'], style: TextStyle(fontWeight: FontWeight.w400)),
            ],
          ),
        ),
        SizedBox(height: 5,),
        RichText(
          text: TextSpan(
            text: details[2]['detail'],
            style: TextStyle(
              fontWeight: FontWeight.w800, 
              fontSize: 18, 
              color: Colors.black
            ),
            children: <TextSpan>[
              TextSpan(text: details[2]['text'], style: TextStyle(fontWeight: FontWeight.w400)),
            ],
          ),
        ),

        SizedBox(height: 25,),

        // "Add to calendar" button (opens a link, most likely to a calendar invite)
        GestureDetector(
          onTap: () {
            void _launchURL() async {
              final res = await NetworkUtils.getWithErrorHandling(context, "getEventButtonInformation");
              final Map<String, dynamic> json = jsonDecode(res);
              final List<dynamic>? sections = json['sections'] as List<dynamic>?;

              if (sections == null || sections.isEmpty) {
                return;
              }

              final url = sections[1]['link'];
              
              try {
                await launchUrlString(url, mode: LaunchMode.externalApplication);
              } catch(e) {
                return;
              }
            }

            _launchURL();
          },
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
    );
  }

  return ScrollConfiguration(
    behavior: CardScrollBehavior(),
    child: (
        ListView(
          shrinkWrap: true,
          controller: ModalScrollController.of(context),
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: FutureBuilder<Widget>(
                future: loadPageFromServer(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      child: Center(
                        child: CircularProgressIndicator()
                      ),
                      height: 50.0,
                      width: 50.0
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return snapshot.data ?? Text('No text loaded');
                  }
                },
              ),
            )
          ],
        )
    ),
  );
}