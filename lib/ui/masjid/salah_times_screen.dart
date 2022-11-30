import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:location/location.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:noteapp/constants/app_themes.dart';
import 'package:noteapp/ui/masjid/waktuSalat.dart';

// enum Salahs { fajr, zuhr, asar, maghreb, isha }

final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

class SalahTimesScreen extends StatefulWidget {
  SalahTimesScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _SalahTimesScreenState createState() => _SalahTimesScreenState();
}

class _SalahTimesScreenState extends State<SalahTimesScreen> {
  // final location = new Location();
  String? locationError;
  PrayerTimes? prayerTimes;

  DateTime nextPrayerTime = DateTime.now();

  Timer? _timer;
  DateTime currentDateTime = DateTime.now();

  bool showPrayerTime = false;
  Position? currentPosition;

  String locationMessage = "";

  bool loading = false;
  bool loadingPrayers = false;

  bool hanfiCalculation = true;

  bool showEnglishName = true;
  @override
  void initState() {
    super.initState();
    this._timer = new Timer.periodic(Duration(seconds: 1), setTime);
    loadData();
  }

  void loadData() async {
    setState(() {
      loading = true;
      loadingPrayers = true;
    });
    await _getCurrentPosition();
    var nyParams = CalculationMethod.karachi.getParameters();

    setState(() {
      loading = false;

      if (currentPosition != null) {
        nyParams.madhab = hanfiCalculation ? Madhab.hanafi : Madhab.shafi;

        prayerTimes = PrayerTimes(
            // Coordinates(33.5834, 71.4332),
            Coordinates(currentPosition!.latitude, currentPosition!.longitude),
            DateComponents.from(DateTime.now()),
            nyParams);
      }

      loadingPrayers = false;
    });

    if (prayerTimes != null) {
      nextPrayerTime = prayerTimes!.timeForPrayer(prayerTimes!.nextPrayer())!;
    }
  }

  double timeToDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

  void setTime(Timer timer) {
    setState(() {
      currentDateTime = new DateTime.now();
    });
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return;
    }

    final position = await _geolocatorPlatform.getCurrentPosition();
    setState(() {
      currentPosition = position;
      print(currentPosition.toString());
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
        showPrayerTime = false;
      });
      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          locationMessage = AppThemes.kPermissionDeniedMessage;
          showPrayerTime = false;
        });

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        locationMessage = AppThemes.kPermissionDeniedForeverMessage;
        showPrayerTime = false;
      });
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            widget.title,
            textAlign: TextAlign.center,
          ),
        ),
      ),
      body: loading
          ? CircularProgressIndicator().center()
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
              : loadingPrayers
                  ? CircularProgressIndicator().center()
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          // SizedBox(
                          //   width: 150,
                          //   height: 150,
                          //   child: AnalogClock(
                          //     decoration: BoxDecoration(
                          //         border: Border.all(
                          //             width: 2.0, color: Colors.white),
                          //         color: Colors.transparent,
                          //         shape: BoxShape.circle),
                          //     width: 150.0,
                          //     isLive: false,
                          //     hourHandColor: Colors.white,
                          //     minuteHandColor: Colors.white,
                          //     showSecondHand: true,
                          //     digitalClockColor: Colors.white,
                          //     numberColor: Colors.white,
                          //     showNumbers: true,
                          //     textScaleFactor: 1.4,
                          //     showTicks: true,
                          //     showDigitalClock: true,
                          //     datetime: currentDateTime,
                          //     key: const GlobalObjectKey(3),
                          //   ),
                          // ),
                          16.height,
                          Builder(
                            builder: (BuildContext context) {
                              if (prayerTimes != null) {
                                return Column(
                                  children: [
                                    // Text(
                                    //   'Start Time',
                                    //   textAlign: TextAlign.center,
                                    //   style: TextStyle(
                                    //       fontWeight: FontWeight.normal,
                                    //       fontSize: 22),
                                    // ),
                                    32.height,
                                    SalatEntryTime(
                                      name: "Fajr",
                                      urdu_name: "الفجر",
                                      time: DateFormat.jm()
                                          .format(prayerTimes!.fajr),
                                      isCurrent: prayerTimes!.currentPrayer() ==
                                          Prayer.fajr,
                                      showEnglishName: showEnglishName,
                                    ),
                                    16.height,
                                    SalatEntryTime(
                                      name: "Sun Rise",
                                      urdu_name: "الطلوع",
                                      time: DateFormat.jm()
                                          .format(prayerTimes!.sunrise),
                                      isCurrent: false,
                                      showEnglishName: showEnglishName,
                                    ),
                                    16.height,
                                    SalatEntryTime(
                                      name: "Zuhr",
                                      urdu_name: "الظہر",
                                      time: DateFormat.jm()
                                          .format(prayerTimes!.dhuhr),
                                      isCurrent: prayerTimes!.currentPrayer() ==
                                          Prayer.dhuhr,
                                      showEnglishName: showEnglishName,
                                    ),
                                    16.height,
                                    SalatEntryTime(
                                      name: "Asar",
                                      urdu_name: "العصر",
                                      time: DateFormat.jm()
                                          .format(prayerTimes!.asr),
                                      isCurrent: prayerTimes!.currentPrayer() ==
                                          Prayer.asr,
                                      showEnglishName: showEnglishName,
                                    ),
                                    16.height,
                                    SalatEntryTime(
                                      name: "Maghreb",
                                      urdu_name: "المغرب",
                                      time: DateFormat.jm()
                                          .format(prayerTimes!.maghrib),
                                      isCurrent: prayerTimes!.currentPrayer() ==
                                          Prayer.maghrib,
                                      showEnglishName: showEnglishName,
                                    ),
                                    16.height,
                                    SalatEntryTime(
                                      name: "Isha",
                                      urdu_name: "العشا",
                                      time: DateFormat.jm()
                                          .format(prayerTimes!.isha),
                                      isCurrent: prayerTimes!.currentPrayer() ==
                                          Prayer.isha,
                                      showEnglishName: showEnglishName,
                                    ),
                                    64.height,
                                    FlutterSwitch(
                                      activeText: "English Names",
                                      inactiveText: "Urdu Names",
                                      value: showEnglishName,
                                      valueFontSize: 24.0,
                                      width: 220,
                                      borderRadius: 30.0,
                                      showOnOff: true,
                                      onToggle: (val) {
                                        setState(() {
                                          showEnglishName = val;
                                        });
                                      },
                                    ),

                                    64.height,
                                    FlutterSwitch(
                                      activeText: "Hanfi",
                                      inactiveText: "Shafi",
                                      value: hanfiCalculation,
                                      valueFontSize: 24.0,
                                      width: 220,
                                      borderRadius: 30.0,
                                      showOnOff: true,
                                      onToggle: (val) {
                                        setState(() {
                                          hanfiCalculation = val;
                                          loadData();
                                        });
                                      },
                                    ),
                                  ],
                                );
                              }
                              if (locationError != null) {
                                return Text(locationError ?? "No Error");
                              }
                              return Text('Waiting for Your Location...');
                            },
                          )
                        ],
                      ),
                    ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
