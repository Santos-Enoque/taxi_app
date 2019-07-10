import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:txapita/screens/places.dart';
import 'package:txapita/source/common.dart';
import 'package:txapita/states/app_state.dart';
import "package:google_maps_webservice/places.dart";

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
    return Scaffold(
        key: scaffoldState,
        drawer: Drawer(
          child: Scaffold(
            appBar: AppBar(
              title: Text("Settings"),
            ),
          ),
        ),
        body: Map(scaffoldState));
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
    AppState appState = Provider.of<AppState>(context);
    return appState.center == null
        ? Container(
            alignment: Alignment.center,
            child: Center(child: CircularProgressIndicator()),
          )
        : Stack(
            children: <Widget>[
              GoogleMap(
                initialCameraPosition:
                CameraPosition(target: appState.center, zoom: 17.0),
                onMapCreated: appState.onCreate,
                myLocationEnabled: true,
                mapType: MapType.normal,
                compassEnabled: true,
                markers: appState.markers,
                onCameraMove: appState.onCameraMove,
                polylines: appState.poly,
              ),
              Positioned(
                top: 20,
                left: 0,
                child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: appState.primary,
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
                  height: 100.0,
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
                              color: appState.primary,
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
                          onTap: (){
                            changeScreen(context, Places());
                          },
                          textInputAction: TextInputAction.go,
                          onSubmitted: (value) {
                            appState.sendRequest(value);
                          },
                          controller: destinationController,
                          cursorColor: Colors.blue.shade900,
                          decoration: InputDecoration(
                            icon: Container(
                              margin: EdgeInsets.only(left: 20, top: 5),
                              width: 10,
                              height: 10,
                              child: Icon(
                                Icons.local_taxi,
                                color: appState.primary,
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
                child: Padding(
                  padding: const EdgeInsets.only(left:15.0, right: 15.0),
                  child: Container(
                    color: Colors.white,
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: ListTile(
                          title: CircleAvatar(
                            radius: 20,
                            child: Image.asset('images/car.png', width: 35,),
                            backgroundColor: appState.active,
                          ),
                          subtitle: Text("Mini",textAlign: TextAlign.center ,style: TextStyle(color: darkBlue),),
                           ),
                        ),

                        Expanded(
                          child: ListTile(
                          title: CircleAvatar(
                            radius: 20,
                            child: Image.asset('images/eco-car.png', width: 35,),
                            backgroundColor: appState.disabled,
                          ),
                          subtitle: Text("Micro",textAlign: TextAlign.center ,style: TextStyle(color: darkBlue),),
                           ),
                        ),

                        Expanded(
                          child: ListTile(
                          title: CircleAvatar(
                            radius: 20,
                            child: Image.asset('images/off-road.png', width: 35,),
                            backgroundColor: appState.disabled,
                          ),
                          subtitle: Text("XL",textAlign: TextAlign.center ,style: TextStyle(color: darkBlue),),
                           ),
                        ),
                      ],
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
                      child: Text("Confirm Booking", style: TextStyle(color: appState.white, fontSize: 16),),),
                  ),
                ),)
            ],
          );
  }

//to place the marker in the center we have to track the cobile current position










//  this method here will do the conversion





}
