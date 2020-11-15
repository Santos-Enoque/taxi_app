import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:txapita/helpers/constants.dart';
import 'package:txapita/helpers/style.dart';
import 'package:txapita/models/driver.dart';
import 'package:txapita/models/ride_Request.dart';
import 'package:txapita/models/route.dart';
import 'package:txapita/models/user.dart';
import 'package:txapita/services/drivers.dart';
import 'package:txapita/services/map_requests.dart';
import 'package:txapita/services/ride_requests.dart';
import 'package:txapita/widgets/custom_btn.dart';
import 'package:txapita/widgets/custom_text.dart';
import 'package:txapita/widgets/stars.dart';
import 'package:uuid/uuid.dart';

// * THIS ENUM WILL CONTAIN THE DRAGGABLE WIDGET TO BE DISPLAYED ON THE MAIN SCREEN
enum Show {
  DESTINATION_SELECTION,
  PICKUP_SELECTION,
  PAYMENT_METHOD_SELECTION,
  DRIVER_FOUND,
  TRIP
}

class AppStateProvider with ChangeNotifier {
  static const ACCEPTED = 'accepted';
  static const CANCELLED = 'cancelled';
  static const PENDING = 'pending';
  static const EXPIRED = 'expired';
  static const PICKUP_MARKER_ID = 'pickup';
  static const LOCATION_MARKER_ID = 'location';
  static const DRIVER_AT_LOCATION_NOTIFICATION = 'DRIVER_AT_LOCATION';
  static const REQUEST_ACCEPTED_NOTIFICATION = 'REQUEST_ACCEPTED';
  static const TRIP_STARTED_NOTIFICATION = 'TRIP_STARTED';




  Set<Marker> _markers = {};
  //  this polys will be displayed on the map
  Set<Polyline> _poly = {};
  // this polys temporarely store the polys to destination
  Set<Polyline> _routeToDestinationPolys = {};
  // this polys temporarely store the polys to driver
  Set<Polyline> _routeToDriverpoly = {};

  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  GoogleMapController _mapController;
  Geoflutterfire geo = Geoflutterfire();
  static LatLng _center;
  LatLng _lastPosition = _center;
  TextEditingController pickupLocationControlelr = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  Position position;
  DriverService _driverService = DriverService();
  //  draggable to show
  Show show = Show.DESTINATION_SELECTION;

  //   taxi pin
  BitmapDescriptor carPin;

  //   location pin
  BitmapDescriptor locationPin;

  LatLng get center => _center;

  LatLng get lastPosition => _lastPosition;

  Set<Marker> get markers => _markers;

  Set<Polyline> get poly => _poly;

  GoogleMapController get mapController => _mapController;
  RouteModel routeModel;

  //  Driver request related variables
  bool lookingForDriver = false;
  bool alertsOnUi = false;
  bool driverFound = false;
  bool driverArrived = false;
  RideRequestServices _requestServices = RideRequestServices();
  int timeCounter = 0;
  double percentage = 0;
  Timer periodicTimer;
  String requestedDestination;

  String requestStatus = "";
  double requestedDestinationLat;

  double requestedDestinationLng;
  RideRequestModel rideRequestModel;
  BuildContext mainContext;

//  this variable will listen to the status of the ride request
  StreamSubscription<QuerySnapshot> requestStream;
  // this variable will keep track of the drivers position before and during the ride
  StreamSubscription<QuerySnapshot> driverStream;
//  this stream is for all the driver on the app
  StreamSubscription<List<DriverModel>> allDriversStream;

  DriverModel driverModel;
  LatLng pickupCoordinates;
  LatLng destinationCoordinates;
  double ridePrice = 0;
  String notificationType = "";

  AppStateProvider() {
    _saveDeviceToken();
    fcm.configure(
//      this callback is used when the app runs on the foreground
        onMessage: handleOnMessage,
//        used when the app is closed completely and is launched using the notification
        onLaunch: handleOnLaunch,
//        when its on the background and opened using the notification drawer
        onResume: handleOnResume);

    _setCustomMapPin();
    _getUserLocation();
    _listemToDrivers();
    Geolocator().getPositionStream().listen(_updatePosition);

  }

// ANCHOR: MAPS & LOCATION METHODS
  _updatePosition(Position newPosition){
    position = newPosition;
    notifyListeners();
  }
  Future<Position> _getUserLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    position = await Geolocator().getCurrentPosition();
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);

    if (prefs.getString(COUNTRY) == null) {
      String country = placemark[0].isoCountryCode.toLowerCase();
      await prefs.setString(COUNTRY, country);
    }

    _center = LatLng(position.latitude, position.longitude);
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
    //  MOVE the pickup marker only when selecting the pickup location
    if (show == Show.PICKUP_SELECTION) {
      _lastPosition = position.target;
      changePickupLocationAddress(address: "loading...");
      if (_markers.isNotEmpty) {
        _markers.forEach((element) async {
          if (element.markerId.value == PICKUP_MARKER_ID) {
            _markers.remove(element);
            pickupCoordinates = position.target;
            addPickupMarker(position.target);
            List<Placemark> placemark = await Geolocator()
                .placemarkFromCoordinates(
                    position.target.latitude, position.target.longitude);
            pickupLocationControlelr.text = placemark[0].name;
            notifyListeners();
          }
        });
      }
      notifyListeners();
    }
  }

  Future sendRequest({LatLng origin, LatLng destination}) async {
    LatLng _org;
    LatLng _dest;

    if (origin == null && destination == null) {
      _org = pickupCoordinates;
      _dest = destinationCoordinates;
    } else {
      _org = origin;
      _dest = destination;
    }

    RouteModel route =
        await _googleMapsServices.getRouteByCoordinates(_org, _dest);
    routeModel = route;

    if (origin == null) {
      ridePrice =
          double.parse((routeModel.distance.value / 500).toStringAsFixed(2));
    }
    List<Marker> mks = _markers
        .where((element) => element.markerId.value == "location")
        .toList();
    if (mks.length >= 1) {
      _markers.remove(mks[0]);
    }
// ! another method will be created just to draw the polys and add markers
    _addLocationMarker(destinationCoordinates, routeModel.distance.text);
    _center = destinationCoordinates;
    if (_poly != null) {
      _createRoute(route.points, color: Colors.deepOrange);
    }
    _createRoute(
      route.points,
    );
    _routeToDestinationPolys = _poly;
    notifyListeners();
  }

  void updateDestination({String destination}) {
    destinationController.text = destination;
    notifyListeners();
  }

  _createRoute(String decodeRoute, {Color color}) {
    clearPoly();
    var uuid = new Uuid();
    String polyId = uuid.v1();
    _poly.add(Polyline(
        polylineId: PolylineId(polyId),
        width: 12,
        color: color ?? primary,
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

// ANCHOR: MARKERS AND POLYS
  _addLocationMarker(LatLng position, String distance) {
    _markers.add(Marker(
        markerId: MarkerId(LOCATION_MARKER_ID),
        position: position,
        anchor: Offset(0, 0.85),
        infoWindow:
            InfoWindow(title: destinationController.text, snippet: distance),
        icon: locationPin));
    notifyListeners();
  }

  addPickupMarker(LatLng position) {
    if (pickupCoordinates == null) {
      pickupCoordinates = position;
    }
    _markers.add(Marker(
        markerId: MarkerId(PICKUP_MARKER_ID),
        position: position,
        anchor: Offset(0, 0.85),
        zIndex: 3,
        infoWindow: InfoWindow(title: "Pickup", snippet: "location"),
        icon: locationPin));
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

  _updateDriverMarker(Marker marker) {
    _markers.remove(marker);
    sendRequest(
        origin: pickupCoordinates, destination: driverModel.getPosition());
    notifyListeners();
    _addDriverMarker(
        position: driverModel.getPosition(),
        rotation: driverModel.position.heading,
        driverId: driverModel.id);
  }

  _setCustomMapPin() async {
    carPin = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'images/taxi.png');

    locationPin = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'images/pin.png');
  }

  clearMarkers() {
    _markers.clear();
    notifyListeners();
  }

  _clearDriverMarkers() {
    _markers.forEach((element) {
      String _markerId = element.markerId.value;
      if (_markerId != driverModel.id ||
          _markerId != LOCATION_MARKER_ID ||
          _markerId != PICKUP_MARKER_ID) {
        _markers.remove(element);
        notifyListeners();
      }
    });
  }

  clearPoly() {
    _poly.clear();
    notifyListeners();
  }

// ANCHOR UI METHODS
  changeMainContext(BuildContext context) {
    mainContext = context;
    notifyListeners();
  }

  changeWidgetShowed({Show showWidget}) {
    show = showWidget;
    notifyListeners();
  }

  showRequestCancelledSnackBar(BuildContext context) {}

  showRequestExpiredAlert(BuildContext context) {
    if (alertsOnUi) Navigator.pop(context);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 200,
              child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                          text: "DRIVERS NOT FOUND! \n TRY REQUESTING AGAIN")
                    ],
                  )),
            ),
          );
        });
  }

  showDriverBottomSheet(BuildContext context) {
    if (alertsOnUi) Navigator.pop(context);

    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
              height: 400,
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        text: "7 MIN AWAY",
                        color: green,
                        weight: FontWeight.bold,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: driverModel?.photo == null,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(40)),
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 45,
                            child: Icon(
                              Icons.person,
                              size: 65,
                              color: white,
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: driverModel?.photo != null,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.deepOrange,
                              borderRadius: BorderRadius.circular(40)),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundImage: NetworkImage(driverModel?.photo),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(text: driverModel?.name ?? "Nada"),
                    ],
                  ),
                  SizedBox(height: 10),
                  _stars(rating: driverModel.rating, votes: driverModel.votes),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      FlatButton.icon(
                          onPressed: null,
                          icon: Icon(Icons.directions_car),
                          label: Text(driverModel.car ?? "Nan")),
                      CustomText(
                        text: driverModel.plate,
                        color: Colors.deepOrange,
                      )
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomBtn(
                        text: "Call",
                        onTap: () {},
                        bgColor: green,
                        shadowColor: Colors.green,
                      ),
                      CustomBtn(
                        text: "Cancel",
                        onTap: () {},
                        bgColor: red,
                        shadowColor: Colors.redAccent,
                      ),
                    ],
                  )
                ],
              ));
        });
  }

  _stars({int votes, double rating}) {
    if (votes == 0) {
      return StarsWidget(
        numberOfStars: 0,
      );
    } else {
      double finalRate = rating / votes;
      return StarsWidget(
        numberOfStars: finalRate.floor(),
      );
    }
  }

  // ANCHOR RIDE REQUEST METHODS
  _saveDeviceToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') == null) {
      String deviceToken = await fcm.getToken();
      await prefs.setString('token', deviceToken);
    }
  }

  changeRequestedDestination({String reqDestination, double lat, double lng}) {
    requestedDestination = reqDestination;
    requestedDestinationLat = lat;
    requestedDestinationLng = lng;
    notifyListeners();
  }

  listenToRequest({String id, BuildContext context}) async {
    requestStream = _requestServices.requestStream().listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((doc) async {
        if (doc.document.data['id'] == id) {
          rideRequestModel = RideRequestModel.fromSnapshot(doc.document);
          notifyListeners();
          switch (doc.document.data['status']) {
            case CANCELLED:
              break;
            case ACCEPTED:
              if (lookingForDriver) Navigator.pop(context);
              lookingForDriver = false;
              driverModel = await _driverService
                  .getDriverById(doc.document.data['driverId']);
              periodicTimer.cancel();
              clearPoly();
              _stopListeningToDriversStream();
              _listenToDriver();
              show = Show.DRIVER_FOUND;
              notifyListeners();

              // showDriverBottomSheet(context);
              break;
            case EXPIRED:
              showRequestExpiredAlert(context);
              break;
            default:
              break;
          }
        }
      });
    });
  }

  requestDriver(
      {UserModel user,
      double lat,
      double lng,
      BuildContext context,
      Map distance}) {
    alertsOnUi = true;
    notifyListeners();
    var uuid = new Uuid();
    String id = uuid.v1();
    _requestServices.createRideRequest(
        id: id,
        userId: user.id,
        username: user.name,
        distance: distance,
        destination: {
          "address": requestedDestination,
          "latitude": requestedDestinationLat,
          "longitude": requestedDestinationLng
        },
        position: {
          "latitude": lat,
          "longitude": lng
        });
    listenToRequest(id: id, context: context);
    percentageCounter(requestId: id, context: context);
  }
  

  cancelRequest() {
    lookingForDriver = false;
    _requestServices
        .updateRequest({"id": rideRequestModel.id, "status": "cancelled"});
    periodicTimer.cancel();
    notifyListeners();
  }

// ANCHOR LISTEN TO DRIVER
  _listemToDrivers() {
    allDriversStream = _driverService.getDrivers().listen(_updateMarkers);
  }

  _listenToDriver() {
    driverStream = _driverService.driverStream().listen((event) {
      event.documentChanges.forEach((change) async {
        if (change.document.data['id'] == driverModel.id) {
          driverModel = DriverModel.fromSnapshot(change.document);
          // code to update marker
//          List<Marker> _m = _markers
//              .where((element) => element.markerId.value == driverModel.id).toList();
//          _markers.remove(_m[0]);
          clearMarkers();
          sendRequest(
              origin: pickupCoordinates,
              destination: driverModel.getPosition());
              if(routeModel.distance.value <= 200){
                driverArrived = true;
              }
          notifyListeners();

          _addDriverMarker(
              position: driverModel.getPosition(),
              rotation: driverModel.position.heading,
              driverId: driverModel.id);
          addPickupMarker(pickupCoordinates);
          // _updateDriverMarker(_m[0]);
        }
      });
    });

    show = Show.DRIVER_FOUND;
    notifyListeners();
  }

  _stopListeningToDriversStream() {
//    _clearDriverMarkers();
    allDriversStream.cancel();
  }

//  Timer counter for driver request
  percentageCounter({String requestId, BuildContext context}) {
    lookingForDriver = true;
    notifyListeners();
    periodicTimer = Timer.periodic(Duration(seconds: 1), (time) {
      timeCounter = timeCounter + 1;
      percentage = timeCounter / 100;
      print("====== GOOOO $timeCounter");
      if (timeCounter == 100) {
        timeCounter = 0;
        percentage = 0;
        lookingForDriver = false;
        _requestServices.updateRequest({"id": requestId, "status": "expired"});
        time.cancel();
        if (alertsOnUi) {
          Navigator.pop(context);
          alertsOnUi = false;
          notifyListeners();
        }
        requestStream.cancel();
      }
      notifyListeners();
    });
  }

  setPickCoordinates({LatLng coordinates}) {
    pickupCoordinates = coordinates;
    notifyListeners();
  }

  setDestination({LatLng coordinates}) {
    destinationCoordinates = coordinates;
    notifyListeners();
  }

  changePickupLocationAddress({String address}) {
    pickupLocationControlelr.text = address;
    if (pickupCoordinates != null) {
      _center = pickupCoordinates;
    }
    notifyListeners();
  }

  // ANCHOR PUSH NOTIFICATION METHODS
  Future handleOnMessage(Map<String, dynamic> data) async {
    print("=== data = ${data.toString()}");
    notificationType = data['data']['type'];

    if(notificationType == DRIVER_AT_LOCATION_NOTIFICATION){

    }else if(notificationType == TRIP_STARTED_NOTIFICATION){
      show = Show.TRIP;
      sendRequest(origin: pickupCoordinates, destination: destinationCoordinates);
      notifyListeners();
    }else if(notificationType == REQUEST_ACCEPTED_NOTIFICATION){

    }
    notifyListeners();
  }

  Future handleOnLaunch(Map<String, dynamic> data) async {
    notificationType = data['data']['type'];
    if(notificationType == DRIVER_AT_LOCATION_NOTIFICATION){

    }else if(notificationType == TRIP_STARTED_NOTIFICATION){

    }else if(notificationType == REQUEST_ACCEPTED_NOTIFICATION){

    }
    driverModel = await _driverService.getDriverById(data['data']['driverId']);
    _stopListeningToDriversStream();

    _listenToDriver();
    notifyListeners();
  }

  Future handleOnResume(Map<String, dynamic> data) async {
    notificationType = data['data']['type'];

    _stopListeningToDriversStream();
    if(notificationType == DRIVER_AT_LOCATION_NOTIFICATION){

    }else if(notificationType == TRIP_STARTED_NOTIFICATION){

    }else if(notificationType == REQUEST_ACCEPTED_NOTIFICATION){

    }

    if (lookingForDriver) Navigator.pop(mainContext);
    lookingForDriver = false;
    driverModel = await _driverService.getDriverById(data['data']['driverId']);
    periodicTimer.cancel();
    notifyListeners();
  }
}
