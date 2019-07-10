import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:txapita/requests/map_requests.dart';
import 'package:uuid/uuid.dart';

class AppState with ChangeNotifier{
  Set<Marker> _markers = {};
  Set<Polyline> _poly = {};
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  GoogleMapController _mapController;
  static LatLng _center;
  LatLng _lastPosition = _center;
  TextEditingController _locationController = TextEditingController();
  Color primary = Colors.black;
  Color active = Colors.orange[200];
  Color disabled = Colors.grey[200];
  Color white = Colors.white;
  LatLng get center => _center;
  LatLng get lastPosition => _lastPosition;
  TextEditingController get locationController => _locationController;
  Set<Marker> get markers => _markers;
  Set<Polyline> get poly => _poly;
  GoogleMapController get mapController => _mapController;

  AppState._(){
    _getUserLocation();
  }

  factory AppState(){
    return AppState._();
  }
    _getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition();
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
      _center = LatLng(position.latitude, position.longitude);
      _locationController.text = placemark[0].name;
      notifyListeners();
  }

  onCreate(GoogleMapController controller) {
      _mapController = controller;
      notifyListeners();
  }

  setLastPosition(LatLng position){
    _lastPosition = position;
    notifyListeners();
  }

    onCameraMove(CameraPosition position) {
    _lastPosition = position.target;
  }

    _addMarker(LatLng position, String destination) {
    var uuid = new Uuid();
    String markerId = uuid.v1();
      _markers.add(Marker(
          markerId: MarkerId(markerId),
          position: position,
          infoWindow: InfoWindow(title: destination, snippet: "destino"),
          icon: BitmapDescriptor.defaultMarker));
          notifyListeners();
  }

    void sendRequest(String intendedLocation) async {
    List<Placemark> placemark =
        await Geolocator().placemarkFromAddress(intendedLocation);
    double latitude = placemark[0].position.latitude;
    double longitude = placemark[0].position.longitude;
    LatLng destination = LatLng(latitude, longitude);
    _addMarker(destination, intendedLocation);
    String route =
        await _googleMapsServices.getRouteByCoordinates(_center, destination);
    _createRoute(route);
  }

    void _createRoute(String decodeRoute) {
    var uuid = new Uuid();
    String polyId = uuid.v1();
      poly.add(Polyline(
          polylineId: PolylineId(polyId),
          width: 10,
          color: Colors.orange,
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
}