import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:noteapp/models/masjid_model.dart';
import 'package:noteapp/services/firestore_database.dart';
import 'package:noteapp/ui/masjid/waktuSalat.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:uuid/uuid.dart';

class CreateEditMasjidScreen extends StatefulWidget {
  @override
  _CreateEditMasjidScreenState createState() => _CreateEditMasjidScreenState();
}

class _CreateEditMasjidScreenState extends State<CreateEditMasjidScreen> {
  late TextEditingController _enNameController;
  late TextEditingController _urduNameController;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Masjid? _masjid;

  String selectedEnName = "";
  String selectedUrduName = "";

  String selectedFajrTime = "00:00 AM";
  String selectedZuhrTime = "00:00 AM";
  String selectedAsarTime = "00:00 AM";
  String selectedMaghrebTime = "00:00 AM";
  String selectedJummahTime = "00:00 AM";
  String selectedIshaTime = "00:00 AM";

  TimeOfDay selectedTime = TimeOfDay.now();
  GeoFirePoint? selectedPosition;

  bool get _hasChangedEnName => _masjid?.enName != selectedEnName;
  bool get _hasChangedUrduName => _masjid?.urduName != selectedUrduName;
  bool get _hasChangedFajrTime => _masjid?.fajrTime != selectedFajrTime;
  bool get _hasChangedZuhrTime => _masjid?.zuhrTime != selectedZuhrTime;
  bool get _hasChangedAsarTime => _masjid?.asarTime != selectedAsarTime;
  bool get _hasChangedMaghrebTime =>
      _masjid?.maghrebTime != selectedMaghrebTime;
  bool get _hasChangedIshaTime => _masjid?.ishaTime != selectedIshaTime;
  bool get _hasChangedJummahTime => _masjid?.jummahTime != selectedJummahTime;
  bool get _hasChangedPosition => _masjid?.position != selectedPosition;

  bool get _hasChangedValue =>
      _hasChangedEnName ||
      _hasChangedUrduName ||
      _hasChangedFajrTime ||
      _hasChangedAsarTime ||
      _hasChangedZuhrTime ||
      _hasChangedMaghrebTime ||
      _hasChangedIshaTime ||
      _hasChangedJummahTime ||
      _hasChangedPosition;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Masjid? _masjidModel =
        ModalRoute.of(context)?.settings.arguments as Masjid?;
    if (_masjidModel != null) {
      _masjid = _masjidModel;
    }

    _enNameController = TextEditingController(text: _masjid?.enName ?? "");
    _urduNameController = TextEditingController(text: _masjid?.urduName ?? "");

    selectedEnName = _masjid?.enName ?? "";
    selectedUrduName = _masjid?.urduName ?? "";

    selectedFajrTime = _masjid?.fajrTime ?? "00:00 AM";
    selectedZuhrTime = _masjid?.zuhrTime ?? "00:00 AM";
    selectedAsarTime = _masjid?.asarTime ?? "00:00 AM";
    selectedMaghrebTime = _masjid?.maghrebTime ?? "00:00 AM";
    selectedJummahTime = _masjid?.jummahTime ?? "00:00 AM";
    selectedIshaTime = _masjid?.ishaTime ?? "00:00 AM";
    selectedPosition = _masjid?.position;

    print(_hasChangedValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(_masjid != null ? "Show/Edit Masjid" : "New Masjid"),
        actions: <Widget>[
          TextButton(
              onPressed: _hasChangedValue ? () => saveMasjid(context) : null,
              child: Text("Save"))
        ],
      ),
      body: Center(
        child: _buildForm(context),
      ),
    );
  }

  void saveMasjid(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final firestoreDatabase =
          Provider.of<FirestoreDatabase>(context, listen: false);

      firestoreDatabase.setMasjid(Masjid(
          id: _masjid?.id ?? Uuid().v1(),
          enName: _enNameController.text,
          urduName: _urduNameController.text,
          address: "Address",
          city: "Cityaaa",
          fajrTime: selectedFajrTime,
          asarTime: selectedAsarTime,
          zuhrTime: selectedZuhrTime,
          maghrebTime: selectedMaghrebTime,
          ishaTime: selectedIshaTime,
          jummahTime: selectedJummahTime,
          position: selectedPosition,
          createdBy: firestoreDatabase.uid));

      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _enNameController.dispose();
    _urduNameController.dispose();
    super.dispose();
  }

  Future<String> _selectTime(
      BuildContext context, String currentTimeInString) async {
    TimeOfDay _currentTime = stringToTimeOfDay(currentTimeInString);
    final TimeOfDay? timeOfDay = await showTimePicker(
        context: context,
        initialTime: _currentTime,
        initialEntryMode: TimePickerEntryMode.dial);
    if (timeOfDay != null && timeOfDay != _currentTime) {
      return timeOfDay.format(context);
    } else
      return currentTimeInString;
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(selectedUrduName),
              16.height,
              // TextFormField(
              //   controller: _enNameController,
              //   style: Theme.of(context).textTheme.bodyText1,
              //   validator: (value) =>
              //       value!.isEmpty ? "English name can't be empty" : null,
              //   decoration: InputDecoration(
              //     enabledBorder: OutlineInputBorder(
              //         borderSide: BorderSide(
              //             color: Theme.of(context).iconTheme.color!, width: 2)),
              //     labelText: "English Name",
              //   ),
              // ),
              Text(selectedUrduName),
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 16),
              //   child: TextFormField(
              //     controller: _urduNameController,
              //     style: Theme.of(context).textTheme.bodyText1,
              //     validator: (value) =>
              //         value!.isEmpty ? "Urdu name can't be empty" : null,
              //     // maxLines: 15,
              //     decoration: InputDecoration(
              //       enabledBorder: OutlineInputBorder(
              //           borderSide: BorderSide(
              //               color: Theme.of(context).iconTheme.color!,
              //               width: 2)),
              //       labelText: "Urdu Name",
              //       alignLabelWithHint: true,
              //       contentPadding: new EdgeInsets.symmetric(
              //           vertical: 10.0, horizontal: 10.0),
              //     ),
              //   ),
              // ),
              16.height,
              WaktuSalat(
                name: "الفجر",
                time: selectedFajrTime,
                isCurrent: false,
              ).onTap(() async {
                String str = await _selectTime(context, selectedFajrTime);

                setState(() {
                  selectedFajrTime = str;
                  print(_hasChangedFajrTime);
                });
              }),
              16.height,
              WaktuSalat(
                name: "الظہر",
                time: selectedZuhrTime,
                isCurrent: false,
              ).onTap(() async {
                String str = await _selectTime(context, selectedZuhrTime);

                setState(() {
                  selectedZuhrTime = str;
                });
              }),
              16.height,
              WaktuSalat(
                name: "العصر",
                time: selectedAsarTime,
                isCurrent: false,
              ).onTap(() async {
                String str = await _selectTime(context, selectedAsarTime);

                setState(() {
                  selectedAsarTime = str;
                });
              }),
              16.height,
              WaktuSalat(
                name: "المغرب",
                time: selectedMaghrebTime,
                isCurrent: false,
              ).onTap(() async {
                String str = await _selectTime(context, selectedMaghrebTime);

                setState(() {
                  selectedMaghrebTime = str;
                });
              }),
              16.height,
              WaktuSalat(
                name: "العشا",
                time: selectedIshaTime,
                isCurrent: false,
              ).onTap(() async {
                String str = await _selectTime(context, selectedIshaTime);

                setState(() {
                  selectedIshaTime = str;
                });
              }),
              16.height,
              WaktuSalat(
                name: "الجمعه",
                time: selectedJummahTime,
                isCurrent: false,
              ).onTap(() async {
                String str = await _selectTime(context, selectedJummahTime);

                setState(() {
                  selectedJummahTime = str;
                });
              }),
            ],
          ),
        ),
      ),
    );
  }
}

TimeOfDay stringToTimeOfDay(String tod) {
  final format = DateFormat.jm(); //"6:00 AM"
  return TimeOfDay.fromDateTime(format.parse(tod));
}
