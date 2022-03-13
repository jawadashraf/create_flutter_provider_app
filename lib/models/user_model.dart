import 'package:noteapp/models/masjid_model.dart';

class UserModel {
  String uid;
  String? email;
  String? displayName;
  String? phoneNumber;
  String? photoUrl;
  bool? isAnonymous;
  List<Masjid>? myMasjids;
  String? defaultMasjidId;

  UserModel(
      {required this.uid,
      this.email,
      this.displayName,
      this.phoneNumber,
      this.photoUrl,
      this.isAnonymous,
      this.myMasjids,
      this.defaultMasjidId});
}
