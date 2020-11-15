import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverModel {
  static const ID = "id";
  static const NAME = "name";
  static const LATITUDE = "latitude";
  static const LONGITUDE = "longitude";
  static const HEADING = "heading";
  static const POSITION = "position";
  static const CAR = "car";
  static const PLATE = "plate";
  static const PHOTO = "photo";
  static const RATING = "rating";
  static const VOTES = "votes";
  static const PHONE = "phone";

  String _id;
  String _name;
  String _car;
  String _plate;
  String _photo;
  String _phone;

  double _rating;
  int _votes;

  DriverPosition _position;

  String get id => _id;

  String get name => _name;

  String get car => _car;

  String get plate => _plate;

  String get photo => _photo;

  String get phone => _phone;

  DriverPosition get position => _position;

  double get rating => _rating;

  int get votes => _votes;

  DriverModel.fromSnapshot(DocumentSnapshot snapshot) {
    _name = snapshot.data[NAME];
    _id = snapshot.data[ID];
    _car = snapshot.data[CAR];
    _plate = snapshot.data[PLATE];
    _photo = snapshot.data[PHOTO];
    _phone = snapshot.data[PHONE];

    _rating = snapshot.data[RATING];
    _votes = snapshot.data[VOTES];
    _position = DriverPosition(
        lat: snapshot.data[POSITION][LATITUDE],
        lng: snapshot.data[POSITION][LONGITUDE],
        heading: snapshot.data[POSITION][HEADING]);
  }

  LatLng getPosition() {
    return LatLng(_position.lat, _position.lng);
  }
}

class DriverPosition {
  final double lat;
  final double lng;
  final double heading;

  DriverPosition({this.lat, this.lng, this.heading});
}
