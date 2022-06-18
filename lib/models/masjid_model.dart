import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class Masjid {
  String id;
  String enName;
  String urduName;
  String? address;
  String? city;
  String fajrTime;
  String zuhrTime;
  String asarTime;
  String maghrebTime;
  String ishaTime;
  String jummahTime;
  GeoFirePoint? position;
  String createdBy;

  Masjid(
      {required this.id,
      required this.enName,
      required this.urduName,
      this.address,
      this.city,
      required this.fajrTime,
      required this.zuhrTime,
      required this.asarTime,
      required this.maghrebTime,
      required this.ishaTime,
      required this.jummahTime,
      this.position,
      required this.createdBy});

  factory Masjid.fromMap(Map<String, dynamic> data, String documentId) {
    String enName = data['enName'];
    String urduName = data['urduName'];
    String? address = data['address'];
    String? city = data['city'];
    String zuhrTime = data['zuhrTime'];
    //TimeOfDay(
    // hour: int.parse(data['zuhrTime'].split(":")[0]),
    // minute: int.parse(data['zuhrTime'].split(":")[1]));
    String fajrTime = data['fajrTime'];
    // TimeOfDay(
    //     hour: int.parse(data['fajrTime'].split(":")[0]),
    //     minute: int.parse(data['fajrTime'].split(":")[1]));
    String asarTime = data['asarTime'];
    // TimeOfDay(
    //     hour: int.parse(data['asarTime'].split(":")[0]),
    //     minute: int.parse(data['asarTime'].split(":")[1]));
    String maghrebTime = data['maghrebTime'];
    // TimeOfDay(
    //     hour: int.parse(data['maghrebTime'].split(":")[0]),
    //     minute: int.parse(data['maghrebTime'].split(":")[1]));
    String ishaTime = data['ishaTime'];
    // TimeOfDay(
    //     hour: int.parse(data['ishaTime'].split(":")[0]),
    //     minute: int.parse(data['ishaTime'].split(":")[1]));
    String jummahTime = data['jummahTime'];
    // TimeOfDay(
    //     hour: int.parse(data['jummahTime'].split(":")[0]),
    //     minute: int.parse(data['jummahTime'].split(":")[1]));
    String createdBy = data['createdBy'];

    GeoFirePoint? position = data["position"] != null
        ? GeoFirePoint(data["position"]["geopoint"].latitude,
            data["position"]["geopoint"].longitude)
        : null;

    return Masjid(
        id: documentId.isEmpty ? data['id'] : documentId,
        enName: enName,
        urduName: urduName,
        address: address,
        city: city,
        fajrTime: fajrTime,
        zuhrTime: zuhrTime,
        asarTime: asarTime,
        maghrebTime: maghrebTime,
        ishaTime: ishaTime,
        jummahTime: jummahTime,
        position: position,
        createdBy: createdBy);
  }

  Map<String, dynamic> toMap() {
    return {
      'enName': enName,
      'urduName': urduName,
      'address': address,
      'city': city,
      'fajrTime': fajrTime,
      'zuhrTime': zuhrTime,
      'asarTime': asarTime,
      'maghrebTime': maghrebTime,
      'ishaTime': ishaTime,
      'jummahTime': jummahTime,
      'position': position?.data,
      'createdBy': createdBy
    };
  }

  List<Masjid> dataListFromSnapshot(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((snapshot) {
      final Map<String, dynamic> dataMap =
          snapshot.data() as Map<String, dynamic>;

      return Masjid(
        enName: dataMap['enName'],
        urduName: dataMap['urduName'],
        asarTime: '',
        createdBy: '',
        fajrTime: '',
        id: '',
        ishaTime: '',
        jummahTime: '',
        maghrebTime: '',
        zuhrTime: '',
      );
    }).toList();
  }

  // static String encode(List<Masjid> masjids) => json.encode(
  //       masjids
  //           .map<Map<String, dynamic>>(
  //               (masjid) => Masjid.toMapWithModel(masjid))
  //           .toList(),
  //     );

  // static List<Masjid> decode(String masjids) =>
  //     (json.decode(masjids) as List<dynamic>)
  //         .map<Masjid>((item) => Masjid.fromMap(item, ""))
  //         .toList();
}
