import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
class Homepage extends StatefulWidget{
  HomepageState createState() => HomepageState();
}

class HomepageState extends State<Homepage>{

  Completer<GoogleMapController> _controller = Completer();
  Location location = new Location();
  LocationData currentLocation;
  MapType _mapType= MapType.hybrid;

  File xml;
  static final CameraPosition _position = CameraPosition(
    target: LatLng(0, 0),
    zoom: 0
  );

  Set<Marker> _markers;

  void setInitialLocation() async {   // set the initial location by pulling the user's 
   // current location from the location's getLocation()
    currentLocation = await location.getLocation();
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      new CameraPosition(
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
        zoom: 15
    )));
  }
  
  void getWaterPoints() async {
    final xml = await rootBundle.loadString('assets/20200719 Watertappunten.gpx');    
    XmlDocument _doc = XmlDocument.parse(xml);
    setWaterPoints(_doc);
  }
  void setWaterPoints(XmlDocument _doc){
    final waterpoints = _doc.findAllElements('wpt');
    Set<Marker> _myMarkers = new Set<Marker>();
    waterpoints.forEach((element) {
      _myMarkers.add(
        new Marker(
          markerId: MarkerId('ID:' + element.getElement('name').toString()),
          position: LatLng(double.parse(element.getAttribute("lat")), double.parse(element.getAttribute("lon"))),
          icon: BitmapDescriptor.defaultMarker,
          ));
    });
    this.setState(() {
      _markers = _myMarkers;
    });
  }

  void initState(){
    setInitialLocation();
    getWaterPoints();
  }
  Widget build(BuildContext context){
    
    log("log test");
    return Scaffold(
      appBar: AppBar(title: Text("Water punten"),),
      body: Column(children: [
        Expanded(
          flex:7,
          child: GoogleMap(
            compassEnabled: true,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            markers: _markers,
            mapType: _mapType,
            initialCameraPosition: _position,
            onMapCreated: (controller) {
              _controller.complete(controller);
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(children: [
            FloatingActionButton(
              child: Icon(Icons.map),
              onPressed: () {
                this.setState(() {
                  _mapType = MapType.normal;
                });
              },
            ),
            FloatingActionButton(
              child: Icon(Icons.satellite),
              onPressed: () {
                this.setState(() {
                  _mapType = MapType.hybrid;
                });
              },
            )
          ],)
        )
      ],)
      
      
      
      
    );
  }
}