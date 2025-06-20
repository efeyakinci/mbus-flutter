import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:mbus/about/about_screen.dart';
import 'package:mbus/constants.dart';

const TITLE_STYLE = TextStyle(
    color: MICHIGAN_BLUE, fontSize: 42, fontWeight: FontWeight.w900);
const BODY_STYLE = TextStyle(
    color: Color(0xFF555555), fontSize: 16, fontWeight: FontWeight.normal);

class RouteButton extends StatelessWidget {
  const RouteButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      height: 56,
      width: 56,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(64),
          boxShadow: const [
            BoxShadow(
                color: Color(0xAA222234),
                offset: Offset(1, 1),
                spreadRadius: 1.0,
                blurRadius: 4.0)
          ],
          color: MICHIGAN_BLUE),
      child: const Center(
        child: Icon(
          Icons.alt_route_rounded,
          color: MICHIGAN_MAIZE,
          size: 24,
        ),
      ),
    ));
  }
}

class OnboardingTermsAndConditions extends StatefulWidget {
  final VoidCallback allowNext;

  const OnboardingTermsAndConditions({Key? key, required this.allowNext})
      : super(key: key);

  @override
  _OnboardingTermsAndConditionsState createState() =>
      _OnboardingTermsAndConditionsState();
}

class _OnboardingTermsAndConditionsState
    extends State<OnboardingTermsAndConditions> {
  bool isRead = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Please read the privacy policy and the terms and conditions. When you are done, just come back to this page.",
          style: BODY_STYLE,
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 24,
        ),
        TextButton(
            onPressed: () {
              widget.allowNext();
              setState(() {
                isRead = true;
              });
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const TermsScreen()));
            },
            child: const Text(
              "Terms and Conditions",
              style: TextStyle(fontSize: 18),
            )),
        const SizedBox(
          height: 24,
        ),
        Text(
          isRead
              ? "By pressing next, you acknowledge that you have read and agreed to the terms and conditions and the privacy policy."
              : "Please read the terms and conditions to continue.",
          style: BODY_STYLE.apply(fontWeightDelta: 3),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class OnBoardingScreen extends StatefulWidget {
  final VoidCallback onDone;

  const OnBoardingScreen(this.onDone, {Key? key}) : super(key: key);

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  bool allowNext = true;

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          image: SafeArea(
              child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SvgPicture.asset("assets/welcome_picture.svg"),
            ),
          )),
          title: "Welcome to MBus!",
          decoration:
              const PageDecoration(titleTextStyle: TITLE_STYLE, bodyTextStyle: BODY_STYLE),
          body:
              "Hey, thanks for downloading MBus!\n\nThis (unofficial) app is designed to help you navigate the U-M bus system. To get started, just tap \"Next\" below!",
        ),
        PageViewModel(
          image: SafeArea(
              child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SvgPicture.asset("assets/routes_picture.svg"),
            ),
          )),
          decoration:
              const PageDecoration(titleTextStyle: TITLE_STYLE, bodyTextStyle: BODY_STYLE),
          title: "Routes",
          bodyWidget: RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
                text: "Press the route button \n",
                style: BODY_STYLE,
                children: [
                  WidgetSpan(child: RouteButton()),
                  TextSpan(
                      text:
                          "\non the bottom right of the map to select what routes you'd like to view on the screen! You can simply swipe down on the route card to remove it from the screen.\n\nTip: Pressing and holding on a route allows you to only select that route!")
                ]),
          ),
        ),
        PageViewModel(
            image: SafeArea(
                child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SvgPicture.asset("assets/bus_stop_picture.svg"),
              ),
            )),
            title: "Bus Stops",
            decoration: const PageDecoration(
              titleTextStyle: TITLE_STYLE,
            ),
            bodyWidget: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                  text: "You can tap on ",
                  style: BODY_STYLE,
                  children: [
                    WidgetSpan(
                        child: Image(
                      image: AssetImage("assets/bus_stop.png"),
                      height: 24.0,
                    )),
                    TextSpan(
                        text:
                            " icons in order to view upcoming stops at a bus station or to add the bus station to your favorites, after which you will be able to quickly view incoming buses to the stop inside the \"Favorites\" screen.\n\nTo return to the main map from any information card, just swipe down on the card!")
                  ]),
            )),
        PageViewModel(
            image: SafeArea(
                child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SvgPicture.asset("assets/navigation_picture.svg"),
              ),
            )),
            title: "Buses",
            decoration:
                const PageDecoration(titleTextStyle: TITLE_STYLE, bodyTextStyle: BODY_STYLE),
            bodyWidget: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: "Icons that look like \n",
                  style: BODY_STYLE,
                  children: [
                    WidgetSpan(
                        child: Transform.rotate(
                      angle: pi / 2,
                      child: const Image(
                        image: AssetImage("assets/bus_blue.png"),
                        width: 64.0,
                      ),
                    )),
                    const TextSpan(
                        text:
                            "\nrepresent live positions of buses. Their colors match the color of their routes. To get more information about a bus, such as its route and next stops, you can tap its bus icon.")
                  ]),
            )),
        PageViewModel(
            image: SafeArea(
                child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SvgPicture.asset("assets/legalities_picture.svg"),
              ),
            )),
            decoration:
                const PageDecoration(titleTextStyle: TITLE_STYLE, bodyTextStyle: BODY_STYLE),
            title: "Legalities",
            bodyWidget: OnboardingTermsAndConditions(allowNext: () {
              setState(() {
                allowNext = true;
              });
            })),
        PageViewModel(
            image: SafeArea(
                child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SvgPicture.asset("assets/current_location_picture.svg"),
              ),
            )),
            decoration:
                const PageDecoration(titleTextStyle: TITLE_STYLE, bodyTextStyle: BODY_STYLE),
            title: "Almost there...",
            body:
                "When you tap done, you will be prompted for access to your location. Please provide the app access to your precise location to see your current location on the map.\n\nRemember, if you experience any issues, you can contact me through the \"Send Feedback\" option in the \"More\" tab.\n\nThat's all! I hope that you enjoy using M-Bus!"),
      ],
      freeze: !allowNext,
      showNextButton: allowNext,
      next: const Text("Next"),
      done: const Text("Done"),
      onDone: widget.onDone,
      dotsDecorator: const DotsDecorator(
          size: Size.square(6), activeColor: MICHIGAN_MAIZE),
      onChange: (page) {
        if (page == 4) {
          setState(() {
            allowNext = false;
          });
        }
      },
    );
  }
}