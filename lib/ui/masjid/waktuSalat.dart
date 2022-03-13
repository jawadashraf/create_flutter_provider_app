import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:noteapp/constants/app_font_family.dart';
import 'package:noteapp/constants/app_themes.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../main.dart';
import 'create_edit_masjid_screen.dart';

class WaktuSalat extends StatelessWidget {
  final name;
  final time;
  final isCurrent;
  final prayerIndex;
  WaktuSalat({this.name, this.time, this.isCurrent = false, this.prayerIndex});

  @override
  Widget build(BuildContext context) {
    Future<void> _checkPendingNotificationRequests() async {
      final List<PendingNotificationRequest> pendingNotificationRequests =
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          content:
              Text('${pendingNotificationRequests.length} pending notification '
                  'requests'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }

    return Slidable(
        // Specify a key if the Slidable is dismissible.
        key: ValueKey(prayerIndex),

        // The start action pane is the one at the left or the top side.
        startActionPane: ActionPane(
          // A motion is a widget used to control how the pane animates.
          motion: const ScrollMotion(),

          // All actions are defined in the children parameter.
          children: [
            // A SlidableAction can have an icon and/or a label.

            SlidableAction(
              onPressed: (context) async {
                _scheduleDailyNotification(prayerIndex, time, "Title: $name",
                    "Body", "chanelId:$name", "channel name", "description");

                // _checkPendingNotificationRequests();
              },
              backgroundColor: Color(0xFF7BC043),
              foregroundColor: Colors.white,
              icon: Icons.alarm_add,
              label: 'Alarm',
            ),
          ],
        ),

        // The child of the Slidable is what the user sees when the
        // component is not dragged.
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 0, 16, 12),
          decoration: BoxDecoration(
              color: AppThemes.color3, borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  GlowText(
                    time.toString().replaceAll('AM', '').replaceAll('PM', ''),
                    blurRadius: 10,
                    style: TextStyle(
                        color: isCurrent
                            ? AppThemes.clockColorGreen
                            : AppThemes.clockColorRed,
                        fontWeight: FontWeight.normal,
                        fontFamily: AppFontFamily.digital,
                        fontSize: 48),
                  ),
                  // SizedBox(
                  //   width: 10,
                  // ),
                  // Icon(Icons.alarm,
                  //     color: isCurrent ? clockColorGreen : clockColorRed)
                ],
              ),
              // Text(
              //   name,
              //   style: TextStyle(
              //       color: isCurrent ? clockColorGreen : clockColorRed,
              //       fontWeight: FontWeight.normal,
              //       fontSize: 28),
              // ),
              Text(
                name,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  // color: isCurrent
                  //     ? AppThemes.clockColorGreen
                  //     : AppThemes.clockColorRed,
                ),
              )
            ],
          ),
        ));
  }
}

Future<void> _scheduleDailyNotification(
    int prayerIndex,
    String currentTimeInString,
    String title,
    String body,
    String channelId,
    String channelName,
    String description) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
      prayerIndex,
      title,
      body,
      _nextInstanceOfJamaatTime(currentTimeInString),
      NotificationDetails(
        android: AndroidNotificationDetails(channelId, channelName,
            channelDescription: description),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time);
}

tz.TZDateTime _nextInstanceOfJamaatTime(String currentTimeInString) {
  TimeOfDay _currentTime = stringToTimeOfDay(currentTimeInString);

  TimeOfDay notiTime = _currentTime.plusMinutes(-15);

  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, notiTime.hour, notiTime.minute);

  print(scheduledDate);
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}

extension TimeOfDayExtension on TimeOfDay {
  // Ported from org.threeten.bp;
  TimeOfDay plusMinutes(int minutes) {
    if (minutes == 0) {
      return this;
    } else {
      int mofd = this.hour * 60 + this.minute;
      int newMofd = ((minutes % 1440) + mofd + 1440) % 1440;
      if (mofd == newMofd) {
        return this;
      } else {
        int newHour = newMofd ~/ 60;
        int newMinute = newMofd % 60;
        return TimeOfDay(hour: newHour, minute: newMinute);
      }
    }
  }
}

class SalatEntryTime extends StatelessWidget {
  final name;
  final urdu_name;
  final time;
  final isCurrent;
  final showEnglishName;
  SalatEntryTime(
      {this.name,
      this.time,
      this.isCurrent = false,
      this.urdu_name,
      this.showEnglishName = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
      // decoration: BoxDecoration(
      //     color: AppThemes.color3, borderRadius: BorderRadius.circular(10)),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          !showEnglishName
              ? Container()
              : Expanded(
                  child: Text(
                    name,
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
                  ),
                ),
          Expanded(
            child: Text(
              time,
              // blurRadius: 5,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 42,
                  fontFamily: AppFontFamily.digital,
                  color: isCurrent
                      ? AppThemes.clockColorGreen
                      : AppThemes.clockColorRed),
            ),
          ),
          showEnglishName
              ? Container()
              : Expanded(
                  child: Text(
                    urdu_name,
                    textAlign: TextAlign.right,
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
                  ),
                )
        ],
      ),
    );
  }
}
