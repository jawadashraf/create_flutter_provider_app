import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:noteapp/app_localizations.dart';
import 'package:noteapp/constants/app_themes.dart';
import 'package:noteapp/models/masjid_model.dart';
import 'package:noteapp/models/todo_model.dart';
import 'package:noteapp/models/user_model.dart';
import 'package:noteapp/providers/auth_provider.dart';
import 'package:noteapp/routes.dart';
import 'package:noteapp/services/firestore_database.dart';
import 'package:noteapp/ui/masjid/masjid_list_item.dart';
import 'package:noteapp/ui/masjid/salah_times_screen.dart';
import 'package:noteapp/ui/todo/empty_content.dart';
import 'package:noteapp/ui/masjid/masjids_extra_actions.dart';
import 'package:provider/provider.dart';

class MasjidsScreen extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    UserModel? _user;
    final authProvider = Provider.of<AuthProvider>(context);
    final firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);

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
                    ),
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
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute<void>(
                //     builder: (BuildContext context) => const MyHomePage(
                //       title: 'Apartments',
                //     ),
                //   ),
                // );
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.compass),
              title: const Text(
                'Qibla Direction',
                style: TextStyle(fontSize: 18.0, color: Colors.black87),
              ),
              onTap: () {
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute<void>(
                //     builder: (BuildContext context) => const MyHomePage(
                //       title: 'Townhomes',
                //     ),
                //   ),
                // );
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

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("My Masjid"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed(
            Routes.create_edit_masjid,
          );
        },
      ),
      body: WillPopScope(
          onWillPop: () async => false, child: _buildBodySection(context)),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildBodySection(BuildContext context) {
    final firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);

    return StreamBuilder(
        stream: firestoreDatabase.masjidsStream(),
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
                        "Remove",
                        style: TextStyle(color: Theme.of(context).canvasColor),
                      )),
                    ),
                    key: Key(masjids[index].id),
                    onDismissed: (direction) {
                      firestoreDatabase.deleteMasjid(masjids[index]);

                      _scaffoldKey.currentState!.showSnackBar(SnackBar(
                        backgroundColor: Theme.of(context).appBarTheme.color,
                        content: Text(
                          "Removed" + masjids[index].enName,
                          style:
                              TextStyle(color: Theme.of(context).canvasColor),
                        ),
                        duration: Duration(seconds: 3),
                        action: SnackBarAction(
                          label: "Undo",
                          textColor: Theme.of(context).canvasColor,
                          onPressed: () {
                            firestoreDatabase.setMasjid(masjids[index]);
                          },
                        ),
                      ));
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
}
