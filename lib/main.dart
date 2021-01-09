import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Completer<GoogleMapController> _controller = Completer();
  String _homeloc = "searching...";
  Position _currentPosition;
  String gmaploc = "";
  CameraPosition _userpos;
  // CameraPosition _home;
  double latitude = 6.4676929;
  double longitude = 100.5067673;
  Set<Marker> markers = Set();
  MarkerId markerId1 = MarkerId("12");
  GoogleMapController gmcontroller;
  
  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    try {
      _controller = Completer();
      _userpos = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 17,
      );
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.grey[300],
          appBar: AppBar(
            backgroundColor: Colors.teal,
            title: Text(
              "Google Map",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(height: 10),
                Container(
                  height: 400,
                  width: 380,
                  child: GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: _userpos,
                      markers: markers.toSet(),
                      onMapCreated: (controller) {
                        _controller.complete(controller);
                      },
                      onTap: (newLatLng) {
                        _loadLoc(newLatLng);
                      }),
                ),
                SizedBox(height: 10),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          child: Text(
                            "Address :",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Text(
                    _homeloc,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  child: Text(
                    "Latitude :",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    latitude.toStringAsFixed(7),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  child: Text(
                    "Longitude :",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    longitude.toStringAsFixed(7),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }
  void _loadLoc(LatLng loc) async {
    markers.clear();
    latitude = loc.latitude;
    longitude = loc.longitude;
    _getLocationfromlatlng(latitude, longitude);
    // _home = CameraPosition(
    //   target: loc,
    //   zoom: 17,
    // );
    markers.add(Marker(
      markerId: markerId1,
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(title: "Lat:"+latitude.toStringAsFixed(7)+"  "+
      "Long:"+longitude.toStringAsFixed(7)),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ));
    _userpos = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 17,
    );
  }
   
  _getLocationfromlatlng(double lat, double lng) async {
    final Geolocator geolocator = Geolocator()
      ..placemarkFromCoordinates(lat, lng);
    _currentPosition = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final coordinates = new Coordinates(lat, lng);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    _homeloc = first.addressLine;

    setState(() {
      _homeloc = first.addressLine;
    });
  }

  Future<void> _getLocation() async {
    try {
      final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
      geolocator
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .then((Position position) async {
        print(position);
        markers.add(Marker(
          markerId: markerId1,
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(title: "Lat:"+latitude.toStringAsFixed(7)+"  "+
          "Long:"+longitude.toStringAsFixed(7)),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ));
        _currentPosition = position;
        if (_currentPosition != null) {
          final coordinates = new Coordinates(
              _currentPosition.latitude, _currentPosition.longitude);
          var addresses =
              await Geocoder.local.findAddressesFromCoordinates(coordinates);
          setState(() {
            var first = addresses.first;
            _homeloc = first.addressLine;
            if (_homeloc != null) {
              latitude = _currentPosition.latitude;
              longitude = _currentPosition.longitude;
            }
          });
        }
      });
    } catch (exception) {
      print(exception.toString());
    }
  }
}
