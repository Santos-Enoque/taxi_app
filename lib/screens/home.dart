import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:txapita/helpers/constants.dart';
import 'package:txapita/helpers/screen_navigation.dart';
import 'package:txapita/helpers/style.dart';
import 'package:txapita/providers/app_state.dart';
import "package:google_maps_webservice/places.dart";
import 'package:txapita/providers/user.dart';
import 'package:txapita/screens/splash.dart';
import 'package:txapita/widgets/custom_text.dart';

import 'login.dart';

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
  void initState() {
    super.initState();
    _deviceToken();
  }

  _deviceToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    UserProvider _user = Provider.of<UserProvider>(context, listen: false);

    if (_user.userModel?.token != preferences.getString('token')) {
      Provider.of<UserProvider>(context, listen: false).saveDeviceToken();
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return SafeArea(
      child: Scaffold(
          key: scaffoldState,
          drawer: Drawer(
              child: ListView(
            children: [
              UserAccountsDrawerHeader(
                  accountName: CustomText(
                    text: userProvider.userModel?.name ?? "",
                    size: 18,
                    weight: FontWeight.bold,
                  ),
                  accountEmail: CustomText(
                    text: userProvider.userModel?.email ?? "",
                  )),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: CustomText(text: "Log out"),
                onTap: () {
                  userProvider.signOut();
                  changeScreenReplacement(context, LoginScreen());
                },
              )
            ],
          )),
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
    UserProvider userProvider = Provider.of<UserProvider>(context);

    return appState.center == null
        ? Splash()
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
//              Positioned(
//                bottom: 60,
//                right: 0,
//                left: 0,
//                height: 60,
//                child: Visibility(
//                  visible: appState.routeModel != null,
//                  child: Padding(
//                    padding: const EdgeInsets.only(left: 15.0, right: 15.0),
//                    child: Container(
//                      color: Colors.white,
//                      child: Row(
//                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                        children: <Widget>[
//                          FlatButton.icon(
//                              onPressed: null,
//                              icon: Icon(Icons.timer),
//                              label: Text(
//                                  appState.routeModel?.timeNeeded?.text ?? "")),
//                          FlatButton.icon(
//                              onPressed: null,
//                              icon: Icon(Icons.flag),
//                              label: Text(
//                                  appState.routeModel?.distance?.text ?? "")),
//                          FlatButton(
//                              onPressed: () {},
//                              child: CustomText(
//                                text:
//                                    "\$${appState.routeModel?.distance?.value == null ? 0 : appState.routeModel?.distance?.value / 500}" ??
//                                        "",
//                                color: Colors.deepOrange,
//                              ))
//                        ],
//                      ),
//                    ),
//                  ),
//                ),
//              ),

              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: appState.lookingForDriver
                    ? Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Container(
                          color: white,
                          child: ListTile(
                            title: SpinKitWave(
                              color: black,
                              size: 30,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: grey.withOpacity(.5),
                                  offset: Offset(3, 2),
                                  blurRadius: 7)
                            ]),
                        child: Column(
                          children: [
                            // ANCHOR BOTTOM TEXT FIELDS
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Container(
                                color: grey.withOpacity(.3),
                                child: TextField(
                                  onTap: () async {
                                    Prediction p =
                                        await PlacesAutocomplete.show(
                                            context: context,
                                            apiKey: GOOGLE_MAPS_API_KEY,
                                            mode:
                                                Mode.overlay, // Mode.fullscreen
                                            language: "pt",
                                            components: [
                                          new Component(Component.country, "mz")
                                        ]);
                                    PlacesDetailsResponse detail = await places
                                        .getDetailsByPlaceId(p.placeId);
                                    double lat =
                                        detail.result.geometry.location.lat;
                                    double lng =
                                        detail.result.geometry.location.lng;
                                    appState.changeRequestedDestination(
                                        reqDestination: p.description,
                                        lat: lat,
                                        lng: lng);
                                    LatLng coordinates = LatLng(lat, lng);
                                    appState.sendRequest(
                                        coordinates: coordinates);
                                  },
                                  textInputAction: TextInputAction.go,
//                          onSubmitted: (value) {
//                            appState.sendRequest(intendedLocation: value);
//                          },
                                  controller: destinationController,
                                  cursorColor: Colors.blue.shade900,
                                  decoration: InputDecoration(
                                    icon: Container(
                                      margin:
                                          EdgeInsets.only(left: 20, bottom: 15),
                                      width: 10,
                                      height: 10,
                                      child: Icon(
                                        Icons.location_on,
                                        color: primary,
                                      ),
                                    ),
                                    hintText: "Where to go?",
                                    hintStyle: TextStyle(
                                        color: black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(15),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 15.0,
                                  right: 15.0,
                                ),
                                child: RaisedButton(
                                  onPressed: () {
                                    appState.requestDriver(
                                        distance: appState.routeModel.distance
                                            .toJson(),
                                        user: userProvider.userModel,
                                        lat: appState.position.latitude,
                                        lng: appState.position.longitude,
                                        context: context);
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20.0)), //this right here
                                            child: Container(
                                              height: 200,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SpinKitWave(
                                                      color: black,
                                                      size: 30,
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        CustomText(
                                                            text:
                                                                "Looking for a driver"),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 30,
                                                    ),
                                                    LinearPercentIndicator(
                                                      lineHeight: 4,
                                                      animation: true,
                                                      animationDuration: 100000,
                                                      percent: 1,
                                                      backgroundColor: Colors
                                                          .grey
                                                          .withOpacity(0.2),
                                                      progressColor:
                                                          Colors.deepOrange,
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        FlatButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                              appState
                                                                  .cancelRequest();
                                                              scaffoldSate
                                                                  .currentState
                                                                  .showSnackBar(
                                                                      SnackBar(
                                                                          content:
                                                                              Text("Request cancelled!")));
                                                            },
                                                            child: CustomText(
                                                              text:
                                                                  "Cancel Request",
                                                              color: Colors
                                                                  .deepOrange,
                                                            )),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                  color: darkBlue,
                                  child: Text(
                                    "Request ride",
                                    style:
                                        TextStyle(color: white, fontSize: 16),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              height: 15,
                            )
                          ],
                        ),
                      ),
              )
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
