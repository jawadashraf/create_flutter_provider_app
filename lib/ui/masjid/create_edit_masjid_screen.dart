import 'package:adhan/adhan.dart' as Adhan;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:hijri/hijri_calendar.dart';
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
  String ishraqTime = "000";
  String chashtTime = "";
  String nisfNahaarTime = "";

  String timeLimitCurrentPrayer = "00:00";
  String timeToNextPrayer = "--";
  DateTime? nextPrayerTime = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  GeoPoint? selectedPosition;

  PickResult? selectedPlace;

  final kInitialPosition = LatLng(33.58757, 71.44239);

  var marqueeText = "...........................";

  Adhan.PrayerTimes? prayerTimes;

  Adhan.Prayer? nextPrayer;

  Adhan.Prayer? currentPrayer;

  var saharTime;

  var iftaar;

  bool get _hasChangedEnName => _masjid?.enName != selectedEnName;
  bool get _hasChangedUrduName => _masjid?.urduName != selectedUrduName;
  bool get _hasChangedFajrTime => _masjid?.fajrTime != selectedFajrTime;
  bool get _hasChangedZuhrTime => _masjid?.zuhrTime != selectedZuhrTime;
  bool get _hasChangedAsarTime => _masjid?.asarTime != selectedAsarTime;
  // bool get _hasChangedMaghrebTime =>
  //     _masjid?.maghrebTime != selectedMaghrebTime;
  bool get _hasChangedIshaTime => _masjid?.ishaTime != selectedIshaTime;
  bool get _hasChangedJummahTime => _masjid?.jummahTime != selectedJummahTime;
  // bool get _hasChangedPosition => _masjid?.position != selectedPosition;
  bool get _hasChangedPosition => _masjid?.coordinates != selectedPosition;

  bool get _hasChangedValue =>
      _hasChangedEnName ||
      _hasChangedUrduName ||
      _hasChangedFajrTime ||
      _hasChangedAsarTime ||
      _hasChangedZuhrTime ||
      // _hasChangedMaghrebTime ||
      _hasChangedIshaTime ||
      _hasChangedJummahTime ||
      _hasChangedPosition;

  DateFormat formatter = DateFormat('jm');

  String _groupValue = getStringAsync("masjidNameDisplay").isEmpty
      ? "None"
      : getStringAsync("masjidNameDisplay");

  List<String> _status = ["None", "English", "Urdu", "Both"];
  bool displayArabic = true;

  @override
  void initState() {
    super.initState();

    // Future.delayed(Duration.zero, () {
    //   this.loadData();
    // });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      this.loadData();
      this.loadPrayerTimes();
    });
  }

  void loadData() async {
    print("here");
    final Masjid? _masjidModel =
        ModalRoute.of(context)?.settings.arguments as Masjid?;

    _enNameController = TextEditingController(text: _masjid?.enName ?? "");
    _urduNameController = TextEditingController(text: _masjid?.urduName ?? "");

    if (_masjidModel != null) {
      _masjid = _masjidModel;
    } else {
      _groupValue = "Both";
    }

    _enNameController = TextEditingController(text: _masjid?.enName ?? "");
    _urduNameController = TextEditingController(text: _masjid?.urduName ?? "");

    selectedEnName = _masjid?.enName ?? "";
    selectedUrduName = _masjid?.urduName ?? "";

    selectedFajrTime = _masjid?.fajrTime ?? "00:00 AM";
    selectedZuhrTime = _masjid?.zuhrTime ?? "00:00 AM";
    selectedAsarTime = _masjid?.asarTime ?? "00:00 AM";
    // selectedMaghrebTime = _masjid?.maghrebTime ?? "00:00 AM";
    selectedJummahTime = _masjid?.jummahTime ?? "00:00 AM";
    selectedIshaTime = _masjid?.ishaTime ?? "00:00 AM";
    // selectedPosition = _masjid?.position;
    selectedPosition = _masjid?.coordinates;

    setState(() {});
    if (selectedPosition != null)
      MapsUtil.getMarker(
              latlng: LatLng(
                  selectedPosition!.latitude, selectedPosition!.longitude))
          .then((marker) {
        allMarkers.add(marker);
        setState(() {});
      });
  }

  int minutesBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  void loadPrayerTimes() async {
    if (selectedPosition == null) return;
    setState(() {
      marqueeText = "لآ اِلَهَ اِلّا اللّهُ مُحَمَّدٌ رَسُوُل اللّه ";
    });

    var nyParams = Adhan.CalculationMethod.karachi.getParameters();

    setState(() {
      // loading = false;

      prayerTimes = Adhan.PrayerTimes(
          // Coordinates(33.5834, 71.4332),
          Adhan.Coordinates(
              selectedPosition!.latitude, selectedPosition!.longitude),
          Adhan.DateComponents.from(DateTime.now()),
          nyParams);

      if (prayerTimes != null) {
        nextPrayerTime = prayerTimes!.timeForPrayer(prayerTimes!.nextPrayer());

        selectedMaghrebTime = formatter
            .format(prayerTimes!.timeForPrayer(Adhan.Prayer.maghrib)!)
            .toString();

        timeLimitCurrentPrayer = nextPrayerTime != null
            ? formatter.format(nextPrayerTime!).toString()
            : "00:00";

        currentPrayer = prayerTimes!.currentPrayer();
        nextPrayer = prayerTimes!.nextPrayer();

        timeToNextPrayer = getTimeToNextPrayer();

        print("Time for next prayer $timeLimitCurrentPrayer");

        ishraqTime = formatter
            .format(prayerTimes!.sunrise.add(Duration(minutes: 15)))
            .toString()
            .replaceAll('AM', '')
            .replaceAll('PM', '');

        var milliSeconds = prayerTimes!.maghrib
                .difference(prayerTimes!.sunrise)
                .inMilliseconds /
            4;
        chashtTime = formatter
            .format(prayerTimes!.sunrise
                .add(Duration(milliseconds: milliSeconds.round())))
            .toString()
            .replaceAll('AM', '')
            .replaceAll('PM', '');

        nisfNahaarTime = formatter
            .format(prayerTimes!.dhuhr.add(Duration(minutes: -15)))
            .toString()
            .replaceAll('AM', '')
            .replaceAll('PM', '');

        saharTime = formatter
            .format(prayerTimes!.fajr.add(Duration(minutes: -5)))
            .toString()
            .replaceAll('AM', '')
            .replaceAll('PM', '');

        iftaar = formatter
            .format(prayerTimes!.maghrib)
            .toString()
            .replaceAll('AM', '')
            .replaceAll('PM', '');

        var formattedDtate = DateFormat.yMMMEd('ur_PK');
        var dateString = formattedDtate.format(DateTime.now()) + "            ";
        print(dateString);

        HijriCalendar.setLocal('en');
        var _todayHijriEnglish = HijriCalendar.now();

        String hijriEngYear = _todayHijriEnglish.hYear.toString();

        String hijriEngDay = _todayHijriEnglish.hDay.toString();

        HijriCalendar.setLocal('ar');
        var _todayHijriArabic = HijriCalendar.now();

        String today = "";
        String todayHijriText = hijriEngDay +
            " " +
            _todayHijriArabic.toFormat("MMMM") +
            " " +
            hijriEngYear +
            "\u202C" +
            "            ";

        String ishraqText = "اشراق :" + "\u202C" + ishraqTime + "            ";
        String chashtText = "چاشت :" + "\u202C" + chashtTime + "           ";
        String nisfNahaarText =
            "نصف النہار:" + "\u202C" + nisfNahaarTime + "            ";

        marqueeText = dateString +
            todayHijriText +
            ishraqText +
            chashtText +
            nisfNahaarText;

        print(marqueeText);
      }
      // loadingPrayers = false;
    });
  }

  @override
  void didChangeDependencies() {
    print("Dependcy Change Called");
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    void handleClick(String value) {
      switch (value) {
        case 'English Name':
          setState(() {
            _groupValue = "English";
            setValue("masjidNameDisplay", _groupValue);
          });
          break;
        case 'Urdu Name':
          setState(() {
            _groupValue = "Urdu";
            setValue("masjidNameDisplay", _groupValue);
          });
          break;
        case 'Both Names':
          setState(() {
            _groupValue = "Both";
            setValue("masjidNameDisplay", _groupValue);
          });
          break;
        case 'No Names':
          setState(() {
            _groupValue = "None";
            setValue("masjidNameDisplay", _groupValue);
          });
          break;
        case 'Urdu Prayer':
          setState(() {
            displayArabic = true;
          });
          break;
        case 'English Prayer':
          setState(() {
            displayArabic = false;
          });
          break;
      }
    }

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
              child: Text("Save")),
          PopupMenuButton<String>(
            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {
                'English Name',
                'Urdu Name',
                'Both Names',
                'No Names',
                'Urdu Prayer',
                'English Prayer'
              }.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Center(
        child: _buildForm(context),
      ),
    );
  }

  void saveMasjid(BuildContext context) async {
    if (selectedEnName.isEmpty) {
      toast("English Name cannot be empty", bgColor: Colors.redAccent);
      return;
    }

    if (selectedUrduName.isEmpty) {
      toast("Urdu Name cannot be empty", bgColor: Colors.redAccent);
      return;
    }

    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final firestoreDatabase =
          Provider.of<FirestoreDatabase>(context, listen: false);

      List<String>? myMasjids = getStringListAsync('myMasjids');

      var masjidId = _masjid?.id ?? Uuid().v1();

      if (myMasjids == null || myMasjids.isEmpty) {
        myMasjids = [];
        myMasjids.add(masjidId);
      } else {
        if (!myMasjids.contains(masjidId)) myMasjids.add(masjidId);
      }
      await setValue("myMasjids", myMasjids);

      firestoreDatabase
          .setMasjid(Masjid(
              id: masjidId,
              enName: selectedEnName,
              urduName: selectedUrduName,
              address: "Address",
              city: "Cityaaa",
              fajrTime: selectedFajrTime,
              asarTime: selectedAsarTime,
              zuhrTime: selectedZuhrTime,
              maghrebTime: selectedMaghrebTime,
              ishaTime: selectedIshaTime,
              jummahTime: selectedJummahTime,
              // position: selectedPosition,
              coordinates: selectedPosition,
              createdBy: firestoreDatabase.uid))
          .then((value) {
        firestoreDatabase.setMyMasjid(masjidId).then((value) {
          toast("Masjid saved successfully", bgColor: Colors.green);
          Navigator.of(context).pop();
        });
      });

      // final Masjid? _masjidModel =
      //     ModalRoute.of(context)?.settings.arguments as Masjid?;

      // Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _enNameController.dispose();
    _urduNameController.dispose();
    super.dispose();
  }

  String getTimeToNextPrayer() {
    String nextJamaatTime = "00:00";

    if (prayerTimes == null) return nextJamaatTime;

    switch (this.prayerTimes!.nextPrayer()) {
      case Adhan.Prayer.fajr:
        nextJamaatTime = selectedFajrTime;
        break;
      case Adhan.Prayer.dhuhr:
        nextJamaatTime = selectedZuhrTime;
        break;
      case Adhan.Prayer.asr:
        nextJamaatTime = selectedAsarTime;
        break;
      case Adhan.Prayer.maghrib:
        nextJamaatTime = selectedMaghrebTime;
        break;
      case Adhan.Prayer.isha:
        nextJamaatTime = selectedIshaTime;
        break;
      default:
        return nextJamaatTime;
    }

    // if (nextJamaatTime == "00") return "--:--";

    TimeOfDay _nextTime = stringToTimeOfDay(nextJamaatTime);
    TimeOfDay _nowTime = TimeOfDay.now();

    double _doubleNextTime =
        _nextTime.hour.toDouble() + (_nextTime.minute.toDouble() / 60);
    double _doubleNowTime =
        _nowTime.hour.toDouble() + (_nowTime.minute.toDouble() / 60);

    double _timeDiff = _doubleNextTime - _doubleNowTime;

    int _hr = _timeDiff.truncate();
    int _minute = ((_timeDiff - _timeDiff.truncate()) * 60).truncate();

    print('$_hr Hour and also $_minute min');

    return "$_hr:$_minute";
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
      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              (_groupValue == "English" || _groupValue == "Both")
                  ? Container(
                      decoration: AppThemes.myLeftBoxDecoration(),
                      child: Text(
                        selectedEnName.isEmpty
                            ? "English Name"
                            : selectedEnName,
                        style: TextStyle(fontSize: 24.0),
                      ).center().onTap(() => _displayEngnameDialog(context)),
                    )
                  : Container(),
              (_groupValue == "English" || _groupValue == "Both")
                  ? 24.height
                  : Container(),
              (_groupValue == "Urdu" || _groupValue == "Both")
                  ? Container(
                      decoration: AppThemes.myRightBoxDecoration(),
                      child: Text(
                              selectedUrduName.isEmpty
                                  ? "Urdu Name"
                                  : selectedUrduName,
                              style: TextStyle(fontSize: 24.0))
                          .center()
                          .onTap(() => _displayUrdunameDialog(context)),
                    )
                  : Container(),
              // RadioGroup<String>.builder(
              //   direction: Axis.horizontal,
              //   groupValue: _groupValue,
              //   horizontalAlignment: MainAxisAlignment.spaceAround,
              //   onChanged: (value) => setState(() {
              //     _groupValue = value!;
              //     // displayArabic = (_groupValue == "None" ||
              //     //         _groupValue == "Urdu" ||
              //     //         _groupValue == "Both")
              //     //     ? true
              //     //     : false;
              //   }),
              //   items: _status,
              //   textStyle: TextStyle(fontSize: 15, color: Colors.green),
              //   itemBuilder: (item) => RadioButtonBuilder(
              //     item,
              //   ),
              // ),
              // 4.height,
              _masjid == null
                  ? Container()
                  : MarqueeWidget(marqueeText: marqueeText),
              // 10.height,
              TimeToNextJamaat(
                timeLimitCurrentPrayer: timeLimitCurrentPrayer,
                timeToNextJamaat: getTimeToNextPrayer(),
              ),
              // 10.height,
              SaharIftaarTime(
                sahar: saharTime ?? "00",
                iftaar: iftaar ?? "00",
              ),
              // 10.height,
              WaktuSalat(
                name: displayArabic ? "الفجر" : "Fajr",
                time: selectedFajrTime,
                isCurrent: prayerTimes != null &&
                    Adhan.Prayer.fajr == prayerTimes!.currentPrayer(),
                prayerIndex: Adhan.Prayer.fajr.index,
              ).onTap(() async {
                String str = await _selectTime(context, selectedFajrTime);

                setState(() {
                  selectedFajrTime = str;
                });
              }),
              8.height,
              WaktuSalat(
                name: displayArabic ? "الظہر" : "Zuhr",
                time: selectedZuhrTime,
                isCurrent: prayerTimes != null &&
                    Adhan.Prayer.dhuhr == prayerTimes!.currentPrayer(),
                prayerIndex: Adhan.Prayer.dhuhr.index,
              ).onTap(() async {
                String str = await _selectTime(context, selectedZuhrTime);

                setState(() {
                  selectedZuhrTime = str;
                });
              }),
              8.height,
              WaktuSalat(
                name: displayArabic ? "العصر" : "Asr",
                time: selectedAsarTime,
                isCurrent: prayerTimes != null &&
                    Adhan.Prayer.asr == prayerTimes!.currentPrayer(),
                prayerIndex: Adhan.Prayer.asr.index,
              ).onTap(() async {
                String str = await _selectTime(context, selectedAsarTime);

                setState(() {
                  selectedAsarTime = str;
                });
              }),
              8.height,
              WaktuSalat(
                name: displayArabic ? "المغرب" : "Maghrib",
                time: selectedMaghrebTime,
                isCurrent: prayerTimes != null &&
                    Adhan.Prayer.maghrib == prayerTimes!.currentPrayer(),
                prayerIndex: Adhan.Prayer.maghrib.index,
              ).onTap(() async {
                String str = await _selectTime(context, selectedMaghrebTime);

                setState(() {
                  selectedMaghrebTime = str;
                });
              }),
              8.height,
              WaktuSalat(
                name: displayArabic ? "العشا" : "Isha",
                time: selectedIshaTime,
                isCurrent: prayerTimes != null &&
                    Adhan.Prayer.isha == prayerTimes!.currentPrayer(),
                prayerIndex: Adhan.Prayer.isha.index,
              ).onTap(() async {
                String str = await _selectTime(context, selectedIshaTime);

                setState(() {
                  selectedIshaTime = str;
                });
              }),
              8.height,
              WaktuSalat(
                name: displayArabic ? "الجمعه" : "Jummah",
                time: selectedJummahTime,
                isCurrent: false,
                prayerIndex: 6,
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
                                  selectedPosition = new GeoPoint(
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
                              //               : ElevatedButton(
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
                onSaved: (newValue) => selectedEnName = newValue.toString(),
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
                style: AppThemes.ElevatedButtonStyle,
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
                style: AppThemes.ElevatedButtonStyle,
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

class TimeToNextJamaat extends StatelessWidget {
  const TimeToNextJamaat({
    Key? key,
    required this.timeLimitCurrentPrayer,
    required this.timeToNextJamaat,
  }) : super(key: key);

  final String timeLimitCurrentPrayer;
  final String timeToNextJamaat;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Text(
              "انتہائے وقت: ${timeLimitCurrentPrayer.replaceAll("AM", "").replaceAll("PM", "")}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                  backgroundColor: Colors.black)),
          Spacer(),
          Text(" بقیہ وقت برائے جماعت: $timeToNextJamaat",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                  backgroundColor: Colors.black))
        ],
      ),
    );
  }
}

class SaharIftaarTime extends StatelessWidget {
  const SaharIftaarTime({
    Key? key,
    required this.sahar,
    required this.iftaar,
  }) : super(key: key);

  final String sahar;
  final String iftaar;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Text(
            " افطار: $iftaar",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
                backgroundColor: Colors.black),
          ),
          Spacer(),
          Text(
            "سحر: ${sahar.replaceAll("AM", "").replaceAll("PM", "")}",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
                backgroundColor: Colors.black),
          ),
        ],
      ),
    );
  }
}

class MarqueeWidget extends StatelessWidget {
  const MarqueeWidget({
    Key? key,
    required this.marqueeText,
  }) : super(key: key);

  final String marqueeText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      constraints: BoxConstraints(
        minHeight: 60,
        minWidth: 200,
        maxHeight: 60,
        maxWidth: 200,
      ),
      child: Marquee.Marquee(
        text: marqueeText,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.green,
            backgroundColor: Colors.black),
        scrollAxis: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        blankSpace: 200.0,
        velocity: 50.0,
        pauseAfterRound: Duration(seconds: 1),
        startPadding: 100.0,
        accelerationDuration: Duration(seconds: 1),
        accelerationCurve: Curves.linear,
        decelerationDuration: Duration(milliseconds: 500),
        decelerationCurve: Curves.easeOut,
        textDirection: ui.TextDirection.rtl,
      ),
    );
  }
}

TimeOfDay stringToTimeOfDay(String tod) {
  print(tod);
  final format = DateFormat.jm(); //"6:00 AM"
  return TimeOfDay.fromDateTime(format.parse(tod));
}
