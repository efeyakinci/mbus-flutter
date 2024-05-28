import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mbus/map/MarkerAnimator.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final rotationStream = TestStream();
  var markerPos = LatLng(42.278235, -83.738118);
  final _annArbor = CameraPosition(
    target: LatLng(42.278235, -83.738118),
    zoom: 14.4746,
  );

  Completer<GoogleMapController> _controller = Completer();


  @override
  void initState() {
    rotationStream.stream.listen((event) {
      setState(() {
        markerPos = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(

        ),
      ),
    );
  }
}

class TestStream {
  final _controller = StreamController<LatLng>();
  static const positions = <LatLng>[LatLng(42.278235, -83.738118), LatLng(42.279235, -83.738118), LatLng(42.279235, -83.737118), LatLng(42.278235, -83.737118)];
  var count = 30.0;

  TestStream() {
    Timer.periodic(Duration(seconds: 20), (timer) async {
      for (int i = 0; i < positions.length; i++) {
        print("Currently on position $i");
        _controller.sink.add(positions[i]);
        await Future.delayed(Duration(seconds: 4));
      }
    });
  }

  Stream<LatLng> get stream => _controller.stream;

}