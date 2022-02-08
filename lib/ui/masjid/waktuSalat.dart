import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:noteapp/constants/app_font_family.dart';
import 'package:noteapp/constants/app_themes.dart';

class WaktuSalat extends StatelessWidget {
  final name;
  final time;
  final isCurrent;
  WaktuSalat({this.name, this.time, this.isCurrent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppThemes.color3, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              GlowText(
                time,
                blurRadius: 10,
                style: TextStyle(
                    color: isCurrent
                        ? AppThemes.clockColorGreen
                        : AppThemes.clockColorRed,
                    fontWeight: FontWeight.normal,
                    fontFamily: AppFontFamily.digital,
                    fontSize: 32),
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
    );
  }
}

class SalatEntryTime extends StatelessWidget {
  final name;
  final urdu_name;
  final time;
  final isCurrent;
  SalatEntryTime(
      {this.name, this.time, this.isCurrent = false, this.urdu_name});

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
          Expanded(
            child: Text(
              name,
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
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
          Expanded(
            child: Text(
              urdu_name,
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          )
        ],
      ),
    );
  }
}
