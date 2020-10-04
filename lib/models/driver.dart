import 'package:cloud_firestore/cloud_firestore.dart';

class DriverModel {
  static const ID = "id";
  static const NAME = "name";
  static const LATITUDE = "latitude";
  static const LONGITUDE = "longitude";
  static const HEADING = "heading";
  static const POSITION = "position";

  String id;
  String name;
  DriverPosition position;

  DriverModel.fromSnapshot(DocumentSnapshot snapshot) {
    name = snapshot.data[NAME];
    id = snapshot.data[ID];
    position = DriverPosition(
        lat: snapshot.data[POSITION][LATITUDE],
        lng: snapshot.data[POSITION][LONGITUDE],
        heading: snapshot.data[POSITION][HEADING]);
  }
}

class DriverPosition {
  final double lat;
  final double lng;
  final double heading;

  DriverPosition({this.lat, this.lng, this.heading});
}
