import 'package:geoflutterfire/geoflutterfire.dart';

class Masjid {
  final String id;
  final String enName;
  final String urduName;
  final String? address;
  final String? city;
  final String fajrTime;
  final String zuhrTime;
  final String asarTime;
  final String maghrebTime;
  final String ishaTime;
  final String jummahTime;
  final GeoFirePoint? position;
  final String createdBy;

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
        id: documentId,
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
}
