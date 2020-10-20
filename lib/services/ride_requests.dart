import 'package:txapita/helpers/constants.dart';

class RideRequestServices{
  String collection = "requests";

  void createRideRequest({String id, String userId, String username,
    String destination,
    Map position,

  }) {
    firebaseFiretore.collection(collection).document(id).setData({
      "username": username,
      "id": id,
      "userId": userId,
      "driverId": "",
      "position": position,
      "status": 'pending'
    });
  }

  void updateUserData(Map<String, dynamic> values){
    firebaseFiretore.collection(collection).document(values['id']).updateData(values);
  }
}