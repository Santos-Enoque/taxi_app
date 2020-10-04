import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:txapita/helpers/constants.dart';
import 'package:txapita/helpers/style.dart';
import 'package:txapita/providers/app_state.dart';
import "package:google_maps_webservice/places.dart";

GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: GOOGLE_MAPS_API_KEY);


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var scaffoldState = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: scaffoldState,
          drawer: Drawer(
            child: Scaffold(
              appBar: AppBar(
                title: Text("Settings"),
              ),
            ),
          ),
          body: Map(scaffoldState)),
    );
  }
}

class Map extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldState;

  Map(this.scaffoldState);

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  GoogleMapsPlaces googlePlaces;
  TextEditingController destinationController = TextEditingController();
  Color darkBlue = Colors.black;
  Color grey = Colors.grey;
  GlobalKey<ScaffoldState> scaffoldSate = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    scaffoldSate = widget.scaffoldState;
  }

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState = Provider.of<AppStateProvider>(context);
    return appState.center == null
        ? Container(
            alignment: Alignment.center,
            child: Center(child: CircularProgressIndicator()),
          )
        : Stack(
            children: <Widget>[
              GoogleMap(
                initialCameraPosition:
                CameraPosition(target: appState.center, zoom: 15),
                onMapCreated: appState.onCreate,
                myLocationEnabled: true,
                mapType: MapType.normal,
                compassEnabled: true,
                markers: appState.markers,
                onCameraMove: appState.onCameraMove,
                polylines: appState.poly,
              ),
              Positioned(
                top: 10,
                left: 15,
                child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: primary,
                      size: 30,
                    ),
                    onPressed: () {
                      scaffoldSate.currentState.openDrawer();
                    }),
              ),
              Positioned(
                top: 60.0,
                right: 15.0,
                left: 15.0,
                child: Container(
                  height: 120.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x88999999),
                        offset: Offset(0, 5),
                        blurRadius: 5.0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        cursorColor: Colors.blue.shade900,
                        controller: appState.locationController,
                        decoration: InputDecoration(
                          icon: Container(
                            margin: EdgeInsets.only(left: 20, top: 5),
                            width: 10,
                            height: 10,
                            child: Icon(
                              Icons.location_on,
                              color: primary,
                            ),
                          ),
                          hintText: "pick up",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextField(
                          onTap: ()async{
                            Prediction p = await PlacesAutocomplete.show(
                                context: context,
                                apiKey: GOOGLE_MAPS_API_KEY,
                                mode: Mode.overlay, // Mode.fullscreen
                                language: "pt",
                                components: [new Component(Component.country, "mz")]);

//                            displayPrediction(p);
                            PlacesDetailsResponse detail =
                            await places.getDetailsByPlaceId(p.placeId);
                            double lat = detail.result.geometry.location.lat;
                            double lng = detail.result.geometry.location.lng;
                            LatLng coordinates = LatLng(lat, lng);
                            appState.sendRequest(coordinates: coordinates);
                          },
                          textInputAction: TextInputAction.go,
//                          onSubmitted: (value) {
//                            appState.sendRequest(intendedLocation: value);
//                          },
                          controller: destinationController,
                          cursorColor: Colors.blue.shade900,
                          decoration: InputDecoration(
                            icon: Container(
                              margin: EdgeInsets.only(left: 20, top: 5),
                              width: 10,
                              height: 10,
                              child: Icon(
                                Icons.local_taxi,
                                color: primary,
                              ),
                            ),
                            hintText: "destination?",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: 15.0, top: 16.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 60, right: 0, left: 0, height: 60,
                child: Visibility(
                  visible: appState.routeModel != null,
                  child: Padding(
                    padding: const EdgeInsets.only(left:15.0, right: 15.0),
                    child: Container(
                      color: Colors.white,
                      child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                         FlatButton.icon(onPressed: (){}, icon: Icon(Icons.timer), label: Text("18 min")),
                          FlatButton.icon(onPressed: (){}, icon: Icon(Icons.attach_money), label: Text("15"))


                        ],
                      ),
                    ),
                  ),
                ),),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Padding(
                    padding: const EdgeInsets.only(left:15.0, right: 15.0),
                    child: RaisedButton(onPressed: (){}, color: darkBlue,
                      child: Text("Confirm Booking", style: TextStyle(color: white, fontSize: 16),),),
                  ),
                ),)
            ],
          );
  }

  Future<Null> displayPrediction(Prediction p) async {
       if (p != null) {
         PlacesDetailsResponse detail =
         await places.getDetailsByPlaceId(p.placeId);

         var placeId = p.placeId;
         double lat = detail.result.geometry.location.lat;
         double lng = detail.result.geometry.location.lng;

         var address = await Geocoder.local.findAddressesFromQuery(p.description);

         print(lat);
         print(lng);
       }
  }

}
