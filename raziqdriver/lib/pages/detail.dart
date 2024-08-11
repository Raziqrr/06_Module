import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raziqdriver/widgets/PrimaryButton.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.myId, required this.rideId});
  final String myId;
  final String rideId;

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot<Map<String, dynamic>>> rideStream =
        FirebaseFirestore.instance.collection('Rides').doc(rideId).snapshots();
    final db = FirebaseFirestore.instance;
    final driverData = db.collection("Users").doc(myId).get();

    void MarkAsFinished() async {
      db.collection("Rides").doc(rideId).update({"status": "completed"});
    }

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Text("Ride details",style: GoogleFonts.montserrat(
        fontWeight: FontWeight.w600,
            fontSize: 19)),
      ),
      body: StreamBuilder(
        stream: rideStream,
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return Center(child: const Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CircularProgressIndicator());
          }

          final ride = snapshot.data!.data();

          print(ride);

          if (ride != null) {
            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Card(
                    elevation: 8,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(ride["date"],
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16)),
                              Text(ride["time"],
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16))
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Text("${ride["duration"]} min",
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w600)),
                              SizedBox(
                                width: 5,
                              ),
                              Text("${ride["distance"]} km",
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                    right: 15, left: 15, top: 2, bottom: 2),
                                child: Text(ride["status"],
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.bold)),
                                decoration: BoxDecoration(
                                    color: ride["status"] == "pending"
                                        ? CupertinoColors.systemYellow
                                        : CupertinoColors.systemGreen,
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Divider(),
                          SizedBox(
                            height: 30,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "${ride["origin"]}",
                                maxLines: 4,
                                softWrap: true,
                                overflow: TextOverflow.fade,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text("To",style: GoogleFonts.montserrat(
                                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue
                              ),),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "${ride["destination"]}",
                                maxLines: 4,
                                softWrap: true,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 20,
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Card(
                    elevation: 8,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  "Passengers (${ride["passengerCount"]}/${ride["carCapacity"]})",style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16)),
                              Row(
                                children: [
                                  Text("${ride["fare"]}",style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,color: CupertinoColors.systemGreen,
                                      fontSize: 16)),
                                  Text("/seat", style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16))
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: ride["passengerCount"],
                            itemBuilder: (BuildContext context, int index) {
                              final passenger = ride["passengers"][index];
                              print(passenger);

                              final passengerGet =
                                  db.collection("Users").doc(passenger).get();
                              return FutureBuilder(
                                future: passengerGet,
                                builder: (BuildContext context,
                                    AsyncSnapshot<
                                            DocumentSnapshot<
                                                Map<String, dynamic>>>
                                        snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(
                                        child:
                                            const Text('Something went wrong'));
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child:
                                            const CircularProgressIndicator());
                                  }
                                  final passengerData = snapshot.data!.data();

                                  if (passengerData != null) {
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      trailing: passengerData["gender"] ==
                                              "Male"
                                          ? Icon(
                                              Icons.male,
                                              color: Colors.blue,
                                            )
                                          : passengerData["gender"] == "Female"
                                              ? Icon(
                                                  Icons.female,
                                                  color: Colors.pink,
                                                )
                                              : Icon(
                                                  Icons.transgender,
                                                  color: Colors.grey,
                                                ),
                                      title: Text(passengerData["name"],style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16)),
                                      subtitle: Row(
                                        children: [
                                          Icon(Icons.phone),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(passengerData["phone"],style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16)),
                                        ],
                                      ),
                                      leading: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(
                                                    passengerData[
                                                        "userImage"]))),
                                      ),
                                    );
                                  } else {
                                    return Center(child: Text("No data"));
                                  }
                                },
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  if (ride["status"] == "pending")
                    Row(
                      children: [
                        Expanded(
                            child: PrimaryButton(
                                onPressed: () {
                                  MarkAsFinished();
                                },
                                text: "Finish")),
                      ],
                    )
                ],
              ),
            );
          } else {
            return Center(child: Text("No data"));
          }
        },
      ),
    );
  }
}
