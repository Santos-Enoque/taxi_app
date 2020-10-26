import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:txapita/helpers/constants.dart';
import 'package:txapita/models/user.dart';
import 'package:txapita/services/user.dart';
import 'package:uuid/uuid.dart';


enum Status{Uninitialized, Authenticated, Authenticating, Unauthenticated}

class UserProvider with ChangeNotifier{
  FirebaseUser _user;
  Status _status = Status.Uninitialized;
  UserServices _userServices = UserServices();
  UserModel _userModel;

//  getter
  UserModel get userModel => _userModel;
  Status get status => _status;
  FirebaseUser get user => _user;

  // public variables
  final formkey = GlobalKey<FormState>();

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();



  UserProvider.initialize(){
    auth.onAuthStateChanged.listen(_onStateChanged);

  }


  Future<bool> signIn()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try{
      _status = Status.Authenticating;
      notifyListeners();
      await auth.signInWithEmailAndPassword(email: email.text.trim(), password: password.text.trim()).then((value) async {
        await prefs.setString("id", value.user.uid);
      });
      return true;
    }catch(e){
      _status = Status.Unauthenticated;
      notifyListeners();
      print(e.toString());
      return false;
    }
  }


  Future<bool> signUp()async{
    try{
      _status = Status.Authenticating;
      notifyListeners();
      await auth.createUserWithEmailAndPassword(email: email.text.trim(), password: password.text.trim()).then((result) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("id", result.user.uid);
        _userServices.createUser(
          id: result.user.uid,
          name: name.text.trim(),
          email: email.text.trim(),
          phone: phone.text.trim(),
        );
      });
      return true;
    }catch(e){
      _status = Status.Unauthenticated;
      notifyListeners();
      print(e.toString());
      return false;
    }
  }

  Future signOut()async{
    auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  void clearController(){
    name.text = "";
    password.text = "";
    email.text = "";
    phone.text = "";
  }

  Future<void> reloadUserModel()async{
    _userModel = await _userServices.getUserById(user.uid);
    notifyListeners();
  }

  updateUserData(Map<String, dynamic> data) async {
     _userServices.updateUserData(data);
  }

  saveDeviceToken()async{
    String deviceToken = await fcm.getToken();
    if(deviceToken != null){
      _userServices.addDeviceToken(
          userId: user.uid,
          token: deviceToken
      );
    }
  }


  _onStateChanged(FirebaseUser firebaseUser) async{
    if(firebaseUser == null){
      _status = Status.Unauthenticated;
    }else{
      _user = firebaseUser;
      _status = Status.Authenticated;
      _userModel = await _userServices.getUserById(user.uid);
    }
    notifyListeners();
  }

}