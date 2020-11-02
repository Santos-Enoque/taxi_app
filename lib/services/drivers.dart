import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:txapita/helpers/constants.dart';
import 'package:txapita/models/driver.dart';

class DriverService {
  String collection = 'drivers';

  Stream<List<DriverModel>> getDrivers() {
    return firebaseFiretore.collection(collection).snapshots().map((event) =>
        event.documents.map((e) => DriverModel.fromSnapshot(e)).toList());
  }

  Future<DriverModel> getDriverById(String id) =>
      firebaseFiretore.collection(collection).document(id).get().then((doc) {
        return DriverModel.fromSnapshot(doc);
      });

  Stream<QuerySnapshot> driverStream() {
    CollectionReference reference = Firestore.instance.collection(collection);
    return reference.snapshots();
  }
}
