import 'package:flutter/material.dart';
import 'package:noteapp/models/pin_information.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:noteapp/services/firestore_database.dart';
import 'package:provider/provider.dart';

class MapPinPillComponent extends StatefulWidget {
  double pinPillPosition;
  PinInformation currentlySelectedPin;

  MapPinPillComponent(
      {required this.pinPillPosition, required this.currentlySelectedPin});

  @override
  State<StatefulWidget> createState() => MapPinPillComponentState();
}

class MapPinPillComponentState extends State<MapPinPillComponent> {
  @override
  Widget build(BuildContext context) {
    Future<void> addMasjid() async {
      final firestoreDatabase =
          Provider.of<FirestoreDatabase>(context, listen: false);

      List<String>? myMasjids = getStringListAsync('myMasjids');

      if (myMasjids == null || myMasjids.isEmpty) {
        myMasjids = [];
        myMasjids.add(widget.currentlySelectedPin.id);
      } else {
        if (!myMasjids.contains(widget.currentlySelectedPin.id))
          myMasjids.add(widget.currentlySelectedPin.id);
      }
      await setValue("myMasjids", myMasjids);
      firestoreDatabase.setMyMasjid(widget.currentlySelectedPin.id);

      // Navigator.of(context).pop();
      // finish(context);
      toast("Masjid added successfully",
          bgColor: Colors.green.shade400, textColor: Colors.white);
    }

    return AnimatedPositioned(
      bottom: widget.pinPillPosition,
      right: 0,
      left: 0,
      duration: Duration(milliseconds: 200),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: EdgeInsets.all(20),
          // height: 70,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(50)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    blurRadius: 20,
                    offset: Offset.zero,
                    color: Colors.grey.withOpacity(0.5))
              ]),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                margin: EdgeInsets.only(left: 10),
                child: ClipOval(
                    child: Image.asset(widget.currentlySelectedPin.avatarPath,
                        fit: BoxFit.cover)),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(widget.currentlySelectedPin.locationName,
                              style: TextStyle(
                                  color:
                                      widget.currentlySelectedPin.labelColor))
                          .paddingAll(8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(widget.currentlySelectedPin.urduName,
                            style: TextStyle(
                                color: widget.currentlySelectedPin.labelColor)),
                      ).paddingAll(8),
                      // Text(
                      //     'Latitude: ${widget.currentlySelectedPin.location.latitude.toString()}',
                      //     style: TextStyle(fontSize: 12, color: Colors.grey)),
                      // Text
                      //     'Longitude: ${widget.currentlySelectedPin.location.longitude.toString()}',
                      //     style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              // Padding(
              //   padding: EdgeInsets.all(15),
              //   child: Image.asset(widget.currentlySelectedPin.pinPath,
              //       width: 50, height: 50),
              // )
              FloatingActionButton(
                  child: Icon(Icons.add),
                  onPressed: () => addMasjid()).paddingRight(8)
            ],
          ),
        ),
      ),
    );
  }
}
