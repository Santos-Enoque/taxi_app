import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  static const ID = "id";
  static const NAME = "name";
  static const EMAIL = "email";
  static const PHONE = "phone";
  static const VOTES = "votes";
  static const TRIPS = "trips";
  static const RATING = "rating";
  static const TOKEN = "token";



  String _id;
  String _name;
  String _email;
  String _phone;
  String _token;

  int _votes;
  int _trips;
  double _rating;

//  getters
  String get name => _name;
  String get email => _email;
  String get id => _id;
  String get token => _token;

  String get phone => _phone;
  int get votes => _votes;
  int get trips => _trips;
  double get rating => _rating;

  UserModel.fromSnapshot(DocumentSnapshot snapshot){
    _name = snapshot.data[NAME];
      _email = snapshot.data[EMAIL];
    _id = snapshot.data[ID];
    _token = snapshot.data[TOKEN];

    _phone = snapshot.data[PHONE];
    _votes = snapshot.data[VOTES];
    _trips = snapshot.data[TRIPS];
    _rating = snapshot.data[RATING];


  }

}