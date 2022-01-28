import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
// import 'package:location/location.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:noteapp/ui/masjid/waktuSalat.dart';
import 'package:analog_clock/analog_clock.dart';

// enum Salahs { fajr, zuhr, asar, maghreb, isha }

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

  @override
  void initState() {
    super.initState();
    this._timer = new Timer.periodic(Duration(seconds: 1), setTime);
    loadData();
  }

  void loadData() async {
    // var locationData = await getLocationData();
    // print("Location found");

    // if (locationData != null) {
    //   print("Location foiund");
    // } else
    //   print("Not found");

    setState(() {
      prayerTimes = PrayerTimes(
          Coordinates(33.5834, 71.4332),
          DateComponents.from(DateTime.now()),
          CalculationMethod.karachi.getParameters());
    });

    if (prayerTimes != null) {
      nextPrayerTime = prayerTimes!.timeForPrayer(prayerTimes!.nextPrayer())!;
    }
    // if (!mounted) {
    //   return;
    // }
    // if (locationData != null) {
    //   setState(() {
    //     prayerTimes = PrayerTimes(
    //         Coordinates(locationData.latitude!, locationData.longitude!),
    //         DateComponents.from(DateTime.now()),
    //         CalculationMethod.karachi.getParameters());
    //   });
    // } else {
    //   setState(() {
    //     locationError = "Couldn't Get Your Location!";
    //   });
    // }
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

  // Future<LocationData?> getLocationData() async {
  //   print("GetLocation Called");
  //   var _serviceEnabled = await location.serviceEnabled();
  //   if (!_serviceEnabled) {
  //     _serviceEnabled = await location.requestService();
  //     if (!_serviceEnabled) {
  //       return null;
  //     }
  //   } else
  //     print("Service Enabled");

  //   var _permissionGranted = await location.hasPermission();
  //   if (_permissionGranted == PermissionStatus.denied) {
  //     _permissionGranted = await location.requestPermission();
  //     if (_permissionGranted != PermissionStatus.granted) {
  //       return null;
  //     }
  //   } else
  //     print("Perm Granted");
  //   var locationData = await location.getLocation();
  //   print(locationData.latitude.toString() + "asdasd");
  //   return locationData;
  // }

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
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              width: 150,
              height: 150,
              child: AnalogClock(
                decoration: BoxDecoration(
                    border: Border.all(width: 2.0, color: Colors.white),
                    color: Colors.transparent,
                    shape: BoxShape.circle),
                width: 150.0,
                isLive: false,
                hourHandColor: Colors.white,
                minuteHandColor: Colors.white,
                showSecondHand: true,
                digitalClockColor: Colors.white,
                numberColor: Colors.white,
                showNumbers: true,
                textScaleFactor: 1.4,
                showTicks: true,
                showDigitalClock: true,
                datetime: currentDateTime,
                key: const GlobalObjectKey(3),
              ),
            ),
            16.height,
            Builder(
              builder: (BuildContext context) {
                if (prayerTimes != null) {
                  return Column(
                    children: [
                      Text(
                        'Start Time',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 22),
                      ),
                      16.height,
                      SalatEntryTime(
                        name: "Fajr",
                        urdu_name: "الفجر",
                        time: DateFormat.jm().format(prayerTimes!.fajr),
                        isCurrent: prayerTimes!.currentPrayer() == Prayer.fajr,
                      ),
                      16.height,
                      SalatEntryTime(
                        name: "Sun Rise",
                        urdu_name: "الطلوع",
                        time: DateFormat.jm().format(prayerTimes!.sunrise),
                        isCurrent: false,
                      ),
                      16.height,
                      SalatEntryTime(
                        name: "Zuhr",
                        urdu_name: "الظہر",
                        time: DateFormat.jm().format(prayerTimes!.dhuhr),
                        isCurrent: prayerTimes!.currentPrayer() == Prayer.dhuhr,
                      ),
                      16.height,
                      SalatEntryTime(
                        name: "Asar",
                        urdu_name: "العصر",
                        time: DateFormat.jm().format(prayerTimes!.asr),
                        isCurrent: prayerTimes!.currentPrayer() == Prayer.asr,
                      ),
                      16.height,
                      SalatEntryTime(
                        name: "Maghreb",
                        urdu_name: "المغرب",
                        time: DateFormat.jm().format(prayerTimes!.maghrib),
                        isCurrent:
                            prayerTimes!.currentPrayer() == Prayer.maghrib,
                      ),
                      16.height,
                      SalatEntryTime(
                        name: "Isha",
                        urdu_name: "العشا",
                        time: DateFormat.jm().format(prayerTimes!.isha),
                        isCurrent: prayerTimes!.currentPrayer() == Prayer.isha,
                      ),
                      // 16.height,
                      // prayerTimes!.timeForPrayer(prayerTimes!.nextPrayer()) ==
                      //         null
                      //     ? Container()
                      //     : SalatEntryTime(
                      //         name: " ",
                      //         urdu_name: " ",
                      //         time: prayerTimes!
                      //             .timeForPrayer(prayerTimes!.nextPrayer())
                      //             .toString(),
                      //         isCurrent: false,
                      //       ),
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
