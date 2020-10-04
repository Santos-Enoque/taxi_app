import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:txapita/models/driver.dart';

class DriverService{
  Firestore _firestore = Firestore.instance;
  String collection = 'locations';

  Stream<List<DriverModel>> getDrivers() {
    return _firestore
        .collection(collection)
        .snapshots()
        .map((event) => event.documents.map((e) => DriverModel.fromSnapshot(e))
        .toList());
  }
}