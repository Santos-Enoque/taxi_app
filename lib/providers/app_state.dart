import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';
import 'package:txapita/helpers/style.dart';
import 'package:txapita/models/driver.dart';
import 'package:txapita/models/route.dart';
import 'package:txapita/services/drivers.dart';
import 'package:txapita/services/map_requests.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';

class AppStateProvider with ChangeNotifier {
  Set<Marker> _markers = {};
  Set<Polyline> _poly = {};
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  GoogleMapController _mapController;
  Geoflutterfire geo = Geoflutterfire();
  static LatLng _center;
  LatLng _lastPosition = _center;
  TextEditingController _locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  Position position;
  DriverService _driverService = DriverService();

  //   taxi pin
  BitmapDescriptor pinLocationIcon;

  LatLng get center => _center;

  LatLng get lastPosition => _lastPosition;

  TextEditingController get locationController => _locationController;

  Set<Marker> get markers => _markers;

  Set<Polyline> get poly => _poly;

  GoogleMapController get mapController => _mapController;
  RouteModel routeModel;

  AppStateProvider() {
    _setCustomMapPin();
    _getUserLocation();
    _driverService.getDrivers().listen(_updateMarkers);
  }

  Future<Position> _getUserLocation() async {
    position = await Geolocator().getCurrentPosition();
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    _center = LatLng(position.latitude, position.longitude);
    _locationController.text = placemark[0].name;
    notifyListeners();
    return position;
  }

  onCreate(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  setLastPosition(LatLng position) {
    _lastPosition = position;
    notifyListeners();
  }

  onCameraMove(CameraPosition position) {
    _lastPosition = position.target;
  }

  _addLocationMarker(LatLng position, String destination, String distance) {
//    _markers.clear();
    var uuid = new Uuid();
    String markerId = uuid.v1();
    _markers.add(Marker(
        markerId: MarkerId(markerId),
        position: position,
        infoWindow: InfoWindow(title: destination, snippet: distance),
        icon: BitmapDescriptor.defaultMarker));
    notifyListeners();
  }

  void _addDriverMarker({LatLng position, double rotation, String driverId}) {
    var uuid = new Uuid();
    String markerId = uuid.v1();
    _markers.add(Marker(
        markerId: MarkerId(markerId),
        position: position,
        rotation: rotation,
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: Offset(0.5, 0.5),
        icon: pinLocationIcon));
  }

  void sendRequest({String intendedLocation, LatLng coordinates}) async {
    LatLng destination = coordinates;
    RouteModel route =
        await _googleMapsServices.getRouteByCoordinates(_center, destination);
    routeModel = route;
    _addLocationMarker(
        destination, routeModel.endAddress, routeModel.distance.text);
    _center = destination;
    destinationController.text = routeModel.endAddress;

    _createRoute(route.points);
    notifyListeners();
  }

  void _createRoute(String decodeRoute) {
    _poly.clear();
    var uuid = new Uuid();
    String polyId = uuid.v1();
    poly.add(Polyline(
        polylineId: PolylineId(polyId),
        width: 12,
        color: primary,
        onTap: () {},
        points: _convertToLatLong(_decodePoly(decodeRoute))));
    notifyListeners();
  }

  List<LatLng> _convertToLatLong(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
// repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negetive then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

/*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }

//  _getDrivers({Position userPosition}) async {
//    geo
//        .collection(collectionRef: Firestore.instance.collection("locations"))
//        .within(
//            center: GeoFirePoint(userPosition.latitude, userPosition.longitude),
//            radius: 20,
//            field: "geolocation",
//    strictMode: true).listen(_updateMarkers);
//  }

  _updateMarkers(List<DriverModel> drivers) {
    clearMarkers();
    drivers.forEach((DriverModel driver) {
      print("=====DB CHANGE ===== \n latitude ${driver.position.lat} longitude ${driver.position.lng}");
      print("=====DB CHANGE ===== \n latitude ${driver.position.lat} longitude ${driver.position.lng}");
      print("=====DB CHANGE ===== \n latitude ${driver.position.lat} longitude ${driver.position.lng}");
      print("=====DB CHANGE ===== \n latitude ${driver.position.lat} longitude ${driver.position.lng}");
      print("=====DB CHANGE ===== \n latitude ${driver.position.lat} longitude ${driver.position.lng}");
      print("=====DB CHANGE ===== \n latitude ${driver.position.lat} longitude ${driver.position.lng}");
      print("=====DB CHANGE ===== \n latitude ${driver.position.lat} longitude ${driver.position.lng}");
      print("=====DB CHANGE ===== \n latitude ${driver.position.lat} longitude ${driver.position.lng}");
      print("=====DB CHANGE ===== \n latitude ${driver.position.lat} longitude ${driver.position.lng}");
      print("=====DB CHANGE ===== \n latitude ${driver.position.lat} longitude ${driver.position.lng}");


      _addDriverMarker(
        driverId: driver.id,
          position: LatLng(driver.position.lat,
              driver.position.lng),
          rotation: driver.position.heading);
    });
  }

  _setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'images/car.png');
  }

  clearMarkers(){
    _markers.clear();
    notifyListeners();
  }

  clearPoly(){
    _poly.clear();
    notifyListeners();
  }
}
