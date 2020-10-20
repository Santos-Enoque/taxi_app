import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:txapita/helpers/style.dart';
import 'package:txapita/models/driver.dart';
import 'package:txapita/models/route.dart';
import 'package:txapita/models/user.dart';
import 'package:txapita/services/drivers.dart';
import 'package:txapita/services/map_requests.dart';
import 'package:txapita/services/ride_requests.dart';
import 'package:txapita/widgets/custom_text.dart';
import 'package:uuid/uuid.dart';

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
  BitmapDescriptor carPin;

  //   location pin
  BitmapDescriptor locationPin;

  LatLng get center => _center;

  LatLng get lastPosition => _lastPosition;

  TextEditingController get locationController => _locationController;

  Set<Marker> get markers => _markers;

  Set<Polyline> get poly => _poly;

  GoogleMapController get mapController => _mapController;
  RouteModel routeModel;

  //     this logic will update the percentage indicator
  int timeCounter = 0;
  double percentage = 0;
  Timer periodicTimer;
  bool lookingForDriver = false;
  RideRequestServices _requestServices = RideRequestServices();

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

  _addLocationMarker(LatLng position, String distance) {
    _markers.add(Marker(
        markerId: MarkerId("location"),
        position: position,
        infoWindow: InfoWindow(title: destinationController.text, snippet: distance),
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
        anchor: Offset(1, 1),
        icon: carPin));
  }

  void sendRequest({String intendedLocation, LatLng coordinates}) async {
    LatLng destination = coordinates;
    LatLng origin = LatLng(position.latitude, position.longitude);
    RouteModel route =
        await _googleMapsServices.getRouteByCoordinates(origin, destination);
    routeModel = route;
    List<Marker> mks = _markers
        .where((element) => element.markerId.value == "location")
        .toList();
    if (mks.length >= 1) {
      _markers.remove(mks[0]);
    }

    _addLocationMarker(
        destination, routeModel.distance.text);
    _center = destination;
    destinationController.text = routeModel.endAddress;

    _createRoute(route.points);
    notifyListeners();
  }

  void updateDestination({String destination}){
    destinationController.text = destination;
    notifyListeners();
  }

  void _createRoute(String decodeRoute) {
    clearPoly();
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
//    this code will ensure that when the driver markers are updated the location marker wont be deleted
    List<Marker> locationMarkers = _markers
        .where((element) => element.markerId.value == 'location')
        .toList();
    clearMarkers();
    if (locationMarkers.length > 0) {
      _markers.add(locationMarkers[0]);
    }

//    here we are updating the drivers markers
    drivers.forEach((DriverModel driver) {
      _addDriverMarker(
          driverId: driver.id,
          position: LatLng(driver.position.lat, driver.position.lng),
          rotation: driver.position.heading);
    });
  }

  _setCustomMapPin() async {
    carPin = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'images/car.png');

    locationPin = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'images/pin.png');
  }

  clearMarkers() {
    _markers.clear();
    notifyListeners();
  }

  clearPoly() {
    _poly.clear();
    notifyListeners();
  }

  requestDriver({UserModel user, double lat, double lng}){
    var uuid = new Uuid();
    String id = uuid.v1();
      _requestServices.createRideRequest(
        id: id,
        userId: user.id,
        username: user.name,
        destination: destinationController.text.trim(),
        position: {
          "latitude": lat,
          "longitude": lng
        }
      );
      percentageCounter();
  }

//  Timer counter for driver request
  percentageCounter() {
    lookingForDriver = true;
    notifyListeners();
    periodicTimer = Timer.periodic(Duration(seconds: 1), (time) {
      timeCounter = timeCounter + 1;
      percentage = timeCounter / 100;
      print("====== GOGOGOG ====== $timeCounter");
      if(timeCounter == 100 ){
        timeCounter = 0;
        percentage = 0;
        lookingForDriver = false;
        time.cancel();

      }
      notifyListeners();
    });
  }


}
