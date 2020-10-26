import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:txapita/helpers/constants.dart';
import 'package:txapita/models/route.dart';

class GoogleMapsServices {
  Future<RouteModel> getRouteByCoordinates(LatLng l1, LatLng l2) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=$GOOGLE_MAPS_API_KEY";
    http.Response response = await http.get(url);
    Map values = jsonDecode(response.body);
    Map routes = values["routes"][0];
    Map legs = values["routes"][0]["legs"][0];
    RouteModel route = RouteModel(
        points: routes["overview_polyline"]["points"],
        distance: Distance.fromMap(legs['distance']),
        timeNeeded: TimeNeeded.fromMap(legs['duration']),
        endAddress: legs['end_address'],
        startAddress: legs['end_address']);
    return route;
  }
}
