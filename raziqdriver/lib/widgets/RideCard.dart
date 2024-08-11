import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raziqdriver/pages/detail.dart';

class RideCard extends StatelessWidget {
  const RideCard({super.key, required this.rideId, required this.myId});
  final String rideId;
  final String myId;
  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot<Map<String, dynamic>>> rideStream =
        FirebaseFirestore.instance.collection('Rides').doc(rideId).snapshots();

    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return DetailPage(myId: myId, rideId: rideId);
        }));
      },
      child: Card(
        margin: EdgeInsets.all(10),
        color: Colors.white,
        elevation: 8,
        child: StreamBuilder(
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

            if (ride != null) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(ride["date"],
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600, fontSize: 16)),
                        Text(ride["time"],
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600, fontSize: 16))
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person),
                            Text(
                                "${ride["passengerCount"]}/${ride["carCapacity"]}",
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: 20,
                          child: VerticalDivider(
                            color: Colors.black,
                            thickness: 2,
                          ),
                        ),
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
                          child: Text(
                            ride["status"],
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold),
                          ),
                          decoration: BoxDecoration(
                              color: ride["status"] == "pending"
                                  ? CupertinoColors.systemYellow
                                  : CupertinoColors.systemGreen,
                              borderRadius: BorderRadius.circular(5)),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              height: 20,
                              width: 20,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(200),
                                color: Colors.black,
                              ),
                            ),
                            Container(
                              height: 30,
                              child: VerticalDivider(
                                color: Colors.black,
                                thickness: 3,
                              ),
                            ),
                            Container(
                              height: 20,
                              width: 20,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(200),
                                color: Colors.black,
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${ride["origin"].split(",")[0]}",
                              maxLines: 3,
                              softWrap: true,
                              overflow: TextOverflow.fade,
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                            Container(
                              height: 30,
                            ),
                            Text(
                              "${ride["destination"].split(",")[0]}",
                              maxLines: 3,
                              softWrap: true,
                              overflow: TextOverflow.fade,
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            )
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Text(
                          ride["fare"],
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.systemGreen,
                              fontSize: 24),
                        ),
                        Text(
                          "/seat",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              );
            } else {
              return Text(
                "No data",
              );
            }
          },
        ),
      ),
    );
  }
}
