import 'package:txapita/helpers/constants.dart';
import 'package:txapita/models/user.dart';

class UserServices{
  String collection = "users";

  void createUser({String id,  String name,
  String email,
  String phone,
  int votes = 0,
  int trips = 0,
  double rating = 0,
  Map position}) {
    firebaseFiretore.collection(collection).document(id).setData({
      "name": name,
      "id": id,
      "phone": phone,
      "email": email,
      "votes": votes,
      "trips": trips,
      "rating": rating,
      "position": position
    });
  }

  void updateUserData(Map<String, dynamic> values){
    firebaseFiretore.collection(collection).document(values['id']).updateData(values);
  }

  Future<UserModel> getUserById(String id) => firebaseFiretore.collection(collection).document(id).get().then((doc){
    return UserModel.fromSnapshot(doc);
  });

  void addDeviceToken({String token, String userId}){
    firebaseFiretore.collection(collection).document(userId).updateData({
      "token": token
    });
  }

}