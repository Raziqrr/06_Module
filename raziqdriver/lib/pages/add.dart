import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart' as poly;
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_fonts/google_fonts.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:raziqdriver/pages/detail.dart';
import 'package:raziqdriver/widgets/CustomTextField.dart';
import 'package:intl/intl.dart';
import 'package:raziqdriver/widgets/PrimaryButton.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key, required this.myId});
  final String myId;

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TextEditingController originController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController fareController = TextEditingController();
  String time = "";
  String fare = "";

  String dateErrorText = "";
  String timeErrorText = "";
  String fareErrorText = "";

  bool originValid = false;
  bool destinationValid = false;
  bool dateValid = false;
  bool timeValid = false;
  bool fareValid = false;

  Map<String, dynamic>? user;

  void GetData(String id) async {
    final db = FirebaseFirestore.instance;
    final driverData = await db.collection("Users").doc(id).get().then((value) {
      final data = value.data();
      if (data != null) {
        setState(() {
          user = data;
          print(user);
        });
      }
    });
  }

  void ScheduleRide(
      int carCapacity,
      String date,
      String time,
      String origin,
      String destination,
      String fare,
      String driverId,
      BuildContext context) async {
    final db = FirebaseFirestore.instance;

    poly.PolylinePoints polylinePoints = poly.PolylinePoints();

    List<geo.Location> originLoc = await geo.locationFromAddress(origin);
    List<geo.Location> destinationLoc =
        await geo.locationFromAddress(destination);
    poly.PolylineResult result =
        await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: "AIzaSyAXwutVf9N_fkr49lXUdlh4HPJdEjbkeqI",
      request: poly.PolylineRequest(
        origin: poly.PointLatLng(originLoc[0].latitude, originLoc[0].longitude),
        destination: poly.PointLatLng(
            destinationLoc[0].latitude, destinationLoc[0].longitude),
        mode: poly.TravelMode.driving,
      ),
    );

    print(result.totalDistanceValue);

    db.collection("Rides").add({
      "capacityStatus": "available",
      "carCapacity": carCapacity,
      "date": date,
      "time": time,
      "destination": destination,
      "origin": origin,
      "driverId": driverId,
      "fare": "RM${fare}",
      "passengerCount": 0,
      "passengers": [],
      "ratedBy": [],
      "status": "pending",
      "distance": "${(result.totalDistanceValue! / 1000).toStringAsFixed(1)}",
      "duration": "${(result.totalDurationValue! / 60).toStringAsFixed(0)}",
      "originCoord": [originLoc[0].latitude, originLoc[0].longitude],
      "destinationCoord": [
        destinationLoc[0].latitude,
        destinationLoc[0].longitude
      ]
    }).then((value) {
      print(value);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ride has been successfully scheduled")));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    GetData(widget.myId);
    print(user);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    originController.dispose();
    destinationController.dispose();
    dateController.dispose();
    timeController.dispose();
    fareController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Expanded(
                child: PrimaryButton(
                    onPressed: (originValid == true &&
                            destinationValid == true &&
                            dateValid == true &&
                            timeValid == true &&
                            fareValid == true)
                        ? () {
                            ScheduleRide(
                                user!["carCapacity"],
                                dateController.text,
                                timeController.text,
                                originController.text,
                                destinationController.text,
                                fareController.text,
                                widget.myId,
                                context);
                          }
                        : null,
                    text: "Create")),
          ],
        ),
      ),
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Text("Schedule a new ride",
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600, fontSize: 19)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                color: Colors.white,
                elevation: 5,
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),

                    Text("Location",style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold, fontSize: 16, color: CupertinoColors.systemGreen)),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Divider(),
                    ),
                    PlacesAutocomplete(
                        top: false,
                        topCardColor: Colors.white,
                        searchController: originController,
                        controller: originController,
                        onChanged: (value) {
                          if (value == null) {
                            originValid = false;
                          }
                          originController.text = value!.description!;
                          setState(() {});
                        },
                        onReset: () {
                          originController.text = "";
                          originController.clear();
                          setState(() {});
                        },
                        onSuggestionSelected: (value) {
                          originController.text = value.description!;
                          originValid = true;
                          setState(() {});
                        },
                        searchHintText: "Search origin location",
                        hideBackButton: true,
                        apiKey: 'AIzaSyAXwutVf9N_fkr49lXUdlh4HPJdEjbkeqI',
                        mounted: mounted),
                    PlacesAutocomplete(
                        top: false,
                        topCardColor: Colors.white,
                        searchController: destinationController,
                        controller: destinationController,
                        onChanged: (value) {
                          if (value == null) {
                            destinationValid = false;
                          }
                          destinationController.text = value!.description!;
                          setState(() {});
                        },
                        onReset: () {
                          destinationController.text = "";
                          destinationController.clear();
                          setState(() {});
                        },
                        onSuggestionSelected: (value) {
                          destinationController.text = value.description!;
                          destinationValid = true;
                          setState(() {});
                        },
                        searchHintText: "Search destination location",
                        hideBackButton: true,
                        apiKey: 'AIzaSyAXwutVf9N_fkr49lXUdlh4HPJdEjbkeqI',
                        mounted: mounted),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              CustomTextField(
                suffixIcon: Icon(
                  Icons.date_range,
                  color: Colors.grey,
                ),
                onTap: () async {
                  final chosenDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2025));

                  if (chosenDate != null) {
                    final newDate = DateFormat.MMMd().format(chosenDate);
                    dateController.text = newDate;
                    dateValid = true;
                    setState(() {});
                  }
                },
                controller: dateController,
                keyboardType: TextInputType.datetime,
                inputFormatters: [],
                onChanged: (value) {},
                hintText: "Date",
                errorText: dateErrorText,
                readOnly: true,
              ),
              SizedBox(
                height: 20,
              ),
              CustomTextField(
                suffixIcon: Icon(
                  Icons.access_time_filled,
                  color: Colors.grey,
                ),
                onTap: () async {
                  final chosenTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                          hour: DateTime.now().hour,
                          minute: DateTime.now().minute));

                  if (chosenTime != null) {
                    timeController.text = chosenTime.format(context);
                    timeValid = true;
                    setState(() {});
                  }
                },
                controller: timeController,
                keyboardType: TextInputType.datetime,
                inputFormatters: [],
                onChanged: (value) {},
                hintText: "Time",
                errorText: timeErrorText,
                readOnly: true,
              ),
              SizedBox(
                height: 20,
              ),
              CustomTextField(
                  suffixIcon: Icon(
                    CupertinoIcons.money_dollar,
                    color: Colors.grey,
                  ),
                  controller: fareController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    if (value.length < 1) {
                      fareErrorText = "Please enter a valid price";
                      fareValid = false;
                    } else {
                      if (value[0] == "0") {
                        fareErrorText = "Price cannot start with 0";
                        fareValid = false;
                      } else {
                        fareErrorText = "";
                        fareValid = true;
                      }
                    }
                    setState(() {});
                  },
                  hintText: "Price per seat",
                  errorText: fareErrorText)
            ],
          ),
        ),
      ),
    );
  }
}
