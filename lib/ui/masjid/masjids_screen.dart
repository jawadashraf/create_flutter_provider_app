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
import 'package:noteapp/ui/masjid/masjids_created_by_me_screen.dart';
import 'package:noteapp/ui/masjid/nearby_masjids.dart';
import 'package:noteapp/ui/masjid/salah_times_screen.dart';
import 'package:noteapp/ui/qiblah/qiblah_main.dart';
import 'package:noteapp/ui/todo/empty_content.dart';
import 'package:provider/provider.dart';
import 'package:nb_utils/nb_utils.dart';

class MasjidsScreen extends StatefulWidget {
  @override
  _MasjidsScreenState createState() => _MasjidsScreenState();
}

class _MasjidsScreenState extends State<MasjidsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String>? myMasjidsIds;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    loadMyMasjidsIds();
  }

  void loadMyMasjidsIds() async {
    // getStringListAsync('myMasjids');
    myMasjidsIds = getStringListAsync('myMasjids');
  }

  @override
  Widget build(BuildContext context) {
    UserModel? _user;
    final authProvider = Provider.of<AuthProvider>(context);
    final firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);

    Stream<List<Masjid>> myStream =
        firestoreDatabase.myMasjidsStream(myMasjidsIds);

    FutureOr onGoBack(dynamic value) {
      print("Go Back Called");
      loadMyMasjidsIds();
      setState(() {});
    }

    Drawer _buildDrawer(BuildContext context) {
      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            StreamBuilder(
                stream: authProvider.user,
                builder: (context, snapshot) {
                  // print(snapshot.data);
                  final UserModel? user = snapshot.data as UserModel?;
                  // print(" I am here");
                  // if (user != null) {
                  //   print("user is not null" + user.displayName!);
                  //   if (user.email != null) print(user.email);
                  // }

                  return UserAccountsDrawerHeader(
                    accountName: Text((user?.isAnonymous ?? true)
                        ? "Anonymous"
                        : user!.displayName!),

                    accountEmail: Text((user?.isAnonymous ?? true)
                        ? "No Email"
                        : user!.email!),
                    decoration: BoxDecoration(
                        color: Colors.black87,
                        image: DecorationImage(
                            image: AssetImage("assets/img/ramadan.png"),
                            scale: 0.5,
                            opacity: 0.5,
                            fit: BoxFit.cover)),
                    // child: Text('Drawer Header'),
                  );
                }),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.mosque),
              title: const Text(
                'My Masjids',
                style: TextStyle(fontSize: 18.0, color: Colors.black87),
              ),
              onTap: () {
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute<void>(
                //     builder: (BuildContext context) => const MyHomePage(
                //       title: 'Houses',
                //     ),
                //   ),
                // );
              },
            ),
            ListTile(
              leading: const Icon(Icons.apartment),
              title: const Text(
                'Find Masjids',
                style: TextStyle(fontSize: 18.0, color: Colors.black87),
              ),
              onTap: () {
                finish(context);
                Navigator.push(
                  context,
                  MaterialPageRoute<bool>(
                    builder: (BuildContext context) => NearByMasjidsScreen(),
                  ),
                ).then(onGoBack);
              },
            ),
            ListTile(
              leading: const Icon(Icons.apartment),
              title: const Text(
                'Masjids Entered By Me',
                style: TextStyle(fontSize: 18.0, color: Colors.black87),
              ),
              onTap: () {
                finish(context);
                Navigator.push(
                  context,
                  MaterialPageRoute<bool>(
                    builder: (BuildContext context) =>
                        MasjidsCreatedByMeScreen(),
                  ),
                ).then(onGoBack);
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.compass),
              title: const Text(
                'Qibla Direction',
                style: TextStyle(fontSize: 18.0, color: Colors.black87),
              ),
              onTap: () {
                QiblahMainScreen().launch(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer_sharp),
              title: const Text(
                'Prayer Times',
                style: TextStyle(fontSize: 18.0, color: Colors.black87),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        SalahTimesScreen(title: "Today's Prayer Times"),
                  ),
                );
              },
            ),
            const Divider(
              height: 10,
              thickness: 1,
            ),
          ],
        ),
      );
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
                    return Dismissible(
                      background: Container(
                        color: Colors.red,
                        child: Center(
                            child: Text(
                          "Remove from My List",
                          style:
                              TextStyle(color: Theme.of(context).canvasColor),
                        )),
                      ),
                      key: Key(masjids[index].id),
                      onDismissed: (direction) async {
                        List<String>? myMasjids =
                            getStringListAsync('myMasjids');

                        if (myMasjids == null || myMasjids.isEmpty) {
                        } else {
                          if (myMasjids.contains(masjids[index].id))
                            myMasjids.remove(masjids[index].id);
                        }
                        await setValue("myMasjids", myMasjids);

                        masjids.removeAt(index);
                        await firestoreDatabase.removeMyMasjid(masjids[index]);

                        toast("Removed: " + masjids[index].enName);
                      },
                      child: ListTile(
                        title: MasjidListItem(
                            enName: masjids[index].enName,
                            urduName: masjids[index].urduName),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                              Routes.create_edit_masjid,
                              arguments: masjids[index]);
                        },
                      ),
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
        title: Text("My Masjids"),
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
          onWillPop: () async => false, child: _buildBodySection(context)),
      drawer: _buildDrawer(context),
    );
  }
}
