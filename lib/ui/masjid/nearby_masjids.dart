import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:noteapp/constants/app_themes.dart';
import 'package:noteapp/models/masjid_model.dart';
import 'package:noteapp/models/pin_information.dart';
import 'package:noteapp/services/firestore_database.dart';
import 'package:noteapp/services/firestore_path.dart';
import 'package:noteapp/services/firestore_service.dart';
import 'package:noteapp/ui/masjid/main_pin_pill.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../map.dart';

import 'package:nb_utils/nb_utils.dart';

final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

// import 'streambuilder_test.dart';

class NearByMasjidsScreen extends StatefulWidget {
  @override
  _NearByMasjidsScreenState createState() => _NearByMasjidsScreenState();
}

class _NearByMasjidsScreenState extends State<NearByMasjidsScreen> {
  GoogleMapController? _mapController;
  TextEditingController? _latitudeController, _longitudeController;
  final _firestoreService = FirestoreService.instance;

  // firestore init
  final radius = BehaviorSubject<double>.seeded(20.0);
  final _firestore = FirebaseFirestore.instance;
  var markers = <MarkerId, Marker>{};

  late Stream<List<DocumentSnapshot>> stream;

  LatLng? cameraCenter = LatLng(33.58757, 71.44239);

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

  Position? currentPosition;

  String locationMessage = "";

  bool loading = false;

  var _zoomLevel = 11.0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    loading = true;

    await _getCurrentPosition();

    setState(() {
      loading = false;
    });
    // if (currentPosition != null) geo = Geoflutterfire();

    {
      GeoPoint center =
          new GeoPoint(currentPosition!.latitude, currentPosition!.longitude);
      stream = radius.switchMap((rad) {
        log("jinfo: rad $rad");
        // final collectionReference = _firestore.collection('masjids');

        // return geo.collection(collectionRef: collectionReference).within(
        //     center: center, radius: rad, field: 'position', strictMode: true);

        return getMasjidsAroundMeStream(center, rad);
      });

      // _updateMarkers(await stream.first);

      _loadMapStyles();
    }
  }

  Future updateMapToBounds({List<LatLng> list = const []}) async {
    await Future.delayed(Duration(milliseconds: 50));

    // list = list.isEmpty
    //     ? markers.map((loc) => loc.marker.position).toList()
    //     : list;

    if (list.isEmpty) {
      list.add(cameraCenter ?? new LatLng(33.58757, 71.44239));
    }
    var zoomLevel = 0.0;

    {
      zoomLevel = MapsUtil.getBoundsZoomLevel(
              MapsUtil.getBoundsFromLatLngList(list),
              Size(
                MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height,
              )) +
          1;

      zoomLevel = zoomLevel == double.infinity ? _zoomLevel : zoomLevel;
    }

    LatLng temp = MapsUtil.getCentralLatlng(list);

    _zoomLevel = zoomLevel;

    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        target: temp,
        zoom: _zoomLevel,
      )),
    );
  }

  Stream<List<QueryDocumentSnapshot>> getMasjidsAroundMeStream(
      GeoPoint position, double distance) {
    log("jinfo: getMasjidsAroundMe called ${position.latitude}");
    double lat = 0.0144927536231884;
    double lon = 0.0181818181818182;
    // double distance = 50;
    // 1000 * 0.000621371;
    double lowerLat = position.latitude - (lat * distance);
    double lowerLon = position.longitude - (lon * distance);
    double greaterLat = position.latitude + (lat * distance);
    double greaterLon = position.longitude + (lon * distance);
    GeoPoint lesserGeopoint = GeoPoint(lowerLat, lowerLon);
    GeoPoint greaterGeopoint = GeoPoint(greaterLat, greaterLon);

    Query query =
        FirebaseFirestore.instance.collection(FirestorePath.masjids());

    query = query
        .where("coordinates", isGreaterThan: lesserGeopoint)
        .where("coordinates", isLessThan: greaterGeopoint);

    final Stream<QuerySnapshot> snapshots = query.snapshots();
    // final allData = snapshots.docs.map((doc) => doc.data()).toList();
    var temp = snapshots.map((snapshot) {
      log("jinfo: getMasjidsAroundMe snapshots.map ${snapshot.docs.length}");
      final result = snapshot.docs.map((snapshot) => snapshot).toList();

      return result;
    });
    return temp;
  }

  Future _loadMapStyles() async {
    _darkMapStyle = await rootBundle.loadString('assets/map_styles/dark.json');
    // _lightMapStyle =
    //     await rootBundle.loadString('assets/map_styles/light.json');
  }

  Future _setMapStyle() async {
    _mapController!.setMapStyle(_darkMapStyle);
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return;
    }

    final position = await _geolocatorPlatform.getCurrentPosition();
    setState(() {
      currentPosition = position;
    });
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        locationMessage = AppThemes.kLocationServicesDisabledMessage;
      });
      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          locationMessage = AppThemes.kPermissionDeniedMessage;
        });

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        locationMessage = AppThemes.kPermissionDeniedForeverMessage;
      });
      return false;
    }

    return true;
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

    final firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);

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
      body: loading
          ? Center(child: CircularProgressIndicator())
          : currentPosition == null
              ? Center(
                  child: Column(
                    children: [
                      Text(locationMessage),
                      ElevatedButton(
                          onPressed: () => loadData(), child: Text("Try Again"))
                    ],
                  ),
                )
              : Container(
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
                                  target: cameraCenter ??
                                      LatLng(33.58757, 71.44239),
                                  zoom: _zoomLevel,
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
                          Spacer(),
                          Text("${markers.length} Masjids found")
                        ],
                      ).paddingAll(16),
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
        log("jinfo: Stream started");
        log("jinfo: documentList ${documentList.length}");

        _updateMarkers(documentList);
        updateMapToBounds(
            list: markers.entries
                .map((e) => new LatLng(
                    e.value.position.latitude, e.value.position.longitude))
                .toList());
      });
    });
  }

  Future<void> _addMarker(double lat, double lng, String name, String masjidId,
      String urduName) async {
    final id = MarkerId(lat.toString() + lng.toString());
    log("jinfo: loading markerIcon");
    final Uint8List markerIcon =
        await MapsUtil.getBytesFromAsset('assets/img/masjid_marker.png', 120);
    log("jinfo: setting _marker");
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
      log("jinfo: markers[id]=_marker");
      markers[id] = _marker;
    });
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    cameraCenter = null;
    log("jinfo: _updateMarker called");
    log("jinfo: _updateMarker called documentList ${documentList.length}");

    documentList.forEach((DocumentSnapshot document) {
      final data = document.data() as Map<String, dynamic>;
      log("jinfo: _updateMarker called data ${data.toString()}");
      final GeoPoint point = data['coordinates']; //['geopoint'];
      final name = data['enName'];
      final id = document.id;
      final urduName = data['urduName'];

      if (cameraCenter == null)
        cameraCenter = LatLng(point.latitude, point.longitude);
      log("jinfo: marker data ${data.toString()}");
      _addMarker(point.latitude, point.longitude, name, id, urduName);
    });

    if (cameraCenter != null) {
      var newPosition =
          CameraPosition(target: cameraCenter!, zoom: getZoomLevel());

      CameraUpdate update = CameraUpdate.newCameraPosition(newPosition);
      // CameraUpdate zoom = CameraUpdate.zoomTo(16);

      _mapController!.moveCamera(update);
    }
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

  double getZoomLevel() {
    if (radius.value < 5) return 20.0;

    if (radius.value <= 10) return 18.0;

    if (radius.value <= 20) return 17.0;

    return 9.0;
  }
}
