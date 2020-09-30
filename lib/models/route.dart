import 'package:flutter/cupertino.dart';

class RouteModel {
  final String points;
  final Distance distance;
  final Duration duration;
  final String startAddress;
  final String endAddress;

  RouteModel(
      {@required this.points,
  @required this.distance,
  @required this.duration,
  @required this.startAddress,
  @required this.endAddress});
}

class Distance {
  String text;
  int value;

  Distance.fromMap(Map data) {
    text = data["text"];
    value = data["value"];
  }
}

class Duration {
  String text;
  int value;

  Duration.fromMap(Map data) {
    text = data["text"];
    value = data["value"];
  }
}
