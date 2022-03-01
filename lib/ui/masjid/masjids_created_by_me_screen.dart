import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:noteapp/models/masjid_model.dart';
import 'package:noteapp/models/user_model.dart';
import 'package:noteapp/providers/auth_provider.dart';
import 'package:noteapp/routes.dart';
import 'package:noteapp/services/firestore_database.dart';
import 'package:noteapp/ui/masjid/masjid_list_item.dart';
import 'package:noteapp/ui/masjid/nearby_masjids.dart';
import 'package:noteapp/ui/masjid/salah_times_screen.dart';
import 'package:noteapp/ui/qiblah/qiblah_main.dart';
import 'package:noteapp/ui/todo/empty_content.dart';
import 'package:provider/provider.dart';
import 'package:nb_utils/nb_utils.dart';

class MasjidsCreatedByMeScreen extends StatefulWidget {
  @override
  _MasjidsCreatedByMeScreenState createState() =>
      _MasjidsCreatedByMeScreenState();
}

class _MasjidsCreatedByMeScreenState extends State<MasjidsCreatedByMeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String>? myMasjidsIds;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserModel? _user;
    final authProvider = Provider.of<AuthProvider>(context);
    final firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);

    Stream<List<Masjid>> myStream =
        firestoreDatabase.masjidsCreatedByMeStream();

    FutureOr onGoBack(dynamic value) {
      print("Go Back Called");
      setState(() {});
    }

    Widget _buildBodySection(BuildContext context) {
      final firestoreDatabase =
          Provider.of<FirestoreDatabase>(context, listen: false);

      return StreamBuilder(
          stream: myStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Masjid> masjids = snapshot.data as List<Masjid>;
              if (masjids.isNotEmpty) {
                return ListView.separated(
                  itemCount: masjids.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: MasjidListItem(
                          enName: masjids[index].enName,
                          urduName: masjids[index].urduName),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                            Routes.create_edit_masjid,
                            arguments: masjids[index]);
                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(height: 0.5);
                  },
                );
              } else {
                return EmptyContentWidget(
                  title: "Nothing here",
                  message: "Add a new masjid",
                  key: Key('EmptyContentWidget'),
                );
              }
            } else if (snapshot.hasError) {
              return EmptyContentWidget(
                title: "Something went wrong",
                message:
                    "Can't load data right now. " + snapshot.error.toString(),
                key: Key('EmptyContentWidget'),
              );
            }
            return Center(child: CircularProgressIndicator());
          });
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Masjids Entered by Me"),
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {});
            },
            child: Icon(
              Icons.refresh,
              size: 26.0,
            ),
          ).paddingRight(20)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .pushNamed(
                Routes.create_edit_masjid,
              )
              .then(onGoBack);
        },
      ),
      body: WillPopScope(
          onWillPop: () async => true, child: _buildBodySection(context)),
    );
  }
}
