import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_search/firestore_search.dart';
import 'package:flutter/material.dart';
import 'package:noteapp/models/masjid_model.dart';

class SearchMasjidsScreen extends StatefulWidget {
  const SearchMasjidsScreen({Key? key}) : super(key: key);

  @override
  _SearchMasjidsScreenState createState() => _SearchMasjidsScreenState();
}

class _SearchMasjidsScreenState extends State<SearchMasjidsScreen> {
  @override
  String name = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Card(
          child: TextField(
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.search), hintText: 'Search...'),
            onChanged: (val) {
              setState(() {
                name = val;
                print(name);
              });
            },
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: (name != "" && name != null)
            ? FirebaseFirestore.instance
                .collection("masjids")
                .where("enName", isGreaterThanOrEqualTo: name)
                .where("enName", isLessThan: name + "z")
                .snapshots()
            : FirebaseFirestore.instance
                .collection("masjids")
                .where("enName", isEqualTo: "!@#")
                .snapshots(),
        builder: (context, snapshot) {
          return (snapshot.connectionState == ConnectionState.waiting)
              ? Center(child: CircularProgressIndicator())
              : snapshot.data!.docs.length < 1
                  ? Center(
                      child: Text("No Masjid Found"),
                    )
                  : ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot data = snapshot.data!.docs[index];
                        return Card(
                          child: Row(
                            children: <Widget>[
                              Text(
                                data['enName'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
        },
      ),
    );
  }
}
