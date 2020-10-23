import 'package:cloud_firestore/cloud_firestore.dart';

class RideRequestModel{
 static const ID = "id";
 static const USERNAME = "username";
 static const USER_ID = "userId";
 static const DRIVER_ID = "driverId";
 static const STATUS = "status";
 static const POSITION = "position";
 static const DESTINATION = "destination";

 String _id;
 String _username;
 String _userId;
 String _driverId;
 String _status;
 Map _position;
 Map _destination;

 String get id => _id;
 String get username => _username;
 String get userId => _userId;
 String get driverId => _driverId;
 String get status => _status;
 Map get position => _position;
 Map get destination => _destination;

 RideRequestModel.fromSnapshot(DocumentSnapshot snapshot){
  _id = snapshot.data[ID];
  _username = snapshot.data[USERNAME];
  _userId = snapshot.data[USER_ID];
  _driverId = snapshot.data[DRIVER_ID];
  _status = snapshot.data[STATUS];
  _position = snapshot.data[POSITION];
  _destination = snapshot.data[DESTINATION];
 }






}