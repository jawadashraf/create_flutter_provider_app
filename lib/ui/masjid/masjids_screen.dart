import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../main.dart';

class MasjidsScreen extends StatefulWidget {
  @override
  _MasjidsScreenState createState() => _MasjidsScreenState();
}

class _MasjidsScreenState extends State<MasjidsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String>? myMasjidsIds;
  String? _defaultMasjidId;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    loadMyMasjidsIds();
  }

  void loadMyMasjidsIds() async {
    // getStringListAsync('myMasjids');
    myMasjidsIds = getStringListAsync('myMasjids');
    _defaultMasjidId = await getDefaultMsjidId();

    print(_defaultMasjidId);
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                // await Navigator.push(
                //   context,
                //   MaterialPageRoute<void>(
                //     builder: (BuildContext context) =>
                //         SecondPage(receivedNotification.payload),
                //   ),
                // );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  Future<String?> getDefaultMsjidId() async {
    final FirebaseAuth _auth1 = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    User user = await _auth1.currentUser!;

    var docSnapshot = await _firestore.collection('users').doc(user.uid).get();

    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data()!;

      // You can then retrieve the value from the Map like this:
      return data['defaultMasjidId'];
    }

    return null;
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
                  _user = snapshot.data as UserModel?;
                  // print(" I am here");
                  // if (user != null) {
                  //   print("user is not null" + user.displayName!);
                  //   if (user.email != null) print(user.email);
                  // }

                  // print(_user!.defaultMasjidId);

                  return UserAccountsDrawerHeader(
                    accountName: Text((_user?.isAnonymous ?? true)
                        ? "Anonymous"
                        : _user!.displayName!),

                    accountEmail: Text((_user?.isAnonymous ?? true)
                        ? "No Email"
                        : _user!.email!),
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
            // ListTile(
            //   leading: FaIcon(FontAwesomeIcons.mosque),
            //   title: const Text(
            //     'My Masjids',
            //     style: TextStyle(fontSize: 18.0, color: Colors.black87),
            //   ),
            //   onTap: () {
            //     // Navigator.pushReplacement(
            //     //   context,
            //     //   MaterialPageRoute<void>(
            //     //     builder: (BuildContext context) => const MyHomePage(
            //     //       title: 'Houses',
            //     //     ),
            //     //   ),
            //     // );
            //   },
            // ),
            ListTile(
              leading: const Icon(FontAwesomeIcons.mosque),
              title: const Text(
                'Masjids Near Me',
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
              leading: const Icon(FontAwesomeIcons.mosque),
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
                finish(context);
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
                finish(context);
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
                    // return Dismissible(
                    //   background: Container(
                    //     color: Colors.red,
                    //     child: Center(
                    //         child: Text(
                    //       "Remove from My List",
                    //       style:
                    //           TextStyle(color: Theme.of(context).canvasColor),
                    //     )),
                    //   ),
                    //   key: Key(masjids[index].id),
                    //   onDismissed: (direction) async {
                    //     List<String>? myMasjids =
                    //         getStringListAsync('myMasjids');

                    //     if (myMasjids == null || myMasjids.isEmpty) {
                    //     } else {
                    //       if (myMasjids.contains(masjids[index].id))
                    //         myMasjids.remove(masjids[index].id);
                    //     }
                    //     await setValue("myMasjids", myMasjids);

                    //     masjids.removeAt(index);
                    //     await firestoreDatabase.removeMyMasjid(masjids[index]);

                    //     toast("Removed: " + masjids[index].enName);
                    //   },
                    //   child: ListTile(
                    //     title: MasjidListItem(
                    //         enName: masjids[index].enName,
                    //         urduName: masjids[index].urduName),
                    //     onTap: () {
                    //       Navigator.of(context).pushNamed(
                    //           Routes.create_edit_masjid,
                    //           arguments: masjids[index]);
                    //     },
                    //   ),
                    // );
                    return Slidable(
                      // Specify a key if the Slidable is dismissible.
                      key: ValueKey(index),

                      // The start action pane is the one at the left or the top side.
                      startActionPane: ActionPane(
                        // A motion is a widget used to control how the pane animates.
                        motion: const ScrollMotion(),

                        // A pane can dismiss the Slidable.
                        // dismissible: DismissiblePane(onDismissed: () async {
                        //   List<String>? myMasjids =
                        //       getStringListAsync('myMasjids');

                        //   if (myMasjids == null || myMasjids.isEmpty) {
                        //   } else {
                        //     if (myMasjids.contains(masjids[index].id))
                        //       myMasjids.remove(masjids[index].id);
                        //   }
                        //   await setValue("myMasjids", myMasjids);

                        //   masjids.removeAt(index);
                        //   await firestoreDatabase
                        //       .removeMyMasjid(masjids[index]);

                        //   toast("Removed: " + masjids[index].enName);
                        // }),

                        // All actions are defined in the children parameter.
                        children: [
                          // A SlidableAction can have an icon and/or a label.
                          SlidableAction(
                            onPressed: (context) async {
                              List<String>? myMasjids =
                                  getStringListAsync('myMasjids');

                              if (myMasjids == null || myMasjids.isEmpty) {
                              } else {
                                if (myMasjids.contains(masjids[index].id))
                                  print("before mymasjids remove");
                                myMasjids.remove(masjids[index].id);
                              }
                              await setValue("myMasjids", myMasjids);

                              print("before removeMyMasjid");
                              await firestoreDatabase
                                  .removeMyMasjid(masjids[index]);

                              // print("before masjids removeAt");
                              // masjids.removeAt(index);

                              loadMyMasjidsIds();
                              setState(() {});

                              toast("Removed: " + masjids[index].enName);
                            },
                            backgroundColor: Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Remove',
                          ),
                          SlidableAction(
                            onPressed: (context) async {
                              await firestoreDatabase
                                  .setDefaultMasjid(masjids[index].id);

                              // print("before masjids removeAt");
                              // masjids.removeAt(index);
                              setState(() {
                                _defaultMasjidId = masjids[index].id;
                              });
                              loadMyMasjidsIds();

                              setState(() {
                                // _defaultMasjidId = await getDefaultMsjidId();
                              });
                              toast("Default Masjid: " + masjids[index].enName);
                            },
                            backgroundColor: Color(0xFF21B7CA),
                            foregroundColor: Colors.white,
                            icon: Icons.settings,
                            label: 'Default',
                          ),
                        ],
                      ),

                      // The end action pane is the one at the right or the bottom side.
                      // endActionPane: const ActionPane(
                      //   motion: ScrollMotion(),
                      //   children: [
                      //     SlidableAction(
                      //       // An action can be bigger than the others.
                      //       flex: 2,
                      //       onPressed: null,
                      //       backgroundColor: Color(0xFF7BC043),
                      //       foregroundColor: Colors.white,
                      //       icon: Icons.archive,
                      //       label: 'Remove',
                      //     ),
                      //     SlidableAction(
                      //       onPressed: null,
                      //       backgroundColor: Color(0xFF0392CF),
                      //       foregroundColor: Colors.white,
                      //       icon: Icons.save,
                      //       label: 'Default',
                      //     ),
                      //   ],
                      // ),

                      // The child of the Slidable is what the user sees when the
                      // component is not dragged.
                      child: ListTile(
                        title: MasjidListItem(
                          enName: masjids[index].enName,
                          urduName: masjids[index].urduName,
                          isDefault: _defaultMasjidId == masjids[index].id,
                        ),
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

  void removeMadjid(List<Masjid> masjids, int index,
      FirestoreDatabase firestoreDatabase) async {
    List<String>? myMasjids = getStringListAsync('myMasjids');

    if (myMasjids == null || myMasjids.isEmpty) {
    } else {
      if (myMasjids.contains(masjids[index].id))
        myMasjids.remove(masjids[index].id);
    }
    await setValue("myMasjids", myMasjids);

    masjids.removeAt(index);
    await firestoreDatabase.removeMyMasjid(masjids[index]);

    toast("Removed: " + masjids[index].enName);
  }
}
