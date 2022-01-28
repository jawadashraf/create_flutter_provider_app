import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:noteapp/constants/app_themes.dart';

class MasjidListItem extends StatelessWidget {
  final enName;
  final urduName;
  MasjidListItem({this.enName, this.urduName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppThemes.color3, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Text(
              enName,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 16),
            ),
          ),
          // Text(
          //   name,
          //   style: TextStyle(
          //       color: isCurrent ? clockColorGreen : clockColorRed,
          //       fontWeight: FontWeight.normal,
          //       fontSize: 28),
          // ),
          Flexible(
            child: Text(
              urduName,
              textAlign: TextAlign.right,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
