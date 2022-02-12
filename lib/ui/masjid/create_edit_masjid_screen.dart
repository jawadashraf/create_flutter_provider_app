import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:noteapp/constants/app_themes.dart';
import 'package:noteapp/map.dart';
import 'package:noteapp/models/masjid_model.dart';
import 'package:noteapp/services/firestore_database.dart';
import 'package:noteapp/ui/masjid/waktuSalat.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui' as ui;

import 'package:marquee/marquee.dart' as Marquee;

final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

class CreateEditMasjidScreen extends StatefulWidget {
  @override
  _CreateEditMasjidScreenState createState() => _CreateEditMasjidScreenState();
}

class _CreateEditMasjidScreenState extends State<CreateEditMasjidScreen> {
  late TextEditingController _enNameController;
  late TextEditingController _urduNameController;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Masjid? _masjid;

  late GoogleMapController mapController;

  List<Marker> allMarkers = <Marker>[];

  String selectedEnName = "";
  String selectedUrduName = "";

  String selectedFajrTime = "00:00 AM";
  String selectedZuhrTime = "00:00 AM";
  String selectedAsarTime = "00:00 AM";
  String selectedMaghrebTime = "00:00 AM";
  String selectedJummahTime = "00:00 AM";
  String selectedIshaTime = "00:00 AM";

  TimeOfDay selectedTime = TimeOfDay.now();
  GeoFirePoint? selectedPosition;

  PickResult? selectedPlace;

  final kInitialPosition = LatLng(33.58757, 71.44239);

  bool get _hasChangedEnName => _masjid?.enName != selectedEnName;
  bool get _hasChangedUrduName => _masjid?.urduName != selectedUrduName;
  bool get _hasChangedFajrTime => _masjid?.fajrTime != selectedFajrTime;
  bool get _hasChangedZuhrTime => _masjid?.zuhrTime != selectedZuhrTime;
  bool get _hasChangedAsarTime => _masjid?.asarTime != selectedAsarTime;
  bool get _hasChangedMaghrebTime =>
      _masjid?.maghrebTime != selectedMaghrebTime;
  bool get _hasChangedIshaTime => _masjid?.ishaTime != selectedIshaTime;
  bool get _hasChangedJummahTime => _masjid?.jummahTime != selectedJummahTime;
  bool get _hasChangedPosition => _masjid?.position != selectedPosition;

  bool get _hasChangedValue =>
      _hasChangedEnName ||
      _hasChangedUrduName ||
      _hasChangedFajrTime ||
      _hasChangedAsarTime ||
      _hasChangedZuhrTime ||
      _hasChangedMaghrebTime ||
      _hasChangedIshaTime ||
      _hasChangedJummahTime ||
      _hasChangedPosition;

  @override
  void initState() {
    super.initState();
  }

  void loadData() {}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Masjid? _masjidModel =
        ModalRoute.of(context)?.settings.arguments as Masjid?;
    if (_masjidModel != null) {
      _masjid = _masjidModel;
    }

    _enNameController = TextEditingController(text: _masjid?.enName ?? "");
    _urduNameController = TextEditingController(text: _masjid?.urduName ?? "");

    selectedEnName = _masjid?.enName ?? "";
    selectedUrduName = _masjid?.urduName ?? "";

    selectedFajrTime = _masjid?.fajrTime ?? "00:00 AM";
    selectedZuhrTime = _masjid?.zuhrTime ?? "00:00 AM";
    selectedAsarTime = _masjid?.asarTime ?? "00:00 AM";
    selectedMaghrebTime = _masjid?.maghrebTime ?? "00:00 AM";
    selectedJummahTime = _masjid?.jummahTime ?? "00:00 AM";
    selectedIshaTime = _masjid?.ishaTime ?? "00:00 AM";
    selectedPosition = _masjid?.position;

    print("Position $selectedPosition");

    if (selectedPosition != null)
      MapsUtil.getMarker(
              latlng: LatLng(
                  selectedPosition!.latitude, selectedPosition!.longitude))
          .then((marker) {
        allMarkers.add(marker);
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(_masjid != null ? "Show/Edit Masjid" : "New Masjid"),
        actions: <Widget>[
          TextButton(
              onPressed: _hasChangedValue ? () => saveMasjid(context) : null,
              child: Text("Save"))
        ],
      ),
      body: Center(
        child: _buildForm(context),
      ),
    );
  }

  void saveMasjid(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final firestoreDatabase =
          Provider.of<FirestoreDatabase>(context, listen: false);

      firestoreDatabase.setMasjid(Masjid(
          id: _masjid?.id ?? Uuid().v1(),
          enName: _enNameController.text,
          urduName: _urduNameController.text,
          address: "Address",
          city: "Cityaaa",
          fajrTime: selectedFajrTime,
          asarTime: selectedAsarTime,
          zuhrTime: selectedZuhrTime,
          maghrebTime: selectedMaghrebTime,
          ishaTime: selectedIshaTime,
          jummahTime: selectedJummahTime,
          position: selectedPosition,
          createdBy: firestoreDatabase.uid));

      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _enNameController.dispose();
    _urduNameController.dispose();
    super.dispose();
  }

  Future<String> _selectTime(
      BuildContext context, String currentTimeInString) async {
    TimeOfDay _currentTime = stringToTimeOfDay(currentTimeInString);
    final TimeOfDay? timeOfDay = await showTimePicker(
        context: context,
        initialTime: _currentTime,
        initialEntryMode: TimePickerEntryMode.dial);
    if (timeOfDay != null && timeOfDay != _currentTime) {
      return timeOfDay.format(context);
    } else
      return currentTimeInString;
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      // _updatePositionList(
      //   _PositionItemType.log,
      //   _kLocationServicesDisabledMessage,
      // );

      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      // _updatePositionList(
      //   _PositionItemType.log,
      //   _kPermissionDeniedForeverMessage,
      // );

      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    // _updatePositionList(
    //   _PositionItemType.log,
    //   _kPermissionGrantedMessage,
    // );
    return true;
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                decoration: AppThemes.myLeftBoxDecoration(),
                child: Text(
                  selectedEnName.isEmpty ? "English Name" : selectedEnName,
                  style: TextStyle(fontSize: 24.0),
                ).center().onTap(() => _displayEngnameDialog(context)),
              ),
              24.height,
              // TextFormField(
              //   controller: _enNameController,
              //   style: Theme.of(context).textTheme.bodyText1,
              //   validator: (value) =>
              //       value!.isEmpty ? "English name can't be empty" : null,
              //   decoration: InputDecoration(
              //     enabledBorder: OutlineInputBorder(
              //         borderSide: BorderSide(
              //             color: Theme.of(context).iconTheme.color!, width: 2)),
              //     labelText: "English Name",
              //   ),
              // ),
              Container(
                decoration: AppThemes.myRightBoxDecoration(),
                child: Text(
                        selectedUrduName.isEmpty
                            ? "Urdu Name"
                            : selectedUrduName,
                        style: TextStyle(fontSize: 24.0))
                    .center()
                    .onTap(() => _displayUrdunameDialog(context)),
              ),
              36.height,
              _masjid == null
                  ? Container()
                  : Container(
                      padding: const EdgeInsets.all(8.0),
                      constraints: BoxConstraints(
                          minHeight: 60,
                          minWidth: double.infinity,
                          maxHeight: 60),
                      child: Marquee.Marquee(
                        text:
                            'لآ اِلَهَ اِلّا اللّهُ مُحَمَّدٌ رَسُوُل اللّه  - لآ اِلَهَ اِلّا اللّهُ مُحَمَّدٌ رَسُوُل اللّهِ - لآ اِلَهَ اِلّا اللّهُ مُحَمَّدٌ رَسُوُل اللّهِ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.green,
                            backgroundColor: Colors.black),
                        scrollAxis: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        blankSpace: 20.0,
                        velocity: 100.0,
                        pauseAfterRound: Duration(seconds: 1),
                        startPadding: 10.0,
                        accelerationDuration: Duration(seconds: 1),
                        accelerationCurve: Curves.linear,
                        decelerationDuration: Duration(milliseconds: 500),
                        decelerationCurve: Curves.easeOut,
                        textDirection: ui.TextDirection.rtl,
                      ),
                      // child: Marquee(
                      //   direction: Axis.horizontal,
                      //   animationDuration: Duration(milliseconds: 100),
                      //   pauseDuration: Duration(milliseconds: 100),
                      //   child: Text(
                      //       "لآ اِلَهَ اِلّا اللّهُ مُحَمَّدٌ رَسُوُل اللّه  - لآ اِلَهَ اِلّا اللّهُ مُحَمَّدٌ رَسُوُل اللّهِ - لآ اِلَهَ اِلّا اللّهُ مُحَمَّدٌ رَسُوُل اللّه"),
                      // ),
                    ),

              16.height,
              WaktuSalat(
                name: "الفجر",
                time: selectedFajrTime,
                isCurrent: false,
              ).onTap(() async {
                String str = await _selectTime(context, selectedFajrTime);

                setState(() {
                  selectedFajrTime = str;
                  print(_hasChangedFajrTime);
                });
              }),
              16.height,
              WaktuSalat(
                name: "الظہر",
                time: selectedZuhrTime,
                isCurrent: false,
              ).onTap(() async {
                String str = await _selectTime(context, selectedZuhrTime);

                setState(() {
                  selectedZuhrTime = str;
                });
              }),
              16.height,
              WaktuSalat(
                name: "العصر",
                time: selectedAsarTime,
                isCurrent: false,
              ).onTap(() async {
                String str = await _selectTime(context, selectedAsarTime);

                setState(() {
                  selectedAsarTime = str;
                });
              }),
              16.height,
              WaktuSalat(
                name: "المغرب",
                time: selectedMaghrebTime,
                isCurrent: false,
              ).onTap(() async {
                String str = await _selectTime(context, selectedMaghrebTime);

                setState(() {
                  selectedMaghrebTime = str;
                });
              }),
              16.height,
              WaktuSalat(
                name: "العشا",
                time: selectedIshaTime,
                isCurrent: false,
              ).onTap(() async {
                String str = await _selectTime(context, selectedIshaTime);

                setState(() {
                  selectedIshaTime = str;
                });
              }),
              16.height,
              WaktuSalat(
                name: "الجمعه",
                time: selectedJummahTime,
                isCurrent: false,
              ).onTap(() async {
                String str = await _selectTime(context, selectedJummahTime);

                setState(() {
                  selectedJummahTime = str;
                });
              }),
              24.height,
              (selectedPosition == null)
                  ? Container()
                  : Container(
                      height: 200,
                      width: 100,
                      child: GoogleMap(
                        compassEnabled: false,
                        scrollGesturesEnabled: true,
                        tiltGesturesEnabled: false,
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        zoomGesturesEnabled: true,
                        mapToolbarEnabled: false,
                        rotateGesturesEnabled: false,
                        liteModeEnabled: false,
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                            target: LatLng(selectedPosition!.latitude,
                                selectedPosition!.longitude),
                            zoom: 17),
                        markers: Set.from(allMarkers),
                        onMapCreated: (GoogleMapController _con) {
                          mapController = _con;
                        },
                      ),
                    ).paddingAll(8),
              16.height,
              ElevatedButton(
                  onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return PlacePicker(
                              apiKey: AppThemes.googleMapApiKey,
                              initialPosition: selectedPosition == null
                                  ? kInitialPosition
                                  : new LatLng(selectedPosition!.latitude,
                                      selectedPosition!.longitude),
                              useCurrentLocation: false,
                              selectInitialPosition: true,

                              //usePlaceDetailSearch: true,
                              onPlacePicked: (result) {
                                selectedPlace = result;
                                Navigator.of(context).pop();
                                setState(() {
                                  print(
                                      "${selectedPlace!.geometry!.location.lat}  ${selectedPlace!.geometry!.location.lng}");
                                  selectedPosition = new GeoFirePoint(
                                      selectedPlace!.geometry!.location.lat,
                                      selectedPlace!.geometry!.location.lng);
                                  LatLng newlatlang = LatLng(
                                      selectedPlace!.geometry!.location.lat,
                                      selectedPlace!.geometry!.location.lng);

                                  MapsUtil.getMarker(
                                          latlng: LatLng(
                                              selectedPosition!.latitude,
                                              selectedPosition!.longitude))
                                      .then((marker) {
                                    allMarkers = [];
                                    allMarkers.add(marker);
                                    setState(() {});
                                  });

                                  mapController.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                          CameraPosition(
                                              target: newlatlang, zoom: 17)
                                          //17 is new zoom level
                                          ));
                                });
                              },
                              //forceSearchOnZoomChanged: true,
                              //automaticallyImplyAppBarLeading: false,
                              //autocompleteLanguage: "ko",
                              //region: 'au',
                              //selectInitialPosition: true,
                              // selectedPlaceWidgetBuilder: (_, selectedPlace, state, isSearchBarFocused) {
                              //   print("state: $state, isSearchBarFocused: $isSearchBarFocused");
                              //   return isSearchBarFocused
                              //       ? Container()
                              //       : FloatingCard(
                              //           bottomPosition: 0.0, // MediaQuery.of(context) will cause rebuild. See MediaQuery document for the information.
                              //           leftPosition: 0.0,
                              //           rightPosition: 0.0,
                              //           width: 500,
                              //           borderRadius: BorderRadius.circular(12.0),
                              //           child: state == SearchingState.Searching
                              //               ? Center(child: CircularProgressIndicator())
                              //               : RaisedButton(
                              //                   child: Text("Pick Here"),
                              //                   onPressed: () {
                              //                     // IMPORTANT: You MUST manage selectedPlace data yourself as using this build will not invoke onPlacePicker as
                              //                     //            this will override default 'Select here' Button.
                              //                     print("do something with [selectedPlace] data");
                              //                     Navigator.of(context).pop();
                              //                   },
                              //                 ),
                              //         );
                              // },
                              pinBuilder: (context, state) {
                                if (state == PinState.Idle) {
                                  return Icon(
                                    Icons.pin_drop_outlined,
                                    size: 36,
                                  );
                                } else {
                                  return Icon(Icons.pin_drop);
                                }
                              },
                            );
                          },
                        ),
                      ),
                  child: Text(selectedPosition != null
                      ? 'Change Location'
                      : 'Add Location'))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _displayEngnameDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.grey.shade900,
            // title: Text('English Name'),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    selectedEnName = value;
                  });
                },
                maxLines: 3,
                controller: _enNameController,
                style: Theme.of(context).textTheme.bodyText1,
                validator: (value) =>
                    value!.isEmpty ? "English name can't be empty" : null,
                // maxLines: 15,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.orangeAccent, width: 2)),
                  labelText: "English Name",
                  hintText: "English Name",
                  hintStyle: TextStyle(color: Colors.grey),
                  alignLabelWithHint: true,
                  contentPadding: new EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 10.0),
                ),
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: AppThemes.raisedButtonStyle,
                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Future<void> _displayUrdunameDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.grey.shade900,
            // title: Text('English Name'),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Directionality(
                textDirection: ui.TextDirection.rtl,
                child: TextFormField(
                  textAlign: TextAlign.right,
                  onChanged: (value) {
                    setState(() {
                      selectedUrduName = value;
                    });
                  },
                  maxLines: 3,
                  controller: _urduNameController,
                  style: Theme.of(context).textTheme.bodyText1,
                  validator: (value) =>
                      value!.isEmpty ? "Urdu name can't be empty" : null,
                  // maxLines: 15,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.orangeAccent, width: 2)),
                    labelText: "اردو نام",
                    alignLabelWithHint: true,
                    contentPadding: new EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 10.0),
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: AppThemes.raisedButtonStyle,
                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }
}

TimeOfDay stringToTimeOfDay(String tod) {
  final format = DateFormat.jm(); //"6:00 AM"
  return TimeOfDay.fromDateTime(format.parse(tod));
}
