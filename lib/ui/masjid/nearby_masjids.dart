import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:noteapp/models/pin_information.dart';
import 'package:noteapp/ui/masjid/main_pin_pill.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../map.dart';

// import 'streambuilder_test.dart';

class NearByMasjidsScreen extends StatefulWidget {
  @override
  _NearByMasjidsScreenState createState() => _NearByMasjidsScreenState();
}

class _NearByMasjidsScreenState extends State<NearByMasjidsScreen> {
  GoogleMapController? _mapController;
  TextEditingController? _latitudeController, _longitudeController;

  // firestore init
  final radius = BehaviorSubject<double>.seeded(20.0);
  final _firestore = FirebaseFirestore.instance;
  final markers = <MarkerId, Marker>{};

  late Stream<List<DocumentSnapshot>> stream;
  late Geoflutterfire geo;

  var cameraCenter = LatLng(33.58757, 71.44239);

  late String _darkMapStyle;

  double pinPillPosition = -200;
  PinInformation currentlySelectedPin = PinInformation(
      pinPath: '',
      avatarPath: '',
      location: LatLng(0, 0),
      locationName: '',
      labelColor: Colors.grey,
      enName: '',
      urduName: '',
      id: '');

  @override
  void initState() {
    super.initState();

    geo = Geoflutterfire();
    GeoFirePoint center = geo.point(latitude: 33.58757, longitude: 71.44239);
    stream = radius.switchMap((rad) {
      final collectionReference = _firestore.collection('masjids');

      return geo.collection(collectionRef: collectionReference).within(
          center: center, radius: rad, field: 'position', strictMode: true);

      /*
      ****Example to specify nested object****
      var collectionReference = _firestore.collection('nestedLocations');
//          .where('name', isEqualTo: 'darshan');
      return geo.collection(collectionRef: collectionReference).within(
          center: center, radius: rad, field: 'address.location.position');
      */
    });

    _loadMapStyles();
  }

  Future _loadMapStyles() async {
    _darkMapStyle = await rootBundle.loadString('assets/map_styles/dark.json');
    // _lightMapStyle =
    //     await rootBundle.loadString('assets/map_styles/light.json');
  }

  Future _setMapStyle() async {
    _mapController!.setMapStyle(_darkMapStyle);
  }

  @override
  void dispose() {
    _latitudeController?.dispose();
    _longitudeController?.dispose();
    radius.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Masjid near me'),
        // actions: <Widget>[
        //   IconButton(
        //     onPressed: _mapController == null ? null : () {},
        //     icon: Icon(Icons.home),
        //   )
        // ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      //       return StreamTestWidget();
      //     }));
      //   },
      //   child: Icon(Icons.navigate_next),
      // ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  width: mediaQuery.size.width - 30,
                  height: mediaQuery.size.height * (7 / 10),
                  child: Stack(children: [
                    GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: cameraCenter,
                        zoom: 11.0,
                      ),
                      markers: Set<Marker>.of(markers.values),
                      onTap: (LatLng location) {
                        setState(() {
                          pinPillPosition = -200;
                        });
                      },
                    ),
                    MapPinPillComponent(
                        pinPillPosition: pinPillPosition,
                        currentlySelectedPin: currentlySelectedPin)
                  ]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Slider(
                min: 1,
                max: 100,
                divisions: 10,
                value: _value,
                label: _label,
                activeColor: Colors.blue,
                inactiveColor: Colors.blue.withOpacity(0.2),
                onChanged: (double value) => changed(value),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  child: Text('Within ${_value.floor()} KM'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
      _setMapStyle();
//      _showHome();
      //start listening after map is created
      stream.listen((List<DocumentSnapshot> documentList) {
        _updateMarkers(documentList);
      });
    });
  }

  Future<void> _addMarker(double lat, double lng, String name, String masjidId,
      String urduName) async {
    final id = MarkerId(lat.toString() + lng.toString());
    final Uint8List markerIcon =
        await MapsUtil.getBytesFromAsset('assets/img/masjid_marker.png', 120);
    final _marker = Marker(
      markerId: id,
      position: LatLng(lat, lng),
      icon: BitmapDescriptor.fromBytes(markerIcon),
      infoWindow: InfoWindow(
          title: 'Name', snippet: '$name \n Tap to add to your list'),
      onTap: () {
        setState(() {
          currentlySelectedPin = new PinInformation(
              locationName: '$name',
              location: LatLng(lat, lng),
              pinPath: "assets/img/masjid_marker.png",
              avatarPath: "assets/img/masjid_marker.png",
              labelColor: Colors.black87,
              enName: name,
              urduName: urduName,
              id: masjidId);
          pinPillPosition = 50;
        });
      },
    );
    setState(() {
      markers[id] = _marker;
    });
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    documentList.forEach((DocumentSnapshot document) {
      final data = document.data() as Map<String, dynamic>;

      final GeoPoint point = data['position']['geopoint'];
      final name = data['enName'];
      final id = document.id;
      final urduName = data['urduName'];
      _addMarker(point.latitude, point.longitude, name, id, urduName);
    });

    // _mapController!.animateCamera(
    //                                   CameraUpdate.newCameraPosition(
    //                                       CameraPosition(
    //                                           target: newlatlang, zoom: 17)
    //                                       //17 is new zoom level
    //                                       ));
  }

  double _value = 20.0;
  String _label = '';

  changed(value) {
    setState(() {
      _value = value;
      _label = '${_value.toInt().toString()} kms';
      markers.clear();
    });
    radius.add(value);
  }
}
