import 'package:flutter/cupertino.dart';

class RouteModel {
  final String points;
  final Distance distance;
  final TimeNeeded timeNeeded;
  final String startAddress;
  final String endAddress;

  RouteModel(
      {@required this.points,
      @required this.distance,
      @required this.timeNeeded,
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

  Map toJson() => {"text": text, "value": value};
}

class TimeNeeded {
  String text;
  int value;

  TimeNeeded.fromMap(Map data) {
    text = data["text"];
    value = data["value"];
  }
}
